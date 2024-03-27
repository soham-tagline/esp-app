# EspAdapter

This Ruby library provides a EspAdapter::Mailchimp class to interact with the Mailchimp Marketing API (version 3.0). It simplifies integrating Mailchimp functionalities into your Ruby applications.

## Installation

To install EspAdapter, add it to your Gemfile by executing:

    $ gem 'esp_adapter'

Then run:

    $ bundle install

## Usage

The EspAdapter::Mailchimp class offers methods for various Mailchimp Marketing API interactions. Here are some examples:

1. Getting All Lists:

```RUBY
require ‘esp_adapter’

mailchimp = EspAdapter::Mailchimp.new(‘<Your mailchimp api key>’)

lists = mailchimp.lists

# The `lists` method calls to retrieving data from the Mailchimp API endpoint for lists.

puts lists.inspect  # This displays the response data from the Mailchimp API
```

2. Getting Metrics of a Specific List:

```RUBY
list_id = 'YOUR_LIST_ID'

metrics = mailchimp.list_metrics(list_id)

# The `list_metrics` method retrieves data for a specific list using the list ID.

puts metrics.inspect  # This displays the metrics data for the specified list
```

### Note:

Refer to the Mailchimp Marketing API documentation for a complete list of available methods and parameters. You can find the documentation here: https://mailchimp.com/developer/marketing/api/

## Development

Clone the repository:

    $ git clone https://github.com/soham-tagline/esp-app.git

Navigate into the cloned directory:

    $ cd esp-app

Run bin/setup to install dependencies:

    $ bin/setup

Run tests using:

    $ bundle exec rspec

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/soham-tagline/esp-app.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
