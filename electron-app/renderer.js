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
    this.audioLevel = 0;
    
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
  
  setAudioLevel(level) {
    this.audioLevel = level;
  }
  
  animate() {
    if (!this.isActive) return;
    
    this.ctx.fillStyle = 'rgba(10, 10, 15, 0.1)';
    this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
    
    this.time += 0.005;
    
    const audioMultiplier = 1 + this.audioLevel * 0.5;
    const sortedParticles = [...this.particles].sort((a, b) => a.z - b.z);
    
    for (const particle of sortedParticles) {
      const rotationSpeed = 0.3 + this.audioLevel * 0.2;
      const cosTime = Math.cos(this.time * rotationSpeed);
      const sinTime = Math.sin(this.time * rotationSpeed);
      
      const x = particle.originalX * cosTime - particle.originalZ * sinTime;
      const z = particle.originalX * sinTime + particle.originalZ * cosTime;
      const y = particle.originalY;
      
      const wave = Math.sin(this.time * 2 + particle.offset) * 10 * audioMultiplier;
      
      const scale = 400 / (400 + z);
      const projectedX = this.centerX + (x + wave * 0.3) * scale;
      const projectedY = this.centerY + (y + wave * 0.3) * scale;
      
      const hue = (this.time * 20 + particle.offset * 30 + this.audioLevel * 100) % 360;
      const saturation = 20 + this.audioLevel * 30;
      const lightness = 60 + (z / this.radius) * 20;
      const alpha = (0.3 + scale * 0.5) * particle.brightness;
      
      this.ctx.beginPath();
      this.ctx.arc(projectedX, projectedY, particle.size * scale * audioMultiplier, 0, Math.PI * 2);
      this.ctx.fillStyle = `hsla(${hue}, ${saturation}%, ${lightness}%, ${alpha})`;
      this.ctx.fill();
      
      if (particle.brightness > 0.8) {
        this.ctx.beginPath();
        this.ctx.arc(projectedX, projectedY, particle.size * scale * 2, 0, Math.PI * 2);
        this.ctx.fillStyle = `hsla(${hue}, ${saturation}%, ${lightness}%, ${alpha * 0.3})`;
        this.ctx.fill();
      }
    }
    
    const gradient = this.ctx.createRadialGradient(
      this.centerX, this.centerY, 0,
      this.centerX, this.centerY, this.radius * 0.5
    );
    gradient.addColorStop(0, `rgba(0, 255, 136, ${0.05 + this.audioLevel * 0.1})`);
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
    setInterval(() => this.updateMetrics(), 2000);
  }
  
  async updateMetrics() {
    try {
      if (typeof window.electronAPI !== 'undefined' && window.electronAPI.getSystemMetrics) {
        const metrics = await window.electronAPI.getSystemMetrics();
        this.displayMetrics(metrics);
      } else {
        this.displayFallbackMetrics();
      }
    } catch (error) {
      console.error('Failed to get system metrics:', error);
      this.displayFallbackMetrics();
    }
  }
  
  displayMetrics(metrics) {
    if (this.cpuValue) {
      this.cpuValue.textContent = `${metrics.cpu}%`;
      this.cpuBar.style.width = `${Math.min(metrics.cpu, 100)}%`;
      
      if (metrics.cpu > 80) {
        this.cpuBar.style.background = 'linear-gradient(90deg, #ff3b3b, #ff6b6b)';
      } else if (metrics.cpu > 50) {
        this.cpuBar.style.background = 'linear-gradient(90deg, #ff9500, #ffd700)';
      } else {
        this.cpuBar.style.background = 'linear-gradient(90deg, #00ff88, #00d4ff)';
      }
    }
    
    if (this.ramValue) {
      this.ramValue.textContent = `${metrics.ram}%`;
      this.ramBar.style.width = `${Math.min(metrics.ram, 100)}%`;
      this.ramDetails.textContent = `${metrics.ramUsed} / ${metrics.ramTotal} GB`;
      
      if (metrics.ram > 80) {
        this.ramBar.style.background = 'linear-gradient(90deg, #ff3b3b, #ff6b6b)';
      } else if (metrics.ram > 60) {
        this.ramBar.style.background = 'linear-gradient(90deg, #ff9500, #ffd700)';
      } else {
        this.ramBar.style.background = 'linear-gradient(90deg, #ff0066, #ff9500)';
      }
    }
    
    if (this.processesBody && metrics.processes && metrics.processes.length > 0) {
      this.processesBody.innerHTML = metrics.processes.map(p => `
        <tr>
          <td title="${p.name}">${this.truncateName(p.name, 20)}</td>
          <td class="cpu-cell">${parseFloat(p.cpu).toFixed(1)}%</td>
          <td>${parseFloat(p.mem).toFixed(1)}%</td>
        </tr>
      `).join('');
    }
    
    if (this.metricsStatus) {
      this.metricsStatus.classList.add('online');
    }
  }
  
  displayFallbackMetrics() {
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

// Camera Manager
class CameraManager {
  constructor() {
    this.video = document.getElementById('cameraFeed');
    this.offlineDisplay = document.getElementById('videoOffline');
    this.cameraBtn = document.getElementById('cameraBtn');
    this.stream = null;
    this.isActive = false;
    
    if (this.cameraBtn) {
      this.cameraBtn.addEventListener('click', () => this.toggle());
    }
  }
  
  async toggle() {
    if (this.isActive) {
      this.stop();
    } else {
      await this.start();
    }
  }
  
  async start() {
    try {
      this.stream = await navigator.mediaDevices.getUserMedia({
        video: { width: 320, height: 240, facingMode: 'user' },
        audio: false
      });
      
      this.video.srcObject = this.stream;
      this.video.style.display = 'block';
      this.offlineDisplay.style.display = 'none';
      this.cameraBtn.classList.add('active');
      this.isActive = true;
      
      console.log('Camera started');
    } catch (error) {
      console.error('Camera access denied:', error);
      alert('Camera access denied. Please allow camera access in your system settings.');
    }
  }
  
  stop() {
    if (this.stream) {
      this.stream.getTracks().forEach(track => track.stop());
      this.stream = null;
    }
    
    this.video.srcObject = null;
    this.video.style.display = 'none';
    this.offlineDisplay.style.display = 'flex';
    this.cameraBtn.classList.remove('active');
    this.isActive = false;
    
    console.log('Camera stopped');
  }
}

// Microphone & Speech Recognition Manager
class MicrophoneManager {
  constructor(particleSystem, transcriptManager) {
    this.micBtn = document.getElementById('micBtn');
    this.speechIndicator = document.getElementById('speechIndicator');
    this.particleSystem = particleSystem;
    this.transcriptManager = transcriptManager;
    this.isListening = false;
    this.recognition = null;
    this.audioContext = null;
    this.analyser = null;
    this.microphone = null;
    
    this.initSpeechRecognition();
    
    if (this.micBtn) {
      this.micBtn.addEventListener('click', () => this.toggle());
    }
  }
  
  initSpeechRecognition() {
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    
    if (SpeechRecognition) {
      this.recognition = new SpeechRecognition();
      this.recognition.continuous = true;
      this.recognition.interimResults = true;
      this.recognition.lang = 'en-US';
      
      this.recognition.onresult = (event) => {
        let finalTranscript = '';
        let interimTranscript = '';
        
        for (let i = event.resultIndex; i < event.results.length; i++) {
          const transcript = event.results[i][0].transcript;
          if (event.results[i].isFinal) {
            finalTranscript += transcript;
          } else {
            interimTranscript += transcript;
          }
        }
        
        if (finalTranscript) {
          this.transcriptManager.addMessage(finalTranscript, 'user');
          this.transcriptManager.sendToAI(finalTranscript);
        }
      };
      
      this.recognition.onerror = (event) => {
        console.error('Speech recognition error:', event.error);
        if (event.error === 'not-allowed') {
          alert('Microphone access denied. Please allow microphone access.');
        }
      };
      
      this.recognition.onend = () => {
        if (this.isListening) {
          // Restart if still supposed to be listening
          this.recognition.start();
        }
      };
    } else {
      console.warn('Speech recognition not supported');
    }
  }
  
  async toggle() {
    if (this.isListening) {
      this.stop();
    } else {
      await this.start();
    }
  }
  
  async start() {
    try {
      // Start audio visualization
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      this.audioContext = new (window.AudioContext || window.webkitAudioContext)();
      this.analyser = this.audioContext.createAnalyser();
      this.microphone = this.audioContext.createMediaStreamSource(stream);
      this.microphone.connect(this.analyser);
      this.analyser.fftSize = 256;
      
      this.isListening = true;
      this.micBtn.classList.add('active');
      if (this.speechIndicator) {
        this.speechIndicator.style.display = 'flex';
      }
      
      // Update listening status
      const listeningStatus = document.querySelector('.status-item.listening');
      if (listeningStatus) {
        listeningStatus.style.opacity = '1';
      }
      
      // Start speech recognition
      if (this.recognition) {
        this.recognition.start();
      }
      
      // Start audio level monitoring
      this.monitorAudioLevel();
      
      console.log('Microphone started');
    } catch (error) {
      console.error('Microphone access denied:', error);
      alert('Microphone access denied. Please allow microphone access.');
    }
  }
  
  stop() {
    this.isListening = false;
    
    if (this.recognition) {
      this.recognition.stop();
    }
    
    if (this.audioContext) {
      this.audioContext.close();
      this.audioContext = null;
    }
    
    this.micBtn.classList.remove('active');
    if (this.speechIndicator) {
      this.speechIndicator.style.display = 'none';
    }
    
    // Update listening status
    const listeningStatus = document.querySelector('.status-item.listening');
    if (listeningStatus) {
      listeningStatus.style.opacity = '0.3';
    }
    
    if (this.particleSystem) {
      this.particleSystem.setAudioLevel(0);
    }
    
    console.log('Microphone stopped');
  }
  
  monitorAudioLevel() {
    if (!this.isListening || !this.analyser) return;
    
    const dataArray = new Uint8Array(this.analyser.frequencyBinCount);
    this.analyser.getByteFrequencyData(dataArray);
    
    // Calculate average volume
    const average = dataArray.reduce((a, b) => a + b) / dataArray.length;
    const normalizedLevel = Math.min(average / 128, 1);
    
    // Update particle system with audio level
    if (this.particleSystem) {
      this.particleSystem.setAudioLevel(normalizedLevel);
    }
    
    requestAnimationFrame(() => this.monitorAudioLevel());
  }
}

// Transcript/Chat Manager with AI Integration
class TranscriptManager {
  constructor() {
    this.messages = document.getElementById('transcriptMessages');
    this.input = document.getElementById('messageInput');
    this.sendBtn = document.getElementById('sendBtn');
    this.settings = {
      provider: 'openai',
      apiKey: ''
    };
    
    this.loadSettings();
    this.setupEventListeners();
  }
  
  async loadSettings() {
    try {
      if (typeof window.electronAPI !== 'undefined' && window.electronAPI.loadSettings) {
        this.settings = await window.electronAPI.loadSettings();
      }
    } catch (error) {
      console.error('Failed to load settings:', error);
    }
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
    
    await this.sendToAI(text);
  }
  
  async sendToAI(text) {
    // Show typing indicator
    this.showTypingIndicator();
    
    try {
      if (typeof window.electronAPI !== 'undefined' && window.electronAPI.sendAIMessage) {
        const result = await window.electronAPI.sendAIMessage(
          text,
          this.settings.provider,
          this.settings.apiKey
        );
        
        this.hideTypingIndicator();
        
        if (result.success) {
          this.addMessage(result.response, 'ai');
        } else {
          this.addMessage(`Error: ${result.error}`, 'ai');
        }
      } else {
        // Fallback response for browser testing
        this.hideTypingIndicator();
        setTimeout(() => {
          this.addMessage('I received your message! To enable AI responses, please configure your API key in settings.', 'ai');
        }, 500);
      }
    } catch (error) {
      this.hideTypingIndicator();
      this.addMessage(`Error: ${error.message}`, 'ai');
    }
  }
  
  showTypingIndicator() {
    const indicator = document.createElement('div');
    indicator.className = 'transcript-message ai typing';
    indicator.id = 'typingIndicator';
    indicator.innerHTML = `
      <span class="message-label">KREO</span>
      <div class="message-bubble">
        <div class="typing-indicator">
          <span></span><span></span><span></span>
        </div>
      </div>
    `;
    this.messages.appendChild(indicator);
    this.messages.scrollTop = this.messages.scrollHeight;
  }
  
  hideTypingIndicator() {
    const indicator = document.getElementById('typingIndicator');
    if (indicator) {
      indicator.remove();
    }
  }
  
  addMessage(text, type) {
    const messageDiv = document.createElement('div');
    messageDiv.className = `transcript-message ${type}`;
    messageDiv.innerHTML = `
      <span class="message-label">${type === 'user' ? 'YOU' : 'KREO'}</span>
      <div class="message-bubble">${this.escapeHtml(text)}</div>
    `;
    
    this.messages.appendChild(messageDiv);
    this.messages.scrollTop = this.messages.scrollHeight;
  }
  
  escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }
  
  updateSettings(settings) {
    this.settings = { ...this.settings, ...settings };
  }
}

