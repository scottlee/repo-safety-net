# Repo Safety Net

## Overview

Helps prevents commits to `origin/master` by first fetching the status of the repository. If the repository is advertised (via API endpoint) as closed the commit is blocked, locally. Conversely, if the repository is open the commit is accepted.

**This repository is comprised of two pieces:**

1. A WordPress plugin that creates an endpoint (example.com/repo-status/) for advertising a project repository status. 
2. A trio of Bash scripts that are installed as various Git hooks.

## Installation (Client)

1. `curl -O https://raw.githubusercontent.com/scottlee/repo-safety-net/master/bin/rsn.sh`
2. `chmod +x rsn.sh` 
3. Optional: `sudo mv rsn.sh /usr/local/bin/rsn`

## Installation (Server)

1. Clone this repo.
2. Activate the plugin.
3. Configure. (Plugins > Repo Safety Net)

## Usage
1. Clone a project repository as you normally would.
2. Install the pre-commit hook via rsn.sh `rsn install  -p example.com/repo-status/ -t vip` **Note:** The trailing slash is required for the URL.
3. Check the status of any repo with `rsn status` for the current dir or `rsn status ~/repos/my-awesome-project` to check a different one.
4. Help is available with `rsn help`

## Commands

`install`: Install the plugin for the current directory.

Params:

1. `-p` The remote url generated by the plugin.
2. `-t` The type of repo. Optional. Currently accepts `vip` or `git-only` as valid options. Default is `git-only`. This parameter dictates which git hooks are installed.


`status`: Get the status of a repo. Accepts a path to a repo or checks the current directory is nothing is passed
 
Example: `rsn status` or `rsn status ~/repos/my-awesome-project`

`help`: Generates help information.

## Changing Repo Types

Currently, changing repo types can be done by removing the installed git hooks manually from the. .git/hooks folder and then runnning `rsn install` with the new repo type.

