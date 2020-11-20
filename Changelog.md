# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.2] - 2020-11-19
### Added
- Swift Package Support

## [2.0.1] - 2020-11-17
### Removed
- Fixed module/class name collision which caused Failed to load module 'MailchimpSDK' error when integrating. (#16)

## [2.0] - 2020-11-11
### Changed
- Renamed MailchimpSDK class to Mailchimp to avoid ambiguity.

## [1.0] - 2020-07-20
### Changed
- Bumped version to 1.0

## [0.1.6] - 2020-06-25
### Changed
- Updated documentation and README
- Updated .gitignore

## [0.1.5] - 2020-04-14
### Added
- `set_version` lane to Fastfile

### Changed
- `release` lane no longer accepts a `version` argument

## [0.1.4] - 2020-03-19
### Fixed
- podspec validation

## [0.1.3] - 2020-03-19
### Added
- Cocoapods support

## [0.1.2] - 2020-02-17
### Fixed
- Decode errors within responses

## [0.1.1] - 2020-01-31
### Fixed
- Module/class name collision which caused Failed to load module 'MailchimpSDK' error when integrating.

## [0.1.0] - 2020-01-06
### Added
- Create or update Contacts in an Audience
- Add and remove tags and merge fields from Contacts
- Track events for Contacts
