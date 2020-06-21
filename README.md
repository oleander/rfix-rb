# Rfix [![Build Status](https://travis-ci.org/oleander/rfix-rb.svg?branch=master)](https://travis-ci.org/oleander/rfix-rb) [![Gem](https://img.shields.io/gem/dt/rfix)](https://rubygems.org/gems/rfix)

RuboCop CLI that only complains about your latest changes. Includes a RuboCop formatter with syntax highlighting and build in hyperlinks for offense documentation. Supports both linting (`rfix lint`) and the RuboCops autofix feature (`rfix local|origin|branch`) for the changes you made.

Supports the same CLI arguments as RuboCop. Run `rfix --help` for the complete list.

![Printscreen](resources/ps.png)

## Installation

``` shell
$ gem install rfix --pre
```

## Help

``` shell
$ rfix branch <branch> # Fix changes made between HEAD and <branch>
$ rfix origin          # Fix changes made between HEAD and origin branch
$ rfix local           # Fix changes not yet pushed to upstream branch
$ rfix info            # Display runtime dependencies and their versions
$ rfix all             # Fix all files in this repository (not recommended)
$ rfix lint            # Shortcut for 'rfix local --dry --untracked'
$ rfix                 # Displays this list of supported commands
```

### Arguments

- `--dry` Turns off RuboCops autofix feature (read-only mode)
- `--help` Displays RubyCops and Rfix supported arguments
- `--list-files` List all files being passed to RubyCop
- `--untracked` Include files not tracked by git
- `--config` Configuration file, defaults to `.rubocop.yml`

## Development

### Setup

1. Download repository
  1. `$ git clone https://github.com/oleander/rfix-rb`
  2. `$ cd rfix-rb`
2. Downloads fixtures and run time dependencies
  - `$ bundle exec rake setup`

### Install from repository

``` shell
$ bundle exec rake local
```

### Run tests

``` shell
$ bundle exec rake spec
```

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
