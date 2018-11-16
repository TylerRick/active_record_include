require_dependency 'application_record'
require_dependency 'concerns/creature_concern'
require_dependency 'concerns/creature_self_identification'

class Creature < ApplicationRecord
  include CreatureConcern
  include_recursively CreatureSelfIdentification
end
