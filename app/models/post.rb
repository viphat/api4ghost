require 'fileutils'

class Post < ActiveRecord::Base
  attr_reader :link, :published_month

  def self.export_posts_to_markdown()
    path = '/home/viphat/md'

    Post.where(page: false).find_each do |post|
      file_path =
        if post.status == "published"
          "#{path}/published/#{post.published_at.year}"
        else
          "#{path}/draft/"
        end
      FileUtils::mkdir_p(file_path)
      if post.status == "published"
        file_name = "#{file_path}/#{post.published_at.strftime("%Y-%m-%d")}-#{post.slug}.md"
      else
        file_name = "#{file_path}/#{post.slug}.md"
      end

      target = open(file_name, 'w')
      tags_ids = PostsTag.where(post_id: post.id).pluck(:tag_id)
      tags = Tag.where(id: tags_ids).map { |x| x.slug }
      target.write("---\n")
      target.write("layout: default\n")
      target.write("title: \"#{post.title}\"\n")
      target.write("date: #{post.published_at.strftime('%Y-%m-%d %H:%M:%S')}\n") if post.status == "published"
      target.write("permalink: /:slug\n")
      target.write("tags: [#{tags.join(', ')}]\n")
      target.write("---\n")
      target.write("\n")
      target.write(post.markdown)
      target.write("\n")
      target.close()
    end
  end

  def self.get_posts()
    posts  = []
    Post.where(page: false).find_each do |post|
      posts.push({
        title: post.title,
        slug: post.slug,
        content: post.markdown,
        status: post.status,
        visibility: post.visibility,
        created_at: post.created_at.to_i * 1000,
        updated_at: post.updated_at.to_i * 1000,
        published_at: post.published_at.to_i * 1000
      })
    end
    posts
  end

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