# Application template recipe for the rails_apps_composer. Change the recipe here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/models.rb

after_bundler do
  say_wizard "recipe running after 'bundle install'"
  ### DEVISE ###
  if prefer :authentication, 'devise'
    # prevent logging of password_confirmation
    gsub_file 'config/application.rb', /:password/, ':password, :password_confirmation'
    generate 'devise:install'
    generate 'devise_invitable:install' if prefer :devise_modules, 'invitable'
    generate 'devise user' # create the User model
    if prefer :orm, 'mongoid'
      ## DEVISE AND MONGOID
      copy_from_repo 'app/models/user.rb', :repo => 'https://raw.github.com/RailsApps/rails3-mongoid-devise/master/' unless rails_4?
      if (prefer :devise_modules, 'confirmable') || (prefer :devise_modules, 'invitable')
        gsub_file 'app/models/user.rb', /:registerable,/, ":registerable, :confirmable,"
        gsub_file 'app/models/user.rb', /# field :confirmation_token/, "field :confirmation_token"
        gsub_file 'app/models/user.rb', /# field :confirmed_at/, "field :confirmed_at"
        gsub_file 'app/models/user.rb', /# field :confirmation_sent_at/, "field :confirmation_sent_at"
        gsub_file 'app/models/user.rb', /# field :unconfirmed_email/, "field :unconfirmed_email"
      end
      if (prefer :devise_modules, 'invitable')
        gsub_file 'app/models/user.rb', /\bend\s*\Z/ do
  <<-RUBY
  #invitable
  field :invitation_token, :type => String
  field :invitation_sent_at, :type => Time
  field :invitation_accepted_at, :type => Time
  field :invitation_limit, :type => Integer
  field :invited_by_id, :type => String
  field :invited_by_type, :type => String
end
RUBY
        end
      end
    else
      ## DEVISE AND ACTIVE RECORD
      unless prefer :railsapps, 'rails-recurly-subscription-saas'
        generate 'migration AddNameToUsers name:string'
      end
      copy_from_repo 'app/models/user.rb', :repo => 'https://raw.github.com/RailsApps/rails3-devise-rspec-cucumber/master/' unless rails_4?
      if (prefer :devise_modules, 'confirmable') || (prefer :devise_modules, 'invitable')
        gsub_file 'app/models/user.rb', /:registerable,/, ":registerable, :confirmable,"
        generate 'migration AddConfirmableToUsers confirmation_token:string confirmed_at:datetime confirmation_sent_at:datetime unconfirmed_email:string'
      end
      run 'bundle exec rake db:migrate'
    end
    ## DEVISE AND CUCUMBER
    if prefer :integration, 'cucumber'
      # Cucumber wants to test GET requests not DELETE requests for destroy_user_session_path
      # (see https://github.com/RailsApps/rails3-devise-rspec-cucumber/issues/3)
      gsub_file 'config/initializers/devise.rb', 'config.sign_out_via = :delete', 'config.sign_out_via = Rails.env.test? ? :get : :delete'
    end
  end
  ### OMNIAUTH ###
  if prefer :authentication, 'omniauth'
    if rails_4_1?
      copy_from_repo 'config/initializers/omniauth.rb', :repo => 'https://raw.github.com/RailsApps/rails-omniauth/master/'
    else
      copy_from_repo 'config/initializers/omniauth.rb', :repo => 'https://raw.github.com/RailsApps/rails3-mongoid-omniauth/master/'
    end
    gsub_file 'config/initializers/omniauth.rb', /twitter/, prefs[:omniauth_provider] unless prefer :omniauth_provider, 'twitter'
    if prefer :orm, 'mongoid'
      copy_from_repo 'app/models/user.rb', :repo => 'https://raw.github.com/RailsApps/rails3-mongoid-omniauth/master/'
    else
      generate 'model User name:string email:string provider:string uid:string'
      run 'bundle exec rake db:migrate'
      copy_from_repo 'app/models/user.rb', :repo => 'https://raw.github.com/RailsApps/rails-omniauth/master/'
    end
  end
  ### SUBDOMAINS ###
  copy_from_repo 'app/models/user.rb', :repo => 'https://raw.github.com/RailsApps/rails3-subdomains/master/' if prefer :starter_app, 'subdomains_app'
  ### AUTHORIZATION ###
  if prefer :authorization, 'pundit'
    generate 'migration AddRoleToUsers role:integer'
    copy_from_repo 'app/models/user.rb', :repo => 'https://raw.github.com/RailsApps/rails-devise-pundit/master/'
    if (prefer :devise_modules, 'confirmable') || (prefer :devise_modules, 'invitable')
      gsub_file 'app/models/user.rb', /:registerable,/, ":registerable, :confirmable,"
      generate 'migration AddConfirmableToUsers confirmation_token:string confirmed_at:datetime confirmation_sent_at:datetime unconfirmed_email:string'
    end
  end
  if prefer :authorization, 'cancan'
    generate 'cancan:ability'
    if prefer :starter_app, 'admin_app'
      # Limit access to the users#index page
      copy_from_repo 'app/models/ability.rb', :repo => 'https://raw.github.com/RailsApps/rails3-bootstrap-devise-cancan/master/'
      # allow an admin to update roles
      insert_into_file 'app/models/user.rb', "  attr_accessible :role_ids, :as => :admin\n", :before => "  attr_accessible"
    end
    unless prefer :orm, 'mongoid'
      generate 'rolify Role User'
    else
      generate 'rolify Role User --orm=mongoid'
    end
  end
  ### GIT ###
  git :add => '-A' if prefer :git, true
  git :commit => '-qm "rails_apps_composer: models"' if prefer :git, true
end # after_bundler

__END__

name: models
description: "Add models needed for starter apps."
author: RailsApps

requires: [setup, gems]
run_after: [setup, gems]
category: mvc
