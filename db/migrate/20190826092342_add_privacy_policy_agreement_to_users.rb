class AddPrivacyPolicyAgreementToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :privacy_policy_agreement, :boolean, default: false
  end
end
