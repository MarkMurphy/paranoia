module Paranoia
  module Persistence
    extend ActiveSupport::Concern

    module ClassMethods
      def paranoid?; true; end

      def destroy_all!(conditions = nil)
        with_paranoid(force: true) do
          destroy_all(conditions)
        end
      end

      def restore_all(associations: true)
        only_deleted.each do |record|
          record.restore(associations: associations)
        end
      end
    end

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

    def restore(associations: true)
      self.class.transaction do
        run_callbacks(:restore) do
          raise ActiveRecordError, "cannot touch on a new record object" unless persisted?

          attributes = timestamp_attributes_for_update_in_model
          current_time = current_time_from_proper_timezone
          changes = {}

          attributes.each do |column|
            column = column.to_s
            changes[column] = write_attribute(column, current_time)
          end

          changes[paranoia_column] = write_attribute(paranoia_column, paranoia_sentinel_value)

          changes[self.class.locking_column] = increment_lock if locking_enabled?

          @changed_attributes.except!(*changes.keys)
          primary_key = self.class.primary_key
          self.class.unscoped.where(primary_key => self[primary_key]).update_all(changes) == 1

          restore_associations if associations
        end
      end
    end

    def restore_associations(recursive: true)
      self.class.reflect_on_all_associations.each do |association|
        next unless association.klass.paranoid?

        if association.collection?
          send(association.name).restore_all
        else
          association.klass.unscoped do
            send(association.name).try(:restore, associations: recursive)
          end
        end
      end
    end

  end
end