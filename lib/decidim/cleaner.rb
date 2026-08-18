# frozen_string_literal: true

require "decidim/cleaner/admin"
require "decidim/cleaner/engine"
require "decidim/cleaner/admin_engine"

module Decidim
  # This namespace holds the logic of the `Cleaner` module.
  module Cleaner
    mattr_accessor :delete_admin_logs_after, default: ENV.fetch("DECIDIM_CLEANER_DELETE_ADMIN_LOGS", "365").to_i

    mattr_accessor :delete_inactive_users_after, default: ENV.fetch("DECIDIM_CLEANER_DELETE_INACTIVE_USERS", "30").to_i

    mattr_accessor :delete_inactive_users_email_after, default: ENV.fetch("DECIDIM_CLEANER_INACTIVE_USERS_MAIL", "365").to_i

    mattr_accessor :delete_authorization_data_after, default: ENV.fetch("DECIDIM_CLEANER_DELETE_AUTHORIZATION_DATA", "30").to_i
  end
end
