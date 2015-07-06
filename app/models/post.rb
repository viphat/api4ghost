class Post < ActiveRecord::Base
  attr_reader :link, :published_month

  def self.get_month_archive
    Post.where(page: false).where.not(published_at: nil).order('posts.published_at DESC').pluck("concat(date_part('month',posts.published_at),'/',date_part('year',posts.published_at)) as published_month").uniq()
  end

  def self.get_post_archive
    ungrouped_posts = Post.where(page: false).where.not(published_at: nil).order('posts.published_at DESC').select(:id,:title,"concat('http://notes.viphat.work/',posts.slug) as link","concat(date_part('month',posts.published_at),'/',date_part('year',posts.published_at)) as published_month",:featured
    )
    grouped_posts = {}
    post_new_struct = Struct.new(:id,:title,:link,:published_month,:featured)
    ungrouped_posts.each do |p|
      post = post_new_struct.new(p.id,p.title,p.attributes['link'],p.attributes['published_month'],p.featured)
      if grouped_posts["#{post.published_month}"].nil?
        grouped_posts["#{post.published_month}"] = [post]
      else
        grouped_posts["#{post.published_month}"] << post
      end
    end
    grouped_posts
  end
end