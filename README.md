# Rfix [![Build Status](https://travis-ci.org/oleander/rfix-rb.svg?branch=master)](https://travis-ci.org/oleander/rfix-rb) [![Gem](https://img.shields.io/gem/dt/rfix)](https://rubygems.org/gems/rfix)

RuboCop CLI that only complains about your latest changes. Includes a RuboCop formatter with syntax highlighting and build in hyperlinks for offense documentation. Supports both linting (`rfix lint`) and the RuboCops autofix feature (`rfix local|origin|branch`) for the changes you made.

![Printscreen](resources/ps.png)

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
    command: ["rfix", "local", "--untracked", "--dry"]
    description: "Lint changes since last push using RuboCop"
    parallelize: true
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/oleander/rfix.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
