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
      end
      #puts %(#{self}.modules_to_include_when_connected=#{self.modules_to_include_when_connected.inspect})
      unless options[:recursive]
        options[:into_classes] ||= [self]
      end
      self.modules_to_include_when_connected ||= []
      self.modules_to_include_when_connected  |= [{mod => options}]
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
        self.modules_to_include_when_connected.each do |config|
        config.each do |(mod, options)|
          self.singleton_class.class_eval do
            attr_accessor :modules_already_included_when_connected
          end
          self.modules_already_included_when_connected ||= []
          next if self.modules_already_included_when_connected.include?(mod)

          match = (
            if options[:recursive]
              self < ActiveRecord::Base && !self.abstract_class?
            else
              self.in? options[:into_classes]
            end
          )
          #puts %(Include #{mod} into #{self} (#{options.inspect})? #{match})
          if match
            puts "Including #{mod} into #{self}" if ActiveRecordInclude::WhenConnected.verbose
            modules_already_included_when_connected << mod
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
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.class_eval do
    include ActiveRecordInclude::WhenConnected
  end
end

