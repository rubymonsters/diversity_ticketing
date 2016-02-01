class AddDirectionsForApplicantsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :applicant_directions, :text
  end
end
