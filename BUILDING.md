# Building Pownin Assistant

This guide provides detailed instructions for building the Pownin Assistant application for Intel Mac.

## Prerequisites

### System Requirements
- **Operating System**: macOS 13.0 (Ventura) or later
- **Architecture**: Intel Mac (x86_64)
- **Xcode**: Version 14.0 or later
- **Swift**: Version 5.9 or later
- **Command Line Tools**: Xcode Command Line Tools installed

### Verify Prerequisites

```bash
# Check macOS version
sw_vers

# Check system architecture
uname -m
# Should output: x86_64

# Check Swift version
swift --version
# Should be 5.9 or later

# Check Xcode version
xcodebuild -version
# Should be 14.0 or later
```

### Install Prerequisites

If you don't have Xcode Command Line Tools installed:

```bash
xcode-select --install
```

## Building Methods

### Method 1: Using Makefile (Recommended)

The project includes a Makefile with convenient commands.

#### Build for Release (Intel Mac)

```bash
make build
```

This executes: `swift build -c release --arch x86_64`

#### Build for Debug

```bash
make build-debug
```

This executes: `swift build --arch x86_64`

#### View All Make Commands

```bash
make help
```

Output:
```
Pownin Assistant - Makefile Commands
=====================================
build           Build the application for Intel Mac (x86_64)
build-debug     Build in debug mode
run             Run the application
test            Run tests
clean           Clean build artifacts
verify-ai       Verify AI integration components
check-arch      Display system architecture information
package         Create distribution package
help            Display this help message
```

### Method 2: Using Swift Package Manager Directly

#### Build for Release

```bash
swift build -c release --arch x86_64
```

#### Build for Debug

```bash
swift build --arch x86_64
```

#### Run the Application

```bash
swift run
```

### Method 3: Using Xcode

While the project is set up with Swift Package Manager, you can also open it in Xcode:

1. Open Terminal and navigate to project directory
2. Generate Xcode project:
   ```bash
   swift package generate-xcodeproj
   ```
3. Open the generated `.xcodeproj` file
4. Select the target and run (⌘R)

**Note**: Ensure the build architecture is set to x86_64 in Xcode build settings.

## Build Output

### Location

Build artifacts are placed in the `.build` directory:

```
.build/
├── debug/              # Debug builds
│   └── PowninAssistant
└── release/            # Release builds
    └── PowninAssistant
```

### Binary

The built binary is located at:
- Debug: `.build/debug/PowninAssistant`
- Release: `.build/release/PowninAssistant`

### Running the Binary

```bash
# Run debug build
.build/debug/PowninAssistant

# Run release build
.build/release/PowninAssistant
```

## Verification

### Verify AI Integration

Before running, verify all AI components are properly implemented:

```bash
make verify-ai
```

Expected output:
```
Verifying AI integration...
✓ AIService.swift found
✓ processMessage method exists
✓ gatherContext method exists
✓ generateResponse method exists
✓ SystemMonitor.swift found
✓ getCPUUsage method exists
✓ getMemoryUsage method exists
✓ ContextAnalyzer.swift found
✓ analyzeConversation method exists
✓ All AI integration components verified
```

### Check System Architecture

Verify you're on an Intel Mac:

```bash
make check-arch
```

Expected output:
```
System Architecture Information:
================================
x86_64
```

## Troubleshooting

### Issue: "No such module 'SwiftUI'"

**Cause**: SwiftUI is not available (wrong platform or old macOS version)

**Solution**: 
- Ensure you're on macOS 13.0 or later
- Update Xcode to version 14.0 or later
- Run: `xcode-select --install`

### Issue: "Build failed for architecture x86_64"

**Cause**: Build settings might not be correct

**Solution**:
```bash
# Clean and rebuild
make clean
make build
```

### Issue: "Command Line Tools not found"

**Cause**: Xcode Command Line Tools not installed

**Solution**:
```bash
xcode-select --install
```

Then restart Terminal and try again.

### Issue: "Swift version too old"

**Cause**: Swift version is older than 5.9

**Solution**:
- Update Xcode to the latest version
- Or install Swift from swift.org

### Issue: "Cannot run on Apple Silicon Mac"

**Cause**: This build is specifically for Intel Mac (x86_64)

**Solution**:
For Apple Silicon, you would need to:
1. Remove `--arch x86_64` flags
2. Or use Rosetta 2 to run the Intel build

To check your Mac type:
```bash
uname -m
# x86_64 = Intel Mac
# arm64 = Apple Silicon
```

## Testing

### Run Tests

```bash
make test
```

Or directly:
```bash
swift test --arch x86_64
```

### Manual Testing

