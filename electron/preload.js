const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electron', {
    setServerUrl: (url) => ipcRenderer.send('set-server-url', url)
});
