#!/bin/bash
#
# Add Git hooks to a repository
#
# Requirements:
#  - None yet!
#

CP_SOURCE="${BASH_SOURCE%/*}/../var/git-hooks"

cp -Rv "$CP_SOURCE/." .git/hooks/
