#Handles Tag management - Event organizers can choose from a pool of existing tags
#and add them to their event. Only Admins can access the tags_index_view to add/delete/modify tags.
module Admin
  class TagsController < ApplicationController
    before_action :require_admin
    before_action :set_locale_to_english

    def index
      @tags = Tag.includes(:category).order(:name).group_by(&:category)
    end

    def create
      @tag = Tag.new(tag_params)

      if @tag.save
        flash[:notice] = "Tag #{@tag.name} was successfully created."
      else
        flash[:alert] = "There was a problem creating the new tag."
      end
      redirect_to admin_tags_path
    end

    def destroy
      @tag = Tag.find(params[:id])
      @tag.destroy
      redirect_to admin_tags_path
    end

    private
      def tag_params
        params.require(:tag).permit(:name, :category_id, :locale)
      end
  end
end
