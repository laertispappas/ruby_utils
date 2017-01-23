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

### Ruby::Utils::Option
A scala like container for zero or one element. An option can be either Some[Object]
or None object.

Creating a Some or None option:
```ruby
  def find_person(id)
    person = Person.find_by_id
    person ? Some(person) : None
  end

  person = find_person(1)
  person.class # None if not found else Some(person)
```

#### `#empty? || #defined?` True if None, false if Some

```ruby
  none = None
  none.empty? # => true
  none.defined? # => false

  some = Some(Class.new)
  some.empty? # => false
  some.defined? # => true
```

#### `get` Returns the option's value or an exception is raised in case of non empty option.

```ruby
  none = None
  none.get # => NoSuchElementError

  some = Some(12)
  some.get # => 12
```

#### `get_or_else(default)` Returns the option's value if the option is nonempty, otherwise return the result of evaluating `default`.

```ruby
  none = None
  none.get_or_else("default") # => 'default'


  some = Some(12)
  some.get_or_else("default") # => 12
```

#### `map(f=nil, &block)` Returns a Some containing the result of applying f / or evaluating the block to self option's value if this option is nonempty. Otherwise return None

```ruby
  f = ->(x) { x*x }

  none = None
  none.map(f) #=> None
  none.map { |e| e* 100 } # -> none

  some = Some(10)
  some.map(f) # => Some(100)
  some.map { |e| e*2 } # => Some(20)
```

#### `flat_map(f, &block)` If the option is nonempty, return a function applied to its value.
Otherwise return None.

```ruby
  f = ->(x) { x * 10 }
  none = None
  none.flat_map(f) # => None
  none.flat_map { |a| a } # => None

  some = Some(20)
  some.flat_map(f) # => 200
  some.flat_map { |e| e * 2 } # => 40
```

#### `filter(p=nil, &block)` If the option is nonempty and the given predicate `p` yields `false` on its value, return `None`. Otherwise return the option value itself.

```ruby
  p = ->(x) { x % 2 == 0 }

  none = None
  none.filter(p) # => None
  none.filter { |a| a == 1 } # => None

  some = Some(10)
  some.filter(p) # => Some(10)

  some = Some(3)
  some.filter(p) # => None
```

#### `or_else(alternative)` If the option is nonempty return it, otherwise return the result of evaluating an alternative expression.

```ruby
  none = None
  none.or_else(12) # => 12
  none.or_else(Some(12)) # => Some(12)

  some = Some(10)
  some.or_else(111) # => Some(10)
```

#### `match` [Experimental] Provides pseudo pattern match for option classes (see also `List#match`)

```ruby
  def get(id)
    if id == 1
      None
    else
      Some(id)
    end
  end

  some_value = get(1) # None
  result = some_value.match {
    on None => 'missing'
    on Some(x) => x * 100
  }

  purs result # => 'missing'


  other_value = get(10)
  res2 = other_value.match {
    on None => 'missing2'
    on Some(y) => y * 10
  }

  puts res2 # => 100
```


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
