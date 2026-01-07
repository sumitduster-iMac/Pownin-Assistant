//
//  GrokProvider.swift
//  Pownin-Assistant
//
//  xAI Grok model provider
//

import Foundation

class GrokProvider: AIModelProvider {
    let name = "xAI Grok"
    private let apiKey: String?
    private let model: String
    private let baseURL = "https://api.x.ai/v1/chat/completions"
    
    var isAvailable: Bool {
        guard let key = apiKey, !key.isEmpty else {
            return false
        }
        return true
    }
    
    init(apiKey: String? = nil, model: String = "grok-beta") {
        self.apiKey = apiKey ?? ProcessInfo.processInfo.environment["XAI_API_KEY"]
        self.model = model
    }
    
    func generateResponse(prompt: String, context: MessageContext) async throws -> String {
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            throw AIModelError.invalidAPIKey
        }
        
        // Build system message with context
        let systemMessage = buildSystemMessage(context: context)
        
        // Prepare request
        guard let url = URL(string: baseURL) else {
            throw AIModelError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": systemMessage],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 500,
            "temperature": 0.7
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
            throw AIModelError.networkError(NSError(domain: "xAI", code: httpResponse.statusCode))
        }
        
        // Parse response (OpenAI-compatible format)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIModelError.invalidResponse
        }
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func buildSystemMessage(context: MessageContext) -> String {
        var systemMessage = """
        You are Pownin Assistant, an intelligent macOS assistant optimized for Intel Mac.
        You help users with system information, answer questions, and provide context-aware assistance.
        """
        
        if let systemState = context.systemState {
            systemMessage += """
            
            Current system state:
            - CPU Usage: \(String(format: "%.1f%%", systemState.cpuUsage))
            - Memory Usage: \(String(format: "%.1f%%", systemState.memoryUsage))
            - Architecture: Intel x86_64
            """
        }
        
        if let relevantData = context.relevantData, !relevantData.isEmpty {
            systemMessage += "\n\nConversation context: \(relevantData)"
        }
        
        systemMessage += "\n\nProvide helpful, concise responses. When discussing system metrics, use the current values provided."
        
        return systemMessage
    }
}
