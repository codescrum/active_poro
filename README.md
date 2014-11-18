[![GitHub version](https://badge.fury.io/gh/boennemann%2Fbadges.svg)](http://badge.fury.io/gh/boennemann%2Fbadges)

[![Code Climate](https://codeclimate.com/github/codescrum/active_poro/badges/gpa.svg)](https://codeclimate.com/github/codescrum/active_poro)

[![Test Coverage](https://codeclimate.com/github/codescrum/active_poro/badges/coverage.svg)](https://codeclimate.com/github/codescrum/active_poro)

# active_poro
Makes possible the use of has_many, has_one, belongs_to relations in POROs as you would expect


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_poro'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_poro

## Usage

You may use ActivePoro::Model as a mixin to enable relations/associations to be built between POROs
Currently supported associations:

- has_many
- has_one
- belongs_to

Example:

```ruby
require 'active_poro'

class Dog
  include ActivePoro::Model
  has_many :fleas
end

class Flea
  include ActivePoro::Model
  belongs_to :dog
end
```

Now, with that in place you should be able to do

```ruby
dog = Dog.new
flea_a = Flea.new
flea_b = Flea.new

# associate the fleas with the dog
dog.fleas = [flea_a, flea_b]

# now fleas have the dog associated back
flea_a.dog == dog
#=> true

# now fleas have the dog associated back
flea_b.dog == dog
#=> true

# if a new dog is created
another_dog = Dog.new

# and flea_b for example, jumps to it (i.e. is associated to this other dog)
flea_b.dog = another_dog

# then dog does not have flea_b now
dog.fleas
#=> [flea_a] # simplified output, not actual output on the console

# and another_dog gets flea_b
another_dog.fleas

#=> [flea_b] # simplified output, not actual output on the console
```

This also works with has_one and belongs_to as expected.

## Contributing

1. Fork it ( https://github.com/codescrum/active_poro/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
