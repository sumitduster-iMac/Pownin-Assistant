//
//  WebView.swift
//  Pownin-Assistant
//
//  WebView wrapper for displaying web content and railway integration
//

import SwiftUI
import WebKit

// MARK: - WebView Representable
struct WebView: NSViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var loadingProgress: Double
    var onNavigationFinished: (() -> Void)?
    
    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsMagnification = true
        
        // Custom user agent
        webView.customUserAgent = "PowninAssistant/1.0"
        
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        if nsView.url != url {
            let request = URLRequest(url: url)
            nsView.load(request)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
                self.parent.loadingProgress = 0.1
            }
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.loadingProgress = 0.5
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.loadingProgress = 1.0
                self.parent.onNavigationFinished?()
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.loadingProgress = 0
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.loadingProgress = 0
            }
        }
    }
}

// MARK: - Web View Container
struct WebViewContainer: View {
    let url: URL
    @State private var isLoading: Bool = true
    @State private var loadingProgress: Double = 0
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        ZStack {
            WebView(
                url: url,
                isLoading: $isLoading,
                loadingProgress: $loadingProgress
            )
            
            if isLoading {
                LoadingOverlayView(progress: loadingProgress)
            }
            
            if showError {
                ErrorOverlayView(message: errorMessage) {
                    showError = false
                }
            }
        }
    }
}

// MARK: - Loading Overlay View
struct LoadingOverlayView: View {
    let progress: Double
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(width: geometry.size.width * progress, height: 4)
                        .cornerRadius(2)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(width: 200, height: 4)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.windowBackgroundColor).opacity(0.95))
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        )
    }
}

// MARK: - Error Overlay View
struct ErrorOverlayView: View {
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            Text("Error Loading Content")
                .font(.headline)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Dismiss", action: onDismiss)
                .buttonStyle(.borderedProminent)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.windowBackgroundColor))
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        )
    }
}

// MARK: - Railway Integration View
struct RailwayIntegrationView: View {
    @State private var railwayURL: String = ""
    @State private var isConnected: Bool = false
    @State private var showingURLInput: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "train.side.front.car")
                    .font(.system(size: 18))
                    .foregroundColor(.purple)
                
                Text("Railway Integration")
                    .font(.headline)
                
                Spacer()
                
                ConnectionStatusBadge(isConnected: isConnected)
                
                Button(action: { showingURLInput.toggle() }) {
                    Image(systemName: "gear")
                        .font(.system(size: 16))
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Content
            if isConnected, let url = URL(string: railwayURL) {
                WebViewContainer(url: url)
            } else {
                RailwayPlaceholderView {
                    showingURLInput = true
                }
            }
        }
        .sheet(isPresented: $showingURLInput) {
            RailwayURLInputSheet(
                urlString: $railwayURL,
                isConnected: $isConnected,
                isPresented: $showingURLInput
            )
        }
    }
}

// MARK: - Connection Status Badge
struct ConnectionStatusBadge: View {
    let isConnected: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isConnected ? Color.green : Color.gray)
                .frame(width: 8, height: 8)
            
            Text(isConnected ? "Connected" : "Not Connected")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isConnected ? .green : .secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill((isConnected ? Color.green : Color.gray).opacity(0.1))
        )
    }
}

// MARK: - Railway Placeholder View
struct RailwayPlaceholderView: View {
    let onConnect: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "train.side.front.car")
                .font(.system(size: 60))
                .foregroundColor(.purple.opacity(0.5))
            
            Text("Connect to Railway")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Deploy and monitor your applications with Railway integration.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
            
            Button(action: onConnect) {
                Label("Connect Railway", systemImage: "link")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// MARK: - Railway URL Input Sheet
struct RailwayURLInputSheet: View {
    @Binding var urlString: String
    @Binding var isConnected: Bool
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Railway Configuration")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Railway Dashboard URL")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField("https://railway.app/project/...", text: $urlString)
                    .textFieldStyle(.roundedBorder)
            }
            
            HStack(spacing: 12) {
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(.bordered)
                
                Button("Connect") {
                    if !urlString.isEmpty {
                        isConnected = true
                        isPresented = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(urlString.isEmpty)
            }
        }
        .padding(30)
        .frame(width: 400)
    }
}

// MARK: - Preview
struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        RailwayIntegrationView()
            .frame(width: 800, height: 600)
    }
}
