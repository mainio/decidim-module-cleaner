class AddDeleteInactiveManagedUsersToOrganization < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_organizations, :delete_inactive_managed_users, :boolean, default: false, null: false
    add_column :decidim_organizations, :delete_inactive_managed_users_after, :integer
  end
end
