module LogWhenIncluded
  extend ActiveSupport::Concern

  module ClassMethods
    def log_included(base, mod)
      base.class_eval do
        puts "#{self}: included #{mod}"
        singleton_class.class_eval do
          attr_accessor :was_included
        end
        was_included ||= []
        was_included << mod
        puts %(was_included=#{(was_included).inspect})
      end
    end
  end
end

module TestWhenConnected
  include LogWhenIncluded
  def self.included(base)
    log_included base, self
  end
end

module TestWhenConnectedRecursive
  include LogWhenIncluded
  def self.included(base)
    log_included base, self
  end
end
