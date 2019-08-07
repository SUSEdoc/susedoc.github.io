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
CONFIGDTD="config.dtd"

[[ $TRAVIS_BRANCH == "master" ]] || succeed "We currently only build for master. Stopping early."
[[ $(echo "$TRAVIS_COMMIT_MESSAGE" | head -1 | grep -oP "^\[auto-commit\]") ]] && succeed "This commit appears to have been created automatically by Travis. Stopping early."

$GIT checkout "$TRAVIS_BRANCH"

if [[ ! $(cat "$CONFIGXML" | xmllint --noout --noent - 2>&1) ]]; then
  log "Rebuilding index.html file after original commit $TRAVIS_COMMIT."
  I_AM_A_MACHINE=1 ./update-index.sh
  [[ $? -eq 0 ]] || fail "Update-index script failed."
  git add 'r/'
  if [[ $($GIT diff -U0 index.html | sed -r -n -e '/^[-+]/ p' | sed -r -n -e '/^(\+\+\+|---|.*@@buildtimestamp@@)/ !p' | wc -l) -eq 0 \
        && -z $(git status | grep -P '\br/') ]]; then
    succeed "It seems only the time stamp of index.html has changed. Not pushing."
  fi
else
  fail "$CONFIGXML is unavailable or invalid. Will not update index.html.\n"
fi

# Add all changed files to the staging area, commit and push
$GIT add index.html r/
log "Commit"
$GIT commit -m "[auto-commit] Travis update of index.html after commit ${TRAVIS_COMMIT}"
log "Push"
$GIT push $extraparams --set-upstream "$NEWREMOTE" "$TRAVIS_BRANCH"

succeed "We're done."
