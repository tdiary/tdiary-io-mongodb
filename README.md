# TDiary::IO::MongoDB

mongoid adapter for tDiary

## Installation

Add this line to your tDiary's Gemfile.local:

    gem 'tdiary-io-mongodb'

And then execute:

    $ bundle

## Usage

Add follow snipet to your tdiary.conf

```ruby
@io_class = TDiary::IO::MongoDB
```

## Migration

`bin/tdiary-mongodb-convert` is utility that uploads tDiary default IO data to MongoDB.

(1) Migrate tDiary configuration

Migrate your tDiary configuration to MongoDB.

```
$ bundle exec tdiary-mongodb-convert -c $DATA_PATH/tdiary.conf -m $MONGODB_URI
```

 * $MONGODB_URI: the uri of mongodb (mongodb://)
 * $DATA_PATH: the path of your tdiary data directory

(2) Migrate tDiary data

Migrate your tDiary data to MongoDB.

```
$ bundle exec tdiary-mongodb-convert -s ./lib/tdiary/style -m $MONGODB_URI $DATA_PATH
```
 * $MONGODB_URI: the uri of mongodb (mongodb://)
 * $DATA_PATH: the path of your tdiary data directory

### Note

If you use the style provided by an external gem (like GFM style), append the gem to Gemfile and run `bundle`.

```
gem 'tdiary-style-gfm'
gem 'tdiary-style-etdiary'
gem 'tdiary-style-rd
```

### See also

 * http://sho.tdiary.net/20150206.html#p01 (in Japanese)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
