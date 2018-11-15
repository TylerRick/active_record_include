module CreatureSelfIdentification
  extend ActiveSupport::Concern

  included do
    puts "#{self}: included CreatureSelfIdentification"
    define_method "#{self.model_name.singular}?" do
      true
    end
  end
end

