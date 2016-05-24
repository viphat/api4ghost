class Api::V1::PostsController < ApplicationController

  def get_posts
    posts = Post.get_posts
    render json: { posts: posts }
  end

  def archive
    posts = Post.get_post_archive
    months = Post.get_month_archive
    archive = {}
    archive["months"] = []
    months.each do |m|
      each_month = {}
      each_month["key"] = m
      each_month["value"] = posts["#{m}"]
      archive["months"] << each_month
    end
    render json: { post_archive: archive }
  end

end
