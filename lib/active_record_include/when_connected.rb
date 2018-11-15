module ActiveRecordInclude::WhenConnected
  extend ActiveSupport::Concern

  mattr_accessor :verbose, instance_accessor: false
  @@verbose = false

  mattr_accessor :modules_to_load, instance_accessor: false
  @@modules_to_load = []

  module ClassMethods
    def include_when_connected(*mods, **options)
      ActiveRecordInclude::WhenConnected.modules_to_load |= mods
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
        ActiveRecordInclude::WhenConnected.modules_to_load.each do |mod|
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

