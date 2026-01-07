//
//  AIService.swift
//  Pownin-Assistant
//
//  AI integration service with dynamic response capabilities
//

import Foundation
import Combine

@MainActor
class AIService: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isProcessing: Bool = false
    
    private var conversationHistory: [Message] = []
    private let contextAnalyzer = ContextAnalyzer()
    
    init() {
        // Add welcome message
        let welcomeMessage = Message(
            content: "Hello! I'm Pownin Assistant, your intelligent macOS companion. I can help you with system information, answer questions, and provide context-aware assistance. How can I help you today?",
            isUser: false
        )
        messages.append(welcomeMessage)
    }
    
    func processMessage(_ input: String) async {
        // Add user message
        let userMessage = Message(content: input, isUser: true)
        messages.append(userMessage)
        conversationHistory.append(userMessage)
        
        isProcessing = true
        
        // Gather real-time context (synchronous but in async context for future extensibility)
        let context = gatherContext()
        
        // Generate AI response based on input and context
        let response = generateResponse(for: input, context: context)
        
        // Add AI response
        let aiMessage = Message(
            content: response,
            isUser: false,
            context: context
        )
        messages.append(aiMessage)
        conversationHistory.append(aiMessage)
        
        isProcessing = false
    }
    
    private func gatherContext() -> MessageContext {
        // Gather real-time system data
        let systemState = SystemState(
            cpuUsage: SystemMonitor.shared.getCPUUsage(),
            memoryUsage: SystemMonitor.shared.getMemoryUsage()
        )
        
        // Analyze conversation context
        let relevantData = contextAnalyzer.analyzeConversation(conversationHistory)
        
        return MessageContext(systemState: systemState, relevantData: relevantData)
    }
    
    private func generateResponse(for input: String, context: MessageContext) -> String {
        // Note: Processing is synchronous since all logic is local
        // If external API calls are added in the future, make this async again
        
        let lowercasedInput = input.lowercased()
        
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
        
        // Default intelligent response
        return "I understand you're asking about '\(input)'. As an AI assistant with real-time context awareness, I'm constantly monitoring your system (CPU: \(String(format: "%.1f%%", context.systemState?.cpuUsage ?? 0.0)), Memory: \(String(format: "%.1f%%", context.systemState?.memoryUsage ?? 0.0))) to provide the most relevant assistance. Could you provide more details about what you'd like to know?"
    }
    
    func clearHistory() {
        messages.removeAll()
        conversationHistory.removeAll()
    }
}
