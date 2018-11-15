module LogWhenIncluded
  extend ActiveSupport::Concern

  module ClassMethods
    def log_included(base, mod)
      base.class_eval do
        #puts "#{self}: included #{mod}"
        self.singleton_class.class_eval do
          attr_accessor :was_included
        end
        self.was_included ||= []
        self.was_included << mod
      end
    end
  end
end

module TestWhenConnected
  include LogWhenIncluded
  def self.included(base)
    log_included base, self
    #puts %(#{base}.was_included=#{base.was_included.inspect})
  end
end

module TestWhenConnectedRecursive
  include LogWhenIncluded
  def self.included(base)
    log_included base, self
  end
end
