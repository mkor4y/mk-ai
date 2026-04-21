const { app, BrowserWindow, ipcMain, Menu } = require('electron');
const path = require('path');

let mainWindow;
let SERVER_URL = 'http://localhost:3000';

function createWindow() {
    mainWindow = new BrowserWindow({
        width: 1200,
        height: 800,
        icon: path.join(__dirname, 'icon.ico'), // Eğer icon varsa
        webPreferences: {
            nodeIntegration: false,
            contextIsolation: true,
            preload: path.join(__dirname, 'preload.js')
        }
    });

    // Varsayılan menüyü gizle
    mainWindow.setMenuBarVisibility(false);

    loadApp();

    mainWindow.on('closed', function () {
        mainWindow = null;
    });
}

function loadApp() {
    console.log(`Loading URL: ${SERVER_URL}`);
    mainWindow.loadURL(SERVER_URL).catch((err) => {
        console.log('Connection failed, loading error page...');
        mainWindow.loadFile(path.join(__dirname, 'error.html'));
    });
}

app.on('ready', createWindow);

app.on('window-all-closed', function () {
    if (process.platform !== 'darwin') app.quit();
});

app.on('activate', function () {
    if (mainWindow === null) createWindow();
});

// IPC: Yeni sunucu URL'ini ayarla ve yeniden yükle
ipcMain.on('set-server-url', (event, url) => {
    SERVER_URL = url;
    loadApp();
});

// Hata durumunda da error page'e düşmesini garantile
app.on('web-contents-created', (event, contents) => {
    contents.on('did-fail-load', (event, errorCode, errorDescription) => {
        console.log('Failed to load:', errorDescription);
        // Sadece ana sayfa yüklenemezse error page göster
        // (Resim vb. yüklenemezse tüm sayfayı bozma)
        if (mainWindow && mainWindow.webContents === contents) {
            // Döngüye girmemesi için URL kontrolü yapılabilir
            // Ama loadFile local dosya olduğu için fail etmez
            mainWindow.loadFile(path.join(__dirname, 'error.html'));
        }
    });
});
