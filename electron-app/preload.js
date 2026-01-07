const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  // System info
  getSystemInfo: () => ipcRenderer.invoke('get-system-info'),
  getSystemMetrics: () => ipcRenderer.invoke('get-system-metrics'),
  
  // AI Chat
  sendMessage: (message) => ipcRenderer.invoke('send-message', message),
  sendAIMessage: (message, provider, apiKey) => ipcRenderer.invoke('send-ai-message', { message, provider, apiKey }),
  
  // Settings
  saveSettings: (settings) => ipcRenderer.invoke('save-settings', settings),
  loadSettings: () => ipcRenderer.invoke('load-settings'),
  
  // Events
  onOpenSettings: (callback) => ipcRenderer.on('open-settings', callback)
});
