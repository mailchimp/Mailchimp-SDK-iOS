fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios build_framework
```
fastlane ios build_framework
```
Builds the SDK framework
### ios archive_framework
```
fastlane ios archive_framework
```
Archives the SDK framework
### ios create_binary_framework
```
fastlane ios create_binary_framework
```
Create Swift Binary Framework
### ios release
```
fastlane ios release
```
Create a release candidate
### ios clean
```
fastlane ios clean
```
Clean deploy artifacts
### ios set_version
```
fastlane ios set_version
```
Sets the SDK version in all files

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
