require 'spec_helper'

#ActiveRecordInclude::WhenInherited.verbose = true
#ActiveRecordInclude::WhenConnected.verbose = true

RSpec.describe ActiveRecordInclude, :aggregate_failures do
  context 'when the model has been defined but not connected yet' do
    it 'ActiveRecordTextColumns' do
      expect(ActiveRecord::Base.ancestors).to_not include(ActiveRecordTextColumns)
      expect(ApplicationRecord. ancestors).to     include(ActiveRecordTextColumns)
      expect(Thing.             ancestors).to     include(ActiveRecordTextColumns)
      expect(Creature.          ancestors).to     include(ActiveRecordTextColumns)
      expect(Animal.            ancestors).to     include(ActiveRecordTextColumns)
      expect(Person.            ancestors).to     include(ActiveRecordTextColumns)
    end
    it do
      expect(Creature.          ancestors).to     include(CreatureSelfIdentification)
      expect(Thing.             ancestors).to_not include(CreatureSelfIdentification)

      expect(Thing.             ancestors).to_not include(TestWhenConnected)
      expect(Creature.          ancestors).to_not include(TestWhenConnected)
      expect(Animal.            ancestors).to_not include(TestWhenConnected)
      expect(Thing.             ancestors).to_not include(TestWhenConnectedRecursive)
      expect(Creature.          ancestors).to_not include(TestWhenConnectedRecursive)
      expect(Animal.            ancestors).to_not include(TestWhenConnectedRecursive)
    end
    it 'nothing includes NormalizeTextColumns yet' do
      expect(Thing.             ancestors).to_not include(NormalizeTextColumns)
    end
    it do
      expect(ApplicationRecord).to_not respond_to(:animal?)
      expect(Creature).to be_creature
      expect(Creature).to_not respond_to(:animal?)
      expect(Animal).to be_animal
      expect(Animal).to be_creature
      expect(Person).to be_person
      expect(Person).to be_creature
    end
  end
  context 'when the model has connected' do
    before { Thing.connection }
    before { Animal.connection }
    before { Person.connection }
    it 'NormalizeTextColumns' do
      expect(ActiveRecord::Base.ancestors).to_not include(NormalizeTextColumns)
      expect(ApplicationRecord. ancestors).to_not include(NormalizeTextColumns)
      expect(Thing.             ancestors).to     include(NormalizeTextColumns)
      expect(Creature.          ancestors).to_not include(NormalizeTextColumns)
      expect(Animal.            ancestors).to     include(NormalizeTextColumns)
      expect(Person.            ancestors).to     include(NormalizeTextColumns)
      person = Person.new
      person.name = ' Seuss '
      expect(person.name).to eq 'Seuss'
    end
    it 'NormalizeTextColumns' do
      expect(ActiveRecord::Base.ancestors).to_not include(TestWhenConnected)
      expect(ApplicationRecord. ancestors).to_not include(TestWhenConnected)
      expect(Thing.             ancestors).to_not include(TestWhenConnected)
      expect(Creature.          ancestors).to     include(TestWhenConnected)
      expect(Animal.            ancestors).to     include(TestWhenConnected)
      expect(Person.            ancestors).to     include(TestWhenConnected)
    end
  end
end
