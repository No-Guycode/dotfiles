const { app, BrowserWindow } = require('electron')

function createWindow() {
  const win = new BrowserWindow({
    width: 1920,
    height: 1080,
    frame: false,
    transparent: true,
    alwaysOnTop: false,
    skipTaskbar: true,
    resizable: false,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true
    }
  })
  
  win.loadFile('/home/ahmed/.config/hypr/UserScripts/Clock.html')
  win.setIgnoreMouseEvents(true) // Click-through
}

app.whenReady().then(createWindow)
app.on('window-all-closed', () => app.quit())
