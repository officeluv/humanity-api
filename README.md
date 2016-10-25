# HumanityApi

This gem allows easy access to the [Humanity API](https://www.humanity.shiftplanning.com/api/) using Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'humanity_api'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install humanity_api

## Usage

```ruby

# Use this gem by instantiating the class. The class is initialized with a output format of 'json'.
# Currently, the output format can only be set as json.
humanity_api = HumanityApi.new

# If you have the key and token set in your environment variables as "HUMANITY_KEY" and "HUMANITY_TOKEN", 
# the gem will find and use them. You can also access the key and token using getters and setters:
humanity_api.token = "your_token"
humanity_api.key = "your_key"

# Or you can pass them in the data packet when you make the call to the API:
data = {token: "your_token", key: "your_key"}

# Pass in a request method in your data packet as a string. If a method is not passed in, it will
# default to a get request.
data[:method] = "update"

# Also in your data packet, pass in the Humanity module as a string. You can see the full list of
# modules at https://www.humanity.shiftplanning.com/api/.
data[:module] = "staff.employee"

# You can pass in all the request parameters for the module in your data packet as well.
data[:name] = "Jane Kim"
data[:job_title] = "Developer"

# The call to the Humanity API is wrapped inside the #request_humanity_data method. Call this
# method with the data packet containing your request parameters.
humanity_api.request_humanity_data(data)

# You can check whether errors exist by using the #errors? method. You can also see which errors exist
# on the instance by using the errors getter.
humanity_api.errors? # returns true/false
humanity_api.errors  # returns an array containing error messages

# If the call is successful, the response will return an object containing the requested data from the
# Humanity API. Otherwise, it will return an object containing the error. You can check whether the
# errors on the response by accessing the 'error' key on the response object.
response = humanity_api.parse_humanity_response(data)
response['error']

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/officeluv/humanity_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [GNU License](https://www.gnu.org/licenses/gpl-3.0.en.html).

