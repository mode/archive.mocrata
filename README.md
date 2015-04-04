# Mocrata

[![Build Status](https://travis-ci.org/mode/mocrata.svg?branch=master)](https://travis-ci.org/mode/mocrata)
[![Code Climate](https://codeclimate.com/repos/53ea7f57e30ba007c500a24a/badges/44f08215be76ea780d56/gpa.svg)](https://codeclimate.com/repos/53ea7f57e30ba007c500a24a/feed)
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

```ruby
Mocrata.configure do |config|
  config.app_token = 'yourtoken' # optional Socrata application token
end
```

### Accessing data

```ruby
dataset = Mocrata::Dataset.new("http://opendata.socrata.com/resource/mnkm-8ram")

dataset.name
=> "Country List ISO 3166 Codes Latitude Longitude"

dataset.csv_header
=> ["Country", "Alpha code", "Numeric code", "Latitude", "Longitude"]

dataset.csv
=> [["Albania", "AL", "8", "41", "20"],
    ["Algeria", "DZ", "12", "28", "3"], ...]

dataset.json
=> [{"longitude_average"=>"20",
     "latitude_average"=>"41",
     "alpha_2_code"=>"AL",
     "numeric_code"=>"8",
     "country"=>"Albania"}, ...]

dataset.fields
=> {":created_at"=>"meta_data", ":id"=>"meta_data", ":updated_at"=>"meta_data",
"alpha_2_code"=>"text", "country"=>"text", "latitude_average"=>"number",
"longitude_average"=>"number", "numeric_code"=>"number"}
```

### Iterating through rows

```ruby
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
