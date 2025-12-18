# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Cleaner
    describe CleanAuthorizationDataJob do
      subject { described_class }

      let!(:organization) { create(:organization, delete_authorization_data: true, delete_authorization_data_after: 25) }
      let!(:active_user) { create(:user, :confirmed, organization:) }
      let!(:old_deleted_user) { create(:user, :deleted, organization:, deleted_at: 25.days.ago) }
      let!(:deleted_user) { create(:user, :deleted, organization:, deleted_at: Time.now) }
      let!(:active_authorization) { create(:authorization, user: active_user) }
      let!(:idle_authorization) { create(:authorization, user: deleted_user) }
      let!(:expired_authorization) { create(:authorization, user: old_deleted_user) }

      context "when the delay is specified" do
        it "enqueues job in queue 'cleaner'" do
          expect(subject.queue_name).to eq("scheduled")
        end

        it "removes the authorizations that should be removed" do
          expect(Decidim::Authorization.count).to eq(3)

          subject.perform_now

          expect(Decidim::Authorization.count).to eq(2)
          expect(Decidim::Authorization.all).to include(active_authorization, idle_authorization)
        end
      end

      context "when the delay is not specified" do
        let!(:organization) { create(:organization, delete_authorization_data: true) }
        let!(:old_deleted_user) { create(:user, :deleted, organization:, deleted_at: 30.days.ago) }

        it "enqueues job in queue 'cleaner'" do
          expect(subject.queue_name).to eq("scheduled")
        end

        it "removes the authorizations that should be removed" do
          expect(Decidim::Authorization.count).to eq(3)

          subject.perform_now

          expect(Decidim::Authorization.count).to eq(2)
          expect(Decidim::Authorization.all).to include(active_authorization, idle_authorization)
        end
      end

      context "when the cleaning is not enabled" do
        let!(:organization) { create(:organization, delete_authorization_data: false) }

        it "removes no authorizations" do
          expect(Decidim::Authorization.count).to eq(3)

          subject.perform_now

          expect(Decidim::Authorization.count).to eq(3)
        end
      end
    end
  end
end
