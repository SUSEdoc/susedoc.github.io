#!/bin/bash -e
#
# License: MIT

RED='\e[31m'
GREEN='\e[32m'
BLUE='\e[34m'
BOLD='\e[1m'
RESET='\e[0m' # No Color

log() {
  # $1 - optional: string: "+" for green color, "-" for red color
  # $2 - message
  colorcode="$BLUE"
  [[ "$1" == '+' ]] && colorcode="$GREEN" && shift
  [[ "$1" == '-' ]] && colorcode="$RED" && shift
  echo -e "$colorcode${1}$RESET"
}

fail() {
  # $1 - message
  echo -e "$RED$BOLD${1}$RESET"
  exit 1
}

succeed() {
  # $1 - message
  echo -e "$GREEN$BOLD${1}$RESET"
  exit 0
}


source env.list
REPO=$(echo "$TRAVIS_REPO_SLUG" | sed -e 's/.*\///g')
echo "TRAVIS_REPO_SLUG=\"$TRAVIS_REPO_SLUG\""
echo "REPO=\"$REPO\""
echo "TRAVIS_BRANCH=\"$TRAVIS_BRANCH\""

# Decrypt the SSH private key
openssl aes-256-cbc -md md5 -pass "pass:$ENCRYPTED_PRIVKEY_SECRET" -in ./ssh_key.enc -out ./ssh_key -d -a
# SSH refuses to use the key if its readable to the world
chmod 0600 ssh_key
# Start the SSH authentication agent
eval $(ssh-agent -s)
# Display the key fingerprint from the file
ssh-keygen -lf ssh_key
# Import the private key
ssh-add ssh_key
# Display fingerprints of available SSH keys
ssh-add -l

# Set the git username and email used for the commits
git config --global user.name "Travis CI"
git config --global user.email "$COMMIT_AUTHOR_EMAIL"

mkdir ~/.ssh
ssh-keyscan github.com >> ~/.ssh/known_hosts

PUBREPO=$(pwd)
GIT="git -C $PUBREPO"
BRANCH=$TRAVIS_BRANCH
NEWREMOTE="origin-ssh"

$GIT remote add "$NEWREMOTE" ssh://git@github.com/SUSEdoc/susedoc.github.io.git

CONFIGXML="index-config.xml"

if [[ ! $(cat "$CONFIGXML" | xmllint --noout --noent - 2>&1) ]]; then
  log "Rebuilding index.html file after original commit $TRAVIS_COMMIT."
  I_AM_A_MACHINE=1 ./update-index.sh
  if [[ $($GIT diff -U0 index.html | sed -r -n -e '/^\+/ p' | sed -r -n -e '/^\+\+\+/ !p' | wc -l) -le 1 ]]; then
    succeed "It seems only the time stamp of index.html has changed. Not pushing."
  fi
else
  fail "$CONFIGXML is unavailable or invalid. Will not update index.html.\n"
fi

# Add all changed files to the staging area, commit and push
$GIT add index.html
log "Commit"
$GIT commit -m "Travis update of index.html after commit ${TRAVIS_COMMIT}"
log "Push"
$GIT push $extraparams --set-upstream "$NEWREMOTE" "$(git rev-parse --abbrev-ref HEAD)"

succeed "We're done."
