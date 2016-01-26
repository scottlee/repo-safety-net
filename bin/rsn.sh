#!/usr/bin/env bash
# Vars

remote_url=false
installing=false
repo_path="$(pwd)"
git_path=false
hook_path=false

if [ -f rsn.prefs ]; then
    echo 'Reading Prefs'
    source rsn.prefs
    if [ $saved_remote_url ]; then
        remote_url=$saved_remote_url
    fi
fi

# Functions
is_repo_path_a_git_repo() {
    git_path="$repo_path/.git"

    if [ ! -d $git_path ]; then
        echo "Error: $repo_path is not a git repository"
        exit 1
    fi
}

install_hook(){
   echo "Installing pre-commit hook"
   hook_path="$git_path/hooks"
   echo "Downloading hook..."
   echo "$(curl -o $hook_path/pre-commit https://raw.githubusercontent.com/ryanwelcher/repo-safety-net/develop/bin/pre-commit.rsn)"
   chmod +x "$hook_path/pre-commit"
   echo "Hook Installed."
}


## Pretty rough at the moment but this is the idea for
## saving some per-repo settings
install_settings_file() {
    echo "Creating RSN preferences file"
    if [ ! -f rsn.prefs ]; then
        touch rsn.prefs
        echo "prefs_installed=true" >> rsn.prefs
    fi
    echo "saved_remote_url=$remote_url" >> rsn.prefs
}

install_script(){
   is_repo_path_a_git_repo
   #install_hook
   install_settings_file
}


get_status() {
    echo "Getting status for $remote_url"
}



# Program

if ! options=$(getopt -o h, i, s -l help,install:,status -- "$@")
then
    exit 1
fi

while [ $# -gt 0 ]
do
    case $1 in
    -h|--help)
        echo "Repo Safety Net"
        echo ""
        echo ""
        echo "USAGE:"
        echo "   ./bin/rsn.sh [options]"
        echo ""
        echo "OPTIONS:"
        echo " -h, --help       Destroys humanity or tells you how to use this - I can't remember"
        echo " -i, --install:    Installs the script and the git hook to this repo"
        echo " -s, --status     Get the status of this repo."
        exit;;
    -s|--status)
        get_status
        exit;;
    -i|--install)
        installing=true
        remote_url="$2" ; shift;;
    (--) shift;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
    (*) shift;;
    esac
    shift
done


if [[ $installing && $remote_url ]]; then
    echo "Installing Repo Safety Net for:"
    echo "Repo: $repo_path"
    echo "Remote Endoint: $remote_url"
    install_script
else
    echo "Please specify the repo you want to connect to:"
    echo "rsh --install 'http://path.com/endpoint'"
    exit 1
fi