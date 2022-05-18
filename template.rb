# Taken from https://github.com/mattbrictson/rails-template
# But stripped of remote stuff, because not needed at the moment
# TODO: add option for cloning from remote
def add_template_repository_to_source_path
  source_paths.unshift(File.dirname(__FILE__))
end

def add_gems
  # -------------------------------------------------------------------------
  # Install relevant code quality and security gems
  # -------------------------------------------------------------------------
  gem_group :development, :test do
    gem 'bundler-audit', '~> 0.9.0.1'
    gem 'ruby_audit', '~> 2.1'
    gem 'brakeman', '~> 5.2', '>= 5.2.1'
    gem 'rubocop', '~> 1.26', require: false
    gem 'rubocop-rails', '~> 2.14', '>= 2.14.2'
  end

  # -------------------------------------------------------------------------
  # Install letter_opener for receiving emails in dev mode
  # -------------------------------------------------------------------------
  gem_group :development do
    gem 'letter_opener', '~> 1.8', '>= 1.8.1'
  end

  # -------------------------------------------------------------------------
  # Install SimpleCov for tracking test coverage
  # -------------------------------------------------------------------------
  gem_group :test do
    gem 'simplecov', require: false
  end

  # -------------------------------------------------------------------------
  # Install ViewComponent and Lookbook for developing components in isolation
  # -------------------------------------------------------------------------
  gem 'view_component', '~> 2.52'
  gem 'lookbook', '~> 0.8.0'

  # -------------------------------------------------------------------------
  # Install Devise for authentication
  # -------------------------------------------------------------------------
  gem 'devise', '~> 4.8', '>= 4.8.1'
end

