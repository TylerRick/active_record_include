# ActiveRecordInclude

Have you ever wanted to make a module get included into *all* of your models so that you don't have
to remember to include in each individual model?

Sure, if all you need is for some methods to be *available* in all your models, then you can just
include the module in your `ApplicationRecord` and all subclasses of `ApplicationRecord` will have
access to those methods by inheritance.

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
has connected to its database:

```ruby
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
    include_when_connected NormalizeTextColumns
  end
```

By default, it includes the module into all subclasses. If you *don't* want it to include the module into subclasses, pass `recursive: false`.

```ruby
  class SomeModel < ActiveRecord::Base
    include_when_connected MyConcern, recursive: false
  end
```


## Limitations

### `ActiveSupport::Concern` modules are only included if the module is not already an ancestor

This means that the order you include concerns matters.

If you have `AA < A < ApplicationRecord` and you include the concern into `A` and then `AA`, when
you include it into `AA` the `included` block will not be run for `AA`, because it has already been
run for an ancestor of `AA`, namely `A`.

If on the other hand you somehow managed to include the concern into `AA` *before* it got included
into `A`, you *can* get it include the `included` block of the concern for both `AA` *and* `A`. But
this is easier said then done, because `A` needs to be defined first before you can
subclass it, and usually they are in different files so it would get included into `A` as soon as
the file for `A` was loaded.  You would have to be very, very intentional about it, and reopen `A`,
like this:

```
class A < ApplicationRecord
end
class AA < A
  include MyConcern
end
class A
  include MyConcern
end
```

This is a limitation of `ActiveSupport::Concern`, not of this gem. (`include_when_inherited` calls
`include` to include the concern, but it has no effect.)

Often this limitation isn't a problem, because all of your models are direct descendents of
`ApplicationRecord` and you don't need to *also* include the concern into `ApplicationRecord`, for
example.

But if you really need a module's features to be appended (its `included` code) into both a model
and its superclass, one way to work around this limitation is to define your own `included`
callback, like we did in
[`spec/support/models/concerns/creature_self_identification.rb`](spec/support/models/concerns/creature_self_identification.rb):

```ruby
  def self.included(base)
    base.class_eval do
      puts "#{self}: included CreatureSelfIdentification"
      extend ClassMethods
      define_identity_methods
    end
  end
```

Then you can call `include_recursively` from the base class of the class hierarchy you want to
include the module in, and it will append its features to *all* of its descendents:

```ruby
class Creature < ApplicationRecord
  include CreatureConcern
  include_recursively CreatureSelfIdentification
end
```


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_record_include'
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/TylerRick/active_record_include.
