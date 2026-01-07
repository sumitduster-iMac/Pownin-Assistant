# Pownin-Assistant

An intelligent cross-platform assistant with AI integration and real-time system monitoring. Available as both a native macOS Swift app and an Electron cross-platform app.

## Features

### 🎨 Modern UI
- Clean, native interface with sidebar navigation
- Real-time system status display (CPU and Memory)
- Interactive chat with AI assistant
- Animated status indicators and dark mode support

### 🤖 AI Integration
- **8 AI Providers**: OpenAI GPT, Anthropic Claude, xAI Grok, GitHub Copilot, Google Gemini, Perplexity, Mistral, Local AI
- **Automatic Fallback**: Switches providers based on availability
- **Context-Aware**: Uses real-time system metrics in responses

### 💻 Cross-Platform
- **Swift**: Native macOS app optimized for Intel x86_64
- **Electron**: Cross-platform support for macOS, Windows, Linux

### 🚀 Railway Integration
- Monitor Railway deployments
- Trigger deploys from the app
- View project status and logs

## Quick Start

### Swift macOS App

```bash
swift build -c release --arch x86_64
swift run
```

### Electron App

```bash
cd electron-app
npm install
npm start
```

See [QUICK_START.md](QUICK_START.md) for detailed instructions.

## Architecture

```
PowninAssistant/           # Swift macOS app
├── Views/
│   ├── ContentView.swift  # Main UI with sidebar
│   ├── WebView.swift      # Web content display
│   └── RailwayApp.swift   # Railway integration
├── Services/
│   ├── AIService.swift    # AI orchestration
│   └── SystemMonitor.swift
└── Models/

electron-app/              # Cross-platform Electron app
├── main.js
├── index.html
├── styles.css
└── package.json
```

## AI Model Setup

Configure any or all providers (see [AI_MODELS.md](AI_MODELS.md)):

```bash
export OPENAI_API_KEY="your-key"
export ANTHROPIC_API_KEY="your-key"
```

Works without API keys using local AI fallback.

## Requirements

- **Swift App**: macOS 13.0+, Xcode 14+, Swift 5.9+
- **Electron App**: Node.js 18+, npm 9+

## Development

### Build Swift App
```bash
swift build -c release --arch x86_64
```

### Build Electron App
```bash
cd electron-app
npm install
npm run build
npm run package
```

### Generate App Icons
```bash
swift scripts/generate_app_icons.swift source-icon.png ./output
node scripts/generate-icons.mjs
```

## CI/CD

GitHub Actions workflows for:
- Swift build and test on Intel Mac
- Electron builds for all platforms
- Security audits and linting

## License

MIT License - see [LICENSE](LICENSE)

## Author

Sumit Duster

## Contributing

Contributions welcome! Please submit a Pull Request.
