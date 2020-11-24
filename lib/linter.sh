#!/usr/bin/env bash

source /action/wolf.sh
source /action/detect.sh

INTERACTIVE=${INTERACTIVE:="false"}
VALIDATE_JS="${VALIDATE_JS:=${DETECT_JS}}"
VALIDATE_PYTHON="${VALIDATE_PYTHON:=${DETECT_PYTHON}}"
VALIDATE_RUBY="${VALIDATE_RUBY:=${DETECT_RUBY}}"
VALIDATE_SHELL="${VALIDATE_SHELL:=${DETECT_SHELL}}"

if [ -z "${CONTINUOUS_INTEGRATION}" ];
then
  INTERACTIVE="true"
fi

runner() {
  CMD=$1 ; shift
  ARGS=$1 ; shift
  OUTPUT=$1 ; shift

  SECONDS=0

  echo "**** Running $CMD"

  if [ -z "${OUTPUT}"];
  then
    eval "$CMD" "$ARGS"
  else
    eval "$CMD" "$ARGS" > $OUTPUT
  fi

  echo "Elapsed: $(($SECONDS / 60))min $(($SECONDS % 60))sec"
}

if [ "${VALIDATE_JS}" = "true" ];
then
  if [ "${INTERACTIVE}" = "true" ];
  then
    runner eslint "."
  else
    runner eslint "--format checkstyle --output-file eslint-result.xml ."
  fi
fi

if [ "${VALIDATE_RUBY}" = "true" ];
then
  if [ "${INTERACTIVE}" = "true" ];
  then
    runner fasterer "."
    runner flay
    runner reek "."
    runner rubocop
  else
    runner /action/fasterer-checkstyle ". fasterer-result.xml"
    runner /action/flay-checkstyle "flay-result.xml"
    runner /action/reek-checkstyle ". reek-result.xml"
    runner rubocop "--require rubocop/formatter/checkstyle_formatter --format RuboCop::Formatter::CheckstyleFormatter --out rubocop-result.xml"
  fi
fi

if [ "${VALIDATE_PYTHON}" = "true" ];
then
  echo
fi

if [ "${VALIDATE_SHELL}" = "true" ];
then
  runner /usr/bin/shellcheck "$(find . -name "*.sh")"
fi
