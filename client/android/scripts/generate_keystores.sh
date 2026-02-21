#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEYSTORES_DIR="$(dirname "$SCRIPT_DIR")/keystores"
mkdir -p "$KEYSTORES_DIR"

if [ -f "$KEYSTORES_DIR/debug.keystore" ]; then
  echo "debug.keystore already exists, skipping"
else
  keytool -genkey -v -keystore "$KEYSTORES_DIR/debug.keystore" \
    -storepass android -alias androiddebugkey -keypass android \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -dname "CN=Android Debug,O=Android,C=US"
  echo "Created debug.keystore"
fi

if [ -f "$KEYSTORES_DIR/prod.keystore" ]; then
  echo "prod.keystore already exists, skipping"
else
  read -sp "Enter password for prod.keystore (default: assettuner_prod): " PROD_PASS
  echo
  PROD_PASS="${PROD_PASS:-assettuner_prod}"
  keytool -genkey -v -keystore "$KEYSTORES_DIR/prod.keystore" \
    -storepass "$PROD_PASS" -alias upload -keypass "$PROD_PASS" \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -dname "CN=Asset Tuner,OU=Mobile,O=Asset Tuner,C=US"
  echo "Created prod.keystore"
  echo ""
  echo "Add to client/android/key.properties (create from key.properties.example if needed):"
  echo "storePassword=$PROD_PASS"
  echo "keyPassword=$PROD_PASS"
  echo "keyAlias=upload"
  echo "storeFile=keystores/prod.keystore"
fi
