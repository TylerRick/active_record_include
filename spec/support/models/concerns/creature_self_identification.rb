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

  # Not `included do`
  def self.included(base)
    base.class_eval do
      puts "#{self}: included CreatureSelfIdentification" if ActiveRecordInclude::WhenInherited.verbose
      extend ClassMethods
      define_identity_methods
    end
  end
end

