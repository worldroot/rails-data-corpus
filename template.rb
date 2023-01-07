=begin
Template Name: Rails - Template
Author: Richard Chan
Author URI: https://middlekid.io
Instructions: $ rails new myapp -d <postgresql, mysql, sqlite3> -m template.rb
=end

def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

def add_gems
  gem 'devise', '~> 4.7', '>= 4.7.2'
  gem 'friendly_id', '~> 5.3'
  gem 'sidekiq', '~> 6.1', '>= 6.1.1'
  gem 'name_of_person', '~> 1.1', '>= 1.1.1'
  gem "local_time", "~> 2.1"
  gem 'simple_form'
  gem 'mini_magick', '~> 4.5', '>= 4.5.1'
  gem 'stripe'
  gem 'figaro'
end

def set_application_name
  # Ask user for application name
  application_name = ask("What is the name of your application? Default: New App")

  # Checks if application name is empty and add default Jumpstart.
  application_name = application_name.present? ? application_name : "New App"

  # Add Application Name to Config
  environment "config.application_name = '#{application_name}'"

  # Announce the user where he can change the application name in the future.
  puts "Your application name is #{application_name}. You can change this later on: ./config/application.rb"
end

def add_users
  # Install Devise
  generate "devise:install"

  # Configure Devise
  environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }",
              env: 'development'

  route "root to: 'home#index'"

  # Create Devise User
  generate :devise, "User",
            "first_name",
            "last_name",
            "admin:boolean",
            "stripe_id:string",
            "card_brand:string",
            "card_last4:string",
            "card_exp_month:string",
            "card_exp_year:string",
            "expires_at:datetime"

  # set admin boolean to false by default
  in_root do
    migration = Dir.glob("db/migrate/*").max_by{ |f| File.mtime(f) }
    gsub_file migration, /:admin/, ":admin, default: false"
  end

  # name_of_person gem
  append_to_file("app/models/user.rb", "\nhas_person_name\n", after: "class User < ApplicationRecord")
end

def copy_templates
  directory "app", force: true
end

def add_tailwind
  # Until PostCSS 8 ships with Webpacker/Rails we need to run this compatability version
  # See: https://tailwindcss.com/docs/installation#post-css-7-compatibility-build
  run "yarn add tailwindcss@npm:@tailwindcss/postcss7-compat postcss@^7 autoprefixer@^9"

  run "mkdir -p app/javascript/stylesheets"

  append_to_file("app/javascript/packs/application.js", 'import "stylesheets/application"')
  inject_into_file("./postcss.config.js", "\n    require('tailwindcss')('./app/javascript/stylesheets/tailwind.config.js'),", after: "plugins: [")

  run "mkdir -p app/javascript/stylesheets/components"
end

# Remove Application CSS
def remove_app_css
  remove_file "app/assets/stylesheets/application.css"
end

def add_sidekiq
  environment "config.active_job.queue_adapter = :sidekiq"

  insert_into_file "config/routes.rb",
    "require 'sidekiq/web'\n\n",
    before: "Rails.application.routes.draw do"

  content = <<-RUBY
    authenticate :user, lambda { |u| u.admin? } do
      mount Sidekiq::Web => '/sidekiq'
    end
  RUBY
  insert_into_file "config/routes.rb", "#{content}\n\n", after: "Rails.application.routes.draw do\n"
end

def add_foreman
  copy_file "Procfile"
end

def add_friendly_id
  generate "friendly_id"
end

def run_figaro
  run "bundle exec figaro install"
end

def move_stripe_charges_into_javascript_packs
  run "mv app/javascript/charges.js app/javascript/packs"
  append_to_file("app/javascript/packs/application.js", "\nrequire('packs/charges')\n")
end

def add_simple_form
  generate "simple_form:install"
end

def stop_spring
  run "spring stop"
end

def add_action_text
  run "rails action_text:install"
end

def add_action_text_config_to_stylesheets
  append_to_file("app/assets/stylesheets/actiontext.scss", "\n@import 'trix/dist/trix';\n")
  append_to_file("app/assets/stylesheets/application.scss", "\n@import './actiontext.scss';\n")
end

# Main setup
source_paths

add_gems

after_bundle do
  set_application_name
  stop_spring
  add_users
  remove_app_css
  add_sidekiq
  add_foreman
  copy_templates
  add_tailwind
  add_friendly_id
  run_figaro
  add_simple_form
  add_action_text
  add_action_text_config_to_stylesheets
  move_stripe_charges_into_javascript_packs

  # Migrate
  rails_command "db:create"
  rails_command "db:migrate"

  git :init
  git add: "."
  git commit: %Q{ -m "Initial commit" }

  say
  say "Rails app from template successfully created! 👍", :green
  say
  say "Switch to your app by running:"
  say "$ cd #{app_name}", :yellow
  say
  say "Then run:"
  say "$ rails server", :green
end
