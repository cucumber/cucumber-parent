SHELL := /usr/bin/env bash

default:
	mvn clean install
.PHONY: default

VERSION = $(shell mvn help:evaluate -Dexpression=project.version -q -DforceStdout 2> /dev/null)
NEW_VERSION = $(subst -SNAPSHOT,,$(VERSION))
CURRENT_BRANCH = $(shell git rev-parse --abbrev-ref HEAD)

clean:
	mvn clean release:clean
.PHONY: clean

version:
	@echo ""
	@echo "The next version of Cucumber Parent will be $(NEW_VERSION) and released from '$(CURRENT_BRANCH)'"
	@echo ""
.PHONY: version

update-compatibility:
	MSG_VERSION=$$(mvn help:evaluate -Dexpression=messages.version -q -DforceStdout 2> /dev/null) && \
	git clone --branch messages/v$$MSG_VERSION git@github.com:cucumber/cucumber.git target/cucumber
	rm -rf compatibility/src/test/resources/*
	cp -r target/cucumber/compatibility-kit/javascript/features .m2compatibility/src/test/resources
	rm -rf target/cucumber
.PHONY: update-compatibility

update-dependency-versions:
	mvn versions:force-releases
	mvn versions:update-properties -DallowMajorUpdates=false -Dmaven.version.rules="file://`pwd`/.m2/maven-version-rules.xml"
.PHONY: update-dependency-versions

update-major-dependency-versions:
	mvn versions:force-releases
	mvn versions:update-properties -DallowMajorUpdates=true -Dmaven.version.rules="file://`pwd`/.m2/maven-version-rules.xml"
.PHONY: update-major-dependency-versions

.release-in-docker: default
	[ -f '/home/cukebot/configure' ] && /home/cukebot/configure
	mvn --batch-mode release:clean release:prepare -DautoVersionSubmodules=true -Darguments="-DskipTests=true -DskipITs=true -Darchetype.test.skip=true"
	git checkout "v$(NEW_VERSION)"
	mvn deploy -P-examples -P-compatibility -Psign-source-javadoc -DskipTests=true -DskipITs=true -Darchetype.test.skip=true
	git checkout $(CURRENT_BRANCH)
	git fetch
.PHONY: .release-in-docker

release:
	[ -d '../secrets' ]  || git clone keybase://team/cucumberbdd/secrets ../secrets
	git -C ../secrets pull
	docker run \
	  --volume "${shell pwd}":/app \
		--volume "${shell pwd}/../secrets/.ssh":/home/cukebot/.ssh \
	  --volume "${shell pwd}/../secrets/configure":/home/cukebot/configure \
	  --volume "${shell pwd}/../secrets/codesigning.key":/home/cukebot/codesigning.key \
	  --volume "${shell pwd}/../secrets/gpg-with-passphrase":/home/cukebot/gpg-with-passphrase \
	  --volume "${HOME}/.m2"/repository:/home/cukebot/.m2/repository \
	  --env-file "${shell pwd}/../secrets/secrets.list" \
	  --user 1000 \
	  --rm \
	  -it cucumber/cucumber-build:latest \
	  make .release-in-docker
.PHONY: release
