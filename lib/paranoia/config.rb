require 'active_support/configurable'

module Paranoia
  # Configures global settings for Paranoia
  #   Paranoia.configure do |config|
  #     config.default_column = :deleted_at
  #   end
  def self.configure(&block)
    yield @config ||= Paranoia::Configuration.new
  end

  # Global settings for Paranoia
  def self.config
    @config ||= Paranoia::Configuration.new
  end

  class Configuration #:nodoc:
    include ActiveSupport::Configurable
    config_accessor :default_sentinel_value
    config_accessor :default_column do
      :deleted_at
    end
  end
end
