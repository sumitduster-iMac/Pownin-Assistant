//
//  ContentView.swift
//  Pownin-Assistant
//
//  Main UI for the assistant application with enhanced visual design
//

import SwiftUI

// MARK: - Main Content View
struct ContentView: View {
    @EnvironmentObject var aiService: AIService
    @State private var userInput: String = ""
    @State private var isProcessing: Bool = false
    @State private var showSettings: Bool = false
    @State private var selectedConversation: Int = 0
    
    var body: some View {
        NavigationView {
            // Sidebar
            SidebarView(selectedConversation: $selectedConversation)
                .frame(minWidth: 200, idealWidth: 250, maxWidth: 300)
            
            // Main Chat Area
            VStack(spacing: 0) {
                // Header
                EnhancedHeaderView()
                
                // Chat Messages Area
                ChatMessagesView()
                
                Divider()
                
                // Input Area
                EnhancedInputAreaView(
                    userInput: $userInput,
                    isProcessing: $isProcessing,
                    onSend: sendMessage
                )
            }
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(minWidth: 800, minHeight: 600)
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
    
    private func sendMessage() {
        guard !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isProcessing = true
        let input = userInput
        userInput = ""
        
        Task {
            await aiService.processMessage(input)
            isProcessing = false
        }
    }
}

// MARK: - Sidebar View
struct SidebarView: View {
    @Binding var selectedConversation: Int
    @State private var conversations: [String] = ["Current Chat"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Sidebar Header
            HStack {
                Text("Conversations")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Button(action: addNewConversation) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Conversation List
            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(conversations.indices, id: \.self) { index in
                        ConversationRowView(
                            title: conversations[index],
                            isSelected: selectedConversation == index,
                            onSelect: { selectedConversation = index }
                        )
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
            }
            
            Divider()
            
            // Sidebar Footer
            SidebarFooterView()
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private func addNewConversation() {
        conversations.append("New Chat \(conversations.count)")
        selectedConversation = conversations.count - 1
    }
}

// MARK: - Conversation Row View
struct ConversationRowView: View {
    let title: String
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: "bubble.left.fill")
                    .font(.system(size: 14))
                    .foregroundColor(isSelected ? .white : .secondary)
                
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(1)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Sidebar Footer View
struct SidebarFooterView: View {
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "gear")
                    .font(.system(size: 14))
                Text("Settings")
                    .font(.system(size: 13))
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
            .onTapGesture {
                // Open settings
            }
            
            HStack {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 14))
                Text("Help")
                    .font(.system(size: 13))
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .padding(.vertical, 8)
        .foregroundColor(.secondary)
    }
}

// MARK: - Enhanced Header View
struct EnhancedHeaderView: View {
    @EnvironmentObject var aiService: AIService
    @State private var cpuUsage: Double = 0.0
    @State private var memoryUsage: Double = 0.0
    @State private var timer: Timer?
    
    var body: some View {
        HStack(spacing: 16) {
            // App Title and Status
            VStack(alignment: .leading, spacing: 4) {
                Text("Pownin Assistant")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 20) {
                    SystemMetricView(
                        icon: "cpu",
                        label: "CPU",
                        value: String(format: "%.1f%%", cpuUsage),
                        color: cpuColor
                    )
                    
                    SystemMetricView(
                        icon: "memorychip",
                        label: "Memory",
                        value: String(format: "%.1f%%", memoryUsage),
                        color: memoryColor
                    )
                    
                    AIProviderBadge(provider: aiService.currentProvider)
                }
            }
            
            Spacer()
            
            // Status Indicator
            EnhancedStatusIndicatorView()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(NSColor.controlBackgroundColor),
                    Color(NSColor.controlBackgroundColor).opacity(0.95)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onAppear { startSystemMonitoring() }
        .onDisappear { stopSystemMonitoring() }
    }
    
    private var cpuColor: Color {
        if cpuUsage > 80 { return .red }
        if cpuUsage > 50 { return .orange }
        return .blue
    }
    
    private var memoryColor: Color {
        if memoryUsage > 80 { return .red }
        if memoryUsage > 50 { return .orange }
        return .green
    }
    
