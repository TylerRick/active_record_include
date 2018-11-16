module ActiveRecordInclude::WhenInherited
  extend ActiveSupport::Concern

  mattr_accessor :verbose, instance_accessor: false
  @@verbose = false

  module ClassMethods
    def include_when_inherited(mod)
      self.class_eval do
        unless    defined?(modules_to_include_when_inherited)
          class_attribute :modules_to_include_when_inherited
        end
      end
      #puts %(#{self}.modules_to_include_when_inherited=#{self.modules_to_include_when_inherited.inspect})
      self.modules_to_include_when_inherited ||= []
      self.modules_to_include_when_inherited  |= [mod]
      unless self < OnInherit
        include     OnInherit
      end
    end
    alias_method :include_in_subclasses, :include_when_inherited

    def include_recursively(mod)
      include               mod
      include_in_subclasses mod
    end
  end

  module OnInherit
    extend ActiveSupport::Concern

    module ClassMethods
      private
      def inherited(subclass)
        super.tap do
          subclass.modules_to_include_when_inherited.each do |mod|
            if subclass < ActiveRecord::Base && !subclass.abstract_class?
              puts "Including #{mod} into #{subclass}" if ActiveRecordInclude::WhenInherited.verbose
              subclass.class_eval do
                include mod
              end
            end
          end
        end
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.class_eval do
    include ActiveRecordInclude::WhenInherited
  end
end