// Settings Manager
class SettingsManager {
  constructor(transcriptManager) {
    this.transcriptManager = transcriptManager;
    this.modal = document.getElementById('settingsModal');
    this.closeBtn = document.getElementById('closeSettings');
    this.saveBtn = document.getElementById('saveSettings');
    this.providerSelect = document.getElementById('aiProvider');
    this.apiKeyInput = document.getElementById('apiKey');
    
    this.setupEventListeners();
    this.loadSettings();
  }
  
  setupEventListeners() {
    // Open settings from button
    const settingsBtn = document.getElementById('settingsBtn');
    if (settingsBtn) {
      settingsBtn.addEventListener('click', () => this.open());
    }
    
    // Open settings from menu or keyboard shortcut
    document.addEventListener('keydown', (e) => {
      if ((e.metaKey || e.ctrlKey) && e.key === ',') {
        e.preventDefault();
        this.open();
      }
    });
    
    if (this.closeBtn) {
      this.closeBtn.addEventListener('click', () => this.close());
    }
    
    if (this.saveBtn) {
      this.saveBtn.addEventListener('click', () => this.save());
    }
    
    if (this.modal) {
      this.modal.addEventListener('click', (e) => {
        if (e.target === this.modal) {
          this.close();
        }
      });
    }
  }
  
