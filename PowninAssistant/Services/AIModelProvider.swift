//
//  AIModelProvider.swift
//  Pownin-Assistant
//
//  AI model provider protocol for different AI services
//

import Foundation

/// Protocol for AI model providers
protocol AIModelProvider {
    var name: String { get }
    var isAvailable: Bool { get }
    func generateResponse(prompt: String, context: MessageContext) async throws -> String
}

/// Errors that can occur during AI model operations
enum AIModelError: Error {
    case invalidAPIKey
    case networkError(Error)
    case invalidResponse
    case modelNotAvailable
    case rateLimitExceeded
    case timeout
    
    var localizedDescription: String {
        switch self {
        case .invalidAPIKey:
            return "Invalid API key. Please check your configuration."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from AI model."
        case .modelNotAvailable:
            return "AI model is not available."
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .timeout:
            return "Request timeout. Please try again."
        }
    }
}
