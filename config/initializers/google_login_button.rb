# frozen_string_literal: true

# Renders a plain "Continue with Google" button on the login page.
#
# This intentionally bypasses OpenProject::Plugins::AuthPlugin's provider
# listing, since that mechanism hides all non-"developer" provider buttons
# unless an Enterprise token with the :sso_auth_providers feature is active
# (see modules/auth_plugins/lib/open_project/plugins/auth_plugin.rb#filtered_strategy?).
# The actual /auth/google login flow itself is unaffected by that check.
Rails.application.config.to_prepare do
  unless defined?(HydraLoginButtonHook)
    class HydraLoginButtonHook < OpenProject::Hook::ViewListener
      render_on :view_account_login_auth_provider,
                partial: "hooks/login/hydra_button"
    end
  end
end