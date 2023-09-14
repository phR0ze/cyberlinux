Git, Bitbucket, Github, Github
====================================================================================================
<img align="left" width="48" height="48" src="../../../art/logo_256x256.png">
git documentation including public hosting such as github, gitlab and bitbucket
<br><br>

### Quick links
* [.. up dir](..)
* [Git](#git)
  * [Branches](#branch)
    * [Delete Branch](#delete-branch)
    * [Push Branch](#push-branch)
  * [Clone](#clone)
    * [Clone a specific branch](#clone-a-specific-branch)
  * [Cherry Pick](#cherry-pick)
  * [Diff](#diff)
    * [Diff Branches](#diff-branches)
    * [Diff Name Only](#diff-name-only)
    * [Diff Specific Dir](#diff-specific-dir)
    * [Diff Two Commits](#diff-two-commits)
  * [Hooks](#hooks)
    * [Set Local](#set-local)
  * [Reauthor](#reauthor)
    * [Reauthor Range](#reauthor-range)
  * [Rebase](#rebase)
    * [Squash](#squash)
  * [Remotes](#remotes)
    * [Add Remote](#add-remote)
    * [Rename Remote](#rename-remote)
  * [Resolve Conflicts](#resolve-conflicts)
  * [Tags](#tags)
    * [Checkout a tag](#checkout-a-tag)
    * [Delete All Tags](#delete-all-tags)
    * [Delete Matching Tags](#delete-matching-tags)
* [Bitbucket](#bitbucket)
  * [Bitbucket Static Pages](#bitbucket-static-pages)
    * [Bitbucket Publish Pages](#bitbucket-publish-pages)
  * [Bitbucket SSH Keys](#bitbucket-ssh-keys)
* [Github](#github)
  * [CLI](#cli)
  * [Actions](#actions)
    * [Build & Test Workflow](#build-and-test-workflow)
    * [Block PRs on failing checks](#block-prs-on-failing-checks)
    * [Add a Status Badge](#add-a-status-badge)
    * [Build Docker Image](#build-docker-image)
    * [Publish Docker Image](#publish-docker-image)
  * [Container Registry](#container-registry)
  * [Github Pages](#github-pages)
  * [Github Large File Storage](#github-large-file-storage)
  * [Security](#security)
    * [Codeowners](#codeowners)
* [Gitlab](#gitlab)
  * [Gitlab Pages](#gitlab-pages)

# Git

## Branches

### Delete Branch

* Delete Local Branch
  ```bash
  $ git branch -d <branch>
  ```

* Delete Remote Branch
  ```bash
  $ git push origin -d <branch>
  ```

### Push Branch

* Push to Different Name
Call out the remote first then the branch names `<local-name>:<remote-name>`

```bash
# Push local working to upstream/master
$ git push upstream working:master

# Push local master to upstream/fix
$ git push upstream master:fix
```

## Clone

* Clone a specific branch
  ```bash
  $ git clone --single-branch -b <branchname> <remote-repo>
  ```

## Cherry Pick
Git cherry-pick allows you to merg in a single commit from one branch to another.

```bash
$ git cherry-pick <HASH>
```

## Diff

### Diff Branches
```bash
$ git diff v1.0.0..v1.0.1
```

### Diff Name Only
```bash
$ git diff HEAD^ --name-only
```

* Diff Name Only with Excludes
You can exclude files from a diff with the `:(exclude)<pattern>` syntax.

```bash
# git diff HEAD~20 --name-only -- . ':(exclude)<pattern>'
$ git diff HEAD~20 --name-only -- . ':(exclude)vendor/*'
.gitignore
.vscode/launch.json
Gopkg.lock
Gopkg.toml
Makefile
README.md
VERSION
go.mod
go.sum
```

### Diff Specific Dir
```bash
$ git diff HEAD^ --name-only /dir/to/filter/on
```

### Diff Two Commits
```bash
$ git diff 176aaaaf fecb1299 --name-only
```

## Hooks

### Set Local
Often we'll want custom hooks to run after commits to auto incrementa a version number or something.
To do this create the hooks in your repo at `.githooks` then configure your repo to use the hooks.

```bash
# Change to your project root
cd ~/Projects/cyberlinux

# Set hooks to be used locally from your repo
git config core.hooksPath .githooks
```

## Reauthor

### Reauthor Range
1. Identify the last good commit:
   ```bash
   $ git log -5 --oneline
   31ce85f31 (HEAD -> staging) Patch nil reference bug
   6d74d628e Adding new Dockerfile and cleaning up README and Makefile
   d490c85c4 Versioning vendored packages
   038bad502 Simplifying root dir
   89bd14c15 (tag: v2.16.5, origin/release-2.16) Fixing validation issue
   ```
2. Invoke an interactive rebase and change all entries to `edit`:
   ```bash
   $ git rebase -i -p 89bd14c15
   ```
3. Each time rebase stops:
   ```bash
   $ git commit --amend --author="user <user@example.com>" --no-edit
   $ git rebase --continue
   ```

## Rebase
### Squash
```bash
# Squash the last 78 commits into a single commit
$ git rebase -i HEAD~78
```

## Remotes

### Add Remote
```bash
# syntax: git remote add <name> <url>
$ git remote add origin ssh://user@ip-address/root/path/to/project
```

### Rename Remote
```bash
# syntax: git remote rename <old> <new>
$ git remote rename origin upstream
```

## Resolve Conflicts
This can happen when your merging, rebasing or cherry-picking commits

```bash
# Run status to see conflicts
$ git status
On branch istio
Your branch is up to date with 'upstream/master'.

You are currently cherry-picking commit 3dc0eb85.
  (fix conflicts and run "git cherry-pick --continue")
  (use "git cherry-pick --abort" to cancel the cherry-pick operation)

Changes to be committed:
	modified:   project1/templates/deployment.yaml

Unmerged paths:
  (use "git add/rm <file>..." as appropriate to mark resolution)
	both modified:   project1/templates/cronjobs.yaml
	both modified:   project1/templates/db-migrate.yaml
	deleted by them: project1/templates/foo.yaml

# Now deal with them
# Manually: alias gf='vim `git diff --name-only --diff-filter=M | uniq`'
# Note in this context HEAD the new stuff your merging in
$ gf

# Mark them resolved
$ git add .

# Continue
$ git cherry-pick --continue
```

## Tags

### Checkout a Tag
```bash
$ git checkout -b <my branch> tags/<my tag>
```

### Delete All Tags

Delete all local tags
```bash
$ git tag -d $(git tag -l)
```

Fetch all remote tags
```bash
$ git fetch
```

Delete all remove tags
```bash
$ git push origin --delete $(git tag -l)
```

Delete all local tags
```bash
$ git tag -d $(git tag -l)
```

### Delete Matching Tags

Delete all matching local tags
```bash
# Deletes all local tags starting with 'v1'
$ git tag -d $(git tag -l "v1*")
```

Delete all matching remote tags
```bash
$ git push origin --delete $(git tag -l)
```

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

## CLI
In more complicated projects you'll want to automate github operations like posting PRs, assigning
reviewers or adding labels. These types of operations fall into the github automation category and
are served by a few different tools.

The [Github CLI](https://cli.github.com/) project brings Github to your terminal as a free an open
source project using terminology consistent with github. The [Github CLI is also written in GO](https://github.com/cli/cli)

## Actions
Actions is a completely free feature for github open source projects.

References:
* [Workflows](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/workflow-syntax-for-github-actions)
* [Trigger Events](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/events-that-trigger-workflows#webhook-events)

Terms:
* ***Steps*** are the most primitive types and run a command or an action.
* ***Actions*** are precanned composed of multiple commands that combine to form jobs.
* ***Jobs*** - each job runs in a specified container environment and combine to form workflows.
* ***Workflows*** are defined in YAML and composed of one or more jobs.

**Workflows:** 
* People with write or admin permissions to a repository can create, edit or view workflows. Workflows
  are custom automated process that you can set up in your repository to build, test, package, release
  or deploy any project on GitHub. GitHub has pre-built Actions store similar to CodeFresh. These
  reusable steps seem to be the next wave of CI/CD hotness. TravisCI and older platforms don't have
* Each `workflow` must have at least one `job` and a job must contain at least one `step`. Steps run
  commands or use an `action`.

**Useful actions to use in steps:**
* [Setup Go Env](https://github.com/marketplace/actions/setup-go-environment)

### Build & Test Workflow
GitHub hosted runners as referred to in the `runs-on` call out are virutal machines hosted by GitHub.
Each job in a workflow executes in a fresh instance of the virtual machine. All steps in a job
execute on the same instance of the virtual machine, allowing the actions in that job to share
information using the filesystem.

Filesystems on GitHub hosted runners have the following [env vars](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/using-environment-variables) listed you can use:
* ***HOME*** - user related data
* ***GITHUB_WORKSPACE*** - writable directory for actions and shell commands to execute in
* ***GITHUB_EVENT_PATH*** - The `POST` payload of the event that triggered the workflow
* ...

#### rust build and test
References:
* [Unofficial Github Actions](https://github.com/actions-rs/meta)
* [Clippy action](https://github.com/actions-rs/clippy-check)
* [grcov action](https://github.com/actions-rs/grcov)
* [Tarpaulin action](https://github.com/actions-rs/tarpaulin)

1. Create a new `.github/workflows` directory in your repository
````
$ mkdir -p .github/workflows
```

2. Create a new workflow file e.g. `.github/workflows/build.yaml`
```yaml
name: build

# Triggered on pushes to the repo
on: 
  push:
    branches:
    - main

# Jobs to execute when triggered
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v2

      - name: Install stable Rust toolchain
        uses: actions-rs/toolchain@v1
        with:
          toolchain: stable

      - name: Build application
        uses: actions-rs/cargo@v1
        with:
          command: build
          args: --all-features

      - name: Test application
        uses: actions-rs/cargo@v1
        with:
          command: test
          args: --all-features

      - name: Lint application
        uses: actions-rs/clippy-check@v1
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
```

#### rust code coverage
I'm using github actions with tarpaulin and codecov

References:
* [Tarpaulin github action](https://github.com/actions-rs/tarpaulin)

1. Sign in to codecov.io
2. Add repo
3. Copy the upload token:
4. Login to github and navigate to `Settings >Secretes`  
   a. Click `New repository secret`  
   b. Set name to `CODECOV_TOKEN`  
   c. Set value to the value copied from codecov.io  
   d. Click `Add secret`  
5. Add two new blocks to our previous workflow
   ```yaml
      - name: Clean
        uses: actions-rs/cargo@v1
        with:
          command: clean

      - name: Tarpaulin code coverage
        id: coverage
        uses: actions-rs/tarpaulin@v0.1

      - name: Upload to codecov.io
        uses: codecov/codecov-action@v1.0.2
        with:
          token: ${{secrets.CODECOV_TOKEN}}
   ```

#### golang build and test<a name="golang-build-and-test"/></a>
1. Create a new `.github/workflows` directory in your repository

2. Create a new workflow file e.g. `.github/workflows/build.yaml`
```yaml
name: build

# Triggered on pushes to the repo
on: 
  push:
    branches:
    - master

# Jobs to execute when triggered
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Standard action to pull source
        uses: actions/checkout@v2
      - name: Setup Go build environment
        uses: actions/setup-go@v2
        with:
          go-version: 1.15.3
      - name: Build application
        run: |
          make
      - name: Test application
        run: |
          make test
```

### Add a Status Badge
https://help.github.com/en/actions/automating-your-workflow-with-github-actions/configuring-a-workflow#adding-a-workflow-status-badge-to-your-repository

You must call out the workflow that the status should be associated with and if your workflow uses
the `name` keyword you need to use that else use the full path of the file. And if you have spaces in
the name you need to encode that.

Example:
```
# template
![](https://github.com/<OWNER>/<REPOSITORY>/workflows/<WORKFLOW_NAME>/badge.svg)

# template example
![](https://github.com/my-owner/hello-world/workflows/.github/workflows/build.yaml/badge.svg)

# Working with workflow name called out from `name` field
https://github.com/phR0ze/alpine-base/workflows/Build%20Docker%20Image/badge.svg

# Working example simply using the root filename of workflow
![build](https://github.com/phR0ze/witcher/workflows/build/badge.svg?branch=main)

[![build-badge](https://github.com/phR0ze/alpine-base/workflows/build/badge.svg)](https://github.com/phR0ze/alpine-base/actions)
```

### Build Docker Image
Create a basic docker image builder workflow `.github/workflows/build.yaml`:
```yaml
name: Build Docker Image
on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1
    - name: Build Docker image
      run: docker build . --file Dockerfile --tag alpine-base:$(date +%s)
```

### Publish Docker Image
We'll have to use dockerhub as GitHub's packages require authentication to pull from.

1. Create DockerHub secrets in Github:  
   a. Navigate to `Settings >Secrets`  
   b. Click `Add a new secret`  
   c. Fill out `DOCKERHUB_USER` and value  
   d. Fill out `DOCKERHUB_PASS` and value  

Create a basic docker image builder workflow `.github/workflows/publish.yaml`:
```yaml
name: Publish Docker Image
on:
  release:
    types: [published]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1
    - name: Build Docker image
      run: docker build . --file Dockerfile --tag alpine-base:${GITHUB_REF}
```

## Container Registry
Github container registry uses a new domain `ghcr.io/OWNER/IMAGE_NAME` e.g.
`ghcr.io/phR0ze/alpine-net`.

**References**:
* [Container Registry About](https://docs.github.com/en/packages/guides/about-github-container-registry)

ITS A JOKE - DATA TRANSFER LIMITS ARE RIDICULOUS

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

## Security

### Codeowners
[CODEOWNERS](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners) 
are automatically requested for review when someone opens a pull request that modifies code that they 
own. Code owners are not automatically requested to review draft pull requests; however once the PR 
is marked as ready for review the codeowners are automatically notified. This feature when combined 
with the branch protection rule to `Require review from Code Owners` effectively blocks merges 
without proper eyes seeing the changes.

* the last matching entry has the highest level of precedence

* File location

* File syntax
[Codeowners file syntax](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners#codeowners-syntax)
Consists of patterns similar to a gitignore file with owners associated with the file pattern 
matches.

* gitignore type file pattern match followed by one or more users or groups using the `@org/team-name` format

# Gitlab

## Gitlab Pages
**Reference**
* [Gitlab Pages docs](https://docs.gitlab.com/ee/user/project/pages/)
* [100MB max artifact size](https://docs.gitlab.com/ee/administration/instance_limits.html)


<!-- 
vim: ts=2:sw=2:sts=2
-->
