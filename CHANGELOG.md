# VoltCheckout SDK Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

- **Added** for new features.
- **Changed** for changes in existing functionality.
- **Deprecated** for soon-to-be removed features.
- **Removed** for now removed features.
- **Fixed** for any bug fixes.
- **Security** in case of vulnerabilities.


## [1.0.5] - 2026-05-26

### Added

- Apache 2.0 license

### Fixed

- Documentation build for GitHub pages
- Internal CI pipeline issues

## [1.0.3] - 2026-05-21

### Changed

- First public release

## [0.8.0] - 2026-05-20

### Added

- `PaymentIntent` result builder, for easier payment creation
- State restoration in case SDK flow is interrupted
- Support for payments in GBP

### Changed

- SDK now does not automatically dismiss when user is redirected to the browser
- `.paymentComplete` result is renamed to `.paymentCreated`

## [0.7.3] - 2026-03-30

### Added

- Support for institutions requiring additional account identifiers
- Support for GB institutions

### Changed

- Automatically set country when starting payment with institution

## [0.7.2] - 2025-12-16

### Added

- Institution verification before every payment

## [0.7.0] - 2025-12-12

### Added

- Feedback collection form
- Payment cancellation logic

## [0.6.0] - 2025-11-13

### Added

- Flow for selecting institution
- Returning selected institution to merchant from both flows

## [0.5.0] - 2025-10-28

### Added

- Payment progress and result handling

## [0.4.0] - 2025-10-13

### Changed

- Bump minor version to acknowledge completing eduational view and country switching features

## [0.2.3] - 2025-10-13

### Added

- Ability to select and change payment country

## [0.2.2] - 2025-09-16

### Added

- Educational view fully according to the design

## [0.2.1] - 2025-09-02

### Changed

- Bump minor version to acknowledge completing institutions feature

## [0.1.4] - 2025-09-02

### Added

- Disabled institutions popover
- Various improvements and polishing around institutions feature

## [0.1.3] - 2025-08-26

### Added

- Institutions branches view and search

## [0.1.2] - 2025-08-25

### Added

- Institutions grid view with groupping and filtering

## [0.1.0] - 2025-08-13

### Added

- It's now possible to create a payment in happy path.
