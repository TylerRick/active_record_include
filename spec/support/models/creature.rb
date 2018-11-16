require_dependency 'application_record'
require_dependency 'concerns/creature_self_identification'
require_dependency 'concerns/log_when_included'

class Creature < ApplicationRecord
  include_recursively CreatureSelfIdentification
  include_when_connected TestWhenConnected
  include_when_connected TestWhenConnectedRecursive, recursive: true
end
