#!/bin/bash

set -euo pipefail

cachePath=/var/www/feed-cache/
volumeMountPath=/var/www/feeds/json/cve/1.1/

# prevent existing but empty apiKey
if [[ -z "${NVD_API_KEY}" ]]; then
  unset NVD_API_KEY
fi

echo "fetching NIST data...";
mkdir -p "${volumeMountPath}" # ensure subdirs
mkdir -p "${cachePath}" # ensure subdirs

java -Xmx2560m -jar /app/vulnz.jar cve --cache --directory ${cachePath}
cd ${cachePath} || (echo "${cachePath} not found - could not zip cve files\!" && exit 1)

echo "Copy files to target-location..."
cp -R "${cachePath}/." "${volumeMountPath}"

echo "DONE"
