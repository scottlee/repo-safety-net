# Repo Safety Net

## Overview

Helps prevents commits to `origin/master` by first fetching the status of the repository. If the repository is advertised (via API endpoint) as closed the commit is blocked, locally. Conversely, if the repository is open the commit is accepted.

**This repository is comprised of two pieces:**

1. A WordPress plugin that creates an endpoint (example.com/repo-status) for advertising a project repository status. 
2. A pair of Bash scripts. One for installing a Git pre-commit hook. And the other is the pre-commit hook itself.

## Installation (Client)

1. `curl -O https://raw.githubusercontent.com/scottlee/repo-safety-net/develop/bin/rsn.sh`
2. `chmod +x rsn.sh` 
3. Optional: `sudo mv rsn.sh /usr/local/bin/rsn`

## Installation (Server)

1. Clone this repo.
2. Activate the plugin.
3. Configure. (Plugins > Repo Safety Net)

## Usage
1. Clone a project repository as you normally would.
2. Install the pre-commit hook via rsn.sh `rsn --install example.com/repo-status path/to/repository`

## Future Ideas

- Have the pre-commit only hit the API once by parsing results.
- Log the activity of when/who locked the repo.
- "Re-enable the repo after ___ hours"

