module Paranoia
  module Scoping
    extend ActiveSupport::Concern

    included do
      default_scope { paranoid_scope }
    end

    module ClassMethods
      def paranoid_scope
        where(table_name => { paranoia_column => paranoia_sentinel_value })
      end

      def only_deleted
        with_deleted.where.not(table_name => { paranoia_column => paranoia_sentinel_value })
      end

      alias :deleted :only_deleted

      if ActiveRecord::Base.respond_to?(:unscope)
        # Rails >= 4.1
        def with_deleted
          unscope(where: paranoia_column)
        end
      else
        # Rails < 4.1
        def with_deleted
          all.tap { |s| s.default_scope = false }
        end
      end
    end
  end
end
