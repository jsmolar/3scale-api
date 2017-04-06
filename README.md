This gem aims to expose all [3scale](http://3scale.net) APIs with a Ruby interface.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ThreeScaleRest'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ThreeScaleRest

## Usage


```ruby
require 'three_scale_api'
client = ThreeScaleApi::Client.new(endpoint: 'https://foo-admin.3scale.net', provider_key: 'foobar', log_level: 'debug')

services = client.services.list
service = client.services['my_service']
```

## Design

Design decisions:

* 0 runtime dependencies
* thread safety
* tested

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To run tests run `rake` or `rspec`.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Testing
You need to have set these ENV variables:
```bash
ENDPOINT=               # Url to admin pages
PROVIDER_KEY=           # Provider key
LOG_LEVEL=              # Logging Level
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pestanko/3scale-api.
