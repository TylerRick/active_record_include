require 'active_record/migration'

ActiveRecord::Schema.define do
  create_table :creatures, force: true do |t|
    t.string :type
    t.string :name
    t.string :skill
  end

  create_table :things, force: true do |t|
    t.string :name
  end
end
