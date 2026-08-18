# frozen_string_literal: true

Decidim::Admin::Engine.routes.draw do
  resource :organization, controller: "organization" do
    resource :cleaner, only: [:edit, :update], controller: "/decidim/cleaner/admin/organization_cleaner"
  end
end
