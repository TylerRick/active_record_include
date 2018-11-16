module CreatureSelfIdentification
  extend ActiveSupport::Concern

  included do
    puts "#{self}: included CreatureSelfIdentification"
    type = model_name.singular
    [self, self.singleton_class].each do |klass|
      klass.class_eval do
        define_method "#{type}?" do
          true
        end
      end
    end
  end
end

