# VSCODE
Building the open source version of Visual Studio Code

* including marketplace access

## Patching
1. Copy source to ***a*** and ***b***
2. Make changes as desired in ***b***
3. Run:
```bash
diff -ruN a b > vscode.patch
```
