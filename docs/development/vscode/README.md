# vscode
====================================================================================================
<img align="left" width="48" height="48" src="../../../art/logo_256x256.png">
Develop with Visual Studio Code
<br><br>

### Quick links
* [.. up dir](..)
* [Install](#install)
* [Install Extensions](#install-extensions)
* [Keyboard Shortcuts](#keyboard-shortcuts)
* [General Settings](#general-settings)
* [Language Config](#language-config)
  * [Golang](#golang)
    * [Install Golang](#install-golang)
    * [Config Golang](#config-golang)
  * [Rust](#rust)
    * [Install Rust](#install-rust)
    * [Config Rust](#config-rust)
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
3. Install General extensions:
  * `Vim vscodevim.vim`
  * `VSCode Great Icons emmanuelbeziat.vscode-great-icons`
  * `Code Runner formulahendry.code-runner`
  * `Better TOML bungcip.better-toml`
  * `Docker Peterjausover.vscode-docker`
4. Install Golang extensions
  * `Go ms-vscode.go`
5. Install Rust extensions
  * `rust-analyzer by matklad.rust-analyzer`  
  * `CodeLLDB by Vadim Chugunov`  
  * `crates by Seray Uzgur`  
  * `Rust Test Lens by Hannes De Valkeneer`  

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

## Golang <a name="golang"></a>

### Install Golang <a name="install-golang"></a>
Install golang dependencies;

```bash
$ sudo pacman -S go go-tools go-bindata delve
```

### Config Golang <a name="config-golang"></a>
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

## Rust <a name="rust"></a>

### Install Rust <a name="install-rust"></a>
You'll need rust, the debugger and the musl target

```bash
$ sudo pacman -S rust rust-musl lldb
```

### Config Rust <a name="config-rust"></a>
1. Install and configure language server:
   a. Install extension `rust-analyzer by matklad.rust-analyzer`  
   b. Click `Yes` bottom right to install helper tooling  
2. Install and configure debugger support:
   a. Install extension `CodeLLDB by Vadim Chugunov`  
   b. Now switch to debug mode and click drop down `Add Configuration...` then `LLDB`  
   c. Cargo should popup a dialog click `Yes` which generates   
   d. Add `"sourceLanguages": ["rust"]` which will add two debug configs
3. Install and configure crate support:
   a. Install extension `Better TOML by bungcip`  
   b. Install extension `crates by Seray Uzgur`  
4. Install and configure unit test debug launching:
   a. Install extension `Rust Test Lens by Hannes De Valkeneer`  

## Troubleshooting <a name="troubleshooting"></a>

### Remove All Extensions <a name="remove-all-extensions"></a>
Extensions are stored in ***~/.vscode/extensions***

To clean up all extensions simply remove this directory
