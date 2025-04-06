# Changelog

## [1.1.0] - 2025-04-06

### Added

- Allow for creating NAT instance as an alternative to using AWS NAT Gateway
- Added [TODO.md] and [CHANGELOG.md]

### Chnaged

- Converted from user-specified routing to "preconfigured" private and public routing

### Removed

- Removed Security Group functionality (moving that to its own module)

## [1.0.0] - 2025-01-23

### Added

- Adding subnet/route table associations by @rockpenguin in https://github.com/rockpenguin/rockpenguin-aws-vpc/pull/1
- Adding Security Group bits by @rockpenguin in https://github.com/rockpenguin/rockpenguin-aws-vpc/pull/2

### Changed

- Refactoring Security Groups into a separate module by @rockpenguin in https://github.com/rockpenguin/rockpenguin-aws-vpc/pull/3
- Upgrading AWS provider to 5.x by @rockpenguin in https://github.com/rockpenguin/rockpenguin-aws-vpc/pull/4
