//
//  OCRManager.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 文字识别管理
//

import Foundation
import Vision
import UIKit

class OCRManager {
    // 识别图片中的文字
    static func recognizeText(from image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(OCRError.invalidImage))
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(.failure(OCRError.noTextFound))
                return
            }
            
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            let fullText = recognizedStrings.joined(separator: "\n")
            completion(.success(fullText))
        }
        
        // 配置识别选项
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["zh-Hans", "zh-Hant", "en-US"]
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // 识别收据金额
    static func extractAmount(from image: UIImage, completion: @escaping (Result<Double, Error>) -> Void) {
        recognizeText(from: image) { result in
            switch result {
            case .success(let text):
                if let amount = parseAmount(from: text) {
                    completion(.success(amount))
                } else {
                    completion(.failure(OCRError.noAmountFound))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 从文本中提取金额
    private static func parseAmount(from text: String) -> Double? {
        // 匹配金额模式：¥123.45, $123.45, 123.45元等
        let patterns = [
            "¥([0-9,]+\\.?[0-9]*)",
            "\\$([0-9,]+\\.?[0-9]*)",
            "([0-9,]+\\.?[0-9]*)元",
            "总计[：:]*\\s*([0-9,]+\\.?[0-9]*)",
            "合计[：:]*\\s*([0-9,]+\\.?[0-9]*)"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let match = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)),
               match.numberOfRanges > 1 {
                let amountRange = match.range(at: 1)
                if let range = Range(amountRange, in: text) {
                    let amountString = String(text[range]).replacingOccurrences(of: ",", with: "")
                    if let amount = Double(amountString) {
                        return amount
                    }
                }
            }
        }
        
        return nil
    }
    
    // 识别商家名称
    static func extractMerchantName(from text: String) -> String? {
        let lines = text.split(separator: "\n")
        // 通常第一行或第二行是商家名称
        return lines.first.map { String($0) }
    }
}

enum OCRError: LocalizedError {
    case invalidImage
    case noTextFound
    case noAmountFound
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "无效的图片"
        case .noTextFound:
            return "未识别到文字"
        case .noAmountFound:
            return "未找到金额信息"
        }
    }
}

