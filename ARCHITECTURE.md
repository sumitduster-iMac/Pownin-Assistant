# Pownin Assistant - Technical Architecture

## System Architecture

The Pownin Assistant is built with a clean, modular architecture following SOLID principles and SwiftUI best practices.

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    User Interface                        │
│                  (SwiftUI Views)                         │
├─────────────────────────────────────────────────────────┤
│                   View Models                            │
│              (@StateObject/@Published)                   │
├─────────────────────────────────────────────────────────┤
│                  Service Layer                           │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐   │
│  │  AIService   │ │SystemMonitor │ │ContextAnalyzer│   │
│  └──────────────┘ └──────────────┘ └──────────────┘   │
├─────────────────────────────────────────────────────────┤
│                   Data Models                            │
│          (Message, SystemState, Context)                 │
├─────────────────────────────────────────────────────────┤
│              System APIs (Darwin/Foundation)             │
└─────────────────────────────────────────────────────────┘
```

## Component Details

### 1. Application Layer

**PowninAssistantApp.swift**
- Entry point using `@main`
- Initializes `AIService` as a `@StateObject`
- Configures window properties (minimum size, style)
- Provides global environment objects

### 2. UI Layer

**ContentView.swift**
- Main view coordinator
- Manages user input state
- Handles message sending logic
- Integrates all sub-views

**Sub-Views:**
- `HeaderView`: System metrics and status display
- `MessageBubbleView`: Individual message display
- `InputAreaView`: User input interface
- `StatusIndicatorView`: AI status animation
- `SystemInfoLabel`: Metric display component

### 3. Service Layer

#### AIService.swift
**Responsibilities:**
- Message processing and management
- Context gathering from system
- Response generation
- State management (`@Published` properties)

**Key Methods:**
- `processMessage(_:)`: Main entry point for user input
- `gatherContext()`: Collects real-time system data
- `generateResponse(for:context:)`: Creates intelligent responses

**AI Workflow:**
```
User Input → Add to Messages → Gather Context
    ↓
System Data + Conversation History
    ↓
Context Analysis → Intent Detection
    ↓
Response Generation → AI Message → Display
```

#### SystemMonitor.swift
**Responsibilities:**
- Real-time CPU usage monitoring
- Memory usage tracking
- System architecture detection
- Intel Mac compatibility verification

**Key Methods:**
- `getCPUUsage()`: Returns current CPU percentage
- `getMemoryUsage()`: Returns current memory percentage
- `getArchitecture()`: Returns system architecture string
- `isIntelMac()`: Verifies Intel x86_64 architecture

**Implementation Details:**
- Uses Darwin framework for system calls
- Direct access to `host_processor_info` for CPU data
- `vm_statistics64` for memory information
- Proper memory management with `vm_deallocate`

#### ContextAnalyzer.swift
**Responsibilities:**
- Conversation history analysis
- Topic extraction
- Intent determination
- Keyword extraction

**Key Methods:**
- `analyzeConversation(_:)`: Analyzes message history
- `determineIntent(_:)`: Identifies user intent
- `extractKeywords(_:)`: Extracts relevant keywords

### 4. Data Layer

**Models/Message.swift**
- `Message`: Core message structure
  - `id`: Unique identifier
  - `content`: Message text
  - `isUser`: Message source
  - `timestamp`: Creation time
  - `context`: Associated context data

- `MessageContext`: Contextual information
  - `systemState`: System metrics snapshot
  - `relevantData`: Additional context data

- `SystemState`: System metrics snapshot
  - `cpuUsage`: CPU percentage at time
  - `memoryUsage`: Memory percentage at time
  - `timestamp`: Capture time

## Intel Mac Compatibility

### Architecture Support
- **Build Target**: x86_64 (Intel 64-bit)
- **Minimum macOS**: 13.0 (Ventura)
- **Swift Version**: 5.9+

### System Integration
1. **CPU Monitoring**:
   - Uses `host_processor_info` with `PROCESSOR_CPU_LOAD_INFO`
   - Calculates average across all CPU cores
   - Handles Intel multi-core architectures

2. **Memory Monitoring**:
   - Uses `host_statistics64` with `HOST_VM_INFO64`
   - Accounts for active, wired, and compressed memory
   - Reads total physical memory via `sysctlbyname`

3. **Architecture Detection**:
   - Uses `uname` system call
   - Verifies x86_64 architecture
   - Provides compatibility checking

## AI Integration Workflow

### 1. Input Processing
```swift
User Message → AIService.processMessage()
    ↓
