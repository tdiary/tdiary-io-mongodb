$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'tdiary/comment_manager'
require 'tdiary/comment'
require 'tdiary/referer_manager'
require 'tdiary/cache/file'
require 'tdiary/io/mongodb'

module TDiary
	class TDiaryBase
		DIRTY_NONE = 1
		DIRTY_DIARY = 1
		DIRTY_COMMENT = 2
	end

	module IO
		class MongoDB 
			def initialize(tdiary)
				@tdiary = tdiary
			end

			def style(style)
				DummyStyle
			end
		end
	end
end

class DummyTDiary
	def conf
		DummyConf.new
	end

	def ignore_parser_cache
		false
	end
end

class DummyConf
	def database_url
		'mongodb://localhost:27017/tdiary_test'
	end

	def cache_path
		nil
	end
end

class DummyStyle
	attr_accessor :title, :to_src

	def initialize(id, title, body, last_modified)
		@title = title
		@to_src = body
	end

	def style
		"dummy"
	end

	def last_modified
		Time.now
	end

	def visible?
		true
	end

	def show(dummy); end

	def add_comment(com)
		@comments ||= []
		@comments << com
	end

	def count_comments(dummy)
		(@comments || []).size
	end

	def each_comment(limit)
		(@comments || []).each{|com| yield com}
	end
end

RSpec.configure do |c|
	c.after(:suite) do
		Mongoid.default_client.database.collections.each do |collection|
			collection.drop
		end
	end
end
