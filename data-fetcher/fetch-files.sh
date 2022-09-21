#!/bin/bash

# Copyright (C) 2022, Martin Drößler <m.droessler@handelsblattgroup.com>
# Copyright (C) 2022, Handelsblatt GmbH
#
# This file is part of "simple nist k8s mirror"
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


set +e

baseURL="https://nvd.nist.gov/feeds/json/cve/1.1/nvdcve-1.1-"
volumeMountPath=/var/www/feeds/json/cve/1.1/
specialFileKeys=("modified" "recent")
startYear=2002
endYear=$(date +"%Y")

downloadAndVerifyFilePair() {
	local filekey=$1
	
	currentDataURL="${baseURL}${filekey}.json.gz"
	currentMetaURL="${baseURL}${filekey}.meta"
	
	echo "fetching: ${currentDataURL}";
	wget "${currentDataURL}"
	
	echo "fetching: ${currentMetaURL}";
	wget "${currentMetaURL}"
	
	echo "verify data-file...";
	gunzip -k "nvdcve-1.1-${filekey}.json.gz"
	sha256sum -c <(echo "$(grep "sha256" "nvdcve-1.1-${filekey}.meta" | cut -d ':' -f 2 | tr -d '\r')  nvdcve-1.1-${filekey}.json")
	return $?
}

##
# Main
#
encounteredError=0
result="SUCCESS"
tempDir=$(mktemp -d --tmpdir "tmp.nist.XXXXXXXXXX")
cd "${tempDir}"

echo "fetching NIST data...";

for fk in ${specialFileKeys[@]}; do
	downloadAndVerifyFilePair "${fk}"
	if [ $? -gt 0 ]; then
		encounteredError=1
		break;
	fi
done

if [ ${encounteredError} -eq 0 ]; then
	indexYear=${startYear}
	while [ ${indexYear} -le ${endYear} ]; do
		downloadAndVerifyFilePair "${indexYear}"
		if [ $? -gt 0 ]; then
			encounteredError=1
			break;
		fi
		indexYear=$((indexYear + 1))
	done
fi

if [ ${encounteredError} -eq 0 ]; then
	echo "NIST data fetched successfully. Now copy to storage volume...";
	mkdir -p "${volumeMountPath}" # ensure subdirs
	rm ${tempDir}/*.json
	cp -R "${tempDir}/." "${volumeMountPath}"
else 
	result="ERROR"
fi

echo "cleanup...";
cd /
rm -rf "${tempDir}"

echo "${result}";
