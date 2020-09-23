#!/bin/bash

DETECT_JS="false"
DETECT_PYTHON="false"
DETECT_RUBY="false"
DETECT_SHELL="false"

# Javascript
test -f package.json && DETECT_JS="true"

# Python
test -f "requirements.txt" -o -f "setup.cfg" && DETECT_PYTHON="true"

# Ruby
test -f "Gemfile" -o -f ".rubocop.yml" && DETECT_RUBY="true"

export DETECT_JS DETECT_PYTHON DETECT_RUBY DETECT_SHELL