    private func startSystemMonitoring() {
        updateMetrics()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            DispatchQueue.main.async { self.updateMetrics() }
        }
    }
    
    private func stopSystemMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateMetrics() {
        cpuUsage = SystemMonitor.shared.getCPUUsage()
        memoryUsage = SystemMonitor.shared.getMemoryUsage()
    }
}

// MARK: - System Metric View
struct SystemMetricView: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - AI Provider Badge
struct AIProviderBadge: View {
    let provider: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.purple)
            
            Text(provider)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.purple.opacity(0.1))
        )
    }
}

// MARK: - Enhanced Status Indicator View
struct EnhancedStatusIndicatorView: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.3))
                    .frame(width: 24, height: 24)
                    .scaleEffect(isAnimating ? 1.3 : 1.0)
                    .opacity(isAnimating ? 0 : 0.5)
                
                Circle()
                    .fill(Color.green)
                    .frame(width: 10, height: 10)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("AI Active")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
                Text("Ready to assist")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Chat Messages View
struct ChatMessagesView: View {
    @EnvironmentObject var aiService: AIService
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    if aiService.messages.isEmpty {
                        WelcomeView()
                    } else {
                        ForEach(aiService.messages) { message in
                            EnhancedMessageBubbleView(message: message)
                                .id(message.id)
                        }
                    }
                }
                .padding(20)
            }
            .onChange(of: aiService.messages.count) { _ in
                if let lastMessage = aiService.messages.last {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}

// MARK: - Welcome View
struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 60))
                .foregroundColor(.accentColor.opacity(0.6))
            
            Text("Welcome to Pownin Assistant")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Your intelligent AI-powered assistant. Ask me anything about your system, get help with tasks, or just have a conversation!")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 400)
            
            // Quick Actions
            HStack(spacing: 12) {
                QuickActionButton(icon: "cpu", title: "System Status")
                QuickActionButton(icon: "questionmark.circle", title: "Help")
                QuickActionButton(icon: "lightbulb", title: "Suggestions")
            }
            .padding(.top, 10)
        }
        .padding(40)
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let title: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.accentColor)
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
}

// MARK: - Enhanced Message Bubble View
struct EnhancedMessageBubbleView: View {
    let message: Message
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.isUser {
                Spacer(minLength: 60)
            } else {
                // AI Avatar
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.purple, .blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "brain")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 6) {
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        Group {
                            if message.isUser {
                                LinearGradient(
                                    gradient: Gradient(colors: [.accentColor, .accentColor.opacity(0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            } else {
                                Color(NSColor.controlBackgroundColor)
                            }
                        }
                    )
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(16)
                    .textSelection(.enabled)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: 500, alignment: message.isUser ? .trailing : .leading)
            
            if message.isUser {
                // User Avatar
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.2))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.accentColor)
                }
            } else {
                Spacer(minLength: 60)
            }
        }
    }
}

// MARK: - Enhanced Input Area View
struct EnhancedInputAreaView: View {
    @Binding var userInput: String
    @Binding var isProcessing: Bool
    let onSend: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Attachment button
            Button(action: {}) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 22))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            
            // Text Input
            HStack {
                TextField("Ask me anything...", text: $userInput, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...5)
                    .disabled(isProcessing)
                    .onSubmit(onSend)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(NSColor.controlBackgroundColor))
            )
            
            // Send Button
            Button(action: onSend) {
                ZStack {
                    Circle()
                        .fill(userInput.isEmpty || isProcessing ? Color.gray.opacity(0.3) : Color.accentColor)
                        .frame(width: 40, height: 40)
                    
                    if isProcessing {
                        ProgressView()
                            .scaleEffect(0.7)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(userInput.isEmpty || isProcessing)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Settings panel coming soon...")
                .foregroundColor(.secondary)
            
            Button("Close") { dismiss() }
                .buttonStyle(.borderedProminent)
        }
        .frame(width: 400, height: 300)
        .padding()
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AIService())
            .frame(width: 1000, height: 700)
    }
}
