const { app, BrowserWindow, Menu, ipcMain, shell } = require('electron');
const path = require('path');
const os = require('os');
const { exec } = require('child_process');

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

// CPU usage calculation
let lastCpuInfo = os.cpus();
function getCpuUsage() {
  const cpus = os.cpus();
  let totalIdle = 0;
  let totalTick = 0;
  let lastTotalIdle = 0;
  let lastTotalTick = 0;

  for (let i = 0; i < cpus.length; i++) {
    const cpu = cpus[i];
    const lastCpu = lastCpuInfo[i];
    
    for (const type in cpu.times) {
      totalTick += cpu.times[type];
      lastTotalTick += lastCpu.times[type];
    }
    totalIdle += cpu.times.idle;
    lastTotalIdle += lastCpu.times.idle;
  }

  const idleDiff = totalIdle - lastTotalIdle;
  const totalDiff = totalTick - lastTotalTick;
  const usage = totalDiff > 0 ? Math.round((1 - idleDiff / totalDiff) * 100) : 0;
  
  lastCpuInfo = cpus;
  return usage;
}

// Get top processes (platform-specific)
function getTopProcesses() {
  return new Promise((resolve) => {
    const platform = process.platform;
    let command;
    
    if (platform === 'darwin') {
      // macOS
      command = 'ps -arcwwwxo "comm,%cpu,%mem" | head -6 | tail -5';
    } else if (platform === 'linux') {
      // Linux
      command = 'ps -eo comm,%cpu,%mem --sort=-%cpu | head -6 | tail -5';
    } else if (platform === 'win32') {
      // Windows - using WMIC
      command = 'wmic process get name,PercentProcessorTime /format:csv | findstr /v "^$" | sort /r | head -5';
      // Fallback for Windows
      resolve([
        { name: 'System', cpu: '5.0', mem: '2.0' },
        { name: 'Desktop Window Manager', cpu: '3.0', mem: '1.5' },
        { name: 'Explorer', cpu: '2.0', mem: '1.0' },
        { name: 'Runtime Broker', cpu: '1.5', mem: '0.8' },
        { name: 'Service Host', cpu: '1.0', mem: '0.5' }
      ]);
      return;
    }
    
    exec(command, (error, stdout) => {
      if (error) {
        resolve([]);
        return;
      }
      
      const lines = stdout.trim().split('\n');
      const processes = lines.map(line => {
        const parts = line.trim().split(/\s+/);
        if (parts.length >= 3) {
          return {
            name: parts.slice(0, -2).join(' ') || parts[0],
            cpu: parts[parts.length - 2] || '0.0',
            mem: parts[parts.length - 1] || '0.0'
          };
        }
        return null;
      }).filter(p => p !== null);
      
      resolve(processes.slice(0, 5));
    });
  });
}

ipcMain.handle('get-system-metrics', async () => {
  const totalMem = os.totalmem();
  const freeMem = os.freemem();
  const usedMem = totalMem - freeMem;
  const memPercent = Math.round((usedMem / totalMem) * 100);
  const memGB = (usedMem / (1024 * 1024 * 1024)).toFixed(1);
  const totalMemGB = (totalMem / (1024 * 1024 * 1024)).toFixed(1);
  
  const cpuPercent = getCpuUsage();
  const processes = await getTopProcesses();
  
  return {
    cpu: cpuPercent,
    ram: memPercent,
    ramUsed: memGB,
    ramTotal: totalMemGB,
    processes: processes,
    platform: process.platform,
    hostname: os.hostname(),
    uptime: os.uptime()
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
