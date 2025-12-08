#!/bin/bash
# Script to generate YANG tree diagrams for the entitlement-inventory model

set -e

# Output directory
OUTPUT_DIR="yang/trees"

# Search paths for dependent modules
SEARCH_PATHS="-p . -p /Users/camilo/Documents/Projects/drafts/bmp_yang_model/other_examples/yang/experimental/ietf-extracted-YANG-modules -p /Users/camilo/.pyenv/versions/3.13.5/share/yang/modules/ietf/ -p /Users/camilo/.pyenv/versions/3.13.5/share/yang/modules/iana/"

# YANG module
YANG_MODULE="yang/ietf-entitlement-inventory.yang"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo "Generating YANG tree diagram..."

# Generate the tree
pyang $SEARCH_PATHS -f tree "$YANG_MODULE" > "$OUTPUT_DIR/ietf-entitlement-inventory.tree"

echo "Tree generated: $OUTPUT_DIR/ietf-entitlement-inventory.tree"

# Also display the tree
echo ""
echo "=== YANG Tree ==="
cat "$OUTPUT_DIR/ietf-entitlement-inventory.tree"
