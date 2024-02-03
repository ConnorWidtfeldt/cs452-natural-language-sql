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
    sequence_name = "#{table_name}_id_seq"
    return if !connection.columns(table_name).any? {
      |column| column.name == "id" && column.default_function == "nextval('#{sequence_name}'::regclass)"
    }
    connection.execute("ALTER SEQUENCE public.#{sequence_name} RESTART WITH 1")
  end
end

class Artist < ActiveRecord::Base
  self.table_name = :artist
  belongs_to :creator, class_name: "User", optional: true
  has_many :artist_names
  has_many :artist_urls
end

class ArtistName < ActiveRecord::Base
  self.table_name = :artist_name
  belongs_to :artist
end

class ArtistUrl < ActiveRecord::Base
  self.table_name = :artist_url
  belongs_to :artist
end

class Pool < ActiveRecord::Base
  self.table_name = :pool
  belongs_to :creator, class_name: "User"
  has_many :pool_posts
  has_many :posts, through: :pool_posts
end

class PoolPost < ActiveRecord::Base
  self.table_name = :pool_post
  belongs_to :pool
  belongs_to :post
end

class Post < ActiveRecord::Base
  self.table_name = :post
  has_many :pool_posts
  has_many :pools, through: :pool_posts
  has_many :post_approvals
  has_many :post_disapprovals
  has_many :post_comments
  has_many :post_favorites
  has_many :post_images
  has_many :post_tags
  has_many :tags, through: :post_tags
  has_many :post_votes
end

class PostArtist < ActiveRecord::Base
  self.table_name = :post_artist
  belongs_to :post
  belongs_to :artist
end

class PostApproval < ActiveRecord::Base
  self.table_name = :post_approval
  belongs_to :user
  belongs_to :post
end

class PostComment < ActiveRecord::Base
  self.table_name = :post_comment
  belongs_to :post
  belongs_to :user
  has_many :post_comment_votes
end

class PostCommentVote < ActiveRecord::Base
  self.table_name = :post_comment_vote
  belongs_to :post_comment
  belongs_to :user
end

class PostDisapproval < ActiveRecord::Base
  self.table_name = :post_disapproval
  belongs_to :user
  belongs_to :post
end

class PostFavorite < ActiveRecord::Base
  self.table_name = :post_favorite
  belongs_to :post
  belongs_to :user
end

class PostImage < ActiveRecord::Base
  self.table_name = :post_image
  belongs_to :post
end

class PostTag < ActiveRecord::Base
  self.table_name = :post_tag
  belongs_to :post
  belongs_to :tag
  belongs_to :user
end

class PostVote < ActiveRecord::Base
  self.table_name = :post_vote
  belongs_to :post
  belongs_to :user
end

class Tag < ActiveRecord::Base
  self.table_name = :tag
  has_many :post_tags
  has_many :posts, through: :post_tags
  has_many :tag_aliases, foreign_key: "antecedent_tag_id"
  has_many :tag_implications, foreign_key: "antecedent_tag_id"
end

class TagAlias < ActiveRecord::Base
  self.table_name = :tag_alias
  belongs_to :antecedent_tag, class_name: "Tag"
  belongs_to :consequent_tag, class_name: "Tag"
end

class TagImplication < ActiveRecord::Base
  self.table_name = :tag_implication
  belongs_to :antecedent_tag, class_name: "Tag"
  belongs_to :consequent_tag, class_name: "Tag"
end

class User < ActiveRecord::Base
  self.table_name = :user
  has_many :posts, foreign_key: "creator_id"
  has_many :pools, foreign_key: "creator_id"
  has_many :artists, foreign_key: "creator_id"
  has_many :post_approvals
  has_many :post_disapprovals
  has_many :post_comments
  has_many :post_favorites
  has_many :post_votes
end

# Clear all data
puts "Clearing existing data..."
ActiveRecord::Base.connection.execute("SET session_replication_role = 'replica'")
[
  User, Artist, ArtistName, ArtistUrl, Pool, PoolPost, Post, PostArtist, PostApproval, PostComment,
  PostCommentVote, PostDisapproval, PostFavorite, PostImage, PostTag, PostVote, Tag, TagAlias,
  TagImplication
].each(&:delete_all)
ActiveRecord::Base.connection.execute("SET session_replication_role = 'origin'")

