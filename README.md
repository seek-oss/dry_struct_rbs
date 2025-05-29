# DryStructRBS

Generate [RBS](https://github.com/ruby/rbs) type signatures for your [dry-struct](https://dry-rb.org/gems/dry-struct/) classes automatically.

---

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Example Output](#example-output)
- [Requirements](#requirements)
- [Contributing](#contributing)
- [License](#license)

---

## Introduction

**DryStructRBS** is a Ruby gem that generates [RBS](https://github.com/ruby/rbs) type signature files for your [dry-struct](https://dry-rb.org/gems/dry-struct/) classes.  
It introspects your Dry::Struct definitions at runtime, converts them into Ruby classes in memory, and produces accurate `.rbs` files for static type checking and improved IDE support.

---

## Features

- Converts any Dry::Struct class to an equivalent RBS class declaration.
- Supports nested attributes, arrays, and hashes.
- Automatically infers attribute types from dry-struct definitions.
- Outputs valid RBS for use with [Steep](https://github.com/soutaro/steep) or other type checkers.
- Simple API for integration into your build or CI pipeline.

---

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dry_struct_rbs'
```

And then execute:

```sh
bundle install
```

Or install it yourself as:

```sh
gem install dry_struct_rbs
```

---

## Usage

Require the gem and use the generator to produce RBS for your Dry::Struct classes:

```ruby
require 'dry_struct_rbs'

class Person  void
end
```

---

## Requirements

- Ruby 3.0 or newer
- [dry-struct](https://dry-rb.org/gems/dry-struct/)
- [rbs](https://github.com/ruby/rbs)

---

## Contributing

Bug reports and pull requests are welcome!  
Please open an issue or submit a PR with improvements. See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

---

## License

This project is licensed under the MIT License. See [LICENSE.txt](LICENSE.txt) for details.

---

*Happy typing!*
