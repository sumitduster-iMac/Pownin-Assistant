//
//  RailwayApp.swift
//  Pownin-Assistant
//
//  Railway deployment and monitoring integration
//

import SwiftUI

// MARK: - Railway App Model
struct RailwayProject: Identifiable, Codable {
    let id: String
    var name: String
    var status: DeploymentStatus
    var environment: String
    var lastDeployed: Date?
    var url: String?
    
    enum DeploymentStatus: String, Codable {
        case deploying = "deploying"
        case active = "active"
        case failed = "failed"
        case sleeping = "sleeping"
        case unknown = "unknown"
        
        var color: Color {
            switch self {
            case .deploying: return .orange
            case .active: return .green
            case .failed: return .red
            case .sleeping: return .gray
            case .unknown: return .secondary
            }
        }
        
        var icon: String {
            switch self {
            case .deploying: return "arrow.triangle.2.circlepath"
            case .active: return "checkmark.circle.fill"
            case .failed: return "xmark.circle.fill"
            case .sleeping: return "moon.fill"
            case .unknown: return "questionmark.circle"
            }
        }
    }
}

// MARK: - Railway Service
@MainActor
class RailwayService: ObservableObject {
    @Published var projects: [RailwayProject] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var apiToken: String = ""
    
    var isConfigured: Bool {
        !apiToken.isEmpty
    }
    
    func fetchProjects() async {
        guard isConfigured else { return }
        
        isLoading = true
        errorMessage = nil
        
        // Simulate API call - in production, this would call Railway's GraphQL API
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Mock data for demonstration
        projects = [
            RailwayProject(
                id: "proj_1",
                name: "pownin-api",
                status: .active,
                environment: "production",
                lastDeployed: Date().addingTimeInterval(-3600),
                url: "https://pownin-api.up.railway.app"
            ),
            RailwayProject(
                id: "proj_2",
                name: "pownin-web",
                status: .deploying,
                environment: "staging",
                lastDeployed: Date(),
                url: nil
            ),
            RailwayProject(
                id: "proj_3",
                name: "pownin-worker",
                status: .sleeping,
                environment: "production",
                lastDeployed: Date().addingTimeInterval(-86400),
                url: nil
            )
        ]
        
        isLoading = false
    }
    
    func triggerDeploy(projectId: String) async {
        guard let index = projects.firstIndex(where: { $0.id == projectId }) else { return }
        
        projects[index].status = .deploying
        
        // Simulate deployment
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        
        projects[index].status = .active
        projects[index].lastDeployed = Date()
    }
}

// MARK: - Railway Dashboard View
struct RailwayDashboardView: View {
    @StateObject private var service = RailwayService()
    @State private var showingConfiguration: Bool = false
    @State private var selectedProject: RailwayProject?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            RailwayHeaderView(
                isConfigured: service.isConfigured,
                onConfigure: { showingConfiguration = true },
                onRefresh: { Task { await service.fetchProjects() } }
            )
            
            Divider()
            
            // Content
            if !service.isConfigured {
                RailwaySetupView { showingConfiguration = true }
            } else if service.isLoading {
                LoadingView()
            } else if service.projects.isEmpty {
                EmptyProjectsView()
            } else {
                ProjectListView(
                    projects: service.projects,
                    selectedProject: $selectedProject,
                    onDeploy: { projectId in
                        Task { await service.triggerDeploy(projectId: projectId) }
                    }
                )
            }
        }
        .sheet(isPresented: $showingConfiguration) {
            RailwayConfigurationSheet(
                apiToken: $service.apiToken,
                isPresented: $showingConfiguration
            ) {
                Task { await service.fetchProjects() }
            }
        }
        .task {
            if service.isConfigured {
                await service.fetchProjects()
            }
        }
    }
}

// MARK: - Railway Header View
struct RailwayHeaderView: View {
    let isConfigured: Bool
    let onConfigure: () -> Void
    let onRefresh: () -> Void
    
    var body: some View {
        HStack {
            HStack(spacing: 10) {
                Image(systemName: "train.side.front.car")
                    .font(.system(size: 20))
                    .foregroundColor(.purple)
                
                Text("Railway")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                if isConfigured {
                    Button(action: onRefresh) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.plain)
                }
                
                Button(action: onConfigure) {
                    Image(systemName: "gear")
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
}

// MARK: - Railway Setup View
struct RailwaySetupView: View {
    let onSetup: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "train.side.front.car")
                .font(.system(size: 80))
                .foregroundColor(.purple.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("Connect to Railway")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Monitor and manage your Railway deployments directly from Pownin Assistant.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 400)
            }
            
            Button(action: onSetup) {
                Label("Configure Railway", systemImage: "link.badge.plus")
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading projects...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Empty Projects View
struct EmptyProjectsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No projects found")
                .font(.headline)
            
            Text("Create a project on Railway to see it here.")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Project List View
struct ProjectListView: View {
    let projects: [RailwayProject]
    @Binding var selectedProject: RailwayProject?
    let onDeploy: (String) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(projects) { project in
                    ProjectCardView(
                        project: project,
                        isSelected: selectedProject?.id == project.id,
                        onSelect: { selectedProject = project },
                        onDeploy: { onDeploy(project.id) }
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - Project Card View
struct ProjectCardView: View {
    let project: RailwayProject
    let isSelected: Bool
    let onSelect: () -> Void
    let onDeploy: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.name)
                        .font(.headline)
                    
                    Text(project.environment)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.secondary.opacity(0.1)))
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: project.status.icon)
                        .foregroundColor(project.status.color)
                    
                    Text(project.status.rawValue.capitalized)
                        .font(.subheadline)
                        .foregroundColor(project.status.color)
                }
            }
            
            if let lastDeployed = project.lastDeployed {
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text("Last deployed: \(lastDeployed, style: .relative) ago")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            HStack {
                if let url = project.url {
                    Link(destination: URL(string: url)!) {
                        Label("Open", systemImage: "arrow.up.right.square")
                            .font(.caption)
                    }
                }
                
                Spacer()
                
                Button("Deploy") {
                    onDeploy()
                }
                .buttonStyle(.bordered)
                .disabled(project.status == .deploying)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                )
        )
        .onTapGesture(perform: onSelect)
    }
}

// MARK: - Railway Configuration Sheet
struct RailwayConfigurationSheet: View {
    @Binding var apiToken: String
    @Binding var isPresented: Bool
    let onSave: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Railway Configuration")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("API Token")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                SecureField("Enter your Railway API token", text: $apiToken)
                    .textFieldStyle(.roundedBorder)
                
                Text("You can find your API token in Railway's account settings.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 12) {
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(.bordered)
                
                Button("Save") {
                    onSave()
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .disabled(apiToken.isEmpty)
            }
        }
        .padding(30)
        .frame(width: 400)
    }
}

// MARK: - Preview
struct RailwayApp_Previews: PreviewProvider {
    static var previews: some View {
        RailwayDashboardView()
            .frame(width: 600, height: 500)
    }
}
