# QueueTimeStatsdReporter

QueueTimeStatsdReporter reports to Datadog the time a request spends queued before hitting your Rails/Rack application.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'queue_time_statsd_reporter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install queue_time_statsd_reporter

## Usage

In your web server, configure the X-Request-Start header, eg. for Nginx:

```
location @app {
  proxy_set_header X-Request-Start "t=${msec}";
}
```

Next in Rails create an initialiser containing the code:

```ruby
metric_name = "mycorp.widgetsapp.queue_time"
tags = ["env:#{Rails.env}"]
Rails.application.middleware.unshift QueueTimeStatsdReporter, my_statsd_object, metric_name, tags
```

where `my_statsd_object` is an object, perhaps a proxy for your statsd implementation, that has a method with signature:

```ruby
gauge(metric, value, tags=[])
```

When a request is received QueueTimeStatsdReporter will report the time spent queueing by calling the guage method with:

- metric: The string metric name, eg. "mycorp.widgetsapp.queue_time"
- value: the time spent queued in seconds
- tags: any tags passed into the middleware initialiser

### Bringing it all together

For instance, if you're reporting to Datadog your object might look something like:

```ruby
class MyDatadogClass
  def initialize(endpoint = Datadog::Statsd.new(ENV.fetch("STATS_HOST", "localhost"), 8125))
    @endpoint = endpoint
  end

  def gauge(metric, value, tags=[], sample_rate=1)
    @endpoint.gauge(metric, value, tags: tags, sample_rate: sample_rate)
  end
end
```

and your initialiser:

```ruby
Rails.application.middleware.unshift QueueTimeStatsdReporter, MyDatadogClass.new, "mycorp.widgetsapp.queue_time", ["env:#{Rails.env}", "infra:aws"]
```

You can use this middleware outside of Rails too.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rubytune/queue_time_statsd_reporter.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Authors

* @wjessop, will@willj.net
