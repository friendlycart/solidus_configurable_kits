# frozen_string_literal: true

module SolidusConfigurableKits
  module Generators
    class InstallGenerator < Rails::Generators::Base
      MOUNT_ROUTE = "mount SolidusConfigurableKits::Engine"

      class_option :auto_run_migrations, type: :boolean, default: false
      source_root File.expand_path('templates', __dir__)

      def copy_initializer
        template 'initializer.rb', 'config/initializers/solidus_configurable_kits.rb'
      end

      def add_javascripts
        append_file 'vendor/assets/javascripts/spree/frontend/all.js', "//= require spree/frontend/solidus_configurable_kits\n"
        append_file 'vendor/assets/javascripts/spree/backend/all.js', "//= require spree/backend/solidus_configurable_kits\n"
      end

      def add_stylesheets
        inject_into_file 'vendor/assets/stylesheets/spree/frontend/all.css', " *= require spree/frontend/solidus_configurable_kits\n", before: %r{\*/}, verbose: true # rubocop:disable Layout/LineLength
        inject_into_file 'vendor/assets/stylesheets/spree/backend/all.css', " *= require spree/backend/solidus_configurable_kits\n", before: %r{\*/}, verbose: true # rubocop:disable Layout/LineLength
      end

      def add_migrations
        run 'bin/rails railties:install:migrations FROM=solidus_configurable_kits'
      end

      def configure_pricing_options
        inject_into_file 'config/initializers/spree.rb', 
                         "  config.variant_price_selector_class = \"SolidusConfigurableKits::PriceSelector\"\n", 
                         after: "Spree.config do |config|\n", verbose: true # rubocop:disable Layout/LineLength
      end

      def run_migrations
        run_migrations = options[:auto_run_migrations] || ['', 'y', 'Y'].include?(ask('Would you like to run the migrations now? [Y/n]')) # rubocop:disable Layout/LineLength
        if run_migrations
          run 'bin/rails db:migrate'
        else
          puts 'Skipping bin/rails db:migrate, don\'t forget to run it!' # rubocop:disable Rails/Output
        end
      end


    def install_routes
      routes_file_path = File.join('config', 'routes.rb')
      unless File.read(routes_file_path).include? MOUNT_ROUTE
        insert_into_file routes_file_path, after: "Rails.application.routes.draw do\n" do
          <<-RUBY
  # This line mounts Solidus's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Solidus relies on it being the default of "spree"
  #{MOUNT_ROUTE}, at: '/'

          RUBY
        end
      end

      unless options[:quiet]
        puts "*" * 50
        puts "We added the following line to your application's config/routes.rb file:"
        puts " "
        puts "    #{MOUNT_ROUTE}, at: '/'"
      end
    end
    end
  end
end
