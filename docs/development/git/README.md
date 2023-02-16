Git, Bitbucket, Github, Github
====================================================================================================
<img align="left" width="48" height="48" src="../../../art/logo_256x256.png">
git documentation including public hosting such as github, gitlab and bitbucket
<br><br>

### Quick links
* [.. up dir](..)
* [Bitbucket](#bitbucket)
  * [Bitbucket Static Pages](#bitbucket-static-pages)
    * [Bitbucket Publish Pages](#bitbucket-publish-pages)
  * [Bitbucket SSH Keys](#bitbucket-ssh-keys)
* [Github](#github)
  * [Github Pages](#github-pages)
  * [Github Large File Storage](#github-large-file-storage)
* [Gitlab](#gitlab)
  * [Gitlab Pages](#gitlab-pages)

# Bitbucket

## Bitbucket Static Pages
* [Repo and file size limits](https://confluence.atlassian.com/bbkb/what-are-the-repository-and-file-size-limits-1167700604.html)
* [Repo size limits](https://bitbucket.org/blog/repository-size-limits)
* [Configure static website](https://support.atlassian.com/bitbucket-cloud/docs/publishing-a-website-on-bitbucket-cloud/)

* Limitations
  * 1 GB repo soft limit
  * 2 GB repo hard limit
  * 5000 requests per hour
  * 2 GB archive.zip files
  * Upload file size limit of 1GB?
    * I was able to push 115MB so maybe
  * Push limit of 3.5 GB/hour
* Features
  * Unlimited private repos
  * Git LFS limit of 1GB
* Workspace affects the clone URL
  * e.g. `git clone https://bitbucket.org/cyberlinux/aur.git`

### Bitbucket Publish Pages
[Reference](https://support.atlassian.com/bitbucket-cloud/docs/publishing-a-website-on-bitbucket-cloud/)
1. Create a new repository
   1. Set the Project name to `cyberlinux.bitbucket.io`
   2. Clone your repo with git protocol `git@bitbucket.org:cyberlinux/cyberlinux.bitbucket.io.git`
2. Add a `index.html` to the root of your project and commit and push the changes
3. Navigate to your new site [https://cyberlinux.bitbucket.io/](https://cyberlinux.bitbucket.io)
4. Directories are treated as their own sites
   1. Create a new directory `packages`
   2. Add nested directories to that dir `packages/cyberlinux/x86_64`
   3. This will then be accessible from arch linux with `Server = https://cyberlinux.bitbucket.io/packages/$repo/$arch`
5. Adding a new package
   1. Navigate to `~/Projects/cyberlinux.bitbucket.io/packages/cyberlinux/x86_64`
   2. Copy the target package here
   3. Remove stale index files `rm cyberlinux.*`
   4. Rebuild the index files `repo-add cyberlinux.db.tar.gz *.pkg.tar.*`
   5. Replace soft links with hard links for bitbucket to play nice
      ```
      $ ln cyberlinux.db.tar.gz cyberlinux.db -f
      $ ln cyberlinux.files.tar.gz cyberlinux.files -f
      ```

## Bitbucket SSH Keys
Use SSH to avoid password prompts when you push code to Bitbucket

1. Edit your ssh config `~/.ssh/config`
2. Add a match block for bitbucket
   ```
   HostName bitbucket.org
   IdentityFile ~/.ssh/id_rsa
   ```
3. Now Navigate to your workspace root in bitbucket
4. Click the `SSH keys` option on the left
5. Click `Add key`
6. Give the key a label then paste in your public key

# Github

## Github Pages
Github pages are pretty slick as they provide a simple way to create a static website for your 
project. Originally I used this as a nice way to host package files for my Arch Linux distro. However 
Github Pages has a strict file size limit of 100MB which makes this use case difficult as more and 
more packages are exceeding the limit these days.

## Github Large File Storage
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

# Gitlab

## Gitlab Pages
**Reference**
* [Gitlab Pages docs](https://docs.gitlab.com/ee/user/project/pages/)
* [100MB max artifact size](https://docs.gitlab.com/ee/administration/instance_limits.html)


<!-- 
vim: ts=2:sw=2:sts=2
-->
