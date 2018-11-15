require 'active_support/core_ext/object/inclusion'

module ActiveRecordTextColumns
  extend ActiveSupport::Concern

  included do
    puts "#{self}: included ActiveRecordTextColumns" if ActiveRecordInclude::WhenInherited.verbose
  end

  module ClassMethods
    def text_columns
      columns.
        select {|_| _.type.in? [:string, :text, :citext]}.
        reject {|_| _.name.to_sym.in? text_columns_not_treated_as_text.map(&:to_sym) if respond_to?(:text_columns_not_treated_as_text) }
    end
    def text_column_names
      text_columns.map(&:name).map(&:to_sym)
    end
  end

  # Get a list of text_column_names for every model
  def self.text_column_names_by_model
    ::ActiveRecord::Base.descendants.each_with_object({}) do |model, hash|
      next if model.abstract_class?
      hash[model.name] = model.text_column_names
    end
  end
end
