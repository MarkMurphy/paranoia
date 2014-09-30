require 'active_support/concern'
require 'active_support/configurable'
require 'active_record'

require 'paranoia/version'
require 'paranoia/config'
require 'paranoia/persistence'
require 'paranoia/callbacks'
require 'paranoia/scoping'

module Paranoia
  extend ActiveSupport::Concern

  def paranoid?
    self.class.paranoid?
  end

  def paranoid_force
    self.class.paranoid_force
  end

  def with_paranoid(*args, &block)
    self.class.with_paranoid(*args, &block)
  end

  module ClassMethods
    def paranoid?; false; end

    def paranoid(options = {})
      include Persistence
      include Callbacks
      include Scoping

      class_attribute :paranoia_column, :paranoia_sentinel_value

      self.paranoia_column = (options.fetch(:column) {
        Paranoia.config.default_column
      }).to_s

      self.paranoia_sentinel_value = options.fetch(:sentinel_value) {
        Paranoia.config.default_sentinel_value
      }
    end

    alias acts_as_paranoid paranoid

    def with_paranoid(force: false)
      forced, previous_force_value = force || self.paranoid_force
      previous_force_value = self.paranoid_force
      self.paranoid_force = forced
      return yield
    ensure
      self.paranoid_force = previous_force_value
    end

    def paranoid_force=(value)
      Thread.current['paranoid_force'] = value
    end

    def paranoid_force
      Thread.current['paranoid_force']
    end
  end

  private

  # Inserts current time into paranoia column.
  # @param with_transaction [boolean] execute with an ActiveRecord transaction.
  def touch_paranoia_column(with_transaction = false)
    unless self.frozen?
      if with_transaction
        with_transaction_returning_status { touch(paranoia_column) }
      else
        touch(paranoia_column)
      end
    end
  end
end

ActiveRecord::Base.send :include, Paranoia