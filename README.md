# Solidus Configurable Kits

Configurable Kits for Solidus.
## Installation

Add solidus_configurable_kits to your Gemfile:

```ruby
gem 'solidus_configurable_kits'
```

Bundle your dependencies and run the installation generator:

```shell
bin/rails generate solidus_configurable_kits:install
```

## Usage

First, make sure that your `Spree::Config.variant_price_selector_class` is either the `SolidusConfigurableKits::PriceSelector` or a class that inherits from it / offers the same functionality.

Also, make sure that your `Spree:Config.order_merger_class` is either the `SolidusConfigurableKits::OrderMerger` or a class that inherits from it/ offers the same functionality.

You can then mark some variants as eligible to be included in kits by adding a "Kit Price" to them. The Kit price will be added to the price of the base kit variant, and will in many cases by `0`.

Afterwards, create your Kit product, and add some kit requirements on the "Kits" tab. On the product display page and in the admin cart, you will now be prompted for the variants that have kit prices before being able to add that product to the cart, and the cart will include some line items that result from fulfilling the kit requirements.
## Development

### Testing the extension

First bundle your dependencies, then run `bin/rake`. `bin/rake` will default to building the dummy
app if it does not exist, then it will run specs. The dummy app can be regenerated by using
`bin/rake extension:test_app`.

```shell
bin/rake
```

To run [Rubocop](https://github.com/bbatsov/rubocop) static code analysis run

```shell
bundle exec rubocop
```

When testing your application's integration with this extension you may use its factories.
Simply add this require statement to your `spec/spec_helper.rb`:

```ruby
require 'solidus_configurable_kits/testing_support/factories'
```

Or, if you are using `FactoryBot.definition_file_paths`, you can load Solidus core
factories along with this extension's factories using this statement:

```ruby
SolidusDevSupport::TestingSupport::Factories.load_for(SolidusConfigurableKits::Engine)
```

### Running the sandbox

To run this extension in a sandboxed Solidus application, you can run `bin/sandbox`. The path for
the sandbox app is `./sandbox` and `bin/rails` will forward any Rails commands to
`sandbox/bin/rails`.

Here's an example:

```
$ bin/rails server
=> Booting Puma
=> Rails 6.0.2.1 application starting in development
* Listening on tcp://127.0.0.1:3000
Use Ctrl-C to stop
```

### Updating the changelog

Before and after releases the changelog should be updated to reflect the up-to-date status of
the project:

```shell
bin/rake changelog
git add CHANGELOG.md
git commit -m "Update the changelog"
```

### Releasing new versions

Please refer to the dedicated [page](https://github.com/solidusio/solidus/wiki/How-to-release-extensions) on Solidus wiki.

## License

Copyright (c) 2021 [Martin Meyerhoff], released under the GNU General Public License v3.
I reserve the right to release this software under different terms to individual clients. Contact me for details.
