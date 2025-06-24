# DryStructRbs

Add to your Gemfile in the development group:

```ruby
group :development do
  gem "dry_struct_rbs", path: "path/to/this/repo"
end
```

Run `bundle install`.

## Usage
Generate RBS files for your app:

```shell
bundle exec dry_struct_rbs app -w
```

Use -w to write files.

Use -f to force overwrite existing files.

Use -n NAMESPACE to set your dry types namespace (default: Types).

Example:
```shell
bundle exec dry_struct_rbs app -w -f -n My::Types
```
