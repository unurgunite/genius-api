## [Unreleased]

## [0.3.0] - 2026-06-12

### Added

- Ruby >= 3.2 requirement
- RBS type signatures for all API modules and extensions
- RBS collection via `rbs_collection.yaml`
- Steep type checker setup
- `docscribe` gem for automated YARD documentation generation
- `.docscribe.yml` config with RBS integration (`rbs.enabled: true`, `rbs.collection: true`, `collapse_generics: true`)
- YARD documentation (100% documented, 0 warnings)
- CI/CD pipeline with GitHub Actions (rubocop, rspec, docscribe checks)
- CHANGELOG.md, CONTRIBUTING.md, CODE_OF_CONDUCT.md
- `bin/release` release script

### Changed

- Updated `actions/checkout` to v4, `ruby/setup-ruby` to v1
- Updated `dotenv`, `parallel`, `rspec`, `rubocop`, `yard`, `coderay` dependencies
- Improved YARD annotations with meaningful descriptions and RBS-derived types
- README.md: updated requirements, added RBS/Steep/docscribe sections

### Fixed

- RuboCop offenses across all source files
- Anonymous block parameter YARD warning in `errors.rb`
- Type annotations aligned with RBS signatures

## [0.2.0] - 2022-04-03

- Updated documentation. Added first tests

## [0.1.0] - 2021-03-23

- Initial release
