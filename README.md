<div align="center">

<img src="PowninAssistant/Assets.xcassets/AppIcon.appiconset/icon.svg" alt="Pownin Assistant Icon" width="200" height="200">

# Pownin Assistant

### An Intelligent Cross-Platform AI Assistant

*Seamlessly integrates 8 AI providers with real-time system monitoring*

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![macOS](https://img.shields.io/badge/macOS-13.0+-blue.svg)](https://www.apple.com/macos)
[![Node.js](https://img.shields.io/badge/Node.js-18+-green.svg)](https://nodejs.org)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

[Quick Start](#quick-start) • [Features](#features) • [AI Models](AI_MODELS.md) • [Documentation](#documentation)

</div>

---

## 🌟 Overview

Pownin Assistant is a powerful, intelligent assistant that brings advanced AI capabilities to your desktop. Available as both a **native macOS Swift application** and a **cross-platform Electron app**, it seamlessly integrates with multiple AI providers while providing real-time system monitoring and Railway deployment management.

## ✨ Features

<table>
<tr>
<td width="50%">

### 🎨 Modern UI
- ✅ Clean, native interface with sidebar navigation
- 📊 Real-time system status display (CPU and Memory)
- 💬 Interactive chat with AI assistant
- 🌙 Animated status indicators and dark mode support

### 🤖 AI Integration
- **8 AI Providers**: OpenAI GPT, Anthropic Claude, xAI Grok, GitHub Copilot, Google Gemini, Perplexity, Mistral, Local AI
- **Automatic Fallback**: Intelligent provider switching based on availability
- **Context-Aware**: Uses real-time system metrics in responses
- **Smart Error Handling**: Graceful degradation and fallback mechanisms

</td>
<td width="50%">

### 💻 Cross-Platform Support
- **Swift**: Native macOS Universal app
  - ✅ Intel x86_64 architecture
  - ✅ Apple Silicon arm64 architecture
  - ✅ Universal binary support
- **Electron**: Cross-platform desktop app
  - 🍎 macOS (Universal)
  - 🪟 Windows
  - 🐧 Linux

### 🚀 Railway Integration
- 📦 Monitor Railway deployments
- 🚀 Trigger deploys from the app
- 📋 View project status and logs in real-time

</td>
</tr>
</table>

## 🚀 Quick Start

### Swift macOS App (Universal Binary)

```bash
# Clone the repository
git clone https://github.com/sumitduster-iMac/Pownin-Assistant.git
cd Pownin-Assistant

# Build Universal binary (Intel + Apple Silicon) - Recommended
make build-universal

# Or build for specific architecture
make build-intel    # Intel Mac (x86_64)
make build-arm      # Apple Silicon Mac (arm64)

# Run the application
swift run
```

### Electron Cross-Platform App

```bash
# Navigate to electron app directory
cd electron-app

# Install dependencies
npm install

# Start the application
npm start

# Package for distribution (optional)
npm run package:mac      # macOS (Universal: x64 + arm64)
npm run package:win      # Windows
npm run package:linux    # Linux
```

> 💡 **Tip**: See [QUICK_START.md](QUICK_START.md) for detailed installation instructions and troubleshooting.

## 🏗️ Architecture

```
📁 PowninAssistant/              # Swift macOS Application
├── 📂 Views/
│   ├── ContentView.swift        # Main UI with sidebar navigation
│   ├── WebView.swift            # Web content display
│   └── RailwayApp.swift         # Railway integration UI
├── 📂 Services/
│   ├── AIService.swift          # AI orchestration & provider management
│   ├── SystemMonitor.swift      # Real-time system metrics
│   └── [8 AI Providers]         # OpenAI, Claude, Grok, etc.
└── 📂 Models/
    └── Data models & types

📁 electron-app/                 # Cross-Platform Electron App
├── main.js                      # Main process
├── index.html                   # UI markup
├── styles.css                   # Styling
└── package.json                 # Dependencies & scripts
```

## 🤖 AI Model Setup

Pownin Assistant supports **8 different AI providers** with automatic fallback. Configure any or all providers to unlock advanced AI capabilities!

```bash
# Configure your preferred AI providers
export OPENAI_API_KEY="sk-..."              # OpenAI GPT-3.5/GPT-4
export ANTHROPIC_API_KEY="sk-ant-..."      # Anthropic Claude
export XAI_API_KEY="xai-..."               # xAI Grok
export GITHUB_TOKEN="ghp_..."              # GitHub Copilot
export GEMINI_API_KEY="..."                # Google Gemini
export PERPLEXITY_API_KEY="..."            # Perplexity AI
export MISTRAL_API_KEY="..."               # Mistral AI
```

### Priority Order
1. **OpenAI GPT** → 2. **Anthropic Claude** → 3. **xAI Grok** → 4. **GitHub Copilot** → 5. **Google Gemini** → 6. **Perplexity** → 7. **Mistral** → 8. **Local AI** (Fallback)

> 🎯 **Works without API keys!** The application automatically falls back to a built-in Local AI system.

📖 See [AI_MODELS.md](AI_MODELS.md) for detailed setup instructions, pricing, and best practices.

## 📋 Requirements

### Swift macOS Application
- **macOS**: 13.0 or later (Ventura+)
- **Xcode**: 14.0 or later
- **Swift**: 5.9 or later
- **Architecture**: Universal binary support (Intel x86_64 & Apple Silicon arm64)

### Electron Cross-Platform Application
- **Node.js**: 18.0 or later
- **npm**: 9.0 or later
- **Platforms**: 
  - 🍎 macOS (Universal: Intel & Apple Silicon)
  - 🪟 Windows 10/11
  - 🐧 Linux (Ubuntu, Debian, Fedora, etc.)

## 🛠️ Development

### Building the Swift App

```bash
# Build Universal binary (Recommended for distribution)
make build-universal

# Build for specific architectures
make build-intel      # Intel Mac (x86_64)
make build-arm        # Apple Silicon Mac (arm64)

# Verify the binary architecture
make check-arch

# Run tests
make test

# Clean build artifacts
make clean
```

### Building the Electron App

```bash
cd electron-app

# Install dependencies
npm install

# Development mode with hot reload
npm start

# Build for production
npm run build

# Package for all platforms
npm run package:mac      # macOS (Universal: x64 + arm64)
npm run package:win      # Windows
npm run package:linux    # Linux
```

### Generate App Icons

```bash
# Generate macOS app icons from source
swift scripts/generate_app_icons.swift source-icon.png ./output

# Generate Electron app icons
node scripts/generate-icons.mjs
```

## 🔄 CI/CD

GitHub Actions workflows automatically handle:

- ✅ **Swift Build & Test**: Automated testing on Intel Mac runners
- 📦 **Multi-Platform Builds**: Electron builds for macOS, Windows, and Linux
- 🔒 **Security Audits**: Automated security scanning and dependency checks
- 🎨 **Code Linting**: Code quality and style enforcement
- 🚀 **Automated Releases**: Tagged releases with artifacts

All workflows run on every push and pull request to ensure code quality and reliability.

## 📚 Documentation

Comprehensive documentation is available for all aspects of the project:

- 📖 [**QUICK_START.md**](QUICK_START.md) - Get started in under 5 minutes
- 🤖 [**AI_MODELS.md**](AI_MODELS.md) - Complete AI provider setup and configuration guide
- 🏗️ [**ARCHITECTURE.md**](ARCHITECTURE.md) - Detailed system architecture and design
- 🔨 [**BUILDING.md**](BUILDING.md) - Build instructions and troubleshooting
- 🎨 [**UI_DESIGN.md**](UI_DESIGN.md) - UI/UX design principles and guidelines
- 📋 [**PROJECT_SUMMARY.md**](PROJECT_SUMMARY.md) - Project overview and roadmap

## 🤝 Contributing

Contributions are welcome and appreciated! Here's how you can help:

1. 🍴 **Fork the repository**
2. 🌱 **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. 💡 **Make your changes**
4. ✅ **Test thoroughly**
5. 📝 **Commit your changes** (`git commit -m 'Add amazing feature'`)
6. 🚀 **Push to the branch** (`git push origin feature/amazing-feature`)
7. 🎉 **Open a Pull Request**

Please ensure your code follows the existing style and includes appropriate tests.

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```
MIT License - Free to use, modify, and distribute
```

## 👤 Author

**Sumit Duster**

- GitHub: [@sumitduster-iMac](https://github.com/sumitduster-iMac)
- Project: [Pownin-Assistant](https://github.com/sumitduster-iMac/Pownin-Assistant)

## 🙏 Acknowledgments

- Built with Swift and Electron
- Powered by OpenAI, Anthropic, Google, and other AI providers
- Thanks to all contributors and the open-source community

---

<div align="center">

**⭐ Star this repository if you find it helpful!**

Made with ❤️ by Sumit Duster

</div>
