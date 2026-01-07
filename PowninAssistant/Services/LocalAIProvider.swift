//
//  LocalAIProvider.swift
//  Pownin-Assistant
//
//  Local rule-based AI provider (fallback when no API keys available)
//

import Foundation

class LocalAIProvider: AIModelProvider {
    let name = "Local AI"
    var isAvailable: Bool { return true }
    
    func generateResponse(prompt: String, context: MessageContext) async throws -> String {
        let lowercasedInput = prompt.lowercased()
        
        // Context-aware responses based on real-time data
        if lowercasedInput.contains("cpu") || lowercasedInput.contains("processor") {
            let cpuUsage = context.systemState?.cpuUsage ?? 0.0
            return "Your CPU is currently at \(String(format: "%.1f%%", cpuUsage)) usage. \(cpuUsage > 70 ? "That's quite high - you might want to check which applications are consuming resources." : "That's a healthy usage level.")"
        }
        
        if lowercasedInput.contains("memory") || lowercasedInput.contains("ram") {
            let memUsage = context.systemState?.memoryUsage ?? 0.0
            return "Your memory usage is at \(String(format: "%.1f%%", memUsage)). \(memUsage > 80 ? "You're running low on available memory. Consider closing some applications." : "Your memory usage is in good shape.")"
        }
        
        if lowercasedInput.contains("system") || lowercasedInput.contains("status") {
            let cpuUsage = context.systemState?.cpuUsage ?? 0.0
            let memUsage = context.systemState?.memoryUsage ?? 0.0
            return """
            Here's your current system status:
            • CPU Usage: \(String(format: "%.1f%%", cpuUsage))
            • Memory Usage: \(String(format: "%.1f%%", memUsage))
            • Architecture: Intel x86_64 (Intel Mac compatible)
            • Status: System running normally
            """
        }
        
        if lowercasedInput.contains("hello") || lowercasedInput.contains("hi") {
            return "Hello! I'm here to assist you with your Intel Mac. What would you like to know?"
        }
        
        if lowercasedInput.contains("help") || lowercasedInput.contains("what can you do") {
            return """
            I can help you with:
            • Real-time system monitoring (CPU, Memory)
            • Intel Mac architecture information
            • Context-aware assistance based on your system state
            • General questions and information
            
            Just ask me anything, and I'll provide intelligent, data-driven responses!
            """
        }
        
        if lowercasedInput.contains("intel") || lowercasedInput.contains("architecture") {
            return "This application is optimized for Intel Mac (x86_64 architecture). It's designed to run efficiently on Intel-based macOS systems with full compatibility and performance optimization."
        }
        
        if lowercasedInput.contains("model") || lowercasedInput.contains("ai") {
            return "I'm currently using the local AI model. To use advanced AI models like OpenAI GPT or Anthropic Claude, you can set up API keys via environment variables: OPENAI_API_KEY or ANTHROPIC_API_KEY."
        }
        
        // Default intelligent response
        return "I understand you're asking about '\(prompt)'. As an AI assistant with real-time context awareness, I'm constantly monitoring your system (CPU: \(String(format: "%.1f%%", context.systemState?.cpuUsage ?? 0.0)), Memory: \(String(format: "%.1f%%", context.systemState?.memoryUsage ?? 0.0))) to provide the most relevant assistance. Could you provide more details about what you'd like to know?"
    }
}
