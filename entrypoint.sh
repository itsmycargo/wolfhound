#!/bin/sh -l

set -e

echo "Pronto $(/app/bin/pronto verbose-version)"
echo ""
echo "Runners"
echo "==============="
/app/bin/pronto list
echo ""


if [ -e "${GITHUB_EVENT_PATH}" ];
then
  eval "$(jq -r '@sh "export GITHUB_PULL_REQUEST_ID=\(.number)"' "${GITHUB_EVENT_PATH}")"
fi

: "${FORMATTER:=$(test -n "${GITHUB_BASE_REF}" && echo "text github_pr_review github_combined_status" || echo "text")}"
: "${GITHUB_BASE_REF:=master}"
: "${GITHUB_WORKSPACE:=/workspace}"
: "${TARGET:="origin/${GITHUB_BASE_REF}"}"

cd "${GITHUB_WORKSPACE}"
PRONTO_GITHUB_ACCESS_TOKEN=${GITHUB_TOKEN} \
  PRONTO_PULL_REQUEST_ID=${GITHUB_PULL_REQUEST_ID} \
  /app/bin/pronto run -c "${TARGET}" -f ${FORMATTER} "$@"
