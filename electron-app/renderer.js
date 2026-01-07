// Particle Visualization for Core System
class ParticleSystem {
  constructor(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.particles = [];
    this.particleCount = 2000;
    this.centerX = 0;
    this.centerY = 0;
    this.radius = 150;
    this.time = 0;
    this.isActive = true;
    
    this.init();
    this.animate();
    
    window.addEventListener('resize', () => this.resize());
  }
  
  init() {
    this.resize();
    this.createParticles();
  }
  
  resize() {
    const rect = this.canvas.parentElement.getBoundingClientRect();
    this.canvas.width = rect.width;
    this.canvas.height = rect.height;
    this.centerX = this.canvas.width / 2;
    this.centerY = this.canvas.height / 2;
    this.radius = Math.min(this.canvas.width, this.canvas.height) * 0.3;
  }
  
  createParticles() {
    this.particles = [];
    for (let i = 0; i < this.particleCount; i++) {
      // Create particles in a spherical distribution
      const theta = Math.random() * Math.PI * 2;
      const phi = Math.acos(2 * Math.random() - 1);
      const r = this.radius * (0.8 + Math.random() * 0.4);
      
      this.particles.push({
        x: r * Math.sin(phi) * Math.cos(theta),
        y: r * Math.sin(phi) * Math.sin(theta),
        z: r * Math.cos(phi),
        originalX: r * Math.sin(phi) * Math.cos(theta),
        originalY: r * Math.sin(phi) * Math.sin(theta),
        originalZ: r * Math.cos(phi),
        size: Math.random() * 2 + 0.5,
        speed: Math.random() * 0.02 + 0.01,
        offset: Math.random() * Math.PI * 2,
        brightness: Math.random() * 0.5 + 0.5
      });
    }
  }
  
  animate() {
    if (!this.isActive) return;
    
    this.ctx.fillStyle = 'rgba(10, 10, 15, 0.1)';
    this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
    
    this.time += 0.005;
    
    // Sort particles by z-depth for proper rendering
    const sortedParticles = [...this.particles].sort((a, b) => a.z - b.z);
    
    for (const particle of sortedParticles) {
      // Rotate the particle
      const rotationSpeed = 0.3;
      const cosTime = Math.cos(this.time * rotationSpeed);
      const sinTime = Math.sin(this.time * rotationSpeed);
      
      // Apply rotation around Y axis
      const x = particle.originalX * cosTime - particle.originalZ * sinTime;
      const z = particle.originalX * sinTime + particle.originalZ * cosTime;
      const y = particle.originalY;
      
      // Add wave effect
      const wave = Math.sin(this.time * 2 + particle.offset) * 10;
      
      // Project 3D to 2D
      const scale = 400 / (400 + z);
      const projectedX = this.centerX + (x + wave * 0.3) * scale;
      const projectedY = this.centerY + (y + wave * 0.3) * scale;
      
      // Calculate color based on position and time
      const hue = (this.time * 20 + particle.offset * 30) % 360;
      const saturation = 20;
      const lightness = 60 + (z / this.radius) * 20;
      const alpha = (0.3 + scale * 0.5) * particle.brightness;
      
      // Draw particle
      this.ctx.beginPath();
      this.ctx.arc(projectedX, projectedY, particle.size * scale, 0, Math.PI * 2);
      this.ctx.fillStyle = `hsla(${hue}, ${saturation}%, ${lightness}%, ${alpha})`;
      this.ctx.fill();
      
      // Add glow effect for some particles
      if (particle.brightness > 0.8) {
        this.ctx.beginPath();
        this.ctx.arc(projectedX, projectedY, particle.size * scale * 2, 0, Math.PI * 2);
        this.ctx.fillStyle = `hsla(${hue}, ${saturation}%, ${lightness}%, ${alpha * 0.3})`;
        this.ctx.fill();
      }
    }
    
    // Draw center glow
    const gradient = this.ctx.createRadialGradient(
      this.centerX, this.centerY, 0,
      this.centerX, this.centerY, this.radius * 0.5
    );
    gradient.addColorStop(0, 'rgba(0, 255, 136, 0.05)');
    gradient.addColorStop(0.5, 'rgba(0, 212, 255, 0.02)');
    gradient.addColorStop(1, 'transparent');
    
    this.ctx.fillStyle = gradient;
    this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
    
    requestAnimationFrame(() => this.animate());
  }
  
  setActive(active) {
    this.isActive = active;
    if (active) this.animate();
  }
}

