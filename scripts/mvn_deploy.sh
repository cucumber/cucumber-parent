#!/usr/bin/env bash
set -euf -o pipefail
mvn deploy -Psign-source-javadoc-travis --settings scripts/ci-settings.xml -DskipTests=true
