module PrettyValidation
  def self.configure
    yield config
  end

  def self.config
    @config ||= Configuration.new
  end

  class Configuration
    include ActiveSupport::Configurable

    config_accessor(:auto_generate) { false }
    config_accessor(:auto_injection) { true }
    config_accessor(:ignored_columns) { [] }
    config_accessor(:ignored_tables) { [] }
    config_accessor(:ignored_uniqueness) { [] }
  end
end
