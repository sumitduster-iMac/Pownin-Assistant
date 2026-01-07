# AI Model Integration Guide

Pownin Assistant now supports multiple AI model providers with automatic fallback. The application intelligently switches between available models to provide the best possible responses.

## Supported AI Models

### 1. OpenAI GPT
- **Models**: GPT-3.5-turbo, GPT-4, GPT-4-turbo
- **Best for**: General conversations, complex reasoning
- **Setup**: Requires OpenAI API key (`OPENAI_API_KEY`)

### 2. Anthropic Claude
- **Models**: Claude 3 Haiku, Claude 3 Sonnet, Claude 3 Opus
- **Best for**: Detailed analysis, creative tasks, long context
- **Setup**: Requires Anthropic API key (`ANTHROPIC_API_KEY`)

### 3. xAI Grok
- **Models**: Grok Beta, Grok-2
- **Best for**: Real-time information, conversational AI
- **Setup**: Requires xAI API key (`XAI_API_KEY`)

### 4. GitHub Copilot
- **Models**: GPT-4o via GitHub Models
- **Best for**: Code-related queries, developer assistance
- **Setup**: Requires GitHub token (`GITHUB_TOKEN`)

### 5. Google Gemini
- **Models**: Gemini Pro, Gemini Pro Vision
- **Best for**: Multimodal tasks, Google ecosystem integration
- **Setup**: Requires Google API key (`GEMINI_API_KEY`)

### 6. Perplexity AI
- **Models**: Llama 3.1 Sonar models
- **Best for**: Research, fact-checking, online information
- **Setup**: Requires Perplexity API key (`PERPLEXITY_API_KEY`)

### 7. Mistral AI
- **Models**: Mistral Small, Mistral Medium, Mistral Large
- **Best for**: European data privacy, multilingual support
- **Setup**: Requires Mistral API key (`MISTRAL_API_KEY`)

### 8. Local AI (Fallback)
- **Type**: Rule-based system
- **Best for**: System monitoring queries, basic interactions
- **Setup**: Always available, no configuration needed

## Configuration

### Setting Up OpenAI

