//
//  ContextAnalyzer.swift
//  Pownin-Assistant
//
//  Context analysis for intelligent AI responses
//

import Foundation

class ContextAnalyzer {
    
    /// Analyze conversation history to extract relevant context
    func analyzeConversation(_ messages: [Message]) -> [String: String] {
        var context: [String: String] = [:]
        
        // Extract topics from recent messages
        let recentMessages = messages.suffix(5)
        var topics: Set<String> = []
        
        for message in recentMessages {
            let words = message.content.lowercased().components(separatedBy: .whitespacesAndNewlines)
            
            // Identify key topics
            if words.contains(where: { $0.contains("cpu") || $0.contains("processor") }) {
                topics.insert("system_performance")
            }
            if words.contains(where: { $0.contains("memory") || $0.contains("ram") }) {
                topics.insert("memory_usage")
            }
            if words.contains(where: { $0.contains("intel") || $0.contains("architecture") }) {
                topics.insert("architecture")
            }
            if words.contains(where: { $0.contains("help") || $0.contains("assist") }) {
                topics.insert("assistance")
            }
        }
        
        context["topics"] = topics.joined(separator: ", ")
        context["message_count"] = String(messages.count)
        context["timestamp"] = ISO8601DateFormatter().string(from: Date())
        
        // Determine user intent
        if let lastUserMessage = messages.last(where: { $0.isUser }) {
            context["last_user_query"] = lastUserMessage.content
            context["user_intent"] = determineIntent(lastUserMessage.content)
        }
        
        return context
    }
    
    private func determineIntent(_ query: String) -> String {
        let lowercased = query.lowercased()
        
        if lowercased.contains("?") {
            return "question"
        } else if lowercased.contains("help") || lowercased.contains("how") {
            return "assistance_request"
        } else if lowercased.contains("show") || lowercased.contains("tell") || lowercased.contains("what") {
            return "information_request"
        } else if lowercased.contains("thank") {
            return "acknowledgment"
        } else {
            return "general"
        }
    }
    
    /// Extract keywords from text
    func extractKeywords(_ text: String) -> [String] {
        let words = text.lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.count > 3 }
        
        // Remove common stop words
        let stopWords = Set(["this", "that", "with", "from", "have", "been", "what", "when", "where", "which", "their", "about", "would", "could", "should"])
        
        return words.filter { !stopWords.contains($0) }
    }
}
