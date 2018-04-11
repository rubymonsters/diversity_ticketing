class AddDirectionsForApplicantsToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :applicant_directions, :text
  end
end
