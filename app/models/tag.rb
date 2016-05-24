class Tag < ActiveRecord::Base

  MAX_WEIGHT = 24
  MIN_WEIGHT = 8

  has_many :posts_tags

  scope :most_used, -> {
    Tag.joins(:posts_tags).group('tags.id').order('count(posts_tags.*) DESC')
  }

  def max_posts_count
    Tag.most_used.first.posts_count
  end

  def posts_count
    PostsTag.where(tag_id: self.id).count
  end

  def text
    self.name
  end

  def weight_diff
    Tag::MAX_WEIGHT - Tag::MIN_WEIGHT
  end

  def weight
    (self.posts_count * self.weight_diff / self.max_posts_count) + Tag::MIN_WEIGHT
  end

  def link
    "http://notes.viphat.work/tag/#{self.slug}"
  end

  def self.get_tags()
    tags = []
    Tag.includes(:posts_tags).find_each do |tag|
      posts = {}
      tag.posts_tags.each do |post_tag|
        post = Post.find_by_id(post_tag.post_id)
        posts[post.slug] = post_tag.sort_order
      end
      tags.push({
        name: tag.name,
        slug: tag.slug,
        posts: posts
      })
    end
    tags
  end

end