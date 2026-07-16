module ActiveRecordInclude::WhenConnected
  extend ActiveSupport::Concern

  mattr_accessor :verbose, instance_accessor: false
  @@verbose = false

  module ClassMethods
    # recursive: default is true.
    # only: (into_classes:)
    # except:
    def include_when_connected(mod, **options)
      self.class_eval do
        unless    defined?(modules_to_include_when_connected)
          class_attribute :modules_to_include_when_connected
        end
      end
      #puts %(#{self}.modules_to_include_when_connected=#{self.modules_to_include_when_connected.inspect})
      if options[:recursive] == false
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
          include_pending_modules_when_connected
        end
      end

      private

      # The pending includes are also applied at the end of `inherited` (after ActiveRecord's own
      # inherited chain has completed and set @base_class), because a class might have its
      # scopes/concern methods accessed before any `connection` call happens on that specific class.
      # (On Rails <= 5.2 the first connection call always happened during class definition, which had
      # the same effective timing.)
      def inherited(subclass)
        super.tap do
          if subclass < ActiveRecord::Base
            subclass.send(:include_pending_modules_when_connected)
          end
        end
      end

      def include_pending_modules_when_connected
        # Rails 7+/8: ActiveRecord (and some extensions, e.g. torque-postgresql's
        # physically_inherited?) call `connection` from within the `inherited` hook chain, i.e.
        # while the new subclass is still mid-definition (AR sets @base_class only *after* its
        # inherited super chain returns). Including concerns that inspect the schema (table_exists?,
        # table_name -> base_class) at that point breaks. Skip; the inherited-after-super hook above
        # (or a later connection call) will perform the includes once the class is fully defined.
        return if name.nil?
        return if self < ActiveRecord::Base && !instance_variable_defined?(:@base_class)
        # Guard against re-entrancy: the included concerns themselves call connection.
        return if @_including_modules_when_connected

        @_including_modules_when_connected = true
        begin
          self.modules_to_include_when_connected.each do |config|
          config.each do |(mod, options)|
            self.singleton_class.class_eval do
              attr_accessor :modules_already_included_when_connected
            end
            self.modules_already_included_when_connected ||= []
            next if self.modules_already_included_when_connected.include?(mod)

            match = (
              if options[:into_classes]
                self.in? options[:into_classes]
              else
                self < ActiveRecord::Base && !self.abstract_class?
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
        ensure
          @_including_modules_when_connected = false
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
