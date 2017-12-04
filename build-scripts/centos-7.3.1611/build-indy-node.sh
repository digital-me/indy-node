#!/bin/bash -xe

INPUT_PATH="$1"
VERSION="$2"
OUTPUT_PATH="${3:-.}"

PACKAGE_NAME=indy-node

# copy the sources to a temporary folder
TMP_DIR="$(mktemp -d)"
cp -r "${INPUT_PATH}/." "${TMP_DIR}"

# prepare the sources
cd "${TMP_DIR}/build-scripts/centos-7.3.1611"
./prepare-package.sh "${TMP_DIR}" "${VERSION}"


sed -i "s/{package_name}/${PACKAGE_NAME}/" "prerm"

fpm --input-type "python" \
    --output-type "rpm" \
    --verbose \
    --python-package-name-prefix "python35u" \
    --python-bin "/usr/bin/python3.5" \
    --exclude "*.pyc" \
    --exclude "*.pyo" \
    --depends at \
    --no-python-fix-dependencies \
    --maintainer "Hyperledger <hyperledger-indy@lists.hyperledger.org>" \
    --before-install "preinst_node" \
    --after-install "postinst_node" \
    --before-remove "prerm" \
    --name "${PACKAGE_NAME}" \
    --package "${OUTPUT_PATH}" \
    "${TMP_DIR}"

rm -rf "${TMP_DIR}"
