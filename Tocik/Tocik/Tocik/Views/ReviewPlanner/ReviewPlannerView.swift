//
//  ReviewPlannerView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  复习计划视图
//

import SwiftUI
import SwiftData

struct ReviewPlannerView: View {
    @Query private var plans: [ReviewPlan]
    @State private var showAddPlan = false
    @State private var selectedPlan: ReviewPlan?
    
    var activePlans: [ReviewPlan] {
        plans.filter { $0.status == .active }
    }
    
    var completedPlans: [ReviewPlan] {
        plans.filter { $0.status == .completed }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 活跃计划
                if !activePlans.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("📝 进行中")
                            .font(.title2.bold())
                            .padding(.horizontal)
                        
                        ForEach(activePlans) { plan in
                            ReviewPlanCard(plan: plan)
                                .onTapGesture {
                                    selectedPlan = plan
                                }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // 已完成计划
                if !completedPlans.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("✅ 已完成")
                            .font(.title2.bold())
                            .padding(.horizontal)
                        
                        ForEach(completedPlans) { plan in
                            ReviewPlanCard(plan: plan)
                        }
                        .padding(.horizontal)
                    }
                }
                
                // 空状态
                if plans.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 80))
                            .foregroundStyle(Theme.reviewGradient)
                        
                        Text("创建复习计划")
                            .font(.title2.bold())
                        
                        Text("使用艾宾浩斯遗忘曲线，科学复习")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: { showAddPlan = true }) {
                            Text("创建第一个计划")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: 300)
                                .background(Theme.reviewGradient)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.top, 100)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("复习计划")
        .toolbar {
            Button(action: { showAddPlan = true }) {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showAddPlan) {
            AddReviewPlanView()
        }
        .sheet(item: $selectedPlan) { plan in
            ReviewPlanDetailView(plan: plan)
        }
    }
}

struct ReviewPlanCard: View {
    let plan: ReviewPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(plan.planName)
                    .font(.headline)
                Spacer()
                Text(plan.status.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .clipShape(Capsule())
            }
            
            Text(plan.subject)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ProgressView(value: plan.progress())
                .tint(Theme.reviewGradient)
            
            Text("\(Int(plan.progress() * 100))% 完成")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var statusColor: Color {
        switch plan.status {
        case .active: return .green
        case .completed: return .blue
        case .paused: return .orange
        }
    }
}

struct AddReviewPlanView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var planName = ""
    @State private var subject = ""
    @State private var reviewMethod: ReviewPlan.ReviewMethod = .ebbinghaus
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("计划名称", text: $planName)
                TextField("科目", text: $subject)
                
                Picker("复习方法", selection: $reviewMethod) {
                    Text("艾宾浩斯曲线").tag(ReviewPlan.ReviewMethod.ebbinghaus)
                    Text("间隔重复").tag(ReviewPlan.ReviewMethod.spaced)
                    Text("循环复习").tag(ReviewPlan.ReviewMethod.cyclic)
                    Text("自定义").tag(ReviewPlan.ReviewMethod.custom)
                }
                
                DatePicker("开始日期", selection: $startDate, displayedComponents: [.date])
                DatePicker("结束日期", selection: $endDate, displayedComponents: [.date])
                
                Section {
                    Text("艾宾浩斯曲线：1、2、4、7、15、30天后复习")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("创建复习计划")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("创建") {
                        let plan = ReviewPlan(
                            planName: planName,
                            subject: subject,
                            startDate: startDate,
                            endDate: endDate,
                            reviewMethod: reviewMethod
                        )
                        
                        // 生成复习会话
                        if reviewMethod == .ebbinghaus {
                            plan.generateEbbinghausSessions()
                        }
                        
                        context.insert(plan)
                        dismiss()
                    }
                    .disabled(planName.isEmpty || subject.isEmpty)
                }
            }
        }
    }
}

struct ReviewPlanDetailView: View {
    @Bindable var plan: ReviewPlan
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("计划信息") {
                    LabeledContent("科目", value: plan.subject)
                    LabeledContent("方法", value: plan.reviewMethod.rawValue)
                    LabeledContent("进度", value: "\(Int(plan.progress() * 100))%")
                    
                    HStack {
                        Text("状态")
                        Spacer()
                        Picker("", selection: $plan.status) {
                            Text("进行中").tag(ReviewPlan.PlanStatus.active)
                            Text("已完成").tag(ReviewPlan.PlanStatus.completed)
                            Text("已暂停").tag(ReviewPlan.PlanStatus.paused)
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section("复习会话") {
                    ForEach(plan.reviewSessions.sorted(by: { $0.scheduledDate < $1.scheduledDate })) { session in
                        ReviewSessionRow(session: session)
                    }
                }
            }
            .navigationTitle(plan.planName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("完成") { dismiss() }
            }
        }
    }
}

struct ReviewSessionRow: View {
    @Bindable var session: ReviewSession
    
    var body: some View {
        HStack {
            Button(action: {
                session.isCompleted.toggle()
                if session.isCompleted && session.actualDate == nil {
                    session.actualDate = Date()
                }
            }) {
                Image(systemName: session.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(session.isCompleted ? .green : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(session.scheduledDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                
                if let actual = session.actualDate, session.isCompleted {
                    Text("已于 \(actual.formatted(date: .abbreviated, time: .omitted)) 完成")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if session.isCompleted, let rating = session.effectivenessRating {
                HStack(spacing: 2) {
                    ForEach(0..<rating, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
    }
}

