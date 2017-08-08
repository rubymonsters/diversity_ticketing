class TagsController < ApplicationController
  before_action :require_admin

  def index
    @tags = Tag.includes(:category).group_by(&:category)
  end

  def create
    @tag = Tag.new(tag_params)

    if @tag.save
      flash[:notice] = "Tag #{@tag.name} was successfully created."
    else
      flash[:alert] = "There was a problem creating the new tag."
    end
    redirect_to tags_path
  end

  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy
    redirect_to tags_path
  end

  private
    def tag_params
      params.require(:tag).permit(:name, :category_id)
    end
end
