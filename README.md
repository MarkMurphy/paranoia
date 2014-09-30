# Paranoia

Paranoia is a light weight and configurable soft-delete gem for Rails 4.

Use this gem if you wished that when you called `destroy` on an Active Record object that it didn't actually destroy it, but just *hid* the record. Paranoia does this by setting a `deleted_at` field to the current time when you `destroy` a record, and hides it by scoping all queries on your model to only include records which do not have a `deleted_at` field.

If you wish to actually destroy an object you may call `destroy!(force: true)`. **WARNING**: This will also *destroy* all `dependent: destroy` records, so please aim this method away from face when using.

If a record has `has_many` associations defined AND those associations have `dependent: :destroy` set on them, then they will also be soft-deleted if `acts_as_paranoid` a.k.a `paranoid` is set, otherwise the normal destroy will be called.



## Table of contents

- [Installation](#installation)
- [Configuration](#configuration)
- [Updating](#updating)
- [Usage](#usage)
    - [Configuring your model](#configuring-your-model)
    - [Force destroy](#force-destroy)
    - [Callbacks](#callbacks)
    - [Retrieve all records including deleted](#retrieve-all-deleted-records-including-deleted)
    - [Retrieve only deleted records](#retrieve-only-deleted-records)
    - [Retrieve deleted associations](#retrieve-deleted-associations)
    - [Check if a record is deleted](#check-if-a-record-is-deleted)
    - [Restoration](#restoration)
- [Bugs and feature requests](#bugs-and-feature-requests)
- [Contributing](#contributing)
- [Versioning](#versioning)
- [Migrating](#migrating)
- [License](#license)



## Installation

**Rails 4**

``` ruby
gem "paranoia", "~> 3.0.0"
```

Of course you can install this for from GitHub as well:

``` ruby
gem "paranoia", :github => "radar/paranoia", :branch => "master"
```

**Rails 3**

``` ruby
gem "paranoia", "~> 1.0"
```

and don't forget to bundle!

``` shell
bundle install
```



## Updating

Updating your installation is as simple as `bundle update paranoia`.

#### Run your migrations for the desired models

``` shell
rails generate migration AddDeletedAtToClients deleted_at:datetime:index
```

and now you have a migration

``` ruby
class AddDeletedAtToClients < ActiveRecord::Migration
  def change
    add_column :clients, :deleted_at, :datetime
    add_index :clients, :deleted_at
  end
end
```



## Configuration

Support for Unique Keys with Null Values

Most databases ignore null columns when it comes to resolving unique index
constraints.  This means unique constraints that involve nullable columns may be
problematic. Instead of using `NULL` to represent a not-deleted row, you can pick
a value that you want paranoia to mean not deleted. Note that you can/should
now apply a `NOT NULL` constraint to your `deleted_at` column.

If you want to use a custome value other than `NULL` to mean not deleted, you can pass it as an option in your model:

```ruby
class Client < ActiveRecord::Base
  acts_as_paranoid sentinel_value: DateTime.new(0)
  # ...
end
```

If you want to use a column other than `deleted_at`, you can pass it as an option in your model:

``` ruby
class Client < ActiveRecord::Base
  acts_as_paranoid column: :destroyed_at
  # ...
end
```

You can also set either of the options above globally in a rails initializer, e.g. `config/initializer/paranoia.rb`

```ruby
# config/initializer/paranoia.rb
Paranoia.configuration do |config|
  config.default_column = :deleted_at
  config.default_sentinel_value = DateTime.new(0)
end
```



## Usage

#### Configuring your model

``` ruby
class Client < ActiveRecord::Base
  acts_as_paranoid # you can also use "paranoid", it's an alias for "acts_as_paranoid"

  # ...
end
```

Hey presto, it's there! Calling `destroy` will now set the `deleted_at` column:


``` ruby
>> client.deleted_at
# => nil
>> client.destroy
# => client
>> client.deleted_at
# => [current timestamp]
```

#### Force destroy

If you really want it gone *gone*, call `destroy!(force: true)`:

``` ruby
>> client.deleted_at
# => nil
>> client.destroy!(force: true)
# => client
```

#### Callbacks

If you want a method to be called on destroy, simply provide a `before_destroy` callback:

``` ruby
class Client < ActiveRecord::Base
  acts_as_paranoid

  before_destroy :some_method

  def some_method
    # do stuff
  end

  # ...
end
```

#### Retrieve all records including deleted

If you want to find all records, even those which are deleted:

``` ruby
Client.with_deleted
```

#### Retrieve only deleted records

If you want to find only the deleted records:

``` ruby
Client.only_deleted
```

#### Retrieve deleted associations

If you want to access soft-deleted associations, override the getter method:

``` ruby
def product
  Product.unscoped { super }
end
```

#### Check if a record is deleted

If you want to check if a record is soft-deleted:

``` ruby
client.destroyed?
```

#### Restoration

If you want to restore a record:

``` ruby
Client.restore(id)
```

If you want to restore a whole bunch of records:

``` ruby
Client.restore([id1, id2, ..., idN])
```

If you want to restore a record and their dependently destroyed associated records:

``` ruby
Client.restore(id, :recursive => true)
```

If you want callbacks to trigger before a restore:

``` ruby
before_restore :callback_name_goes_here
```



## Bugs and feature requests

Have a bug or a feature request? Please first search for existing and closed issues. If your problem or idea is not addressed yet, [please open a new issue](https://github.com/MarkMurphy/paranoia/issues/new).



## Contributing

Come one, come all, contributing is welcome! Feel free to send pull-requests, create issues and feature requests.



## Versioning

For transparency into our release cycle and in striving to maintain backward compatibility, Paranoia is maintained under [the Semantic Versioning guidelines](http://semver.org/). Sometimes we screw up, but we'll adhere to those rules whenever possible.



## Migrating

You can migarte from older versions of Paranoia by replacing the following methods as follows:

| Old Syntax                 | New Syntax                     |
|----------------------------|--------------------------------|
|`find_with_deleted(:all)`   | `with_deleted`                 |
|`find_with_deleted(:first)` | `with_deleted.first`           |
|`find_with_deleted(id)`     | `with_deleted.find(id)`        |
|`really_destroy!`           | `destroy!(force: true)`        |



## License

This gem is released under the MIT license.
