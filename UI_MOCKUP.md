# Pownin Assistant - UI Mockup

This document provides a visual representation of the Pownin Assistant UI for Intel Mac.

## Application Window

The application features a modern, clean interface optimized for macOS.

### Window Properties
- **Dimensions**: Minimum 800x600 pixels
- **Title Bar**: Hidden for modern appearance
- **Background**: Adaptive (Light/Dark mode support)
- **Architecture**: Intel Mac x86_64 optimized

## UI Components Breakdown

### 1. Header Section (Top Bar)
```
┌────────────────────────────────────────────────────────────────┐
│  ● ● ●  Pownin Assistant                       [AI Active ●]    │
│  🖥️ CPU: 45.2%   💾 Memory: 62.1%                               │
└────────────────────────────────────────────────────────────────┘
```

**Elements:**
- Application title: "Pownin Assistant" (18pt, semibold)
- Real-time metrics with icons:
  - CPU icon (blue) + percentage
  - Memory icon (green) + percentage
- AI status indicator:
  - Pulsing green circle when active
  - "AI Active" label

**Updates:** Every 2 seconds

### 2. Chat Interface (Main Area)
```
┌────────────────────────────────────────────────────────────────┐
│                                                                  │
│  ┌─────────────────────────────────────────────────────┐        │
│  │ 🤖 Hello! I'm Pownin Assistant, your intelligent    │        │
│  │    macOS companion. I can help you with system      │        │
│  │    information, answer questions, and provide       │        │
│  │    context-aware assistance...                      │        │
│  └─────────────────────────────────────────────────────┘        │
│  9:30 AM                                                         │
│                                                                  │
│                     ┌────────────────────────────────┐          │
│                     │ What's my system status?       │ 👤       │
│                     └────────────────────────────────┘          │
│                                              9:31 AM             │
│                                                                  │
│  ┌─────────────────────────────────────────────────────┐        │
│  │ 🤖 Here's your current system status:               │        │
│  │    • CPU Usage: 45.2%                               │        │
│  │    • Memory Usage: 62.1%                            │        │
│  │    • Architecture: Intel x86_64 (Intel Mac)         │        │
│  │    • Status: System running normally                │        │
│  └─────────────────────────────────────────────────────┘        │
│  9:31 AM                                                         │
│                                                                  │
│                     ┌────────────────────────────────┐          │
│                     │ Tell me about the AI features  │ 👤       │
│                     └────────────────────────────────┘          │
│                                              9:32 AM             │
│                                                                  │
│  ┌─────────────────────────────────────────────────────┐        │
│  │ 🤖 I provide intelligent, data-driven responses     │        │
│  │    with:                                             │        │
│  │    • Real-time system monitoring                    │        │
│  │    • Context-aware analysis                         │        │
│  │    • Dynamic responses based on your Intel Mac's    │        │
│  │      current state (CPU: 45.2%, Memory: 62.1%)      │        │
│  │    • Conversation history awareness                 │        │
│  └─────────────────────────────────────────────────────┘        │
│  9:32 AM                                                         │
│                                                                  │
└────────────────────────────────────────────────────────────────┘
```

