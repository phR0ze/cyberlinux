Github
====================================================================================================
<img align="left" width="48" height="48" src="../../../art/logo_256x256.png">
Github and git documentation for my use cases
<br><br>

### Quick links
* [.. up dir](..)
* [Git Large File Storage](#git-large-file-storage)

# Git Large File Storage <a name="git-large-file-storage"></a>
**WARNING** the git-lfs feature for Github is worthless as it has a 1Gb upload limit for opensource 
free accounts. Additionally it seems to interfere with powerline causing it to hang for a minute 
repeatedly. By turning off powerline in your shell before navigating to that project you can avoid 
this.

Git Large File Storage (LFS) replaces large files such as audio, videos, datasets and graphics with 
text pointers inside Git, while storing the file contents on a remote server like GitHub.com

1. Install the git-lfs extension for Arch Linux
   ```bash
   $ sudo pacman -S git-lfs
   ```
2. Navigate to the repo you'd like to use git-lfs for
   ```bash
   $ cd ~/Projects/cyberlinux-repo
   ```
3. Enable git-lfs for that repo which adds the configs `post-checkout`, `post-commit`, `post-merge`, 
   and `pre-push` to your local `.githooks` directory
   ```bash
   $ git lfs install
   ```
4. Configure the target extensions to track large file types
   ```bash
   $ git lfs track "*.zst"
   $ git lfs track "*.xz"
   ```
5. Now add all changes and commit them out and push them
   ```bash
   $ git add .
   $ git commit -m "Adding git lfs support"
   $ git lfs migrate import --everything --above=55Mb
   $ git push -f
   ```

<!-- 
vim: ts=2:sw=2:sts=2
-->
