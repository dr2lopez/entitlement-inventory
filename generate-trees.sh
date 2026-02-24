#!/bin/bash
# Generate tree files from the YANG module
# This ensures documentation trees stay in sync with the actual model

set -euo pipefail
set -x  # print commands as they run

trap 'rc=$?; echo "::error::generate-trees.sh failed (exit=$rc) at line $LINENO: $BASH_COMMAND"; exit $rc' ERR

YANG_DIR="yang"
TREES_DIR="trees"
YANG_TREES_DIR="yang/trees"

# Paths for pyang
LOCAL_EXPERIMENTAL="/Users/camilo/Documents/Projects/drafts/bmp_yang_model/other_examples/yang/experimental"

# Where to clone if LOCAL_EXPERIMENTAL doesn't exist
YANG_REPO_DIR="${YANG_REPO_DIR:-${RUNNER_TEMP:-/tmp}/yang}"
YANG_REPO_URL="https://github.com/YangModels/yang.git"

mkdir -p "${TREES_DIR}" "${YANG_TREES_DIR}"

if [[ -d "${LOCAL_EXPERIMENTAL}" ]]; then
  echo "Using local experimental folder: ${LOCAL_EXPERIMENTAL}"
  export YANG_MODPATH="${LOCAL_EXPERIMENTAL}/ietf-extracted-YANG-modules"
  export PYANG_PATHS="-p . -p ${LOCAL_EXPERIMENTAL}"
else
  echo "Local experimental folder not found; cloning YangModels/yang into: ${YANG_REPO_DIR}"
  mkdir -p "$(dirname "${YANG_REPO_DIR}")"

  if [[ ! -d "${YANG_REPO_DIR}/.git" ]]; then
    rm -rf "${YANG_REPO_DIR}" || true
    git clone --depth 1 "${YANG_REPO_URL}" "${YANG_REPO_DIR}"
  fi

  export YANG_MODPATH="${YANG_REPO_DIR}/experimental/ietf-extracted-YANG-modules"
  export PYANG_PATHS="-p . -p ${YANG_REPO_DIR}/experimental"
fi

echo "YANG_MODPATH=${YANG_MODPATH}"
echo "PYANG_PATHS=${PYANG_PATHS}"


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
