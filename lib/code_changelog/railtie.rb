require 'code_changelog'
require 'rails'
module CodeChangelog
  class Railtie < Rails::Railtie
    railtie_name :code_changelog

    rake_tasks do
      load "#{File.dirname(__FILE__)}/../tasks/code_changelog.rake"
    end
  end
end