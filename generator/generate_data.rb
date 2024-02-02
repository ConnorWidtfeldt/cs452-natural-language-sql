#!/usr/bin/env ruby
require "active_record"
require "faker"

ActiveRecord::Base.establish_connection(
  adapter: "postgresql",
  host: "localhost",
  port: 15432,
  username: "cs452",
  password: "cs452",
  database: "cs452",
)

class ActiveRecord::Base
  def self.delete_all
    connection.execute("DELETE FROM public.#{table_name}")
    connection.execute("ALTER SEQUENCE public.#{table_name}_id_seq RESTART WITH 1")
  end
end

class Tag < ActiveRecord::Base
  self.table_name = "tag"
end

class User < ActiveRecord::Base
  self.table_name = "user"
end

# == GENERATE == #

User.delete_all
100.times do
  User.create(
    name: Faker::Name.name,
  )
end

Tag.delete_all
1000.times do
  Tag.create(
    name: Faker::Lorem.word,
  )
end