**Message Bubble Design:**
- **AI Messages (Left):**
  - Gray background (#E5E5E5 light, #3A3A3C dark)
  - Black text
  - Robot emoji indicator
  - Left-aligned
  - Max width: 500px

- **User Messages (Right):**
  - Accent color background (Teal #3366CC)
  - White text
  - User emoji indicator
  - Right-aligned
  - Max width: 500px

- **Timestamps:**
  - Small gray text
  - Below each message
  - Format: h:mm AM/PM

### 3. Input Section (Bottom Bar)
```
┌────────────────────────────────────────────────────────────────┐
│  ┌─────────────────────────────────────────────┐   ┌───────┐   │
│  │ Ask me anything...                          │   │   ⬆   │   │
│  │                                              │   │       │   │
│  └─────────────────────────────────────────────┘   └───────┘   │
└────────────────────────────────────────────────────────────────┘
```

**Elements:**
- Multi-line text field (1-5 lines)
- Placeholder: "Ask me anything..."
- Rounded corners (8px radius)
- Gray background
- Send button:
  - Large circular arrow icon (28pt)
  - Blue when enabled, gray when disabled
  - Changes to hourglass ⏳ during processing

## Color Palette

### Light Mode
- Background: #FFFFFF
- Secondary Background: #F5F5F7
- Control Background: #E5E5E5
- Text: #000000
- Secondary Text: #6B6B6B
- Accent: #3366CC (Teal/Blue)
- Success: #32D74B (Green)

### Dark Mode
- Background: #1C1C1E
- Secondary Background: #2C2C2E
- Control Background: #3A3A3C
- Text: #FFFFFF
- Secondary Text: #AEAEB2
- Accent: #5599FF (Lighter Blue)
- Success: #32D74B (Green)

## Animations

### 1. AI Status Pulse
- Duration: 1.5 seconds
- Repeats: Forever
- Effect: Circle expands and fades out
- Color: Green (#32D74B)

### 2. Message Appearance
- Animation: Fade in + slide up
- Duration: 0.3 seconds
- Easing: Ease in-out

### 3. Auto-scroll
- Animation: Smooth scroll to bottom
- Duration: 0.3 seconds
- Trigger: New message added

### 4. Button States
- Hover: Slight scale (1.05)
- Press: Scale down (0.95)
- Disabled: Opacity 0.5

## Interaction States

### Text Input
- **Empty**: Gray placeholder visible, send button disabled
- **Has Text**: Placeholder hidden, send button enabled
- **Processing**: Input disabled, hourglass shown, no editing

### System Metrics
- **Normal**: Blue/Green indicators
- **High Usage (>70%)**: Yellow warning color
- **Critical (>90%)**: Red alert color

### AI Status
- **Active**: Pulsing green circle
- **Processing**: Spinning indicator
- **Idle**: Solid green circle
- **Error**: Red circle

## Accessibility Features

- ✅ VoiceOver support
- ✅ Keyboard navigation
- ✅ Text selection in messages
- ✅ High contrast mode support
- ✅ Adjustable text size
- ✅ Reduced motion option

## Intel Mac Specific Features

### Architecture Display
When user asks about system: Shows "Intel x86_64 (Intel Mac compatible)"

### Optimized Performance
- Native CPU monitoring using Intel-specific APIs
- Optimized memory tracking for Intel architecture
- Efficient rendering on Intel integrated/discrete GPUs

### Compatibility Notice
Application verifies Intel architecture on launch and displays architecture in system information responses.

## Example Conversation Flow

```
[App Launch]
AI: "Hello! I'm Pownin Assistant, your intelligent macOS companion..."

[User types and sends]
User: "What's my CPU usage?"

[AI processes with real-time data]
AI: "Your CPU is currently at 45.2% usage. That's a healthy usage level."

[Real-time metrics update in header]
Header: CPU: 46.1%  Memory: 62.3%

[Continued conversation]
User: "Check system status"

AI: "Here's your current system status:
     • CPU Usage: 46.1%
     • Memory Usage: 62.3%
     • Architecture: Intel x86_64 (Intel Mac compatible)
     • Status: System running normally"
```

## Responsive Behavior

### Minimum Window Size: 800x600
- All elements scale appropriately
- Text wraps in message bubbles
- Vertical scrolling for message history

### Larger Windows
- Message bubbles maintain max-width of 500px
- Additional white space on sides
- More vertical space for messages

## Technical Implementation Notes

- **Framework**: SwiftUI (native macOS)
- **Minimum macOS**: 13.0 (Ventura)
- **Architecture**: x86_64 (Intel Mac)
- **Rendering**: Metal-accelerated (GPU-optimized)
- **Updates**: Reactive with @Published properties
- **Threading**: Main thread UI, background processing for AI

---

This UI design provides a clean, modern, and efficient interface for the Pownin Assistant, optimized specifically for Intel Mac architecture with real-time AI integration capabilities.
