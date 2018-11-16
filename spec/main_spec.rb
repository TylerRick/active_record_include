require 'spec_helper'

ActiveRecordInclude::WhenInherited.verbose = true
ActiveRecordInclude::WhenConnected.verbose = true

RSpec.describe ActiveRecordInclude, :aggregate_failures do
  context 'when the subclasses have been defined but not connected yet' do
    it do
      expect(ActiveRecord::Base.ancestors).to_not include(ActiveRecordTextColumns)
      expect(ApplicationRecord. ancestors).to     include(ActiveRecordTextColumns)
      expect(Thing.             ancestors).to     include(ActiveRecordTextColumns)
      expect(Creature.          ancestors).to     include(ActiveRecordTextColumns)
      expect(Animal.            ancestors).to     include(ActiveRecordTextColumns)
      expect(Person.            ancestors).to     include(ActiveRecordTextColumns)


      expect(Creature.          ancestors).to     include(CreatureSelfIdentification)
      expect(Thing.             ancestors).to_not include(CreatureSelfIdentification)

      expect(Thing.             ancestors).to_not include(NormalizeTextColumns)
    end
    it do
      expect(Creature.creature?).to be true
      expect(Creature.new.creature?).to be true
      expect(Creature).to_not respond_to(:animal?)
      expect(Animal.animal?).to be true
    end
  end
  context 'when the subclasses have been defined but not connected yet' do
    before { Thing.connection }
    before { Animal.connection }
    before { Person.connection }
    it do
      expect(ActiveRecord::Base.ancestors).to_not include(NormalizeTextColumns)
      expect(ApplicationRecord. ancestors).to_not include(NormalizeTextColumns)
      expect(Thing.             ancestors).to     include(NormalizeTextColumns)
      expect(Animal.            ancestors).to     include(NormalizeTextColumns)
      expect(Person.            ancestors).to     include(NormalizeTextColumns)
      person = Person.new
      person.name = ' Seuss '
      expect(person.name).to eq 'Seuss'
    end
  end
end
