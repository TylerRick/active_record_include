require 'active_record_text_columns'

module NormalizeTextColumns
  extend ActiveSupport::Concern

  included do
    #puts "#{self}: included NormalizeTextColumns"
    normalizy *text_column_names, with: [:strip, :null_if_blank]
  end
end
