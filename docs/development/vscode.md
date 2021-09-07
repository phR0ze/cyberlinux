# vscode
Develop with Visual Studio Code

### Table of Contents
* [Install](#install)
* [Install Extensions](#install-extensions)
* [Keyboard Shortcuts](#keyboard-shortcuts)
* [General Settings](#general-settings)
* [Language Config](#language-config)
  * [Golang Install](#golang-install)
  * [Golang Config ](#go-config)
* [Troubleshooting](#troubleshooting)
  * [Remove All Extensions](#remove-all-extensions)

# Install <a name="install"></a>
```bash
# Install from the cyberlinux repo
$ sudo pacman -S visual-studio-code-bin ripgrep

# Build and install from source
$ yay -Ga visual-studio-code-bin
$ cd visual-studio-code-bin; makepkg -s
$ sudo pacman -U visual-studio-code-bin-1.8.1-3x86_64.pkg.tar.xz
```

# Install Extensions <a name="install-extensions"></a>

1. Launch `code`
2. Click the button on the left that looks like an extension icon
3. Install ***Vim vscodevim.vim***
4. Install ***VSCode Great Icons emmanuelbeziat.vscode-great-icons***
5. Install ***Code Runner formulahendry.code-runner***
6. Install ***Go ms-vscode.go***  
7. Install ***Better TOML bungcip.better-toml***
8. Install ***Docker Peterjausover.vscode-docker***
9. Install ***C/C++ ms-vscode.cpptools***

# Keyboard Shortcuts <a name="keyboard-shortcuts"></a>
Hit `Ctrl+Shift+p` and search for keyboard then choose `Preferences: Open Keyboard Shortcuts`

| Key sequence   | Description             |
| -------------- | ----------------------- |
| Ctrl+Shift+b   | Run Build Task          |
| Ctrl+Shift+n   | Open new instance       |
| Ctrl+Shift+p   | Open command search     |
| Ctrl+Shift+s   | File: Save All          |
| Ctrl+,         | Open settings           |    
| F12            | Go to Definition        |
| Ctrl+Shift+t   | Run Test Task           |


Keyboard shortcut overrides are found in: `~/.config/Code/User/keybindings.json`
```json
[
    {
        "key": "ctrl+shift+s",
        "command": "workbench.action.files.saveAll"
    },
    {
        "key": "ctrl+shift+t",
        "command": "workbench.action.tasks.test"
    }
]
```

# General Settings <a name="general-settings"></a>
Configuration is saved at `~/.config/Code/User/settings.json`

Hit `Ctrl+Shift+p` and search for `json` and select `Preferences: Open Settings(JSON)`
```json
{
    "window.zoomLevel": 0,
    "go.gopath": "~/Projects/go",
    "http.proxyStrictSSL": false,
    "editor.minimap.enabled": true,
    "editor.tabSize": 4,
    "editor.insertSpaces": true,
    "workbench.iconTheme": "vscode-great-icons",
    "telemetry.enableTelemetry": false,
    "telemetry.enableCrashReporter": false,
    "vim.handleKeys": {
        "<C-a>": false,
        "<C-b>": false,
        "<C-c>": false,
        "<C-e>": false,
        "<C-f>": false,
        "<C-h>": false,
        "<C-i>": false,
        "<C-j>": false,
        "<C-k>": false,
        "<C-n>": false,
        "<C-p>": false,
        "<C-s>": false,
        "<C-t>": false,
        "<C-u>": false,
        "<C-v>": false,
        "<C-o>": false,
        "<C-w>": false,
        "<C-x>": false,
        "<C-y>": false,
        "<C-z>": false
    }
}
```

# Language Config <a name="language-config"></a>

## Golang Install <a name="golang-install"></a>

Install golang and dependencies;
```bash
# go                   // golang
# go-bindata           // go binary data tool
# dep                  // go dependency manager
# delve                // go debugger
$ sudo pacman -S go go-tools go-bindata dep delve
```

Install Go Language Server:
```bash
# Remove the old go bins
$ rm -rf ~/Projects/go/bin

# Download the new go language server
$ go get golang.org/x/tools/gopls
```

## Golang Config <a name="golang-config"></a>
1. Set go path in `~/.bashrc`:    
   `export GOPATH=~/Projects/go`  

2. Install Extensions:  
   a. Click the button on the left that looks like an extension icon  
   b. Install ***Go ms-vscode.go***  

3. Add Golang Server Configs:  
   [Go Language](https://github.com/microsoft/vscode-go#go-language-server)  
   Note: you have to open a go file before the Go extension is officially activated  
   a. Hit `Ctrl+Shift+p` and enter `Preferences: Open Settings (JSON)` and paste  
   ```bash
   "go.gopath": "~/Projects/go", // Set the GOPATH to use
   "go.formatTool": "goimports", // Use specific external format tool for go
   "go.useLanguageServer": true, // Use the new gopls language server
   "go.languageServerExperimentalFeatures": {
       "documentLink": false, // Just reference local code via imports not external github pages with popup
       //"signatureHelp": false,
       // "format": true,
       // "autoComplete": true,
       // "diagnostics": true,
       // "goToDefinition": true,
       // "hover": true,
       // "goToTypeDefinition": true,
       // "findReferences": true,
       // "goToImplementation": true
   },
   "[go]": {
       "editor.snippetSuggestions": "none",
       "editor.formatOnSave": true,
       "editor.codeActionsOnSave": {
           "source.organizeImports": true
       }
   },
   "gopls": {
       "usePlaceholders": false, // add parameter placeholders when completing a function
       "completionDocumentation": true // for documentation in completion items
   },
   "files.eol": "\n", // Gopls formatting only supports LF line endings
   ```

## Troubleshooting <a name="troubleshooting"></a>

### Remove All Extensions <a name="remove-all-extensions"></a>
Extensions are stored in ***~/.vscode/extensions***

To clean up all extensions simply remove this directory
