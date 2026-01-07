//
//  AnthropicProvider.swift
//  Pownin-Assistant
//
//  Anthropic Claude model provider
//

import Foundation

class AnthropicProvider: AIModelProvider {
    let name = "Anthropic Claude"
    private let apiKey: String?
    private let model: String
    private let baseURL = "https://api.anthropic.com/v1/messages"
    
    var isAvailable: Bool {
        return apiKey != nil && !apiKey!.isEmpty
    }
    
    init(apiKey: String? = nil, model: String = "claude-3-haiku-20240307") {
        self.apiKey = apiKey ?? ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"]
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
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        
        let requestBody: [String: Any] = [
            "model": model,
            "max_tokens": 500,
            "system": systemMessage,
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        // Make request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIModelError.invalidResponse
        }
        
        if httpResponse.statusCode == 429 {
            throw AIModelError.rateLimitExceeded
        }
        
        guard httpResponse.statusCode == 200 else {
            throw AIModelError.networkError(NSError(domain: "Anthropic", code: httpResponse.statusCode))
        }
        
        // Parse response
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let firstContent = content.first,
              let text = firstContent["text"] as? String else {
            throw AIModelError.invalidResponse
        }
        
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
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
