require 'normalize_text_columns'

ActiveRecord::Base.class_eval do
  include_when_inherited ActiveRecordTextColumns
end

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  include_when_connected NormalizeTextColumns, recursive: true
end
