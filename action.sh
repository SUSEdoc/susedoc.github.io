#!/bin/bash -e
#
# License: MIT

RED='\e[31m'; GREEN='\e[32m'; BLUE='\e[34m'; BOLD='\e[1m'; RESET='\e[0m'
log() { # $1 (optional) "+" green, "-" red; $2 message
  colorcode="$BLUE"
  [[ "$1" == '+' ]] && colorcode="$GREEN" && shift
  [[ "$1" == '-' ]] && colorcode="$RED" && shift
  echo -e "$colorcode${1}$RESET"
}
fail() { # $1 message
  echo -e "$RED$BOLD${1}$RESET"; exit 1
}
succeed() { # $1 message
  echo -e "$GREEN$BOLD${1}$RESET"; exit 0
}

# shellcheck disable=SC2046,SC2086,SC2005
me="$(test -L $(realpath $0) && readlink $(realpath $0) || echo $(realpath $0))"
mydir=$(dirname "$me")


#--


log "Setting up SSH/Git"

[[ -z "$DEPLOY_KEY" ]] && fail "The DEPLOY_KEY environment variable is unset. To clone/push the target repo, this script needs an SSH private key as a deploy key."

# /root/ is not the same as $HOME, and ssh -vvv indicates we need to use /root/
ssh_dir="/root/.ssh"
ssh_socket="/tmp/ssh-$RANDOM.sock"
mkdir "$ssh_dir"

key_file="$ssh_dir/id_rsa_deploy"
echo -e "$DEPLOY_KEY" > "$key_file"
# SSH refuses to use the key if it's world-readable
chmod 0600 "$key_file"
# Start the SSH authentication agent
ssh-agent -s -a "$ssh_socket"
export SSH_AUTH_SOCK="$ssh_socket"
# Display the key fingerprint from the file
ssh-keygen -lf "$key_file"
# Import the private key
ssh-add "$key_file"
# Display fingerprints of available SSH keys
ssh-add -l
# Accept foreign SSH key
ssh-keyscan github.com 2>/dev/null >> "$ssh_dir/known_hosts"
# Make sure we're always using the new SSH key for github.com repos
echo -e "\nHost gh\n  Hostname github.com\n  User git\n  IdentityFile $key_file" \
  >> "$ssh_dir/config"

# The custom_ssh command is useful for debugging SSH connectivity. If
# you're so inclined, you can add e.g. `-vvv` (but that make reading the log
# of `git clone` rather unpleasant, even a simple `-v` nets 60+ lines).
custom_ssh="$HOME/ssh-verbose"
echo 'ssh -v $@' > "$custom_ssh"
chmod +x "$custom_ssh"
export GIT_SSH="$custom_ssh"

mkdir ~/.ssh
ssh-keyscan github.com >> ~/.ssh/known_hosts

# Set the git username and email used for the commits
git config --global user.name "SUSE Doc Team CI"
git config --global user.email "doc-team@suse.com"


#--

short_sha=$(echo "$GITHUB_SHA" | cut -b1-8)

org_original="SUSEdoc"
clone_url="git@github.com:SUSEdoc/susedoc.github.io.git"
branch_conf="main"
branch_pub="gh-pages"

clone_conf="$PWD/sdghio-conf"
clone_pub="$PWD/sdghio-pub"

git_pub="git -C $clone_pub"


#--


branch_input=$(echo "$GITHUB_REF" | sed -r 's,^refs/heads/,,')
org_input="$GITHUB_REPOSITORY_OWNER"
[[ "$org_input" == "$org_original" ]] || succeed "We only build for the original repo under the SUSEdoc org, not for this fork. Stopping early."
[[ "$branch_input" == "$branch_conf" ]] || succeed "We only build for the branch '$branch_conf' but this is '$branch_input'. Stopping early."


#--


# Clone the repo we need to push to later on, make sure both necessary
# branches are available as local refs
git clone "$clone_url" "$clone_pub"
$git_pub checkout "$branch_conf"
$git_pub checkout "$branch_pub"

# From the original clone, create another clone, so we have the config too
git clone --branch "$branch_conf" "$clone_pub" "$clone_conf"


#--


path_config="$clone_conf/config.xml"
path_dtd="$clone_conf/_stuff/config.dtd"

path_upscript="$mydir/update-script/update-index.sh"

if [[ ! $(xmllint --noout --noent "$path_config" 2>&1) ]]; then
  log "Rebuilding index.html file after original commit $short_sha."
  "$path_upscript" "$path_config" "$path_dtd" "$clone_pub" || fail "Update-index script failed."
  $git_pub add 'r/' 'index.html'
  # shellcheck disable=SC2143
  echo -e "Changes in output:\n===="
  PAGER=cat $git_pub diff --cached -U0
  echo -e "====\n\n"
  if [[ $($git_pub diff -U0 --cached 'index.html' | sed -r -n -e '/^[-+]/ p' | sed -r -n -e '/^(\+\+\+|---|.*@@buildtimestamp@@)/ !p' | wc -l) -eq 0 \
        && -z $($git_pub status | grep -P '\br/') ]]; then
    succeed "It appears only the time stamp of index.html has changed. Not pushing."
  fi
else
  fail "$path_config is unavailable or invalid. Will not update index.html.\n"
fi


#--


# Add all changed files to the staging area, commit and push
$git_pub add "index.html" "r/"
log "Commit"
$git_pub commit -m "CI update of index.html/redirects after commit $short_sha"
log "Push"
$git_pub push "origin" "$branch_pub"

succeed "We're done."
