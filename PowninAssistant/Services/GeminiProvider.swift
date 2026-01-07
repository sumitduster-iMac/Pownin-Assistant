//
//  GeminiProvider.swift
//  Pownin-Assistant
//
//  Google Gemini model provider
//

import Foundation

class GeminiProvider: AIModelProvider {
    let name = "Google Gemini"
    private let apiKey: String?
    private let model: String
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models"
    
    var isAvailable: Bool {
        guard let key = apiKey, !key.isEmpty else {
            return false
        }
        return true
    }
    
    init(apiKey: String? = nil, model: String = "gemini-pro") {
        self.apiKey = apiKey ?? ProcessInfo.processInfo.environment["GEMINI_API_KEY"]
        self.model = model
    }
    
    func generateResponse(prompt: String, context: MessageContext) async throws -> String {
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            throw AIModelError.invalidAPIKey
        }
        
        // Build full prompt with context
        let fullPrompt = buildPromptWithContext(prompt: prompt, context: context)
        
        // Prepare request
        guard let url = URL(string: "\(baseURL)/\(model):generateContent?key=\(apiKey)") else {
            throw AIModelError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": fullPrompt]
                    ]
                ]
            ],
            "generationConfig": [
                "maxOutputTokens": 500,
                "temperature": 0.7
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        // Make request with timeout
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        let session = URLSession(configuration: configuration)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIModelError.invalidResponse
        }
        
        if httpResponse.statusCode == 429 {
            throw AIModelError.rateLimitExceeded
        }
        
        guard httpResponse.statusCode == 200 else {
            throw AIModelError.networkError(NSError(domain: "Google", code: httpResponse.statusCode))
        }
        
        // Parse Gemini response format
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            throw AIModelError.invalidResponse
        }
        
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func buildPromptWithContext(prompt: String, context: MessageContext) -> String {
        var fullPrompt = """
        You are Pownin Assistant, an intelligent macOS assistant optimized for Intel Mac.
        You help users with system information, answer questions, and provide context-aware assistance.
        """
        
        if let systemState = context.systemState {
            fullPrompt += """
            
            Current system state:
            - CPU Usage: \(String(format: "%.1f%%", systemState.cpuUsage))
            - Memory Usage: \(String(format: "%.1f%%", systemState.memoryUsage))
            - Architecture: Intel x86_64
            """
        }
        
        if let relevantData = context.relevantData, !relevantData.isEmpty {
            fullPrompt += "\n\nConversation context: \(relevantData)"
        }
        
        fullPrompt += "\n\nProvide helpful, concise responses. When discussing system metrics, use the current values provided."
        fullPrompt += "\n\nUser: \(prompt)\n\nAssistant:"
        
        return fullPrompt
    }
}
