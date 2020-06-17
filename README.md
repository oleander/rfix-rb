# Rfix [![Build Status](https://travis-ci.org/oleander/rfix-rb.svg?branch=master)](https://travis-ci.org/oleander/rfix-rb)

RuboCop CLI that only complains about your latest changes

## Installation

``` shell
$ gem install rfix
$ rfix <local|branch|origin|info|all> [--dry] [--help]
```

## Development

- `git clone https://github.com/oleander/rfix-rb`
- `cd rfix-rb`
- `bundle install`
- `bundle exec rake setup`
- `bundle exec rake local`
- `bundle exec rake spec`

## Overcommit

``` yaml
PreCommit:
  RFix:
    enabled: true
    command: ["rfix", "local", "--dry"]
    description: "Lint changes since last push using RuboCop"
    parallelize: true
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/oleander/rfix.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
