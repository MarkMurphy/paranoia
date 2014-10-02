module Paranoia
  module Scoping
    extend ActiveSupport::Concern

    included do
      default_scope { without_deleted }
    end

    module ClassMethods
      def without_deleted
        where(table_name => { paranoia_column => paranoia_sentinel_value })
      end

      alias_method :paranoia_scope, :without_deleted
      alias_method :not_deleted, :without_deleted
      alias_method :except_deleted, :without_deleted

      def only_deleted
        with_deleted.where.not(table_name => { paranoia_column => paranoia_sentinel_value })
      end

      alias_method :deleted, :only_deleted

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
