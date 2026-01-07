# Pownin Assistant - UI Documentation

## User Interface Layout

The Pownin Assistant features a modern, native macOS interface designed for Intel Mac compatibility.

### Main Window Structure

```
┌─────────────────────────────────────────────────────────────┐
│  Pownin Assistant                    [AI Active ●]           │
│  CPU: 45.2%  Memory: 62.1%                                   │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────────────────────────────────┐           │
│  │ AI: Hello! I'm Pownin Assistant, your       │           │
│  │     intelligent macOS companion...           │  9:30 AM  │
│  └──────────────────────────────────────────────┘           │
│                                                               │
│           ┌─────────────────────────────────────┐            │
│           │ User: What's my system status?      │ 9:31 AM   │
│           └─────────────────────────────────────┘            │
│                                                               │
│  ┌──────────────────────────────────────────────┐           │
│  │ AI: Here's your current system status:      │           │
│  │     • CPU Usage: 45.2%                       │           │
│  │     • Memory Usage: 62.1%                    │           │
│  │     • Architecture: Intel x86_64             │  9:31 AM  │
│  │     • Status: System running normally        │           │
│  └──────────────────────────────────────────────┘           │
│                                                               │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────┐  ┌──────────┐         │
│  │ Ask me anything...                │  │    ↑     │         │
│  └──────────────────────────────────┘  └──────────┘         │
└─────────────────────────────────────────────────────────────┘
```

## UI Components

### 1. Header Bar
- **Application Title**: "Pownin Assistant"
- **Real-time System Metrics**:
  - CPU usage percentage (updated every 2 seconds)
  - Memory usage percentage (updated every 2 seconds)
- **AI Status Indicator**: 
  - Green pulsing circle when AI is active
  - "AI Active" label

### 2. Chat Area
- **Message Bubbles**:
  - User messages: Right-aligned with accent color (teal/blue)
  - AI responses: Left-aligned with gray background
  - Timestamps below each message
- **Auto-scroll**: Automatically scrolls to show latest messages
- **Scrollable**: View full conversation history

### 3. Input Area
- **Text Field**: 
  - Placeholder: "Ask me anything..."
  - Multi-line support (1-5 lines)
  - Rounded corners with gray background
- **Send Button**: 
  - Large circular arrow icon
  - Disabled when empty or processing
  - Changes to hourglass when processing

## Color Scheme

- **Accent Color**: Teal/Blue (#3366CC with variations)
- **Background**: Native macOS window background (adapts to light/dark mode)
- **Text**: Primary and secondary system colors
- **Status Indicators**:
  - CPU: Blue icon
  - Memory: Green icon
  - AI Status: Green when active

## Features Demonstrated in UI

### Real-time System Monitoring
The header displays live CPU and memory usage, demonstrating the Intel Mac compatibility and system monitoring capabilities.

### AI Status Indicator
A pulsing green circle with "AI Active" text shows that the AI service is running and ready to respond.

### Context-Aware Chat
Message bubbles show the conversation flow, with the AI providing intelligent responses based on:
- Real-time system data
- Conversation history
- User intent analysis

### Native macOS Design
- Hidden title bar for modern look
- Native system colors
- Support for light and dark mode
- Standard macOS fonts and spacing

## Interaction Flow

1. User types a question or command in the input field
2. Press Enter or click the send button
3. User message appears right-aligned in the chat
4. AI processes the message (hourglass icon appears)
5. AI response appears left-aligned with:
   - Context-aware content
   - Real-time system metrics (if relevant)
   - Timestamp
6. Conversation continues with full context maintained

## Intel Mac Optimization

The UI is optimized for Intel Mac:
- Uses x86_64 architecture-specific APIs
- Native system monitoring calls for Intel processors
- Optimized rendering for Intel integrated/discrete GPUs
- Memory management tuned for Intel architecture

## Accessibility

- Text selection enabled in message bubbles
- Keyboard navigation supported
- High contrast support
- VoiceOver compatible
- Respects system text size preferences
