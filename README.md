# CLI Generator of DOI Resolution Reports from an ElasticSearch Index

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/kishu`. To experiment with that code, run `bin/console` for an interactive prompt.

![kishu](https://c1.staticflickr.com/8/7196/6947533965_2ae463d1c6_b.jpg)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kishu'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kishu

## Usage


First setup your JWT and the host to send reports

```
export HUB_TOKEN="nsdfkhdfs89745fdfdsDFSFDS"
export HUB_URL="https://api.test.datacite.org"

```

You can generate a usage report locally with:

```shell
kishu sushi generate created_by:{YOUR DATACITE CLIENT ID}
```

To generate and push a usage report in JSON format following the Code of Practice for Usage Metrics, you can use the following command. 

```shell
kishu sushi push created_by:{YOUR DATACITE CLIENT ID}
```

To stream a usage report in JSON format following the Code of Practice for Usage Metrics, you can use the following command. This option should be only used with reports with more than 50,000 datasets or larger than 10MB. We compress all reports that are streammed to the the MDC Hub.

```shell
kishu sushi stream created_by:{YOUR DATACITE CLIENT ID}
```


## Development

We use rspec for unit testing:

```
bundle exec rspec
```

Follow along via [Github Issues](https://github.com/datacite/kishu/issues).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/datacite/kishu. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Kishu project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/kishu/blob/master/CODE_OF_CONDUCT.md).
