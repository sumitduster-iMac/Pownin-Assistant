//
//  PowninAssistantApp.swift
//  Pownin-Assistant
//
//  Created for Intel Mac compatibility
//

import SwiftUI

@main
struct PowninAssistantApp: App {
    @StateObject private var aiService = AIService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(aiService)
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}