def add_users
  # -------------------------------------------------------------------------
  # Basic Devise setup
  # -------------------------------------------------------------------------
  generate 'devise:install'
  environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }", env: 'development'

  # -------------------------------------------------------------------------
  # START: Compatibility fixes until Devise is compatible with Rails 7
  # -------------------------------------------------------------------------
  copy_file 'turbo_devise_controller.rb', 'app/controllers/turbo_devise_controller.rb'

  gsub_file 'config/initializers/devise.rb', '# config.parent_controller = \'DeviseController\'', '# config.parent_controller = \'TurboDeviseController\''

  gsub_file 'config/initializers/devise.rb', '# config.navigational_formats = [\'*/*\', :html]', 'config.navigational_formats = [\'*/*\', :html, :turbo_stream]'

  inject_into_file 'config/initializers/devise.rb', after: "# ==> Warden configuration\n" do <<-EOF
  # Temporary compatibility fix for making Devise work with Rails 7's Turbo
  # See https://www.youtube.com/watch?v=m3uhldUGVes
  config.warden do |manager|
    manager.failure_app = TurboFailureApp
  end
  EOF
  end

  inject_into_file 'config/initializers/devise.rb', after: "# frozen_string_literal: true\n" do <<~EOF
    # Temporary compatibility fix for making Devise work with Rails 7's Turbo
    # See https://www.youtube.com/watch?v=m3uhldUGVes
    class TurboFailureApp < Devise::FailureApp
      def respond
        if request_format == :turbo_stream
          redirect
        else
          super
        end
      end
      def skip_format?
        %w(html turbo_stream */*).include? request_format.to_s
      end
    end
  EOF
  end
  # -------------------------------------------------------------------------
  # END: Compatibility fixes until Devise is compatible with Rails 7
  # -------------------------------------------------------------------------

  # -------------------------------------------------------------------------
  # Generate User model with additional first_name and last_name
  # -------------------------------------------------------------------------
  generate :devise, "User", "first_name", "last_name"

  # -------------------------------------------------------------------------
  # Add role column and default to user (not admin)
  # -------------------------------------------------------------------------
  current_time = Time.now
  migration_filename = "#{current_time.strftime("%Y%m%d%H%M%S")}_add_role_to_users.rb"

  file "db/migrate/#{migration_filename}", <<-CODE
# Add a role column to the user that will be an enum
class AddRoleToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :role, :integer
  end
end
  CODE

  inject_into_file 'app/models/user.rb', after: "class User < ApplicationRecord\n" do <<-EOF
    # Currently we only have two roles:
    enum role: %i[user admin]
    after_initialize :set_default_role, if: :new_record?

    def set_default_role
      self.role ||= :user
    end\n
  EOF
  end

  # -------------------------------------------------------------------------
  # Devise requires a root_path (that still needs to be created)
  # This goes AFTER generating the model to avoid route mismatches
  # -------------------------------------------------------------------------
  route "root 'home#index'"
end

add_template_repository_to_source_path

# -------------------------------------------------------------------------
# Add a note to Gemfile which gems belong to template and not vanilla Rails
# -------------------------------------------------------------------------
append_to_file 'Gemfile', "\n# The following gems are not included in Rails by default. They are part of the applied template"

add_gems

after_bundle do
  # -------------------------------------------------------------------------
  # First, we install Prettier for Ruby formatting
  # -------------------------------------------------------------------------
  run 'npm install -D prettier@2.6.2 @prettier/plugin-ruby@2.1.0'

  # -------------------------------------------------------------------------
  # gitignore node_modules folder
  # -------------------------------------------------------------------------
  append_to_file '.gitignore', "\n# Node.js\nnode_modules\n"

  # -------------------------------------------------------------------------
  # gitignore coverage folder of SimpleCov
  # -------------------------------------------------------------------------
  append_to_file '.gitignore', "\n# SimpleCov coverage folder\ncoverage\n"

  # -------------------------------------------------------------------------
  # Generate home route stub
  # -------------------------------------------------------------------------
  generate :controller, 'home', 'index'

  # -------------------------------------------------------------------------
  # Invoke authentication setup
  # -------------------------------------------------------------------------
  add_users

  # -------------------------------------------------------------------------
  # Configure Lookbook route
  # -------------------------------------------------------------------------
  inject_into_file "config/routes.rb", "  # Lookbook route should be matched first\n  mount Lookbook::Engine, at: '/lookbook' if Rails.env.development?\n\n", after: "Rails.application.routes.draw do\n"

  # -------------------------------------------------------------------------
  # Configure preview layout for ViewComponent/Lookbook views
  # -------------------------------------------------------------------------
  copy_file 'component_preview.html.erb', 'app/views/layouts/component_preview.html.erb'
  environment "config.view_component.default_preview_layout = 'component_preview'"

  # -------------------------------------------------------------------------
  # Configure letter_opener in dev mode
  # -------------------------------------------------------------------------
  environment 'config.action_mailer.perform_deliveries = true', env: 'development'
  environment 'config.action_mailer.delivery_method = :letter_opener', env: 'development'
  inject_into_file "config/environments/development.rb", "# Let letter_opener handle emails in development\n", before: "config.action_mailer.delivery_method = :letter_opener"

  # -------------------------------------------------------------------------
  # Set applications's timezone to Berlin
  # -------------------------------------------------------------------------
  if yes?("Do you want to set the app's timezone to Berlin?")
    environment "config.time_zone = 'Berlin'"
  end

  # -------------------------------------------------------------------------
  # Configure SimpleCov
  # -------------------------------------------------------------------------
  prepend_to_file 'test/test_helper.rb' do <<-EOF
    if ENV['COVERAGE']
      require 'simplecov'
      SimpleCov.start 'rails' do
        enable_coverage :branch
      end
    end\n
  EOF
  end

  inject_into_file 'test/test_helper.rb', after: "parallelize(workers: :number_of_processors)\n" do <<~EOF

      # If tests run with coverage requested we handle parallelization via https://github.com/simplecov-ruby/simplecov/issues/718#issuecomment-538201587
      if ENV['COVERAGE']
        parallelize_setup do |worker|
          SimpleCov.command_name SimpleCov.command_name + '-' + worker
        end

        parallelize_teardown { SimpleCov.result }
      end
  EOF
  end

  # -------------------------------------------------------------------------
  # Add Rubocop configuration
  # -------------------------------------------------------------------------
  copy_file '.rubocop.yml'

  # -------------------------------------------------------------------------
  # Fix all auto-correctable Rubocop violations
  # -------------------------------------------------------------------------
  run 'bundle exec rubocop --auto-correct-all --fail-level error'

  # -------------------------------------------------------------------------
  # Correct all Ruby formatting via Prettier (silently)
  # -------------------------------------------------------------------------
  run 'npx prettier --write ./**/*.rb --loglevel=warn'

  # -------------------------------------------------------------------------
  # Make sure Linux is in the Gemfile.lock
  # -------------------------------------------------------------------------
  run 'bundle lock --add-platform x86_64-linux'
end
