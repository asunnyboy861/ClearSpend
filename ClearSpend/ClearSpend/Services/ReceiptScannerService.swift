import UIKit
import Vision

final class ReceiptScannerService {
    
    func scanReceipt(from image: UIImage) async throws -> ScannedReceipt {
        guard let cgImage = image.cgImage else {
            throw ScanningError.invalidImage
        }
        let text = try await performOCR(on: cgImage)
        return parseReceiptText(text)
    }
    
    private func performOCR(on image: CGImage) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(throwing: ScanningError.noTextFound)
                    return
                }
                let text = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
                continuation.resume(returning: text)
            }
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["en-US"]
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    private func parseReceiptText(_ text: String) -> ScannedReceipt {
        let lines = text.components(separatedBy: "\n")
        var items: [ReceiptLineItem] = []
        var subtotal: Decimal = 0
        var tax: Decimal = 0
        var tip: Decimal = 0
        var total: Decimal = 0
        var merchantName: String?
        
        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }
            if index == 0 { merchantName = trimmed }
            
            if let totalVal = matchPattern(trimmed, pattern: "^[Tt]otal\\s+\\$?(\\d+\\.?\\d*)$") {
                total = totalVal
            } else if let subVal = matchPattern(trimmed, pattern: "^[Ss]ubtotal\\s+\\$?(\\d+\\.?\\d*)$") {
                subtotal = subVal
            } else if let taxVal = matchPattern(trimmed, pattern: "^[Tt]ax\\s+\\$?(\\d+\\.?\\d*)$") {
                tax = taxVal
            } else if let tipVal = matchPattern(trimmed, pattern: "^[Tt]ip\\s+\\$?(\\d+\\.?\\d*)$") {
                tip = tipVal
            } else if let item = matchItemPattern(trimmed) {
                items.append(item)
            }
        }
        
        if total == 0 && !items.isEmpty {
            total = items.map(\.amount).reduce(0, +) + tax + tip
        }
        
        return ScannedReceipt(
            items: items,
            subtotal: subtotal,
            tax: tax,
            tip: tip,
            total: total,
            merchantName: merchantName,
            date: nil
        )
    }
    
    private func matchPattern(_ text: String, pattern: String) -> Decimal? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, range: range),
              let valueRange = Range(match.range(at: 1), in: text) else { return nil }
        return Decimal(string: String(text[valueRange]))
    }
    
    private func matchItemPattern(_ text: String) -> ReceiptLineItem? {
        guard let regex = try? NSRegularExpression(pattern: "^(.+?)\\s+\\$?(\\d+\\.?\\d*)$") else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, range: range) else { return nil }
        guard let nameRange = Range(match.range(at: 1), in: text),
              let amountRange = Range(match.range(at: 2), in: text) else { return nil }
        let name = String(text[nameRange]).trimmingCharacters(in: .whitespaces)
        let amount = Decimal(string: String(text[amountRange])) ?? 0
        guard amount > 0 else { return nil }
        return ReceiptLineItem(name: name, amount: amount)
    }
    
    enum ScanningError: Error {
        case invalidImage
        case noTextFound
    }
}
