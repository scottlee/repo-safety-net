#!/usr/bin/env bash
# Vars
readonly VERSION="0.1.0"
readonly HOOK_TEMPLATE=https://raw.githubusercontent.com/scottlee/repo-safety-net/develop/bin/pre-commit
readonly PRE_PUSH=https://raw.githubusercontent.com/scottlee/repo-safety-net/develop/bin/pre-commit
readonly PREFS_FILE=rsn.prefs

remote_url=""
repo_type="git-only"
installing=false
repo_path="$(pwd)"
git_path=false
hook_path=false

# Functions

read_prefs(){

    ## We can pass a path to the
    ## preferences file we want to load
    if [ ! -z $1 ]; then
        prefs_to_load=$1
    else
        prefs_to_load="$repo_path/$PREFS_FILE"
    fi

    ## Check for the prefs file
    if [ ! -f $prefs_to_load ]; then
        echo "Error: No preferences file exists at $prefs_to_load"
        exit 1
    fi

    #If we're here, we can load the prefs
    source $prefs_to_load

    if [ $saved_remote_url ]; then
        remote_url=$saved_remote_url
    fi
}


## Optional arg for a path to check
## otherwise use this dir as the repo
is_repo_path_a_git_repo() {
    if [ ! -z $1 ]; then
         git_path="$1/.git"
    else
        git_path="$repo_path/.git"
    fi

    if [ ! -d $git_path ]; then
        echo "Error: $repo_path is not a git repository"
        exit 1
    fi
}


# The main install routine
install() {
    if [[ $installing && $remote_url ]]; then
        echo "Installing Repo Safety Net for:"
        echo "Repo: $repo_path"
        echo "Remote Endoint: $remote_url"
        is_repo_path_a_git_repo
        install_hook
        install_settings_file

        echo "Installation Complete"
    else
        echo "Please specify the repo you want to connect to:"
        echo "rsh --install 'http://path.com/'"
        exit 1
    fi
}



install_hook(){
   echo "Installing pre-commit hook ... "
   hook_path="$git_path/hooks"
   echo "Downloading hook..."
   echo "$(curl -#o $hook_path/pre-commit $HOOK_TEMPLATE)"
   chmod +x "$hook_path/pre-commit"
   echo "Hook Installed."
}


## Pretty rough at the moment but this is the idea for
## saving some per-repo settings
install_settings_file() {
    echo "Creating RSN preferences file ... "

    if [ -f "$PREFS_FILE" ]; then
       rm "$PREFS_FILE"
    fi
    
    touch "$PREFS_FILE"
    echo "prefs_installed=true" >> $PREFS_FILE
    echo "saved_remote_url=$remote_url" >> $PREFS_FILE
    echo "repo_type=$repo_type" >> $PREFS_FILE

    echo "Preferences saved"
}


get_status() {
    if [ ! -z $1 ]; then
        passed_repo=$1
        prefs_path="$passed_repo/$PREFS_FILE"

        if [ ! -d $passed_repo ]; then
            echo "Error: $passed_repo is not a valid directory. Please use the full path."
            exit 1
        fi

        is_repo_path_a_git_repo $passed_repo

        read_prefs $prefs_path
    else
        read_prefs
    fi

    if [ ! "$remote_url" ]; then
        echo "The remote url for the repo has not been set"
    else
        echo "Getting status for $remote_url"

        full_response=$( curl -qsw '\n%{http_code}' "$remote_url" ) 2>/dev/null
        header=$(echo "$full_response"| tail -n1)
        if [[ "200" = "$header" ]]; then
            body=$(echo "$full_response"  | head -n1)
        elif [[ "404" = $header ]]; then
            body="Error: The remote url returned a 404."
        else
            body=$(echo "$full_response"  | head -n4)
        fi
        echo "$body"



    fi
}


version_information() {
    echo ""
    echo "Repo Safety Net: v$VERSION"
    echo ""
}



# Program

if ! options=$(getopt -o h, i, s, v -l help,install:,status,version,isvip -- "$@")
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
        case "$1" in
            "") get_status; exit;;
            *) get_status "$2"; shift;;
        esac
        exit;;
    -v|--version)
        version_information
        exit 1;;
    -i|--install)
        installing=true
        case "$2" in
            "") echo "Error: Please provide the remote url"; shift; exit 1;;
            *) remote_url="$2" ;
        esac
        case "$3" in
            "") repo_type="git-only"; shift;;
            "--isvip") repo_type="vip" ; shift;;
        esac
        # Run the install routine
        install
        exit 1;;
    (--) shift;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
    (*) shift;;
    esac
    shift
done