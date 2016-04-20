# Hackster

## Table of Contents

1. [Setting up environment](#setting-up-environment)
1. [Style Guide](#style-guide)
1. [Testing](#testing)
  1. [Server](#server)
  1. [Client](#client)

## Setting up environment

[Getting set up Google Doc](https://docs.google.com/document/d/1VUkw7SITynNE7drLXUzgo1F4rTimasn0MqeriwZvvWQ/edit)

## Style Guide

See [Airbnb React/JSX Style Guide](https://github.com/airbnb/javascript/tree/master/react).

See ThoughtBot's [Style Guide](https://github.com/thoughtbot/guides/tree/dee16052f49cb4b41fb8d090ffdb75942512ddb1/style) and [Best Practices Guide](https://github.com/thoughtbot/guides/tree/dee16052f49cb4b41fb8d090ffdb75942512ddb1/best-practices) for other styles.

## Testing

### Server

We have [Guard::RSpec](https://github.com/guard/guard-rspec) set up. To run from command-line: `guard`. Then, hit enter/return to run tests. To "focus" your testing, such that only certains tests are run, set :focus metadata to true. Eg:

```ruby
RSpec.describe 'User authentication', focus: false do
  scenario 'user signs up', focus: true do
```

Now, the 'user signs up' scenario will run. Note that if no focus is set to true, then all tests will run. If no focus metadata is present, Guard::RSpec defaults it to false.

### Client

See npm scripts in `package.json` for client testing scripts.

To sourcemap in client testing, add 'sourcemap' to preprocessors in `karma.conf.js`. Eg:

```javascript
preprocessors: {
  './spec/javascripts/unit/**/*_test.js': ['webpack', 'sourcemap']
},
```
