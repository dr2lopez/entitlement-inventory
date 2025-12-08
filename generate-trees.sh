#!/bin/bash
# Generate tree files from the YANG module
# This ensures documentation trees stay in sync with the actual model

set -e

YANG_DIR="yang"
TREES_DIR="trees"
YANG_TREES_DIR="yang/trees"

# Paths for pyang
PYANG_PATHS="-p . -p /Users/camilo/Documents/Projects/drafts/bmp_yang_model/other_examples/yang/experimental"

# Generate the full tree (already exists in yang/trees/)
echo "Generating full tree..."
pyang -f tree $PYANG_PATHS $YANG_DIR/ietf-entitlement-inventory.yang > $YANG_TREES_DIR/ietf-entitlement-inventory.tree

# Generate capability subtree (extract from first network-element augment only)
echo "Generating capability subtree..."
pyang -f tree $PYANG_PATHS $YANG_DIR/ietf-entitlement-inventory.yang 2>/dev/null | \
  awk '/\+--ro capabilities!/,/^  augment|^$/' | \
  head -20 | \
  grep -v "^  augment" | grep -v "^$" | \
  sed 's/^   //' > $TREES_DIR/capability_tree.txt

# Generate entitlements subtree
echo "Generating entitlements subtree..."
pyang -f tree $PYANG_PATHS $YANG_DIR/ietf-entitlement-inventory.yang 2>/dev/null | \
  awk '/augment \/inv:network-inventory:$/,/^$/' | \
  grep -v "^  augment" | \
  sed 's/^   //' > $TREES_DIR/entitlements_tree.txt

# Generate installed-entitlements subtree (from network-element augment)
echo "Generating installed-entitlements subtree..."
pyang -f tree $PYANG_PATHS $YANG_DIR/ietf-entitlement-inventory.yang 2>/dev/null | \
  awk '/\+--ro installed-entitlements!/,/^  augment|^$/' | \
  head -4 | \
  grep -v "^  augment" | grep -v "^$" | \
  sed 's/^   //' > $TREES_DIR/installed_entitlments_tree.txt

echo "Tree generation complete."
echo ""
echo "Generated files:"
ls -la $TREES_DIR/*.txt
ls -la $YANG_TREES_DIR/*.tree
