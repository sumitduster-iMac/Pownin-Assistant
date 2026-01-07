//
//  ContentView.swift
//  Pownin-Assistant
//
//  Main UI for the assistant application
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var aiService: AIService
    @State private var userInput: String = ""
    @State private var isProcessing: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HeaderView()
            
            // Chat Messages Area
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(aiService.messages) { message in
                            MessageBubbleView(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: aiService.messages.count) { _ in
                    if let lastMessage = aiService.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            
            // Input Area
            InputAreaView(
                userInput: $userInput,
                isProcessing: $isProcessing,
                onSend: sendMessage
            )
        }
        .background(Color(NSColor.windowBackgroundColor))
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

struct HeaderView: View {
    @EnvironmentObject var aiService: AIService
    @State private var cpuUsage: Double = 0.0
    @State private var memoryUsage: Double = 0.0
    @State private var timer: Timer?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Pownin Assistant")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 16) {
                    SystemInfoLabel(icon: "cpu", value: String(format: "%.1f%%", cpuUsage), color: .blue)
                    SystemInfoLabel(icon: "memorychip", value: String(format: "%.1f%%", memoryUsage), color: .green)
                    
                    // AI Model indicator
                    HStack(spacing: 4) {
                        Image(systemName: "brain")
                            .foregroundColor(.purple)
                            .font(.system(size: 12))
                        Text(aiService.currentProvider)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            StatusIndicatorView()
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .onAppear {
            startSystemMonitoring()
        }
        .onDisappear {
            stopSystemMonitoring()
        }
    }
    
    private func startSystemMonitoring() {
        // Initial update
        updateMetrics()
        
        // Schedule periodic updates
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            // Ensure UI updates happen on main thread
            DispatchQueue.main.async {
                self.updateMetrics()
            }
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

struct SystemInfoLabel: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 12))
            Text(value)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
}

struct StatusIndicatorView: View {
    @State private var isActive = true
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(isActive ? Color.green : Color.gray)
                .frame(width: 8, height: 8)
                .overlay(
                    Circle()
                        .stroke(isActive ? Color.green.opacity(0.3) : Color.clear, lineWidth: 4)
                        .scaleEffect(isActive ? 1.5 : 1.0)
                        .opacity(isActive ? 0 : 1)
                        .animation(
                            isActive ? .easeInOut(duration: 1.5).repeatForever(autoreverses: false) : .default,
                            value: isActive
                        )
                )
            
            Text(isActive ? "AI Active" : "AI Inactive")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        .cornerRadius(12)
    }
}

struct MessageBubbleView: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(12)
                    .background(message.isUser ? Color.accentColor : Color(NSColor.controlBackgroundColor))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(12)
                    .textSelection(.enabled)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: 500, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

struct InputAreaView: View {
    @Binding var userInput: String
    @Binding var isProcessing: Bool
    let onSend: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("Ask me anything...", text: $userInput, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...5)
                .padding(12)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                .disabled(isProcessing)
                .onSubmit(onSend)
            
            Button(action: onSend) {
                Image(systemName: isProcessing ? "hourglass" : "arrow.up.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(userInput.isEmpty ? .gray : .accentColor)
            }
            .buttonStyle(.plain)
            .disabled(userInput.isEmpty || isProcessing)
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AIService())
            .frame(width: 800, height: 600)
    }
}
