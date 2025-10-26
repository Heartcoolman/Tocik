//
//  ConverterView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI

struct ConverterView: View {
    @State private var selectedCategory: ConversionCategory = .length
    @State private var inputValue = ""
    @State private var fromUnit: Int = 0
    @State private var toUnit: Int = 1
    
    var body: some View {
        NavigationStack {
            Form {
                Section("转换类型") {
                    Picker("类别", selection: $selectedCategory) {
                        ForEach(ConversionCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("从") {
                    TextField("输入数值", text: $inputValue)
                        .keyboardType(.decimalPad)
                    
                    Picker("单位", selection: $fromUnit) {
                        ForEach(0..<selectedCategory.units.count, id: \.self) { index in
                            Text(selectedCategory.units[index]).tag(index)
                        }
                    }
                }
                
                Section("到") {
                    Text(convertedValue)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Theme.converterColor)
                    
                    Picker("单位", selection: $toUnit) {
                        ForEach(0..<selectedCategory.units.count, id: \.self) { index in
                            Text(selectedCategory.units[index]).tag(index)
                        }
                    }
                }
                
                Section("常用转换") {
                    ForEach(selectedCategory.commonConversions, id: \.self) { conversion in
                        Button(conversion) {
                            applyCommonConversion(conversion)
                        }
                    }
                }
            }
            .navigationTitle("单位换算")
        }
    }
    
    private var convertedValue: String {
        guard let input = Double(inputValue) else { return "0" }
        let result = selectedCategory.convert(value: input, from: fromUnit, to: toUnit)
        return String(format: "%.4f", result).trimmingCharacters(in: ["0"]).trimmingCharacters(in: ["."])
    }
    
    private func applyCommonConversion(_ conversion: String) {
        // 解析常用转换，例如 "1英寸 = 2.54厘米"
        inputValue = "1"
        
        let category = selectedCategory
        if conversion.contains("英寸") && conversion.contains("厘米") {
            fromUnit = category.units.firstIndex(of: "英寸") ?? 0
            toUnit = category.units.firstIndex(of: "厘米") ?? 0
        }
    }
}

enum ConversionCategory: String, CaseIterable {
    case length = "长度"
    case weight = "重量"
    case temperature = "温度"
    case area = "面积"
    case volume = "体积"
    
    var units: [String] {
        switch self {
        case .length:
            return ["米", "千米", "厘米", "毫米", "英里", "码", "英尺", "英寸"]
        case .weight:
            return ["千克", "克", "毫克", "吨", "磅", "盎司"]
        case .temperature:
            return ["摄氏度", "华氏度", "开尔文"]
        case .area:
            return ["平方米", "平方千米", "平方厘米", "公顷", "英亩", "平方英尺"]
        case .volume:
            return ["升", "毫升", "立方米", "加仑", "品脱"]
        }
    }
    
    var commonConversions: [String] {
        switch self {
        case .length:
            return ["1英寸 = 2.54厘米", "1英尺 = 30.48厘米", "1英里 = 1.609千米"]
        case .weight:
            return ["1磅 = 0.454千克", "1盎司 = 28.35克"]
        case .temperature:
            return ["0°C = 32°F", "100°C = 212°F"]
        case .area:
            return ["1公顷 = 10000平方米", "1英亩 = 4047平方米"]
        case .volume:
            return ["1加仑 = 3.785升", "1品脱 = 0.473升"]
        }
    }
    
    func convert(value: Double, from: Int, to: Int) -> Double {
        // 先转换为基本单位，再转换为目标单位
        let baseValue = toBase(value: value, unit: from)
        return fromBase(value: baseValue, unit: to)
    }
    
    private func toBase(value: Double, unit: Int) -> Double {
        switch self {
        case .length:
            let factors = [1.0, 1000.0, 0.01, 0.001, 1609.34, 0.9144, 0.3048, 0.0254]
            return value * factors[unit]
        case .weight:
            let factors = [1.0, 0.001, 0.000001, 1000.0, 0.453592, 0.0283495]
            return value * factors[unit]
        case .temperature:
            if unit == 0 { return value } // 摄氏度
            if unit == 1 { return (value - 32) * 5/9 } // 华氏度
            return value - 273.15 // 开尔文
        case .area:
            let factors = [1.0, 1000000.0, 0.0001, 10000.0, 4046.86, 0.092903]
            return value * factors[unit]
        case .volume:
            let factors = [1.0, 0.001, 1000.0, 3.78541, 0.473176]
            return value * factors[unit]
        }
    }
    
    private func fromBase(value: Double, unit: Int) -> Double {
        switch self {
        case .length:
            let factors = [1.0, 1000.0, 0.01, 0.001, 1609.34, 0.9144, 0.3048, 0.0254]
            return value / factors[unit]
        case .weight:
            let factors = [1.0, 0.001, 0.000001, 1000.0, 0.453592, 0.0283495]
            return value / factors[unit]
        case .temperature:
            if unit == 0 { return value } // 摄氏度
            if unit == 1 { return value * 9/5 + 32 } // 华氏度
            return value + 273.15 // 开尔文
        case .area:
            let factors = [1.0, 1000000.0, 0.0001, 10000.0, 4046.86, 0.092903]
            return value / factors[unit]
        case .volume:
            let factors = [1.0, 0.001, 1000.0, 3.78541, 0.473176]
            return value / factors[unit]
        }
    }
}

#Preview {
    ConverterView()
}

