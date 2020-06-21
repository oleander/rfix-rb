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
$ rfix branch "branch" # Fix changes made between HEAD and <branch>
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
  - `$ git clone https://github.com/oleander/rfix-rb`
  - `$ cd rfix-rb`
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

Add the following to your `.overcommit.yml`, then run `overcommit --install` and `overcommit --sign pre-commit`. It will lint commits not yet pushed to upstream branch everytime `git commit` is ran.

``` yaml
PreCommit:
  RFix:
    enabled: true
    command: ["rfix", "lint"]
    description: "Lint unchanged commits using RuboCop"
    parallelize: true
```

### From scratch

1. `gem install overcommit rfix`
2. `curl https://raw.githubusercontent.com/oleander/rfix-rb/master/resouces/overcommit.yml > .overcommit.yml`
3. `overcommit --install`
4. `overcommit --sign pre-commit`

Run `overcommit --run` to test the new hook.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/oleander/rfix.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
