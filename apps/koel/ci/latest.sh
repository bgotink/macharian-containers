#!/usr/bin/env bash
channel=$1

if [[ "${channel}" == "release" ]]; then
    version=$(curl -sX GET -L -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/koel/koel/releases | jq --raw-output 'map(select(.draft == false and .prerelease == false)) | .[0].name' 2>/dev/null)
    version="${version#*v}"
    printf "%s" "${version}"
fi
