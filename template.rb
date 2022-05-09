# Taken from https://github.com/mattbrictson/rails-template
# But stripped of remote stuff, because not needed at the moment
def add_template_repository_to_source_path
  source_paths.unshift(File.dirname(__FILE__))
end

def add_gems
  # This appends a new group to the Gemfile. Not super clean but it works
  gem_group :development, :test do
    gem 'bundler-audit', '~> 0.9.0.1'
    gem 'ruby_audit', '~> 2.1'
    gem 'brakeman', '~> 5.2', '>= 5.2.1'
    gem 'rubocop', '~> 1.26', require: false
    gem 'rubocop-rails', '~> 2.14', '>= 2.14.2'
  end
end

add_template_repository_to_source_path

add_gems

after_bundle do
  # First, we install Prettier for Ruby formatting
  run 'npm install -D prettier@2.6.2 @prettier/plugin-ruby@2.1.0'

  # gitignore node_modules folder
  append_to_file '.gitignore', "\n# Node.js\nnode_modules"

  # Rubocop configuration
  copy_file '.rubocop.yml'

  # Fix all auto-correctable Rubocop violations
  run 'bundle exec rubocop -A'

  # TODO: Make sure Linux is in the Gemfile.lock for deploying
  #run 'bundle lock --add-platform x86_64-linux'
end
