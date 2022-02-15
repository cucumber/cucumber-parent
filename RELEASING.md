Releasing
=========

The deployment process of `cucumber-parent` is based on 
[Deploying to OSSRH with Apache Maven](http://central.sonatype.org/pages/apache-maven.html#deploying-to-ossrh-with-apache-maven-introduction).

## Check [![Build Status](https://travis-ci.org/cucumber/cucumber-parent.svg?branch=main)](https://travis-ci.org/cucumber/cucumber-parent) ##

Is the build passing?

```
git checkout main
```

Also check if you can upgrade any dependencies:

```
make update-dependency-versions
```

## Decide what the next version should be ##

Versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html). To sum it up, it depends on what's changed (see `CHANGELOG.md`). Given a version number MAJOR.MINOR.PATCH:

* Bump `MAJOR` when you make incompatible API changes:
  * There are `Removed` entries, or `Changed` entries breaking compatibility
  * A cucumber library dependency upgrade was major
* Bump `MINOR` when you add functionality in a backwards compatible manner:
  * There are `Added` entries, `Changed` entries preserving compatibility, or
  `Deprecated` entries
* Bump `PATCH` when you make backwards compatible bug fixes:
  * There are `Fixed` entries

Display future version by running:

```
make version
```

Check if branch name and version are as expected. To change version run:

```
mvn versions:set -DnewVersion=X.Y.Z-SNAPSHOT
```

## Make the release ##

Only people with permission to push to release/* branches can make releases.

1. Push to a new `release/*` branch to trigger the `release-*` workflows
   ```
   git push origin main:release/v$next_release
   ```
1. Wait until the `release-*` workflows in GitHub Actions have passed
1. In `pom.xml`, bump the **patch** version and append `-SNASHOT` (e.g. `1.2.4-SNAPSHOT`) and commit/push
1. Announce the release
   * in the `#newsletter` Slack channel
   * on the `@cucumberbdd` Twitter account
   * write a blog post
