class TagSerializer < ActiveModel::Serializer
  # cache key: 'tags', expires_in: 3.hours
  attributes :id, :text, :posts_count, :link, :weight
  # has_many :posts_tags

end
