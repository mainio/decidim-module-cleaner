# frozen_string_literal: true

module Decidim
  module Cleaner
    class CleanAuthorizationDataJob < ApplicationJob
      queue_as :scheduled

      def perform
        Decidim::Organization.find_each do |organization|
          next unless organization.delete_authorization_data?

          Decidim::Authorization.joins(
                                  "INNER JOIN decidim_users
                                  ON decidim_users.id = decidim_authorizations.decidim_user_id"
                                )
                                .where("decidim_users.decidim_organization_id = ?", organization.id)
                                .where("decidim_users.deleted_at < ?", delete_authorization_data_before_date(organization))
                                .delete_all

        end
      end

      private

      def delete_authorization_data_before_date(organization)
        Time.zone.now - (organization.delete_authorization_data_after || Decidim::Cleaner.delete_authorization_data_after).days
      end
    end
  end
end