After building, run the application and test:

1. **Launch**: Run the binary
2. **Check UI**: Verify the interface loads
3. **Check Metrics**: Verify CPU and memory percentages update
4. **Test AI**: Send a message like "What's my CPU usage?"
5. **Verify Response**: AI should respond with real-time data

## Packaging for Distribution

### Create Distribution Package

```bash
make package
```

This creates: `PowninAssistant-Intel-Mac.tar.gz`

### Manual Packaging

```bash
# Build release version
swift build -c release --arch x86_64

# Create package
mkdir -p dist
cp .build/release/PowninAssistant dist/
tar -czf PowninAssistant-Intel-Mac.tar.gz -C dist .
rm -rf dist
```

### Distribution Package Contents

```
PowninAssistant-Intel-Mac.tar.gz
└── PowninAssistant  (Intel x86_64 binary)
```

### Installing from Package

```bash
# Extract
tar -xzf PowninAssistant-Intel-Mac.tar.gz

# Run
./PowninAssistant
```

## Clean Build

### Clean All Build Artifacts

```bash
make clean
```

Or directly:
```bash
swift package clean
rm -rf .build
```

This removes:
- `.build/` directory
- All build artifacts
- Package resolved dependencies

## Build Configurations

### Debug Build

- **Optimization**: None (-Onone)
- **Debug Info**: Included
- **Size**: Larger
- **Speed**: Slower
- **Use Case**: Development and debugging

```bash
swift build --arch x86_64
```

### Release Build

- **Optimization**: Full (-O)
- **Debug Info**: Stripped
- **Size**: Smaller
- **Speed**: Faster
- **Use Case**: Distribution

```bash
swift build -c release --arch x86_64
```

## Build Flags Explained

### `--arch x86_64`

Explicitly builds for Intel 64-bit architecture. Required for Intel Mac compatibility.

### `-c release`

Sets build configuration to release mode with optimizations.

### `-v` (Verbose)

Show detailed build output:

```bash
swift build -c release --arch x86_64 -v
```

## Continuous Integration

The project includes a GitHub Actions workflow that automatically builds on push:

### Workflow File

`.github/workflows/ci-build.yml`

### Jobs

1. **build-intel-mac**: Builds on macOS-13 runner with x86_64
2. **ai-integration-check**: Verifies AI components
3. **deployment**: Packages for distribution (on main branch)

### Triggering CI Build

CI builds run automatically on:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`
- Manual workflow dispatch

### Viewing CI Results

1. Go to repository on GitHub
2. Click "Actions" tab
3. View workflow runs and logs

## Development Workflow

### Recommended Development Cycle

1. **Make Changes**: Edit Swift files
2. **Build**: `make build-debug`
3. **Test**: `make test` (if tests exist)
4. **Verify**: `make verify-ai`
5. **Run**: `swift run`
6. **Iterate**: Repeat as needed

### Quick Build & Run

```bash
swift run
```

This builds (if needed) and runs in one command.

## Performance Tips

### Faster Builds

1. **Use Debug Mode** during development:
   ```bash
   make build-debug
   ```

2. **Incremental Builds**: Swift Package Manager uses incremental compilation automatically

3. **Parallel Builds**: SPM uses multiple CPU cores by default

### Build Time

- **Clean Build (Debug)**: ~30-60 seconds
- **Clean Build (Release)**: ~60-90 seconds
- **Incremental Build**: ~5-15 seconds

## Environment Variables

### Custom Build Settings

```bash
# Set specific Swift flags
SWIFT_FLAGS="-warnings-as-errors" swift build

# Set custom optimization level
SWIFT_OPTIMIZATION_LEVEL="-O" swift build
```

## Additional Resources

- **Swift Package Manager**: https://swift.org/package-manager/
- **SwiftUI Documentation**: https://developer.apple.com/documentation/swiftui
- **macOS Development**: https://developer.apple.com/macos/

## Support

If you encounter build issues:

1. Check Prerequisites section
2. Review Troubleshooting section
3. Ensure macOS and Xcode are up to date
4. Clean and rebuild: `make clean && make build`
5. Check GitHub Issues for similar problems

## Summary

**Quick Start** (Most Common):
```bash
make build    # Build for release
swift run     # Run the application
```

**Full Development Cycle**:
```bash
make verify-ai     # Verify components
make build-debug   # Build for development
swift run          # Run and test
make build         # Build for release
make package       # Create distribution
```

**Clean and Rebuild**:
```bash
make clean
make build
```

---

For more information, see:
- [README.md](README.md) - Project overview
- [ARCHITECTURE.md](ARCHITECTURE.md) - Technical details
- [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) - Complete summary
