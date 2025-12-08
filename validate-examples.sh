#!/bin/bash
set -x
set -e


# Specify the directory and the command
DIRECTORY="yang/examples"
COMMAND="yanglint -p . -p /Users/camilo/Documents/Projects/drafts/bmp_yang_model/other_examples/yang/experimental -p /Users/camilo/.pyenv/versions/3.13.5/share/yang/modules/ietf /Users/camilo/.pyenv/versions/3.13.5/share/yang/modules/iana/iana-hardware.yang  yang/ietf-entitlement-inventory.yang"

# Command for capability extension example (requires additional modules)
COMMAND_EXT="yanglint -p . -p /Users/camilo/Documents/Projects/drafts/bmp_yang_model/other_examples/yang/experimental -p /Users/camilo/.pyenv/versions/3.13.5/share/yang/modules/ietf /Users/camilo/.pyenv/versions/3.13.5/share/yang/modules/iana/iana-hardware.yang yang/ietf-entitlement-inventory.yang yang/examples/example-capability-framework.yang yang/examples/example-capability-extension.yang"

# Loop through all files in the directory
for FILE in "$DIRECTORY"/*
do
  # Check if it's a file (not a directory)
  if [ -f "$FILE" ]; then
    # Use extended command for capability extension JSON
    if [[ "$FILE" == *"example8-capability-extension.json" ]]; then
      $COMMAND_EXT "$FILE"
    else
      $COMMAND "$FILE"
    fi
  fi
done
