# Viberuby

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'viberuby'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install viberuby

## Usage in rails app

```
#routes.rb

post 'viberadapter', to: 'viber_adapter#events'
```

```
#viber_adapter_controller.rb

class ViberAdapterController < ApplicationController
  skip_before_action :verify_authenticity_token
  @viber = Viberuby::Client.new(ENV['VIBER_API_TOKEN'])

  def events
    case params['event']
    when 'webhook'
      render plain: webhook_response
    when 'message'
      answer
      render plain: 'ok'
    else
      render plain: 'ok'
    end
  end

  private

  def webhook_response
    {
       "status": 0,
       "status_message": "ok"
    }
  end

  def answer
    @viber.send_message.(message, user_id)
  end
end
```

Start application
`rails s`

Setting a webhook
`curl -d '{"url":"https://localhost:3000/viberadapter"}' -H "X-Viber-Auth-Token: VIBER_API_TOKEN" -X POST https://chatapi.viber.com/pa/set_webhook`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/viberuby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Viberuby project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/viberuby/blob/master/CODE_OF_CONDUCT.md).