  async loadSettings() {
    try {
      if (typeof window.electronAPI !== 'undefined' && window.electronAPI.loadSettings) {
        const settings = await window.electronAPI.loadSettings();
        if (this.providerSelect) {
          this.providerSelect.value = settings.provider || 'openai';
        }
        if (this.apiKeyInput && settings.apiKey) {
          this.apiKeyInput.value = settings.apiKey;
        }
      }
    } catch (error) {
      console.error('Failed to load settings:', error);
    }
  }
  
  open() {
    if (this.modal) {
      this.modal.style.display = 'flex';
    }
  }
  
  close() {
    if (this.modal) {
      this.modal.style.display = 'none';
    }
  }
  
  async save() {
    const settings = {
      provider: this.providerSelect?.value || 'openai',
      apiKey: this.apiKeyInput?.value || ''
    };
    
    try {
      if (typeof window.electronAPI !== 'undefined' && window.electronAPI.saveSettings) {
        await window.electronAPI.saveSettings(settings);
      }
      
      // Update transcript manager settings
      if (this.transcriptManager) {
        this.transcriptManager.updateSettings(settings);
      }
      
      this.close();
      console.log('Settings saved');
    } catch (error) {
      console.error('Failed to save settings:', error);
    }
  }
}

// Control Manager (End button)
class ControlManager {
  constructor(cameraManager, micManager) {
    this.endBtn = document.getElementById('endBtn');
    this.cameraManager = cameraManager;
    this.micManager = micManager;
    
    if (this.endBtn) {
      this.endBtn.addEventListener('click', () => this.endSession());
    }
  }
  
