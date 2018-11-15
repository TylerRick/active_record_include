module CreatureSelfIdentification
  extend ActiveSupport::Concern

  module ClassMethods
    def define_identity_methods
      type = model_name.singular
      define_singleton_method "#{type}?" do
        true
      end
      if superclass.respond_to?(:define_identity_methods)
        superclass.define_identity_methods
      end
    end
  end

  # Can't use `included do` because as soon as you include it into one class,
  # ActiveSupport::Concern will refuse to run the `included` block again if you include it into any
  # descendents (see Readme).
  def self.included(base)
    base.class_eval do
      puts "#{self}: included CreatureSelfIdentification" if ActiveRecordInclude::WhenInherited.verbose
      extend ClassMethods
      define_identity_methods
    end
  end
end

