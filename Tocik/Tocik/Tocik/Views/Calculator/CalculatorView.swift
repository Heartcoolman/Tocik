//
//  CalculatorView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI

struct CalculatorView: View {
    @State private var displayText = "0"
    @State private var currentNumber: Double = 0
    @State private var previousNumber: Double = 0
    @State private var operation: Operation?
    @State private var isNewNumber = true
    @State private var history: [String] = []
    
    enum Operation: String {
        case add = "+"
        case subtract = "−"
        case multiply = "×"
        case divide = "÷"
    }
    
    let buttons: [[CalculatorButton]] = [
        [.clear, .negative, .percent, .divide],
        [.seven, .eight, .nine, .multiply],
        [.four, .five, .six, .subtract],
        [.one, .two, .three, .add],
        [.zero, .decimal, .equal]
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Spacer()
                
                // 显示屏
                VStack(alignment: .trailing, spacing: 8) {
                    if !history.isEmpty {
                        ScrollView {
                            VStack(alignment: .trailing, spacing: 4) {
                                ForEach(history.suffix(3), id: \.self) { item in
                                    Text(item)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .frame(height: 60)
                    }
                    
                    Text(displayText)
                        .font(.system(size: 64, weight: .light))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding()
                
                // 按钮网格
                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(row, id: \.self) { button in
                            CalculatorButtonView(button: button) {
                                handleButtonTap(button)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("计算器")
        }
    }
    
    private func handleButtonTap(_ button: CalculatorButton) {
        switch button {
        case .clear:
            clear()
        case .negative:
            toggleNegative()
        case .percent:
            applyPercent()
        case .divide, .multiply, .subtract, .add:
            setOperation(button.operation!)
        case .equal:
            calculate()
        case .decimal:
            addDecimal()
        default:
            appendNumber(button.title)
        }
    }
    
    private func clear() {
        displayText = "0"
        currentNumber = 0
        previousNumber = 0
        operation = nil
        isNewNumber = true
    }
    
    private func toggleNegative() {
        currentNumber = -currentNumber
        displayText = formatNumber(currentNumber)
    }
    
    private func applyPercent() {
        currentNumber /= 100
        displayText = formatNumber(currentNumber)
    }
    
    private func setOperation(_ op: Operation) {
        if !isNewNumber {
            calculate()
        }
        operation = op
        previousNumber = currentNumber
        isNewNumber = true
    }
    
    private func calculate() {
        guard let operation = operation else { return }
        
        let equation = "\(formatNumber(previousNumber)) \(operation.rawValue) \(formatNumber(currentNumber))"
        
        switch operation {
        case .add:
            currentNumber = previousNumber + currentNumber
        case .subtract:
            currentNumber = previousNumber - currentNumber
        case .multiply:
            currentNumber = previousNumber * currentNumber
        case .divide:
            currentNumber = previousNumber / currentNumber
        }
        
        displayText = formatNumber(currentNumber)
        history.append("\(equation) = \(displayText)")
        
        self.operation = nil
        isNewNumber = true
    }
    
    private func appendNumber(_ digit: String) {
        if isNewNumber {
            displayText = digit
            currentNumber = Double(digit) ?? 0
            isNewNumber = false
        } else {
            displayText += digit
            currentNumber = Double(displayText) ?? 0
        }
    }
    
    private func addDecimal() {
        if isNewNumber {
            displayText = "0."
            isNewNumber = false
        } else if !displayText.contains(".") {
            displayText += "."
        }
    }
    
    private func formatNumber(_ number: Double) -> String {
        if number.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", number)
        }
        return String(number)
    }
}

enum CalculatorButton: Hashable {
    case zero, one, two, three, four, five, six, seven, eight, nine
    case add, subtract, multiply, divide
    case equal, clear, negative, percent, decimal
    
    var title: String {
        switch self {
        case .zero: return "0"
        case .one: return "1"
        case .two: return "2"
        case .three: return "3"
        case .four: return "4"
        case .five: return "5"
        case .six: return "6"
        case .seven: return "7"
        case .eight: return "8"
        case .nine: return "9"
        case .add: return "+"
        case .subtract: return "−"
        case .multiply: return "×"
        case .divide: return "÷"
        case .equal: return "="
        case .clear: return "C"
        case .negative: return "+/-"
        case .percent: return "%"
        case .decimal: return "."
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .add, .subtract, .multiply, .divide, .equal:
            return Theme.calculatorColor
        case .clear, .negative, .percent:
            return Color(.systemGray3)
        default:
            return Color(.systemGray5)
        }
    }
    
    var operation: CalculatorView.Operation? {
        switch self {
        case .add: return .add
        case .subtract: return .subtract
        case .multiply: return .multiply
        case .divide: return .divide
        default: return nil
        }
    }
}

struct CalculatorButtonView: View {
    let button: CalculatorButton
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(button.title)
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(isOperator ? .white : .primary)
                .frame(maxWidth: button == .zero ? .infinity : 80, maxHeight: 80)
                .background(button.backgroundColor)
                .cornerRadius(40)
        }
    }
    
    var isOperator: Bool {
        switch button {
        case .add, .subtract, .multiply, .divide, .equal:
            return true
        default:
            return false
        }
    }
}

#Preview {
    CalculatorView()
}

