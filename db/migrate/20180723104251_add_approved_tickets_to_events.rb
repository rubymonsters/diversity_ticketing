class AddApprovedTicketsToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :approved_tickets, :string
  end
end