  endSession() {
    // Stop camera
    if (this.cameraManager) {
      this.cameraManager.stop();
    }
    
    // Stop microphone
    if (this.micManager) {
      this.micManager.stop();
    }
    
    // Visual feedback
    this.endBtn.style.transform = 'scale(0.95)';
    setTimeout(() => {
      this.endBtn.style.transform = 'scale(1)';
    }, 100);
    
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
  let particleSystem = null;
  if (canvas) {
    particleSystem = new ParticleSystem(canvas);
  }
  
  // Initialize system metrics
  new SystemMetrics();
  
  // Initialize transcript manager
  const transcriptManager = new TranscriptManager();
  
  // Initialize camera manager
  const cameraManager = new CameraManager();
  
  // Initialize microphone manager
  const micManager = new MicrophoneManager(particleSystem, transcriptManager);
  
  // Initialize settings manager
  new SettingsManager(transcriptManager);
  
  // Initialize control manager
  new ControlManager(cameraManager, micManager);
  
  // Initialize navigation
  new NavigationManager();
  
  // Listen for open-settings event from main process
  if (typeof window.electronAPI !== 'undefined') {
    window.electronAPI.onOpenSettings(() => {
      document.getElementById('settingsModal').style.display = 'flex';
    });
  }
  
  console.log('Pownin Assistant Dashboard initialized');
});
