echo "Validating yang modes"

PYANG_INPUT='yang/ietf-entitlement-inventory.yang'

pyang --ietf --max-line-length 69 $PYANG_INPUT

# Compare
for orig in $PYANG_INPUT; do
  pyang --ietf --yang-line-length 69 -f yang --yang-canonical "$orig" > /tmp/canonical.yang
  if ! diff -q "$orig" /tmp/canonical.yang; then
    echo "ERROR: $orig is not canonical. Run: pyang -f yang --yang-line-length 69 --yang-canonical -o \"$orig\" \"$orig\""
    exit 1
  fi
done

yanglint -p . -p /Users/camilo/Documents/Projects/drafts/bmp_yang_model/other_examples/yang/experimental  yang/ietf-entitlement-inventory.yang  -f yang > /dev/null

