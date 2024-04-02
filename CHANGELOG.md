## [0.2.0] - 2024-04-02
- Add `rspec_root`, `rspec_response_allow_headers`, and `rspec_response_identifier` options to configuration.
- Add public method `merge!` for PostmanCollection.
- Fix rake usage.
- Refactor.

## [0.1.16] - 2023-06-01
- Fix default rpdoc_example_folders bug.

## [0.1.15] - 2023-05-18
- Add gitlab templates.
- Update gemspec.

## [0.1.14] - 2023-02-09
- Fix File object method `exists` has been removed error at Ruby 3.2.1.
    - [Removed deprecated Dir.exists? and File.exists?](https://github.com/ruby/ruby/commit/bf97415c02b11a8949f715431aca9eeb6311add2)   
- Add the notice at README.md

## [0.1.13] - 2022-10-03
- Clean empty folders by default

## [0.1.12] - 2022-09-06
- Handle encoding error

## [0.1.11] - 2022-08-09
- Check encoding names using instance (PR#1)

## [0.1.10] - 2022-07-14
- Enable form-data request body

## [0.1.7, 0.1.8, 0.1.9] - 2022-02-14
- Fix rspec parse zip response bug

## [0.1.6] - 2022-02-14
- Update licnese

## [0.1.4, 0.1.5] - 2021-12-22
- Fix rspec parsing bugs

## [0.1.3] - 2021-11-09
- Add require 'rspec/rails' if RSpec::Rails exists

## [0.1.2] - 2021-11-04
- Add gem description
- Remove unecessary gem dependency
- Fix configuration and collection bugs

## [0.1.1] - 2021-11-01
- Add configuration options

## [0.1.0] - 2021-10-30
- Initial release
