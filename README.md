# Block Repeater

A way to repeat a block of code until either a given condition is met or a timeout has been reached

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'block_repeater'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install block_repeater

## Usage
Add the repeater and it's methods into a project
```ruby
include BlockRepeater
```

In order to maintain parity with existing Repeater implementations you may also need to expose the repeater class itself
```ruby 
Repeater = BlockRepeater::Repeater
```

### Repeat method
This is the preferred way to use the repeater. It requires two blocks, the one to be executed and the one which sets the exit condition. As these are ordinary ruby blocks they can be defined using either `{ }` or `do end` syntax.

```ruby
  repeat { call_database_method }.until{ |result| result.count.positive? }
```
```ruby
  repeat do
    call_database_method
  end.until do |result| 
    result.count.positive? 
  end
```
 
The repeater also takes two parameters:
 - `delay:` is how long in seconds the repeater will wait between attempts (defaults to 0.2 seconds)
 - `times:` is how many attempts the repeater will make before giving up (defaults to 25)
 ```ruby
   repeat (delay: 0.5, times: 10){ call_database_method }.until{ |result| result.count.positive? }
 ```

### RSpec functionality
An RSpec expectation can be used in the block for the `until` method. The expectation will be attempted each try, but the exception will only be raised if it has still failed once the number or attempts has been reached.
```ruby
  repeat do
    call_database_method
  end.until do |result| 
    expect(result.count).to be_positive, raise 'No result returned from databased'
  end
```
### Non predefined condition methods
Very simple conditions can be utilised without using a block. This expects either one or two method names which will be called against the result of repeating the main block.
The required format is `until_<method name>` or `until_<method name>_becomes_<method name>`.
  
```ruby
  repeat { a_method_which_returns_a_number }.until_positive?
  #Attempts to call the :positive? method on the result of the method call

  repeat { a_method_which_returns_an_array }.until_count_becomes_positive?
  #Attempts to call :count on the result of the method call, then :positive? on that result
````
This supports two consecutive method calls, anything more complex should be written out in full in the standard manner.

### Direct class usage
It's also possible to directly access the Repeater class which has been left available as to not break existing functionality. It's not recommended to combine this with the non predefined condition method pattern described above.
```ruby
  Repeater = BlockRepeater::Repeater

  Repeater.new do
    call_database_method
  end.until do |result| 
    expect(result.count).to be_positive, raise 'No result returned from databased'
  end.repeat(delay: 1, times: 5)
```
In this case any optional arguments (`times` or `delay`) must be sent to the method called `repeat`, which is called after the second block. The repeat method is mandatory to run the repeater when using it in this manner.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
