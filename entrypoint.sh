#!/bin/sh -l

set -e

echo "Pronto $(/usr/local/bundle/bin/pronto verbose-version)"
echo ""
echo "Runners"
echo "==============="
/usr/local/bundle/bin/pronto list
echo ""


if [ -e "${GITHUB_EVENT_PATH}" ];
then
  eval "$(jq -r '@sh "export PRONTO_PULL_REQUEST_ID=\(.number)"' "${GITHUB_EVENT_PATH}")"
fi

: "${GITHUB_WORKSPACE:=/workspace}"
: "${GITHUB_BASE_REF:=master}"
: "${TARGET:="origin/${GITHUB_BASE_REF}"}"
: "${FORMATTER:=$(test -n "${GITHUB_BASE_REF}" && echo "text github_pr_review" || echo "text")}"

cd "${GITHUB_WORKSPACE}"
PRONTO_GITHUB_ACCESS_TOKEN=${GITHUB_TOKEN} /usr/local/bundle/bin/pronto run -c "${TARGET}" -f "${FORMATTER}" "$@"
