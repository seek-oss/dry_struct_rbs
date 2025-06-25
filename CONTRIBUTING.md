# Contributing to DryStructRbs

Thank you for considering contributing to DryStructRbs! This document provides guidelines and instructions to help make the contribution process smooth for everyone.

## Development Setup

1. Fork the repository on GitHub: https://github.com/seek-pass-oss/dry_struct_rbs
2. Clone your fork locally:
```
git clone git@github.com:YOUR-USERNAME/dry_struct_rbs.git
```
3. Install dependencies:
```
cd dry_struct_rbs
bundle install
```

## Development Process

1. Create a new branch for your feature or bugfix:
```
git checkout -b feature/your-feature-name
```
   or
```
git checkout -b fix/your-bugfix-name
```

2. Make your changes and add tests if applicable
3. Run the tests to ensure everything works:
```
bundle exec rspec
```
4. Commit your changes with a descriptive commit message:
```
git commit -am "Add a concise commit message"
```

## Pull Request Process

1. Push your branch to your fork:
```
git push origin feature/your-feature-name
```
2. Go to the original repository on GitHub and create a Pull Request
3. Fill in the PR template with details of your changes
4. Wait for maintainers to review your PR
5. Address any feedback or requested changes
6. Once approved, your PR will be merged by the maintainers

## Coding Guidelines

- Follow the Ruby style guide and conventions
- Include tests for new features
- Update documentation as needed
- Keep commits focused and atomic

## Reporting Bugs

When reporting bugs, please include:

- A clear description of the issue
- Steps to reproduce
- Expected vs. actual behavior
- Version information (Ruby version, gem version)
- Sample code demonstrating the issue if possible

## Feature Requests

We welcome suggestions for new features! Please provide:

- A clear description of the proposed feature
- The motivation and use cases for the feature
- Any implementation ideas you might have

## Questions?

If you have any questions about contributing, feel free to open an issue in the repository.

Thank you for your contributions!
