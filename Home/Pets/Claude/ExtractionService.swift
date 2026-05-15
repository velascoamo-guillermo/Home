// Home/Pets/Claude/ExtractionService.swift
import Foundation

struct ExtractionResult {
    var visitDate: Date?
    var diagnosis: String
    var testResults: [String: String]
    var medications: [String]
    var recommendations: String
}

enum ExtractionError: LocalizedError {
    case noApiKey
    case networkError(Error)
    case invalidResponse(Int)
    case parseError

    var errorDescription: String? {
        switch self {
        case .noApiKey:               return "No Claude API key configured. Add one in Settings."
        case .networkError(let e):    return "Network error: \(e.localizedDescription)"
        case .invalidResponse(let c): return "API error (status \(c)). Check your API key."
        case .parseError:             return "Could not parse the document. Try a clearer scan."
        }
    }
}

enum ExtractionService {

    static func buildPrompt(petName: String) -> String {
        """
        You are a veterinary records assistant. Analyze the attached document for \(petName) and extract the following information. Respond with ONLY valid JSON matching this exact schema — no markdown, no extra text:

        {
          "visitDate": "YYYY-MM-DD or null",
          "diagnosis": "string",
          "testResults": {"test name": "value"},
          "medications": ["string"],
          "recommendations": "string"
        }

        If a field is not present in the document, use null for dates and empty string/array for others.
        """
    }

    static func parseResponse(_ json: String) throws -> ExtractionResult {
        guard let data = json.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ExtractionError.parseError
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var visitDate: Date? = nil
        if let dateStr = obj["visitDate"] as? String { visitDate = dateFormatter.date(from: dateStr) }
        let diagnosis = obj["diagnosis"] as? String ?? ""
        let testResults = obj["testResults"] as? [String: String] ?? [:]
        let medications = obj["medications"] as? [String] ?? []
        let recommendations = obj["recommendations"] as? String ?? ""
        return ExtractionResult(visitDate: visitDate, diagnosis: diagnosis,
                                testResults: testResults, medications: medications,
                                recommendations: recommendations)
    }

    static func extract(fileURL: URL, petName: String) async throws -> ExtractionResult {
        guard let apiKey = KeychainService.load(account: KeychainService.claudeApiKeyAccount),
              !apiKey.isEmpty else { throw ExtractionError.noApiKey }

        let fileData = try Data(contentsOf: fileURL)
        let base64 = fileData.base64EncodedString()
        let ext = fileURL.pathExtension.lowercased()
        let mediaType = ext == "pdf" ? "application/pdf" : "image/jpeg"
        let contentType = ext == "pdf" ? "document" : "image"

        let contentBlock: [String: Any] = [
            "type": contentType,
            "source": [
                "type": "base64",
                "media_type": mediaType,
                "data": base64
            ]
        ]

        let body: [String: Any] = [
            "model": "claude-sonnet-4-6",
            "max_tokens": 1024,
            "messages": [[
                "role": "user",
                "content": [
                    contentBlock,
                    ["type": "text", "text": buildPrompt(petName: petName)]
                ]
            ]]
        ]

        var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw ExtractionError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw ExtractionError.invalidResponse(code)
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = (json["content"] as? [[String: Any]])?.first,
              let text = content["text"] as? String else {
            throw ExtractionError.parseError
        }

        return try parseResponse(text)
    }
}
