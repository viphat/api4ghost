class Api::V1::TagsController < ApplicationController
  # respond_to :json
  def index
    if params[:limit].present? && params[:limit].to_i > 0
      @tags = Tag.most_used.limit(params[:limit].to_i).shuffle
    else
      @tags = Tag.all.shuffle
    end
    render json: @tags, each_serializer: TagSerializer
  end

  def get_tags
    posts = Tag.get_posts_tags()
    render json: { posts: posts }
  end

end