# Generate Users
puts "Generating users..."
100.times do
  User.create(name: Faker::Name.name, created_at: Faker::Time.backward(days: 365))
end

# Generate Tags
puts "Generating tags..."
known_tags = [
  "mountain",
  "car",
  "cat",
  "dog",
  "bird",
  "fish",
  "tree",
  "flower",
  "house",
  "building",
  "sky",
  "cloud",
  "sun",
  "moon",
  "truck",
  "bus",
  "human",
  "animal",
  "plant",
  "water",
  "fire",
]
known_tags.each do |name|
  next if Tag.exists?(name: name)
  Tag.create(name: name)
end

10.times do
  name = Faker::Verb.unique.base.downcase.gsub(/\s+/, "_")
  next if Tag.exists?(name: name)
  Tag.create(name: name)
end

# Generate TagAliases and TagImplications
puts "Generating tag aliases and implications..."
Tag.limit(10).each do |tag|
  other_tag = Tag.where.not(id: tag).order("RANDOM()").first
  TagAlias.create(antecedent_tag: tag, consequent_tag: other_tag)
  TagImplication.create(antecedent_tag: tag, consequent_tag: other_tag)
end

# Generate Posts
puts "Generating posts..."
5000.times do
  Post.create(created_at: Faker::Time.backward(days: 365))
end

# Generate Artists
puts "Generating artists..."
100.times do
  Artist.create(creator: User.order("RANDOM()").first, created_at: Faker::Time.backward(days: 365))
end

# Associate Posts with Artists
Post.all.each do |post|
  rand(1..2).times do
    PostArtist.create(post: post, artist: Artist.order("RANDOM()").first) rescue nil
  end
end

# Generate ArtistNames and ArtistUrls
puts "Generating artist names and urls..."
Artist.all.each do |artist|
  2.times do
    ArtistName.create(artist: artist, name: Faker::Artist.name, created_at: Faker::Time.backward(days: 365))
    ArtistUrl.create(artist: artist, url: Faker::Internet.url, created_at: Faker::Time.backward(days: 365))
  end
end

# Generate Pools
puts "Generating pools..."
100.times do
  Pool.create(name: Faker::Lorem.sentence, creator: User.order("RANDOM()").first, created_at: Faker::Time.backward(days: 365))
end

# Associate Posts with Pools
puts "Associating posts with pools..."
posts = Post.all
Pool.all.each do |pool|
  posts.sample(15).each do |post|
    PoolPost.create(pool: pool, post: post)
  end
end

disapproval_reasons = [
  "Explicit content",
  "Poor quality",
  "Bad source",
  "Bad tags",
  "Incorrect artist",
  "Incorrect description",
  "DMCA",
  "Other",
]

# Generate Post related data
puts "Generating post related data..."
Post.all.each do |post|
  rand(1..10).times do
    if rand < 0.3 # 30% chance
      PostApproval.create(user: User.order("RANDOM()").first, post: post, created_at: Faker::Time.backward(days: 365)) rescue nil
    end

    if rand < 0.3
      PostDisapproval.create(user: User.order("RANDOM()").first, post: post, message: disapproval_reasons.sample, created_at: Faker::Time.backward(days: 365)) rescue nil
    end

    if rand < 0.3
      PostComment.create(post: post, user: User.order("RANDOM()").first, body: Faker::Lorem.paragraph, created_at: Faker::Time.backward(days: 365)) rescue nil
    end

    if rand < 0.3
      PostFavorite.create(post: post, user: User.order("RANDOM()").first, created_at: Faker::Time.backward(days: 365)) rescue nil
    end

    if rand < 0.3
      PostImage.create(post: post, url: Faker::Internet.url) rescue nil
    end

    if rand < 0.3
      score = rand < 0.7 ? 1 : -1
      PostVote.create(post: post, user: User.order("RANDOM()").first, score: score, created_at: Faker::Time.backward(days: 365)) rescue nil
    end
  end
end

# Generate PostTags
puts "Tagging posts..."
tags = Tag.all
users = User.all
tag_range = (tags.count * 0.5)..(tags.count * 0.8)
Post.all.each do |post|
  tags = tags.sample(rand(tag_range))
  tags.each do |tag|
    PostTag.create(post: post, tag: tag, user: users.sample, created_at: Faker::Time.backward(days: 365))
  end
end
