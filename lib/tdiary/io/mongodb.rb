# -*- coding: utf-8 -*-
#
# mongodb.rb: MongoDB IO for tDiary 3.x
#
# NAME             mongodb
#
# DESCRIPTION      tDiary IO class on MongoDB
#                  Saving Diary data to MongoDB, but Referer data
#
# Copyright        (C) 2013 TADA Tadashi <t@tdtds.jp>
#
# You can distribute this under GPL.

require 'tdiary/io/base'
require 'tempfile'
require 'mongoid'

module TDiary
	module IO
		class MongoDB < Base
			class Conf
				include Mongoid::Document
				include Mongoid::Timestamps
				store_in collection: "conf"

				field :body, type: String
			end

			class Comment
				include Mongoid::Document
				include Mongoid::Timestamps
				store_in collection: "comments"

				belongs_to :diary
				field :name, type: String
				field :mail, type: String
				field :body, type: String
				field :last_modified, type: String
				field :visible, type: Boolean

				index({diary_id: 1})
			end
	
			class Referer
				include Mongoid::Document
				include Mongoid::Timestamps
				store_in collection: "referers"
			end

			class Diary
				include Mongoid::Document
				include Mongoid::Timestamps
				store_in collection: "diaries"
				
				field :diary_id, type: String
				field :year, type: String
				field :month, type: String
				field :day, type: String
				field :title, type: String
				field :body, type: String
				field :style, type: String
				field :last_modified, type: Integer
				field :visible, type: Boolean
				has_many :comments, autosave: true
				has_many :referers, autosave: true

				index({diary_id: 1}, {unique: true})
				index({year: 1, month: 1})
			end

			class Plugin
				include Mongoid::Document
				include Mongoid::Timestamps
				store_in collection: "plugins"

				field :plugin, type: String
				field :key, type: String
				field :value, type: String

				index({plugin: 1, key: 1}, {unique: true})

				def self.get(plugin_name, key)
					record = where(plugin: plugin_name, key: key).first
					return record ? record.value : nil
				end

				def self.set(plugin_name, key, value)
					record = where(plugin: plugin_name, key: key).first
					if record
						record.update_attributes(value: value)
					else
						record = self.new(plugin: plugin_name, key: key, value: value)
						record.save!
					end
				end

				def self.delete(plugin_name, key)
					record = where(plugin: plugin_name, key: key).first
					if record
						record.delete
					end
				end

				def self.keys(plugin_name)
					records = where(plugin: plugin_name)
					return records.map(&:key) rescue []
				end
			end
	
			include Cache

			class << self
				Mongo::Logger.level = Logger::WARN

				def load_cgi_conf(conf)
					db(conf)
					if cgi_conf = Conf.all.first
						cgi_conf.body
					else
						""
					end
				end

				def save_cgi_conf(conf, result)
					db(conf)
					if cgi_conf = Conf.all.first
						cgi_conf.body = result
						cgi_conf.save
					else
						Conf.create(body: result).save
					end
				end

				def db(conf)
					@@_db ||= Mongoid::Config.load_configuration(
						{clients:{default:{uri:(conf.database_url || 'mongodb://localhost:27017/tdiary')}}}
					)
				end

				def plugin_open(conf)
					return nil
				end

				def plugin_close(storage)
					# do nothing
				end

				def plugin_transaction(storage, plugin_name)
					db = plugin_name.dup
					def db.get(key)
						Plugin.get(self, key)
					end
					def db.set(key, value)
						Plugin.set(self, key, value)
					end
					def db.delete(key)
						Plugin.delete(self, key)
					end
					def db.keys
						Plugin.keys(self)
					end
					yield db
				end
			end

			#
			# block must be return boolean which dirty diaries.
			#
			def transaction(date)
				diaries = {}

				if cache = restore_parser_cache(date)
					diaries.update(cache)
				else
					restore(date.strftime("%Y%m%d"), diaries)
				end

				dirty = yield(diaries) if iterator?

				store(diaries, dirty)

				store_parser_cache(date, diaries) if dirty || !cache
			end

			def calendar
				calendar = Hash.new{|hash, key| hash[key] = []}
				Diary.all.map{|d|[d.year, d.month]}.sort.uniq.each do |ym|
					calendar[ym[0]] << ym[1]
				end
				calendar
			end

			def cache_dir
				@tdiary.conf.cache_path || "#{Dir.tmpdir}/cache"
			end

		private

			def restore(date, diaries, month = true)
				query = if month && /(\d{4})(\d\d)(\d\d)/ =~ date
							  Diary.where(year: $1, month: $2)
						  else
							  Diary.where(diary_id: date)
						  end
				query.each do |d|
					style = (d.style.nil? || d.style.empty?) ? 'wiki' : d.style.downcase
					diary = eval("#{style(style)}::new(d.diary_id, d.title, d.body, Time::at(d.last_modified.to_i))")
					diary.show(d.visible)
					d.comments.each do |c|
						comment = TDiary::Comment.new(c.name, c.mail, c.body, Time.at(c.last_modified.to_i))
						comment.show = c.visible
						diary.add_comment(comment)
					end
					diaries[d.diary_id] = diary
				end
			end

			def store(diaries, dirty)
				if dirty
					diaries.each do |diary_id, diary|
						year, month, day = diary_id.scan(/(\d{4})(\d\d)(\d\d)/).flatten
	
						entry = Diary.where(diary_id: diary_id).first

						if (dirty & TDiary::TDiaryBase::DIRTY_DIARY) != 0
							if entry
								entry.title = diary.title
								entry.last_modified = diary.last_modified.to_i
								entry.style = diary.style
								entry.visible = diary.visible?
								entry.body = diary.to_src
							else
								entry = Diary.create(
									diary_id: diary_id,
									year: year, month: month, day: day,
									title: diary.title,
									last_modified: diary.last_modified,
									style: diary.style,
									visible: diary.visible?,
									body: diary.to_src
								)
							end
							entry.save
						end
						if entry && ((dirty & TDiary::TDiaryBase::DIRTY_COMMENT) != 0)
							exist_comments = entry.comments.size
							no = 0
							diary.each_comment(diary.count_comments(true)) do |com|
								if no < exist_comments
									entry.comments[no].name = com.name
									entry.comments[no].mail = com.mail
									entry.comments[no].body = com.body
									entry.comments[no].last_modified = com.date.to_i
									entry.comments[no].visible = com.visible?
									no += 1
								else
									entry.comments.build(
										name: com.name,
										mail: com.mail,
										body: com.body,
										last_modified: com.date.to_i,
										visible: com.visible?
									)
								end
								entry.save
							end
						end
					end
				end
			end

			def db
				self.class.db(@tdiary.conf)
			end
		end
	end
end
