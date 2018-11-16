module ActiveRecordInclude::WhenConnected
  extend ActiveSupport::Concern

  mattr_accessor :verbose, instance_accessor: false
  @@verbose = false

  module ClassMethods
    def include_when_connected(mod, **options)
      self.class_eval do
        unless    defined?(modules_to_include_when_connected)
          class_attribute :modules_to_include_when_connected
        end
        unless    defined?(include_when_connected_options)
          class_attribute :include_when_connected_options
        end
      end
      #puts %(#{self}.modules_to_include_when_connected=#{self.modules_to_include_when_connected.inspect})
      self.modules_to_include_when_connected ||= []
      self.modules_to_include_when_connected  |= [mod]
      unless self < OnConnect
        include     OnConnect
      end
    end
  end

  module OnConnect
    extend ActiveSupport::Concern

    module ClassMethods
    def connection(*)
      super.tap do
        self.modules_to_include_when_connected.each do |mod|
          if self < ActiveRecord::Base && !self.abstract_class? && !(self < mod)
            puts "Including #{mod} into #{self}" if ActiveRecordInclude::WhenConnected.verbose
            class_eval do
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
    include ActiveRecordInclude::WhenConnected
  end
end

