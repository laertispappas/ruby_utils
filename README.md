# ruby_utils

Various ruby core extensions and class utilities.

## Status
TBD


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruby_utils'
```

And then execute:

  $ bundle

Or install it yourself as:

  $ gem install ruby-utils

## Usage
TBD


## Features

### Ruby::Utils::Param
A wrapper around a ruby hash that takes a `hash` on initialization:

```ruby
hash = {
    a: 1,
    b: 2,
    c: {
      d: 3,
      e: {
        f: [{ ff: 1}, { ff: 2 }]
      }
    }
  }

param = Ruby::Utils::Param(hash)

param.c.d # => 3
param.c.missing_key # => Raises error
param.get('c.d') # => 3
```

To get access to the original has you can call `params.to_hash`

#### `#get`
Fetch the value of a key if one exist or raise an exception of no key can be found.

```ruby
param.get('a') # => 1
params.get('c.d') #=> 3
params.get('c.d.missing_key') # => raised an error
```

#### `#getOrElse`
Fetch the value of a key if any or else returns nil by default unless one is provided.

```ruby
params.getOrElse('a') # => 1
params.getOrElse('a.missing_key') # => nil
params.getOrElse('c.d') # => 3

params.getOrElse('a.missing_key', 'default_value') # => 'default_value'
```

#### `#defined?`
Returns true if key is defined else false

```ruby
param.defined?('a') # => true
param.defined?('c.e.f') # => true
param.defined('a.missing') # => false
```

#### `#all?`
Returns true when all keys are present:

```ruby
param.all?('c.e.f') # => true
params.all?(c.missing) # => false
```

#### `#with`
It call the block specified when a key can be found in the hash:

```ruby
param.with('c.e.f') do |cef_value|
  puts cef_value # => [{ ff: 1}, { ff: 2 }]
end

param.with('c.missing_key') do |some|
  raise "This will never be called"
end
```

#### `#map`
It calls the given block for each value when the key can be found in the hash.

```ruby
hash = { a: { b: 'some string' } }
param = Ruby::Utils::Param(hash)

puts param.map('a.b', &upcase) # => SOME STRING

puts param.map('a.b') do |value|
  value.upcase
end # => SOME STRING
```

### Ruby::Utils::Hash
