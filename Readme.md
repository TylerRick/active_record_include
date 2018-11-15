# ActiveRecordInclude

Have you ever wanted to make a module get included into *all* of your models so that you don't have
to remember to include in each individual model?

If the module only includes general methods that can be used by inheritance, then you can just
include the module in your `ApplicationRecord` and you're done!

But if it's a `ActiveSupport::Concern` with a `included` blocks or similar that needs to do
something specific for each individual model subclass, then that approach doesn't work.

You can do something like this to automatically include `MyConcern` into all subclasses of
`ApplicationRecord`:

```ruby
module MyExtensions
  module ClassMethods

  private

    # These extensions aren't on (or can't be on) Base itself but on every model (every subclass of
    # Base)
    def inherited(subclass)
      super
      subclass.class_eval do
        include MyConcern
      end
    end
  end
end

class ApplicationRecord < ActiveRecord::Base
  include MyExtensions
end
```

Or you could use this gem and just write:

```ruby
class ApplicationRecord < ActiveRecord::Base
  include_when_inherited MyConcern
end
```

However, even that doesn't always work.  If we try to connect to a table from `MyConcern` that way,
we'll end up getting an error like this:

```
  PG::UndefinedTable: ERROR:  relation "application_records" does not exist
```

Model extensions/concerns that require an database connection (such as those that get a list of columns for
the model) can't be automatically included from `inherited()` because that's too early (`inherited`
gets called the moment it hits the `class Model < ApplicationRecord` line), *before* the body of the class
definition has been evaluated, and thus before the model (or its ancestors) has had a chance to
configure itself with `self.abstract_class=` or `self.table_name=` yet, for example.

Do this to have it include the given module in all (non-abstract) model subclasses as soon as that model
has connected:

```ruby
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
    include_after_connected NormalizeTextColumns
  end
```


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_record_include'
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/TylerRick/active_record_include.
