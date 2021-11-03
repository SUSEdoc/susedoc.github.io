FROM registry.opensuse.org/documentation/containers/containers/opensuse-git-ssh:latest

COPY update-script/ /update-script/
COPY action.sh /action.sh
ENTRYPOINT ["/action.sh"]
