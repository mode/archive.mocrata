# Mocrata

[![Build Status](https://travis-ci.org/mode/mocrata.svg?branch=master)](https://travis-ci.org/mode/mocrata)
[![Code Climate](https://codeclimate.com/repos/53d16a75695680764e01ea68/badges/c93756788e4438e90512/gpa.png)](https://codeclimate.com/repos/53d16a75695680764e01ea68/feed)
[![Gem Version](https://badge.fury.io/rb/mocrata.svg)](http://badge.fury.io/rb/mocrata)

Mocrata is a [SODA](http://dev.socrata.com/) (Socrata Open Data API) client
developed by [Mode Analytics](https://modeanalytics.com).

## Installation

Add this line to your application's Gemfile:

    gem 'mocrata'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mocrata

## Usage

### Setup

```
Mocrata.configure do |config|
  config.app_token = 'yourtoken' # optional Socrata application token
end
```

### Accessing data

```
dataset = Mocrata::Dataset.new('http://soda.demo.socrata.com/resource/6xzm-fzcu')

dataset.csv
=> [["Sally", 10], ["Earl", 2]]

dataset.json
=> [{"name"=>"Sally", "age"=>10}, {"name"=>"Earl", "age"=>2}]

dataset.fields
=> {"name"=>"text", "age"=>"number"}
```

### Iterating through rows

```
dataset.each_row(:csv) do |row|
  # do something with the row
end

dataset.each_row(:json) { |row| ... }
```

## Documentation

http://rubydoc.info/github/mode/mocrata/master/frames

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
