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
  * [tasks.json](#tasks-json)
* [General Settings](#general-settings)
  * [Powerline glyphs in terminal](#powerline-glyphs-in-terminal)
* [Language Config](#language-config)
  * [Golang](#golang)
    * [Install Golang](#install-golang)
    * [Config Golang](#config-golang)
    * [Debug with dlv](#debug-with-dlv)
  * [Rust](#rust)
    * [Install Rust](#install-rust)
    * [Config Rust](#config-rust)
    * [Rust tasks](#rust-tasks)
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
   | Name                 | Identifier                            |
   | -------------------- | ------------------------------------- |
   | Vim                  | `vscodevim.vim`                       |
   | VSCode Great Icons   | `emmanuelbeziat.vscode-great-icons`   |
   | Code Runner          | `formulahendry.code-runner`           |
   | Better TOML          | `bungcip.better-toml`                 |
   | Docker               | `ms-azuretools.vscode-docker`         |

4. Install Golang extensions
   | Name                 | Identifier                            |
   | -------------------- | ------------------------------------- |
   | Go                   | `golang.go`                           |

5. Install Rust extensions
   | Name                 | Identifier                            |
   | -------------------- | ------------------------------------- |
   | rust-analyzer        | `matklad.rust-analyzer`               |
   | CodeLLDB             | `vadimcn.vscode-lldb`                 |
   | crates               | `serayuzgur.crates`                   |

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
    },
    {
        "key": "ctrl+shift+r",
        "command": "workbench.action.tasks.runTask",
        "args": "Run"
    }
]
```

## tasks.json <a name="tasks-json"></a>
Every project requires the creation of the `.vscode/tasks.json` file to map keybindings to your 
specific project.

* see [Rust tasks](#rust-tasks)

# General Settings <a name="general-settings"></a>
Configuration is saved at `~/.config/Code/User/settings.json`

Hit `Ctrl+Shift+p` and search for `json` and select `Preferences: Open Settings(JSON)`
```json
{
    // General configuration
    "explorer.confirmDelete": false,
    "explorer.confirmDragAndDrop": false,
    "telemetry.enableTelemetry": false,
    "telemetry.enableCrashReporter": false,
    "workbench.iconTheme": "vscode-great-icons",
    "terminal.integrated.fontFamily": "InconsolataGo Nerd Font Mono",
    "terminal.integrated.fontSize": 16,

    // Editor configuration
    "editor.tabSize": 4,
    "editor.insertSpaces": true,
    "editor.minimap.enabled": true,
    "editor.fontSize": 14,
    "editor.fontFamily": "Inconsolata-g",
    "editor.formatOnPaste": true,
    "editor.formatOnSave": true,

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
    },

    // Golang configuration
    "go.gopath": "~/Projects/go",           // Set the GOPATH to use
    "go.formatTool": "goimports",           // Use specific external format tool for go
    "go.useLanguageServer": true,           // Use the new gopls language server
    "[go]": {
        "editor.snippetSuggestions": "none",
        "editor.formatOnSave": true,
        "editor.codeActionsOnSave": {
            "source.organizeImports": true
        }
    },
    "gopls": {
        "usePlaceholders": false,           // add parameter placeholders when completing a function
        "completionDocumentation": true     // for documentation in completion items
    },
    "go.toolsManagement.autoUpdate": true,  // autoupdate gopls tools
    "files.eol": "\n",                      // gopls formatting only supports LF line endings

    // Rust configuration
    "rust-analyzer.inlayHints.enable": false, // turn off the inline types
}
```

## Powerline glyphs in terminal <a name="powerline-glyphs-in-terminal"/></a>
Powerline depends on fonts that support the particular glyphs that it uses. In order to get them to 
show up properly you need to install the right fonts then set VSCode to use the correct fonts for the 
terminal.

1. Install dependency fonts
   ```bash
   $ sudo pacman -S nerd-fonts-inconsolata-go
   ```
2. Determine the font name to use
   ```bash
   $ fc-list | grep -i inconsolata
   /usr/share/fonts/TTF/ttf-inconsolata-g.ttf: Inconsolata\-g:style=g
   ...
   /usr/share/fonts/TTF/InconsolataGo Nerd Font Complete Mono.ttf: InconsolataGo Nerd Font Mono:style=Regular
   ```
3. Copy out the portion after the first colon
   ```
   Inconsolata-g
   InconsolataGo Nerd Font Mono
   ```
3. Hit `Ctrl+Shift+p` and choose `Preferences: Open Settigns (JSON)` then add
   ```json
   "editor.fontFamily": "Inconsolata-g"
   "editor.fontSize": 14
   "terminal.integrated.fontFamily": "InconsolataGo Nerd Font Mono"
   "terminal.integrated.fontSize": 16
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

### Debug with dlv <a name="debug-with-dlv"></a>
The golang extension that we installed ealier will fire the first time you open a golang project and 
ask if you want to download the missing helper tools, say yes to all and it will install `dlv-dap` 
into your go path and keep it up to date i.e. `~/Projects/go/bin` for cyberlinux.

`dlv-dep` should just work out of the box once you have a config setup below.

**Create a new debug config, example replace `PACKAGE` below with your package**
```
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Launch",
            "type": "go",
            "request": "launch",
            "mode": "auto",
            "program": "${workspaceFolder}/cmd/PACKAGE",
            "env": { },
            "args": [
            ]
        }
    ]
}
```

## Rust <a name="rust"></a>

### Install Rust <a name="install-rust"></a>
The Rust `toolchain` is all the necessary build components for your local system while a `target` is 
the ability to cross compile to another platform.

1. Install rust via rustup and the rust debugger lldb
   ```bash
   $ sudo pacman -S rustup lldb
   $ rustup default stable
   ```
2. List all available targets and see which are installed
   ```bash
   $ rustup target list
   ```
3. Install musl target
   ```bash
   $ rustup target add x86_64-unknown-linux-musl
   ```
3. Install android targets for NDK dev
   ```bash
   $ rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android
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
4. Configure Rust Analyzer to not show automatic types

### Rust tasks <a name="rust-tasks"></a>
If you use a `workbench.action.tasks.runTask` in your keybindings it points to your local 
`.vscode/tasks.json` file which you can then associate to a specific task using the keybinding's 
`args` to your tasks.json's `label` mapping. `Build` and `Test` are predetermined labels that vscode 
already understands.

```bash
$ mkdir -p .vscode
tee .vscode/tasks.json <<EOL
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Build",
      "type": "shell",
      "command": [
        "cargo build --all-features",
      ],
      "group": {
        "kind": "build",
        "isDefault": true
      }
    },
    {
      "label": "Test",
      "type": "shell",
      "command": "cargo test --all-features",
      "group": {
        "kind": "test",
        "isDefault": true
      }
    },
    {
      "label": "Run",
      "type": "shell",
      "command": "cargo run"
    }
  ]
}
EOL
```

## Troubleshooting <a name="troubleshooting"></a>

### Remove All Extensions <a name="remove-all-extensions"></a>
Extensions are stored in ***~/.vscode/extensions***

To clean up all extensions simply remove this directory
