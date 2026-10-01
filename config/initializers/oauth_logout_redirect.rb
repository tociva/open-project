# frozen_string_literal: true

# Redirects users to a configurable URL after logout, since OpenProject has
# no built-in setting for this (only for post-login redirect, which is
# already covered by the OPENPROJECT_AFTER_LOGIN_DEFAULT_REDIRECT_URL env var).
Rails.application.config.to_prepare do
  module CustomLogoutRedirect
    def perform_post_logout(prev_session, prev_user)
      if (url = ENV["OAUTH_LOGOUT_URL"]).present?
        redirect_to url, allow_other_host: true
        return
      end

      super
    end
  end

  AccountController.prepend(CustomLogoutRedirect) unless AccountController.ancestors.include?(CustomLogoutRedirect)
end