1. Get your API key from [OpenAI Platform](https://platform.openai.com/api-keys)

2. Set the environment variable:

```bash
export OPENAI_API_KEY="your-api-key-here"
```

3. Or add to your shell profile (~/.zshrc or ~/.bash_profile):

```bash
echo 'export OPENAI_API_KEY="your-api-key-here"' >> ~/.zshrc
source ~/.zshrc
```

### Setting Up Anthropic Claude

1. Get your API key from [Anthropic Console](https://console.anthropic.com/)

2. Set the environment variable:

```bash
export ANTHROPIC_API_KEY="your-api-key-here"
```

3. Or add to your shell profile:

```bash
echo 'export ANTHROPIC_API_KEY="your-api-key-here"' >> ~/.zshrc
source ~/.zshrc
```

### Setting Up xAI Grok

1. Get your API key from [xAI Console](https://console.x.ai/)

2. Set the environment variable:

```bash
export XAI_API_KEY="your-api-key-here"
```

### Setting Up GitHub Copilot

1. Get your GitHub token with Copilot access from [GitHub Settings](https://github.com/settings/tokens)

2. Set the environment variable:

```bash
export GITHUB_TOKEN="your-github-token"
```

### Setting Up Google Gemini

1. Get your API key from [Google AI Studio](https://makersuite.google.com/app/apikey)

2. Set the environment variable:

```bash
export GEMINI_API_KEY="your-api-key-here"
```

### Setting Up Perplexity AI

1. Get your API key from [Perplexity AI](https://www.perplexity.ai/settings/api)

2. Set the environment variable:

```bash
export PERPLEXITY_API_KEY="your-api-key-here"
```

### Setting Up Mistral AI

1. Get your API key from [Mistral Console](https://console.mistral.ai/)

2. Set the environment variable:

```bash
export MISTRAL_API_KEY="your-api-key-here"
```
```

### Running with API Keys

After setting environment variables, run the application:

```bash
# Make sure environment variables are set
env | grep -E "OPENAI_API_KEY|ANTHROPIC_API_KEY|XAI_API_KEY|GITHUB_TOKEN|GEMINI_API_KEY|PERPLEXITY_API_KEY|MISTRAL_API_KEY"

# Run the application
swift run
```

Or using the Makefile:

```bash
make run
```

## How It Works

### Automatic Provider Selection

The application automatically selects the best available AI model in this priority order:

1. **OpenAI GPT** - If API key is configured
2. **Anthropic Claude** - If API key is configured
3. **xAI Grok** - If API key is configured
4. **GitHub Copilot** - If GitHub token is configured
5. **Google Gemini** - If API key is configured
6. **Perplexity AI** - If API key is configured
7. **Mistral AI** - If API key is configured
8. **Local AI** - Always available as fallback

### Smart Fallback

If a provider fails (network error, rate limit, etc.), the system automatically tries the next available provider.

### Current Model Display

The UI header shows which AI model is currently active:
```
🧠 OpenAI GPT         (when OpenAI is available)
🧠 Anthropic Claude   (when Claude is available)
🧠 xAI Grok          (when Grok is available)
🧠 GitHub Copilot    (when Copilot is available)
🧠 Google Gemini     (when Gemini is available)
🧠 Perplexity AI     (when Perplexity is available)
🧠 Mistral AI        (when Mistral is available)
🧠 Local AI          (fallback mode)
```

## Example Responses

### With Advanced AI Models (OpenAI/Claude)

**User:** "Explain quantum computing in simple terms"

**AI (GPT/Claude):** "Quantum computing is like having a super-powered calculator that can explore many possibilities simultaneously. Instead of processing information as traditional bits (0s and 1s), it uses quantum bits or 'qubits' that can be both 0 and 1 at the same time..."

### With Local AI

**User:** "What's my CPU usage?"

**AI (Local):** "Your CPU is currently at 45.2% usage. That's a healthy usage level."

## Features

### Context-Aware Responses

All AI models receive:
- Current system state (CPU, Memory)
- Conversation history
- User intent analysis
- Real-time metrics

Example system message sent to AI:
```
You are Pownin Assistant, an intelligent macOS assistant optimized for Intel Mac.

Current system state:
- CPU Usage: 45.2%
- Memory Usage: 62.1%
- Architecture: Intel x86_64

Provide helpful, concise responses.
```

### Rate Limiting Protection

The application handles rate limits gracefully:
- Catches 429 (Too Many Requests) errors
- Automatically falls back to alternative providers
- Displays informative error messages

### Error Handling

All providers include robust error handling:
- Invalid API keys
- Network errors
- Timeout protection
- Invalid responses
- Rate limiting

## Testing AI Integration

### Check Available Models

Run the application and look at the welcome message. It will list all available models:

```
Available AI models:
• OpenAI GPT ✓
• Anthropic Claude ✓
• Local AI ✓
```

The ✓ indicates the model is configured and ready to use.

### Test Queries

Try these queries to test different providers:

1. **System queries** (handled by all models):
   - "What's my CPU usage?"
   - "Check system status"

2. **Complex queries** (better with GPT/Claude):
   - "Explain the difference between Intel and ARM architectures"
   - "What are best practices for optimizing macOS performance?"

3. **Conversational** (all models):
   - "Hello"
   - "Help"

## API Costs

### OpenAI Pricing (approximate, check current rates)
- GPT-3.5-turbo: ~$0.002 per 1K tokens
- GPT-4: ~$0.03 per 1K tokens (input)

### Anthropic Pricing (approximate, check current rates)
- Claude 3 Haiku: ~$0.0003 per 1K tokens
- Claude 3 Sonnet: ~$0.003 per 1K tokens

**Note:** Pricing may change. Check provider websites for current rates.

### Cost Estimation

Each query typically uses:
- System context: ~100 tokens
- User query: 10-50 tokens
- AI response: 50-200 tokens
- **Total: ~200-350 tokens per interaction**

Example monthly cost (100 interactions/day):
- With GPT-3.5: ~$0.60/month
- With Claude Haiku: ~$0.09/month
- With Local AI: Free

## Troubleshooting

### "Invalid API key" Error

**Problem**: AI model shows as unavailable

**Solution**:
1. Check environment variable is set: `echo $OPENAI_API_KEY`
2. Verify key is correct (no extra spaces)
3. Restart application after setting variable

### "Rate limit exceeded" Error

**Problem**: Too many requests to AI API

**Solution**:
- Application automatically falls back to alternative provider
- Wait a few minutes before retrying
- Consider upgrading API plan

### Network Errors

**Problem**: "Network error" message

**Solution**:
- Check internet connection
- Verify API endpoint is accessible
- Try alternative provider

### All Providers Fail

**Problem**: Only local AI responses

**Solution**:
- Check API keys are configured
- Verify internet connectivity
- Check API service status pages

## Security Best Practices

1. **Never commit API keys** to version control
2. **Use environment variables** for sensitive data
3. **Rotate keys regularly** for security
4. **Set spending limits** on AI provider accounts
5. **Monitor usage** through provider dashboards

## Advanced Configuration

### Custom Models

You can modify the providers in `AIService.swift` to use different models:

```swift
// For OpenAI
OpenAIProvider(model: "gpt-4")  // Use GPT-4 instead of GPT-3.5

// For Anthropic
AnthropicProvider(model: "claude-3-opus-20240229")  // Use Opus instead of Haiku
```

### Custom Providers

To add a new AI provider:

1. Create a new file implementing `AIModelProvider` protocol
2. Add it to the providers list in `AIService.swift`
3. Follow the existing pattern for error handling

## Verification

Check that AI integration is working:

```bash
# Verify environment variables
make verify-ai

# Check which models are available in the app
# Look at the welcome message when app starts
```

## Support

For issues with:
- **OpenAI**: Visit [OpenAI Help Center](https://help.openai.com)
- **Anthropic**: Visit [Anthropic Support](https://www.anthropic.com/support)
- **Local AI**: Check application logs

---

**Note**: All AI models integrate seamlessly with the existing real-time system monitoring and context-aware features. Your conversations are enhanced with live system metrics regardless of which AI provider is active.
