# Repo Safety Net

**Note: Currently a WIP on the `develop` branch. Use at your own risk.**

Creates a simple endpoint (example.com/repo-status) for advertising a project repository status. Used in conjunction with a Git pre-commit hook.


## The future?

 - A better way to copy the pre-commit file locally.
 - Have the pre-commit only hit the API once by parsing results.
 - Log the activity of when/who locked the repo.
 - "Re-enable the repo after ___ hours"
 - Restrict pre-commit script to running only on master.

