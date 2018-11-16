module ActiveRecordInclude::WhenInherited
  extend ActiveSupport::Concern

  mattr_accessor :verbose, instance_accessor: false
  @@verbose = false
  @@verbose = true

  mattr_accessor :modules_to_load, instance_accessor: false
  @@modules_to_load = []

  module ClassMethods
    def include_when_inherited(*mods)
      ActiveRecordInclude::WhenInherited.modules_to_load |= mods
      puts %(ActiveRecordInclude::WhenInherited.modules_to_load=#{(ActiveRecordInclude::WhenInherited.modules_to_load).inspect})
      unless self < OnInherit
        include     OnInherit
      end
    end
    alias_method :include_in_subclasses, :include_when_inherited

    def include_recursively(*mods)
      mods.each {|mod| include mod }
      include_in_subclasses *mods
    end
  end

  module OnInherit
    extend ActiveSupport::Concern

    module ClassMethods
      private
      def inherited(subclass)
        puts "OnInherit: inherited(#{subclass})"
        super.tap do
          ActiveRecordInclude::WhenInherited.modules_to_load.each do |mod|
            if subclass < ActiveRecord::Base && !subclass.abstract_class? && !(subclass < mod)
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
