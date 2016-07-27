module PrettyValidation
  module ValidationFindable
    extend ActiveSupport::Concern

    module ClassMethods
      def inherited(kls)
        super(kls)
        begin
          kls.include "#{kls}Validation".constantize if kls.ancestors.include?(::ActiveRecord::Base)
        rescue NameError
          # nothing
        end
      end
    end
  end
end