// Real-time System Metrics
class SystemMetrics {
  constructor() {
    this.cpuValue = document.getElementById('cpuValue');
    this.cpuBar = document.getElementById('cpuBar');
    this.ramValue = document.getElementById('ramValue');
    this.ramBar = document.getElementById('ramBar');
    this.ramDetails = document.getElementById('ramDetails');
    this.processesBody = document.getElementById('processesBody');
    this.metricsStatus = document.querySelector('.metrics-status');
    
    this.updateMetrics();
    // Update every 2 seconds for real-time data
    setInterval(() => this.updateMetrics(), 2000);
  }
  
  async updateMetrics() {
    try {
      // Check if electronAPI is available
      if (typeof window.electronAPI !== 'undefined' && window.electronAPI.getSystemMetrics) {
        const metrics = await window.electronAPI.getSystemMetrics();
        this.displayMetrics(metrics);
      } else {
        // Fallback for browser testing
        this.displayFallbackMetrics();
      }
    } catch (error) {
      console.error('Failed to get system metrics:', error);
      this.displayFallbackMetrics();
    }
  }
  
  displayMetrics(metrics) {
    // Update CPU
    if (this.cpuValue) {
      this.cpuValue.textContent = `${metrics.cpu}%`;
      this.cpuBar.style.width = `${Math.min(metrics.cpu, 100)}%`;
      
      // Change color based on CPU load
      if (metrics.cpu > 80) {
        this.cpuBar.style.background = 'linear-gradient(90deg, #ff3b3b, #ff6b6b)';
      } else if (metrics.cpu > 50) {
        this.cpuBar.style.background = 'linear-gradient(90deg, #ff9500, #ffd700)';
      } else {
        this.cpuBar.style.background = 'linear-gradient(90deg, #00ff88, #00d4ff)';
      }
    }
    
    // Update RAM
    if (this.ramValue) {
      this.ramValue.textContent = `${metrics.ram}%`;
      this.ramBar.style.width = `${Math.min(metrics.ram, 100)}%`;
      this.ramDetails.textContent = `${metrics.ramUsed} / ${metrics.ramTotal} GB`;
      
      // Change color based on RAM usage
      if (metrics.ram > 80) {
        this.ramBar.style.background = 'linear-gradient(90deg, #ff3b3b, #ff6b6b)';
      } else if (metrics.ram > 60) {
        this.ramBar.style.background = 'linear-gradient(90deg, #ff9500, #ffd700)';
      } else {
        this.ramBar.style.background = 'linear-gradient(90deg, #ff0066, #ff9500)';
      }
    }
    
    // Update processes
    if (this.processesBody && metrics.processes && metrics.processes.length > 0) {
      this.processesBody.innerHTML = metrics.processes.map(p => `
        <tr>
          <td title="${p.name}">${this.truncateName(p.name, 20)}</td>
          <td class="cpu-cell">${parseFloat(p.cpu).toFixed(1)}%</td>
          <td>${parseFloat(p.mem).toFixed(1)}%</td>
        </tr>
      `).join('');
    }
    
    // Update status indicator
    if (this.metricsStatus) {
      this.metricsStatus.classList.add('online');
    }
  }
  
  displayFallbackMetrics() {
    // Fallback with simulated data for browser testing
    const cpu = Math.floor(Math.random() * 30 + 10);
    const ram = Math.floor(Math.random() * 40 + 30);
    
    if (this.cpuValue) {
      this.cpuValue.textContent = `${cpu}%`;
      this.cpuBar.style.width = `${cpu}%`;
    }
    
    if (this.ramValue) {
      this.ramValue.textContent = `${ram}%`;
      this.ramBar.style.width = `${ram}%`;
      this.ramDetails.textContent = `${(ram * 0.16).toFixed(1)} / 16.0 GB`;
    }
    
    if (this.processesBody) {
      const processes = [
        { name: 'System Process', cpu: (5 + Math.random() * 10).toFixed(1), mem: '2.0' },
        { name: 'Browser', cpu: (3 + Math.random() * 8).toFixed(1), mem: '4.5' },
        { name: 'Desktop Manager', cpu: (2 + Math.random() * 5).toFixed(1), mem: '1.2' },
        { name: 'Audio Service', cpu: (1 + Math.random() * 3).toFixed(1), mem: '0.5' },
        { name: 'Background Task', cpu: (0.5 + Math.random() * 2).toFixed(1), mem: '0.3' }
      ];
      
      this.processesBody.innerHTML = processes.map(p => `
        <tr>
          <td>${p.name}</td>
          <td class="cpu-cell">${p.cpu}%</td>
          <td>${p.mem}%</td>
        </tr>
      `).join('');
    }
  }
  
