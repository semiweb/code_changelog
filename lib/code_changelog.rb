require 'code_changelog/version'
require 'code_changelog/arma_code_changelog'
require 'code_changelog/client_code_changelog'


module CodeChangelog
  require "code_changelog/railtie" if defined?(Rails)

  class CodeChangelog
    def initialize()
    end

  end
end
