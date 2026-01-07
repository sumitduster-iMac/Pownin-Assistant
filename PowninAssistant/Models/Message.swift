//
//  Message.swift
//  Pownin-Assistant
//
//  Data model for chat messages
//

import Foundation

struct Message: Identifiable, Codable {
    let id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date
    var context: MessageContext?
    
    init(id: UUID = UUID(), content: String, isUser: Bool, timestamp: Date = Date(), context: MessageContext? = nil) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
        self.context = context
    }
}

struct MessageContext: Codable {
    let systemState: SystemState?
    let relevantData: [String: String]?
    
    init(systemState: SystemState? = nil, relevantData: [String: String]? = nil) {
        self.systemState = systemState
        self.relevantData = relevantData
    }
}

struct SystemState: Codable {
    let cpuUsage: Double
    let memoryUsage: Double
    let timestamp: Date
    
    init(cpuUsage: Double, memoryUsage: Double, timestamp: Date = Date()) {
        self.cpuUsage = cpuUsage
        self.memoryUsage = memoryUsage
        self.timestamp = timestamp
    }
}
