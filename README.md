# Genius API

![Alt](https://repobeats.axiom.co/api/embed/0163add5bf43300944ef69ad09cf68f1a0176bf6.svg "Project stats")

Welcome to the unofficial [Genius API](https://docs.genius.com) representation. This repo reflects all of the service
API and much more!

## Documentation content

1. [Overview][1]
2. [Installation][2]
    1. [Build from source][2.1]
        1. [Manual installation][2.1.1]
        2. [Automatic installation][2.1.2]
    2. [Build via bundler][2.2]
3. [Usage][3]
4. [Todo][4]
5. [Development][5]
6. [Requirements][6]
    1. [Common usage][6.1]
    2. [Development purposes][6.2]
7. [Project style guide][7]
8. [Contributing][8]
9. [License][9]
10. [Code of Conduct][10]

## Overview

As noted above, this gem fully represents Genius service API. The projects source tree is pretty simple. All of the
resources are stored in theirs separate module, so it does code readability much cleaner.

## Installation

Genius API gem is quite simple to use and install

### Build from source

#### Manual installation

The manual installation includes installation via command line interface. it is practically no different from what
happens during the automatic build of the project:

```shell
git clone https://github.com/unurgunite/genius-api.git && \
cd ~/genius-api && \
bundle install && \
gem build genius-api.gemspec && \
gem install genius-api-0.1.0.gem
```

Now everything should work fine. Just type `irb` and `require "genius/api"` to start working with the library

#### Automatic installation

The automatic installation is simpler but it has at least same steps as manual installation:

```shell
git clone https://github.com/unurgunite/genius-api.git && \
cd ~/genius-api && \
bin/setup
```

If you see `irb` interface, then everything works fine. The main goal of automatic installation is that you do not need
to create your own script to simplify project build and clean up the shell history Add this line to your application's.
Note: you do not need to require projects file after the automatic installation. See `bin/setup` file for clarity of the
statement

### Build via bundler

This documentation point is close to those who need to embed the library in their project. Just place this gem to your
Gemfile or create it manually via `bundle init`:

```ruby
# Your Gemfile
gem 'genius-api'
```

And then execute:

```shell
bundle install
```

Or install it yourself for non bundled projects as:

```shell
gem install genius-api
```

## Usage

All docs are available at the separate page: https://unurgunite.github.io/genius-api_docs/

## TODO

- [x] Update `README.md`
- [ ] Refactor code base
- [ ] Add tests with RSpec
- [ ] 100% code coverage with RuboCop
- [ ] Refactor code according to the style guides

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can
also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the
version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version,
push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Requirements

This section will show dependencies which are used in the project. This section splits in two other sections —
requirements for common use and requirements for the development purposes.

### Common use

The `genius-api` gem is built on top of two other gems:

1. [HTTParty][101]
2. [Nokogiri][102]

The HTTParty gem is used to send requests to the REST client of the https://api.genius.com/.

The Nokogiri gem is used to represent XML objects as Ruby structures.

### Development purposes

For the development purposes `genius-api` gem uses:

1. [RSpec][201]
2. [RuboCop][202]
3. [Rake][203]
4. [Dotenv][204]
5. [Coderay][205]
6. [YARD][206]

The RSpec gem is used for test which are located in a separate folder under `spec` name.

The RuboCop gem is used for code formatting.

The Rake gem is used for building tasks as generating documentation.

The Dotenv gem is used for setting variables for test environment (`token`, for e.g.).

The Coderay gem is used for colorizing Rspec output.

The YARD gem is used for the documentation.

## Project style guide

To make the code base much cleaner gem has its own style guides. They are defined in a root folder of the gem in
a `CODESTYLE.md` file. Check it for more details.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/unurgunite/genius-api. This project is
intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to
the [code of conduct](https://github.com/unurgunite/genius-api/blob/master/CODE_OF_CONDUCT.md). To contribute you should
fork this project and create there new branch:

```shell
git clone https://github.com/your-beautiful-username/genius-api.git && \
git checkout -b refactor && \
git commit -m "Affected new changes" && \
git push origin refactor
```

And then make new pull request with additional notes of what you have done. The better the changes are scheduled, the
faster the PR will be checked.

## License

The gem is available as open source under the terms of the [GPLv3 License](https://opensource.org/licenses/GPL-3.0). The
copy of the license is stored in project under the `LICENSE.txt` file
name: [copy of the License](https://github.com/unurgunite/genius-api/blob/master/LICENSE.txt)

## Code of Conduct

Everyone interacting in the Genius::Api project's codebases, issue trackers, chat rooms and mailing lists is expected to
follow the [code of conduct](https://github.com/unurgunite/genius-api/blob/master/CODE_OF_CONDUCT.md).

[1]:https://github.com/unurgunite/genius-api#overview

[2]:https://github.com/unurgunite/genius-api#installation

[2.1]:https://github.com/unurgunite/genius-api#build-from-source

[2.1.1]:https://github.com/unurgunite/genius-api#manual-installation

[2.1.2]:https://github.com/unurgunite/genius-api#automatic-installation

[2.2]:https://github.com/unurgunite/genius-api#build-via-bundler

[3]:https://github.com/unurgunite/genius-api#usage

[4]:https://github.com/unurgunite/genius-api#todo

[5]:https://github.com/unurgunite/genius-api#development

[6]:https://github.com/unurgunite/genius-api#requirements

[6.1]:https://github.com/unurgunite/genius-api#common-usage

[6.2]:https://github.com/unurgunite/genius-api#development-purposes

[7]:https://github.com/unurgunite/genius-api#project-style-guide

[8]:https://github.com/unurgunite/genius-api#contributing

[9]:https://github.com/unurgunite/genius-api#license

[10]:https://github.com/unurgunite/genius-api#code-of-conduct

[101]:https://rubygems.org/gems/httparty

[102]:https://rubygems.org/gems/nokogiri

[201]:https://rubygems.org/gems/rspec

[202]:https://rubygems.org/gems/rubocop

[203]:https://rubygems.org/gems/rake

[204]:https://rubygems.org/gems/dotenv

[205]:https://rubygems.org/gems/coderay

[206]:https://rubygems.org/gems/yard
