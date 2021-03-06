# Application template recipe for the rails_apps_composer. Change the recipe here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/core.rb

## Git
say_wizard "selected all core recipes"

__END__

name: core
description: "Select all core recipes."
author: RailsApps

requires: [git, railsapps,
  learn_rails,
  rails_bootstrap,
  rails_foundation,
  rails_omniauth,
  rails_devise,
  rails_devise_pundit,
  rails_signup_download,
  setup, readme, gems,
  testing, tests4,
  email,
  models, controllers, views, routes,
  frontend,
  init, prelaunch, saas,
  extras, deployment]
category: collections
