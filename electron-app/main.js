const { app, BrowserWindow, Menu, ipcMain, shell } = require('electron');
const path = require('path');

let mainWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1400,
    height: 850,
    minWidth: 900,
    minHeight: 600,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false
    },
    titleBarStyle: 'hiddenInset',
    backgroundColor: '#1a1a2e',
    show: false
  });

  mainWindow.loadFile('index.html');

  mainWindow.once('ready-to-show', () => {
    mainWindow.show();
  });

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

function createMenu() {
  const template = [
    {
      label: 'Pownin Assistant',
      submenu: [
        { label: 'About', click: showAbout },
        { type: 'separator' },
        { label: 'Settings', accelerator: 'CmdOrCtrl+,', click: openSettings },
        { type: 'separator' },
        { role: 'hide' },
        { role: 'hideOthers' },
        { role: 'unhide' },
        { type: 'separator' },
        { role: 'quit' }
      ]
    },
    {
      label: 'Edit',
      submenu: [
        { role: 'undo' },
        { role: 'redo' },
        { type: 'separator' },
        { role: 'cut' },
        { role: 'copy' },
        { role: 'paste' },
        { role: 'selectAll' }
      ]
    },
    {
      label: 'View',
      submenu: [
        { role: 'reload' },
        { role: 'forceReload' },
        { role: 'toggleDevTools' },
        { type: 'separator' },
        { role: 'resetZoom' },
        { role: 'zoomIn' },
        { role: 'zoomOut' },
        { type: 'separator' },
        { role: 'togglefullscreen' }
      ]
    },
    {
      label: 'Window',
      submenu: [
        { role: 'minimize' },
        { role: 'zoom' },
        { type: 'separator' },
        { role: 'front' }
      ]
    },
    {
      label: 'Help',
      submenu: [
        {
          label: 'Documentation',
          click: () => shell.openExternal('https://github.com/sumitduster-iMac/Pownin-Assistant')
        },
        { label: 'About', click: showAbout }
      ]
    }
  ];

  const menu = Menu.buildFromTemplate(template);
  Menu.setApplicationMenu(menu);
}

function showAbout() {
  const aboutWindow = new BrowserWindow({
    width: 400,
    height: 300,
    resizable: false,
    minimizable: false,
    maximizable: false,
    parent: mainWindow,
    modal: true,
    webPreferences: {
      contextIsolation: true,
      nodeIntegration: false
    },
    backgroundColor: '#1a1a2e'
  });

  aboutWindow.loadFile('about.html');
  aboutWindow.setMenu(null);
}

function openSettings() {
  mainWindow.webContents.send('open-settings');
}

// IPC handlers
ipcMain.handle('get-system-info', () => {
  return {
    platform: process.platform,
    arch: process.arch,
    version: app.getVersion(),
    electron: process.versions.electron,
    node: process.versions.node
  };
});

ipcMain.handle('send-message', async (event, message) => {
  // Simulate AI response - in production, this would call the AI service
  return {
    response: `Received: ${message}`,
    timestamp: new Date().toISOString()
  };
});

ipcMain.handle('get-system-metrics', async () => {
  // Return simulated system metrics
  // In production, you could use os-utils or systeminformation package
  return {
    cpu: Math.floor(Math.random() * 30 + 10),
    ram: Math.floor(Math.random() * 15 + 10),
    processes: [
      { name: 'WindowServer', cpu: (35 + Math.random() * 10).toFixed(1), mem: '0.6' },
      { name: 'Eres Helper (GPU)', cpu: (28 + Math.random() * 10).toFixed(1), mem: '1.3' },
      { name: 'Eres Helper (Renderer)', cpu: (15 + Math.random() * 8).toFixed(1), mem: '1.8' },
      { name: 'coreaudiod', cpu: (10 + Math.random() * 5).toFixed(1), mem: '0.7' },
      { name: 'corespotd', cpu: (4 + Math.random() * 4).toFixed(1), mem: '0.2' }
    ]
  };
});

app.whenReady().then(() => {
  createWindow();
  createMenu();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});