  truncateName(name, maxLength) {
    if (name.length > maxLength) {
      return name.substring(0, maxLength - 3) + '...';
    }
    return name;
  }
}

// Transcript/Chat functionality
class TranscriptManager {
  constructor() {
    this.messages = document.getElementById('transcriptMessages');
    this.input = document.getElementById('messageInput');
    this.sendBtn = document.getElementById('sendBtn');
    
    this.setupEventListeners();
  }
  
  setupEventListeners() {
    if (this.sendBtn) {
      this.sendBtn.addEventListener('click', () => this.sendMessage());
    }
    
    if (this.input) {
      this.input.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
          this.sendMessage();
        }
      });
    }
  }
  
  async sendMessage() {
    const text = this.input.value.trim();
    if (!text) return;
    
    this.addMessage(text, 'user');
    this.input.value = '';
    
    // Simulate AI response
    setTimeout(() => {
      this.addMessage('Message received! Processing your request...', 'ai');
    }, 1000);
  }
  
  addMessage(text, type) {
    const messageDiv = document.createElement('div');
    messageDiv.className = `transcript-message ${type}`;
    messageDiv.innerHTML = `
      <span class="message-label">${type === 'user' ? 'YOU' : 'KREO'}</span>
      <div class="message-bubble">${text}</div>
    `;
    
    this.messages.appendChild(messageDiv);
    this.messages.scrollTop = this.messages.scrollHeight;
  }
}

// Control Buttons
class ControlManager {
  constructor() {
    this.cameraBtn = document.getElementById('cameraBtn');
    this.endBtn = document.getElementById('endBtn');
    this.micBtn = document.getElementById('micBtn');
    this.isMicActive = true;
    this.isCameraActive = false;
    
    this.setupEventListeners();
  }
  
  setupEventListeners() {
    if (this.micBtn) {
      this.micBtn.addEventListener('click', () => this.toggleMic());
    }
    
    if (this.cameraBtn) {
      this.cameraBtn.addEventListener('click', () => this.toggleCamera());
    }
    
    if (this.endBtn) {
      this.endBtn.addEventListener('click', () => this.endSession());
    }
  }
  
  toggleMic() {
    this.isMicActive = !this.isMicActive;
    this.micBtn.classList.toggle('active', this.isMicActive);
    
    // Update listening status
    const listeningStatus = document.querySelector('.status-item.listening');
    if (listeningStatus) {
      listeningStatus.style.opacity = this.isMicActive ? '1' : '0.3';
    }
  }
  
  toggleCamera() {
    this.isCameraActive = !this.isCameraActive;
    this.cameraBtn.classList.toggle('active', this.isCameraActive);
    
    const visualInput = document.querySelector('.visual-input-area');
    if (visualInput) {
      if (this.isCameraActive) {
        visualInput.innerHTML = `
          <div class="camera-active">
            <div class="camera-preview">📷 Camera Active</div>
          </div>
        `;
      } else {
        visualInput.innerHTML = `
          <div class="video-feed-offline">
            <div class="camera-icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/>
                <circle cx="12" cy="13" r="4"/>
                <line x1="1" y1="1" x2="23" y2="23"/>
              </svg>
            </div>
            <span class="offline-text">VIDEO FEED OFFLINE</span>
          </div>
        `;
      }
    }
  }
  
  endSession() {
    // Visual feedback for ending session
    this.endBtn.style.transform = 'scale(0.95)';
    setTimeout(() => {
      this.endBtn.style.transform = 'scale(1)';
    }, 100);
    
    // Could implement actual session ending logic here
    console.log('Session ended');
  }
}

// Navigation Tabs
class NavigationManager {
  constructor() {
    this.tabs = document.querySelectorAll('.nav-tab');
    this.setupEventListeners();
  }
  
  setupEventListeners() {
    this.tabs.forEach(tab => {
      tab.addEventListener('click', () => this.switchTab(tab));
    });
  }
  
  switchTab(selectedTab) {
    this.tabs.forEach(tab => tab.classList.remove('active'));
    selectedTab.classList.add('active');
  }
}

// Initialize everything when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  // Initialize particle system
  const canvas = document.getElementById('particleCanvas');
  if (canvas) {
    new ParticleSystem(canvas);
  }
  
  // Initialize system metrics
  new SystemMetrics();
  
  // Initialize transcript manager
  new TranscriptManager();
  
  // Initialize control manager
  new ControlManager();
  
  // Initialize navigation
  new NavigationManager();
  
  console.log('Pownin Assistant Dashboard initialized');
});
