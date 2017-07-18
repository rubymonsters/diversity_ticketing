class TagsController < ApplicationController
  before_action :require_admin

  def index
    @tags = Tag.includes(:category).group_by(&:category)
  end

  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy
    redirect_to tags_path
  end
end
