const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  getSystemInfo: () => ipcRenderer.invoke('get-system-info'),
  sendMessage: (message) => ipcRenderer.invoke('send-message', message),
  onOpenSettings: (callback) => ipcRenderer.on('open-settings', callback),
  getSystemMetrics: () => ipcRenderer.invoke('get-system-metrics')
});
