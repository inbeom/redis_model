require 'active_record'

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
ActiveRecord::Migration.verbose = false
require File.join(File.dirname(__FILE__), 'schema')