Store in conversation history
    ↓
Trigger UI update (@Published)
```

### 2. Context Gathering
```swift
gatherContext()
    ↓
SystemMonitor.getCPUUsage()
SystemMonitor.getMemoryUsage()
    ↓
ContextAnalyzer.analyzeConversation()
    ↓
Build MessageContext object
```

### 3. Response Generation
```swift
generateResponse(for: input, context: context)
    ↓
Analyze input keywords
    ↓
Match against knowledge base
    ↓
Incorporate real-time data
    ↓
Generate contextual response
```

### 4. Response Types

**System Queries:**
- CPU usage requests → Real-time CPU data + analysis
- Memory queries → Current memory usage + recommendations
- Status checks → Comprehensive system overview

**Conversational:**
- Greetings → Personalized responses
- Help requests → Capability listings
- General queries → Context-aware assistance

**Intelligence Features:**
- Real-time data integration
- Conversation history awareness
- Intent-based response selection
- Proactive recommendations based on metrics

## Concurrency Model

### Async/Await
- `AIService.processMessage(_:)` is async
- Context gathering runs asynchronously
- Response generation simulates async processing
- UI updates dispatched to main actor

### Main Actor
- `AIService` marked with `@MainActor`
- All UI updates occur on main thread
- Thread-safe state management

### Timers
- `Timer.scheduledTimer` for periodic updates
- 2-second interval for system monitoring
- Updates CPU and memory metrics

## Build Configuration

### Package.swift
```swift
Platform: macOS 13.0+
Language: Swift 5.9+
Architecture: x86_64
Dependencies: None (native frameworks only)
```

### Build Flags
- `-Xfrontend -warn-concurrency`: Enable concurrency warnings
- `--arch x86_64`: Explicit Intel architecture

### Excluded Files
- Info.plist (not needed for SPM)
- Assets.xcassets (SwiftUI handles resources)

## CI/CD Pipeline

### GitHub Actions Workflow

**Jobs:**
1. **build-intel-mac**
   - Runs on macOS 13 (Intel compatible)
   - Builds with x86_64 architecture flag
   - Archives build artifacts

2. **ai-integration-check**
   - Verifies AI service files exist
   - Checks for required methods
   - Validates system monitor implementation

3. **deployment**
   - Creates release builds
   - Packages for distribution
   - Uploads artifacts

## Security Considerations

### System Access
- Read-only system monitoring
- No privileged operations required
- No network access (local AI)
- No file system modifications

### Data Privacy
- All data processed locally
- No external API calls
- Conversation history in-memory only
- No data persistence (privacy-first)

## Performance Optimization

### Memory Management
- Lazy loading of conversation history
- Proper VM memory deallocation
- Efficient state updates

### CPU Efficiency
- 2-second polling interval (balanced)
- Fallback to simulated data if APIs fail
- Optimized SwiftUI view updates

### Rendering
- LazyVStack for efficient scrolling
- View identity optimization
- Minimal re-renders

## Extensibility

### Adding New AI Capabilities
1. Extend `AIService.generateResponse()`
2. Add new pattern matching
3. Integrate additional context sources

### System Monitoring Extensions
1. Add new methods to `SystemMonitor`
2. Update `SystemState` model
3. Incorporate into `MessageContext`

### UI Customization
1. Modify view components
2. Update color scheme
3. Add new interaction patterns

## Future Enhancements

- [ ] Persistent conversation history
- [ ] External AI API integration
- [ ] More system metrics (disk, network)
- [ ] Custom AI model training
- [ ] Multi-language support
- [ ] Voice interaction
- [ ] Plugin system
