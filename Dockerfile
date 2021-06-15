FROM susedoc/mini-ci:openSUSE-42.3

COPY update-script/ /update-script/
COPY action.sh /action.sh
ENTRYPOINT ["/action.sh"]
