# frozen_string_literal: true

module Decidim
  module Cleaner
    class CleanInactiveManagedUsersJob < ApplicationJob
      queue_as :scheduled

      def perform
        Decidim::Organization.find_each do |organization|
          next unless organization.delete_inactive_managed_users?

          update_warning(
            Decidim::User.unscoped.where(organization:)
                         .not_deleted
                         .managed
                         .joins(
                           "INNER JOIN decidim_impersonation_logs ON decidim_impersonation_logs.decidim_user_id = decidim_users.id"
                          )
                         .where("decidim_impersonation_logs.started_at < ?",
                           notify_inactive_managed_before_date(organization)
                         ).distinct)

          delete_managed_user(
            Decidim::User.unscoped.where(organization:)
                         .not_deleted
                         .managed
                         .joins(
                           "INNER JOIN decidim_impersonation_logs ON decidim_impersonation_logs.decidim_user_id = decidim_users.id"
                         ).where(
                           "warning_date < ?",
                            delete_inactive_managed_before_date(organization)
                         ).distinct)
        end
      end

      def update_warning(users)
        users.find_each do |user|
          next if user.warning_date.present?

          user.update!(warning_date: Time.zone.now)

          # Managed user is still flagged as "notified" even though they are not sent an email nor have an email address
          Rails.logger.info "#{user.email} flagged as 'notified'"
        end
      end

      def delete_managed_user(users)
        users.find_each do |user|
          if Decidim::ImpersonationLog.where(decidim_user_id: user).order(started_at: :desc).first.started_at > user.warning_date
            user.update!(warning_date: nil)
            Rails.logger.info "User with id #{user.id} has logged in again, warning date reset"
            next
          end

          Decidim::DestroyAccount.call(user, Decidim::DeleteAccountForm.from_params({ delete_reason: I18n.t("decidim.cleaner.delete_reason") }))
          Rails.logger.info "User with id #{user.id} destroyed"
        end
      end

      private

      def notify_inactive_managed_before_date(organization)
        Time.zone.now - (organization.delete_inactive_users_email_after || Decidim::Cleaner.delete_inactive_users_email_after).days
      end

      def delete_inactive_managed_before_date(organization)
        Time.zone.now - (organization.delete_inactive_users_after || Decidim::Cleaner.delete_inactive_users_after).days
      end
    end
  end
end
