# Pownin-Assistant

An intelligent macOS assistant application with AI integration and real-time system monitoring capabilities, optimized for Intel Mac architecture.

## Features

### 🎨 Modern UI
- Clean, native macOS interface built with SwiftUI
- Real-time system status display (CPU and Memory usage)
- Interactive chat interface with AI assistant
- Animated status indicators
- Dark mode support

### 🤖 AI Integration
- **Multiple AI Models**: Support for 8 AI providers including OpenAI GPT, Anthropic Claude, xAI Grok, GitHub Copilot, Google Gemini, Perplexity AI, Mistral AI, and Local AI
- **Automatic Fallback**: Intelligently switches between providers based on availability
- **Dynamic Response System**: Context-aware AI responses based on real-time data
- **Context Analysis**: Intelligent conversation analysis to understand user intent
- **Real-time Data Processing**: Integrates live system metrics into responses
- **Conversation History**: Maintains context across multiple interactions

### 💻 Intel Mac Compatibility
- Optimized for Intel x86_64 architecture
- Native system monitoring for Intel-based Macs
- CPU and memory usage tracking
- Architecture detection and reporting

### 🔧 System Monitoring
- Real-time CPU usage monitoring
- Memory usage tracking
- System architecture detection
- Performance metrics integration

## Architecture

The application is structured with clean separation of concerns:

```
PowninAssistant/
├── PowninAssistantApp.swift    # Application entry point
├── Views/
│   └── ContentView.swift        # Main UI components
├── Models/
│   └── Message.swift            # Data models
└── Services/
    ├── AIService.swift          # AI integration and response generation
    ├── AIModelProvider.swift    # AI model provider protocol
    ├── OpenAIProvider.swift     # OpenAI GPT integration
    ├── AnthropicProvider.swift  # Anthropic Claude integration
    ├── GrokProvider.swift       # xAI Grok integration
    ├── CopilotProvider.swift    # GitHub Copilot integration
    ├── GeminiProvider.swift     # Google Gemini integration
    ├── PerplexityProvider.swift # Perplexity AI integration
    ├── MistralProvider.swift    # Mistral AI integration
    ├── LocalAIProvider.swift    # Local rule-based AI (fallback)
    ├── SystemMonitor.swift      # Real-time system monitoring
    └── ContextAnalyzer.swift    # Context analysis for AI
```

## Requirements

- macOS 13.0 or later
- Intel Mac (x86_64 architecture)
- Xcode 14.0 or later
- Swift 5.9 or later
- (Optional) API keys for any of the 7 supported AI providers

## AI Model Setup

Pownin Assistant supports 8 AI model providers. See [AI_MODELS.md](AI_MODELS.md) for detailed configuration.

### Quick Setup

```bash
# Configure any or all of these AI providers:
export OPENAI_API_KEY="your-openai-key"
export ANTHROPIC_API_KEY="your-anthropic-key"
export XAI_API_KEY="your-xai-key"
export GITHUB_TOKEN="your-github-token"
export GEMINI_API_KEY="your-gemini-key"
export PERPLEXITY_API_KEY="your-perplexity-key"
export MISTRAL_API_KEY="your-mistral-key"

# Run the application
swift run
```

The application works without API keys using the local AI fallback.

## Building

### Using Swift Package Manager

```bash
cd PowninAssistant
swift build -c release --arch x86_64
```

### Running

```bash
swift run
```

## AI Capabilities

The AI assistant provides:

1. **Real-time System Insights**: Queries about CPU and memory usage are answered with current data
2. **Context-Aware Responses**: The AI considers conversation history and system state
3. **Dynamic Intelligence**: Responses adapt based on real-time system metrics
4. **Natural Language Understanding**: Recognizes user intent and provides relevant information

### Example Interactions

- "What's my CPU usage?" → Provides current CPU percentage with contextual advice
- "Check system status" → Comprehensive system overview with metrics
- "Tell me about memory" → Memory usage analysis with recommendations
- "Help" → Lists available capabilities and features

## CI/CD Workflow

The project includes a GitHub Actions workflow that:

1. **Builds** the application for Intel Mac architecture
2. **Verifies** AI integration components
3. **Tests** system monitoring capabilities
4. **Packages** distribution builds for release

## Technical Details

### Intel Mac Optimization

The application is specifically built for Intel Mac compatibility:
- Uses x86_64 architecture flags in build process
- Native system calls optimized for Intel processors
- Direct access to Intel-specific CPU metrics
- Memory management tuned for Intel architecture

### AI Integration Workflow

1. **Input Processing**: User messages are captured and stored
2. **Context Gathering**: Real-time system data and conversation history collected
3. **Intent Analysis**: ContextAnalyzer determines user intent and extracts keywords
4. **Response Generation**: AI generates context-aware, data-driven responses
5. **Display**: Formatted response shown with timestamp and context

## License

MIT License - see LICENSE file for details

## Author

Sumit Duster

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.