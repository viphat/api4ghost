class Tag < ActiveRecord::Base
  validates :name, :slug, :hidden_boolean, presence: true

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

end