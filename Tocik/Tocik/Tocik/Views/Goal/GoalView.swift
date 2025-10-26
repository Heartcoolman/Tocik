//
//  GoalView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct GoalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Goal> { !$0.isArchived }, sort: \Goal.startDate, order: .reverse) private var activeGoals: [Goal]
    @Query(filter: #Predicate<Goal> { $0.isArchived }) private var archivedGoals: [Goal]
    
    @State private var showingAddGoal = false
    @State private var showArchived = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if activeGoals.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "target")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("设定您的第一个目标")
                            .font(Theme.headlineFont)
                            .foregroundColor(.secondary)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(showArchived ? archivedGoals : activeGoals) { goal in
                                GoalCard(goal: goal)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("目标管理")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showArchived.toggle() }) {
                        Label(showArchived ? "活跃目标" : "已归档", systemImage: "archivebox")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddGoal = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Theme.primaryColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView()
            }
        }
    }
}

struct GoalCard: View {
    @Environment(\.modelContext) private var modelContext
    let goal: Goal
    
    @State private var showingDetail = false
    
    var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: goal.endDate).day ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(goal.title)
                    .font(Theme.headlineFont)
                
                Spacer()
                
                Text(goal.timeframe.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: goal.colorHex).opacity(0.2))
                    .cornerRadius(4)
            }
            
            if !goal.goalDescription.isEmpty {
                Text(goal.goalDescription)
                    .font(Theme.bodyFont)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // 进度条
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("总体进度")
                        .font(Theme.captionFont)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(goal.overallProgress()))%")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: goal.colorHex))
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: goal.colorHex))
                            .frame(width: geometry.size.width * goal.overallProgress() / 100)
                    }
                }
                .frame(height: 8)
            }
            
            // 关键结果
            if !goal.keyResults.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(goal.keyResults.prefix(3)) { kr in
                        HStack {
                            Image(systemName: kr.progress >= 100 ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(kr.progress >= 100 ? .green : .secondary)
                            
                            Text(kr.title)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text("\(Int(kr.progress))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // 底部信息
            HStack {
                if daysRemaining > 0 {
                    Label("剩余\(daysRemaining)天", systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if daysRemaining == 0 {
                    Label("今天截止", systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundColor(.orange)
                } else {
                    Label("已过期", systemImage: "exclamationmark.circle")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                Button(action: { showingDetail = true }) {
                    Text("详情")
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(Theme.cornerRadius)
        .shadow(radius: 2)
        .sheet(isPresented: $showingDetail) {
            GoalDetailView(goal: goal)
        }
    }
}

#Preview {
    GoalView()
        .modelContainer(for: Goal.self, inMemory: true)
}

