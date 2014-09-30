module Paranoia
  module Persistence
    extend ActiveSupport::Concern

    def destroyed?
      send(paranoia_column) != paranoia_sentinel_value
    end

    alias :deleted? :destroyed?

    def persisted?
      !new_record?
    end

    def destroy(force: false)
      with_paranoid(force: force) do
        return super() if paranoid_force

        callbacks_result = transaction do
          run_callbacks(:destroy) do
            touch_paranoia_column
          end
        end

        callbacks_result ? self : false
      end
    end

    def destroy!(force: false)
      with_paranoid(force: force) do
        paranoid_force ? super() : destroy
      end
    end

    def delete(force: false)
      with_paranoid(force: force) do
        return super() if paranoid_force
        touch_paranoia_column unless deleted? || new_record?
      end
    end

    module ClassMethods
      def paranoid?; true; end

      def destroy_all!(conditions = nil)
        with_paranoid(force: true) do
          destroy_all(conditions)
        end
      end
    end
  end
end