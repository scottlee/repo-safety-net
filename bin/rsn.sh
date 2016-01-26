#!/usr/bin/env bash
# Vars
readonly VERSION="0.1.0"
readonly HOOK_TEMPLATE=https://raw.githubusercontent.com/scottlee/repo-safety-net/develop/bin/pre-commit
readonly PREFS_FILE=rsn.prefs

remote_url=""
installing=false
repo_path="$(pwd)"
git_path=false
hook_path=false

# Functions

read_prefs(){
    if [ -f rsn.prefs ]; then
        echo 'Reading Prefs'
        source rsn.prefs
        if [ $saved_remote_url ]; then
            remote_url=$saved_remote_url
        fi
    fi
}


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
   echo "$(curl -o $hook_path/pre-commit $HOOK_TEMPLATE)"
   chmod +x "$hook_path/pre-commit"
   echo "Hook Installed."
}


## Pretty rough at the moment but this is the idea for
## saving some per-repo settings
install_settings_file() {
    echo "Creating RSN preferences file"

    if [ -f "$PREFS_FILE" ]; then
       rm "$PREFS_FILE"
    fi
    
    touch "$PREFS_FILE"
    echo "prefs_installed=true" >> $PREFS_FILE
    echo "saved_remote_url=$remote_url" >> $PREFS_FILE
}

install_script(){
   is_repo_path_a_git_repo
   install_hook
   install_settings_file
}


get_status() {
    read_prefs
    if [ ! $remote_url ]; then
        echo "The remote url for the repo has not been set"
    else
        echo "Getting status for $remote_url"
        full_response=$(curl --silent "$remote_url")
        echo $full_response
    fi
}


version_information() {
    echo ""
    echo "Repo Safety Net: v$VERSION"
    echo ""
}



# Program

if ! options=$(getopt -o h, i, s, v -l help,install:,repo,status,version -- "$@")
then
    exit 1
fi

while [ $# -gt 0 ]
do
    case $1 in
    -h|--help)
        echo "Repo Safety Net"
        echo ""
        echo "VERSION:"
        echo "v$VERSION"
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
    -v|--version)
        version_information
        exit;;
    -i|--install)
        installing=true
        case "$2" in
            "") echo "Error: Please provide the remote url"; shift; exit 1;;
            *) remote_url="$2" ; shift;;
        esac;;
    -r|--repo)
        repo_path="$2" ; shift;;
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