# seedify

[![Gem Version](https://img.shields.io/gem/v/seedify.svg?style=flat-square&label=version)](https://rubygems.org/gems/seedify)
[![Downloads](https://img.shields.io/gem/dt/seedify.svg?style=flat-square)](https://rubygems.org/gems/seedify)
[![Scrutinizer Code Quality](https://img.shields.io/scrutinizer/g/visualitypl/seedify.svg?style=flat-square)](https://scrutinizer-ci.com/g/visualitypl/seedify/?branch=master)
[![Code Climate](https://img.shields.io/codeclimate/github/visualitypl/seedify.svg?style=flat-square)](https://codeclimate.com/github/visualitypl/seedify)
[![Test Coverage](https://img.shields.io/codeclimate/coverage/github/visualitypl/seedify.svg?style=flat-square)](https://codeclimate.com/github/visualitypl/seedify)

Let your seed code become a first-class member of the Rails app and put it into seed objects. **seedify** allows to implement and organize seeds in object-oriented fashion, putting them into `db/seeds` which organizes seeds much like `app/models` does with models etc. It also provides handy syntax for command line parameters and progress logging.

Here's an overview of what you can achieve with **seedify**:

- organize seed code in object-oriented, Rails convention fitting fashion
- take advantage of inheritance and modularization when writing seeds
- invoke seeds as rake tasks or from within the app/console
- allow to specify custom parameters for your seeds, typed and with defaults
- log the seed progress (e.g. mass creation) without effort
- combine with [factory_girl](https://github.com/thoughtbot/factory_girl) to simplify object creation and share fixtures with specs

## Installation

First, add **seedify** to `Gemfile`. Be sure to add it just to group(s) you'll actually use it in:

```ruby
gem 'seedify', group: 'development'
```

Then run:

```sh
bundle install
```

## Usage

### Basic example

You should start by implementing the `ApplicationSeed` class:

```ruby
# db/seeds/application_seed.rb
class ApplicationSeed < Seedify::Base
  def call
    if Admin.empty?
      log 'create first admin'

      Admin.create!(email: 'admin@example.com', password: 'password')
    else
      log "admin already exists: '#{Admin.first.email}'"
    end
  end
end
```

This will create an admin if there's none and output existing admin's e-mail otherwise.

Now, call the seed as rake task:

```sh
rake seedify
```

or from Rails console:

```ruby
ApplicationSeed.call
```

### Using fixtures

[factory_girl](https://github.com/thoughtbot/factory_girl) is great for sharing model fixtures between tests and seeds. Add `factory_girl_rails` gem to development group and include its methods, so you can use `#create` in seeds:

```ruby
class ApplicationSeed < Seedify::Base
  include FactoryGirl::Syntax::Methods

  def call
    create :admin
  end
end
```

### Custom parameters

You'll often need to parameterize your seed. You can do this easily via `param_reader`:

```ruby
class ApplicationSeed < Seedify::Base
  include FactoryGirl::Syntax::Methods

  param_reader :prefix,    default: 'user'
  param_reader :count,     type: :integer, default: 5
  param_reader :with_post, type: :boolean, default: false

  def call
    count.times do |index|
      user = create :user, email: "#{prefix}-#{index}@example.com"

      create :post, user: user if with_post?
    end
  end
end
```

You can specify the type of your param and have it casted automatically. Supported types are:

- `:string` default type, default value: **nil**
- `:integer` default value: **0**
- `:boolean` default value: **false**, accessor with `?` suffix

Specify the parameters for rake task:

```sh
rake seedify prefix=guy count=20 with_post=true
```

or from Rails console:

```ruby
ApplicationSeed.call prefix: 'guy', count: 20, with_post: true
```

### Logging

Seed with detailed progress logging feels responsive and is easier to debug in case of a failure. That's why **seedify** provides three log methods for your convenience:

**Simple message** (block is optional):

```ruby
log "create user '#{email}'" do
  create :user, email: email
end
```

**Array evaluation with live progress**:

```ruby
log_each ['a', 'b', 'c'], 'create users' do |prefix|
  create :user, email: "#{prefix}@example.com"
end
```

**N-times evaluation with live progress**:

```ruby
log_times 5, 'create users' do |n|
  create :user, email: "user-#{n}@example.com"
end
```

Notes:

- `log_each`/`log_times` is great for creating large amounts of data with live progress indication
- texts between `'`, `"` or `*` (like in first example above) quotes are colorized for emphasis
- logging to `stdout` is enabled by default; disable it by setting the `log` parameter to false

### Organizing seed code

Your seed code will grow along with application development so keeping it clean and well-separated will become important. It's easy thanks to **seedify**'s object-oriented approach. Imagine all-in-one application seed like below:

```ruby
class ApplicationSeed < Seed::Base
  include FactoryGirl::Syntax::Methods

  param_reader :admin_email, default: 'admin@example.com'
  param_reader :user_prefix, default: 'user'
  param_reader :user_count,  type: :integer, default: 5

  param_reader :clear_method, default: 'destroy'

  def call
    clear_model(Admin)
    clear_model(User)

    log "create admin *#{admin_email}* with root priviliges" do
      create :admin, :with_root_priviliges, email: admin_email
    end

    log user_count, 'create users' do |index|
      create :user, email: "#{user_prefix}-#{index}@example.com"
    end
  end

  private

  def clear_model(model)
    case clear_method
    when 'truncate'
      ActiveRecord::Base.connection.execute("TRUNCATE #{model.table_name}")
    when 'destroy'
      model.destroy_all
    end
  end
end
```

You can separate the seed code into domains that fit your application best (including modules). In this case, we'll create model-oriented seeds for `Admin` and `User` models and keep application-wide code and param readers in application seed:

```ruby
# db/seeds/application_seed.rb
class ApplicationSeed < Seed::Base
  include FactoryGirl::Syntax::Methods

  param_reader :clear_method, default: 'destroy'

  def call
    AdminSeed.call
    UserSeed.call
  end

  protected

  def clear_model(model)
    case clear_method
    when 'truncate'
      ActiveRecord::Base.connection.execute("TRUNCATE #{model.table_name}")
    when 'destroy'
      model.destroy_all
    end
  end
end
```

```ruby
# db/seeds/admin_seed.rb
class AdminSeed < ApplicationSeed
  param_reader :admin_email, default: 'admin@example.com'

  def call
    clear_model(Admin)

    log "create admin *#{admin_email}* with root priviliges" do
      create :admin, :with_root_priviliges, email: admin_email
    end
  end
end
```

```ruby
# db/seeds/user_seed.rb
class UserSeed < ApplicationSeed
  param_reader :user_prefix, default: 'user'
  param_reader :user_count,  type: :integer, default: 5

  def call
    clear_model(User)

    log user_count, 'create users' do |index|
      create :user, email: "#{user_prefix}-#{index}@example.com"
    end
  end
end
```

> Params defined in application seed will be available in seeds that inherit from it too.

You can now invoke each seed separately:

```sh
rake seedify:admin clear_method=none
rake seedify:user user_count=10
```

or all at once like before with `rake seedify`.

You should try to write each seed object in a way that makes it possible to use it either stand-alone or as a sub-seed called from another seed object. This way, for instance, you'll be able to generate more objects in specific domain without touching rest of the system or recreate whole system data - depending on your needs - with the same seed code.

You can customize sub-seed invocation with a syntax you already know - the call parameters:

```ruby
# excerpt from db/seeds/application_seed.rb
UserSeed.call user_prefix: 'user_generated_by_app_seed'
```

This way, within **UserSeed**, the `user_prefix` param will equal to *user_generated_by_app_seed* regardless of the one specified when calling the application seed from console or command-line.

### Callbacks and multi-tenancy

If you have code that needs to be run before whole seed suite (similar to `before(:all)` in RSpec), you can use the `before_all` method. It'll be called just once - the first time seed using it or its descendants will be called. Common use case is to pre-set proper schema with multi-tenant application using the [apartment](https://github.com/influitive/apartment) gem:

```ruby
class TenantSeed < Seedify::Base
  param_reader :tenant

  before_all :switch_tenant

  def call
    SomeSeed.call
    OtherSeed.call
  end

  protected

  def switch_tenant
    log "switching to *#{tenant}* schema" do
      Apartment::Tenant.switch!(tenant)
    end
  end
end

class SomeSeed < TenantSeed
end

class OtherSeed < TenantSeed
end
```

You can call tenant seed or some/other seeds separately and proper schema will always be picked.

## Configuration

You can override the default `db/seeds` seed directory if you want to place your seed objects in different place in the project:

```ruby
# excerpt from config/application.rb
config.seedify_seed_directory = "#{config.root}/app/seeds"
```

Remember that everything you put into `app/*` gets preloaded in production so putting your seeds there makes sense only if you actually want to use them in production. That's why they live in `db/seeds` by default.

## Contributing

1. Fork it (https://github.com/visualitypl/seedify/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

