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

module TDiary
	module IO
		module Comment
			def restore_comment(diaries)
				# not implemented yet
				return
			end

			def store_comment(diaries)
				# not implemented yet
				return
			end
		end

		module Referer
			def restore_referer(diaries)
				# not implemented yet
				return
			end

			def store_referer(diaries)
				# not implemented yet
				return
			end
		end

		class MongoDB < Base
			include Comment
			include Referer
			include Cache

			class << self
				def load_cgi_conf(conf)
					# not implemented yet
					return
				end

				def save_cgi_conf(conf, result)
					# not implemented yet
					return
				end

				def db(conf)
					# not implemented yet
					return
				end
			end

			#
			# block must be return boolean which dirty diaries.
			#
			def transaction(date)
				# not implemented yet
				return
			end

			def calendar
				# not implemented yet
				return
			end

			def cache_dir
				# not implemented yet
				return
			end

		private

			def restore(date, diaries, month = true)
				# not implemented yet
				return
			end

			def store(diaries)
				# not implemented yet
				return
			end

			def db
				# not implemented yet
				return
			end
		end
	end
end
