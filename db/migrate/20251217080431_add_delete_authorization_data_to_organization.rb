class AddDeleteAuthorizationDataToOrganization < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_organizations, :delete_authorization_data, :boolean, default: false, null: false
    add_column :decidim_organizations, :delete_authorization_data_after, :integer
  end
end
