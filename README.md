# DryStructRbs

A Ruby gem that automatically generates RBS type definitions for your [dry-struct](https://dry-rb.org/gems/dry-struct/) classes.

## Installation

Add to your Gemfile in the development group:

```ruby
group :development do
  gem 'dry_struct_rbs', 
      git: 'https://github.com/seek-pass-oss/dry_struct_rbs',
      branch: 'master'
end
```

Then execute:

```shell
bundle install
```

## Usage

Generate RBS files for your application with a single command:

```shell
bundle exec dry_struct_rbs app
```

### Options

| Option | Description |
|--------|-------------|
| `-w` | Write generated files to disk (without this flag, output is only displayed) |
| `-f` | Force overwrite existing RBS files |
| `-n NAMESPACE` | Set your dry-types namespace (default: `Types`) |
| `-i PATH` | Ignore directory prefix when generating output paths |

### Examples

Basic usage with file writing:
```shell
bundle exec dry_struct_rbs app -w
```

Generate files with a custom namespace and force overwrite:
```shell
bundle exec dry_struct_rbs app -w -f -n MyApp::Types
```

Generate files while stripping a directory prefix from output paths:
```shell
bundle exec dry_struct_rbs app/models/user.rb -w -i app/models
```

This will transform input paths like `app/models/user.rb` to `sig/user.rbs` instead of `sig/app/models/user.rbs`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/seek-pass-oss/dry_struct_rbs.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
