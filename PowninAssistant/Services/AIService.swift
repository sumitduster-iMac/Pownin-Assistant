//
//  AIService.swift
//  Pownin-Assistant
//
//  AI integration service with dynamic response capabilities
//  Supports multiple AI model providers with automatic fallback
//

import Foundation
import Combine

@MainActor
class AIService: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isProcessing: Bool = false
    @Published var currentProvider: String = "Initializing..."
    
    private var conversationHistory: [Message] = []
    private let contextAnalyzer = ContextAnalyzer()
    private var providers: [AIModelProvider] = []
    private var currentProviderIndex: Int = 0
    
    init() {
        // Initialize all AI model providers
        setupProviders()
        
        // Add welcome message
        let welcomeMessage = Message(
            content: """
            Hello! I'm Pownin Assistant, your intelligent macOS companion powered by \(currentProvider).
            
            I can help you with system information, answer questions, and provide context-aware assistance.
            
            Available AI models:
            \(providers.map { "• \($0.name)\(($0.isAvailable ? " ✓" : " (configure API key)"))" }.joined(separator: "\n"))
            
            How can I help you today?
            """,
            isUser: false
        )
        messages.append(welcomeMessage)
    }
    
    private func setupProviders() {
        // Add all available providers in priority order
        providers = [
            OpenAIProvider(),
            AnthropicProvider(),
            LocalAIProvider() // Always available as fallback
        ]
        
        // Find first available provider
        if let index = providers.firstIndex(where: { $0.isAvailable }) {
            currentProviderIndex = index
            currentProvider = providers[index].name
        }
    }
    
    func processMessage(_ input: String) async {
        // Add user message
        let userMessage = Message(content: input, isUser: true)
        messages.append(userMessage)
        conversationHistory.append(userMessage)
        
        isProcessing = true
        
        // Gather real-time context
        let context = gatherContext()
        
        // Generate AI response using available providers
        let response = await generateResponseWithFallback(for: input, context: context)
        
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
    
    private func generateResponseWithFallback(for input: String, context: MessageContext) async -> String {
        // Try each provider in order
        for (index, provider) in providers.enumerated() {
            guard provider.isAvailable else { continue }
            
            do {
                let response = try await provider.generateResponse(prompt: input, context: context)
                
                // Update current provider if it changed
                if index != currentProviderIndex {
                    currentProviderIndex = index
                    currentProvider = provider.name
                }
                
                return response
            } catch {
                print("[\(provider.name)] Error: \(error.localizedDescription)")
                
                // If this was the current provider and it failed, try next one
                if index == currentProviderIndex {
                    continue
                }
            }
        }
        
        // Fallback message if all providers fail
        return "I apologize, but I'm having trouble generating a response right now. Please try again or check your AI model configuration."
    }
    
    func switchProvider(to providerName: String) {
        if let index = providers.firstIndex(where: { $0.name == providerName && $0.isAvailable }) {
            currentProviderIndex = index
            currentProvider = providers[index].name
            
            let message = Message(
                content: "Switched to \(providerName) for AI responses.",
                isUser: false
            )
            messages.append(message)
        }
    }
    
    func getAvailableProviders() -> [String] {
        return providers.filter { $0.isAvailable }.map { $0.name }
    }
    
    func clearHistory() {
        messages.removeAll()
        conversationHistory.removeAll()
    }
}
