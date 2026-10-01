# frozen_string_literal: true

# Fully env-driven OAuth login. Supports two modes depending on OAUTH_PROVIDER:
#
#   OAUTH_PROVIDER=google_oauth2 (default)
#     Talks to Google directly. Only needs OAUTH_CLIENT_ID/SECRET.
#
#   OAUTH_PROVIDER=oauth2
#     Generic mode for a custom portal/broker that has its own OAuth client
#     id/secret and its own authorize/token endpoints (e.g. a portal that
#     wraps Google/Apple login behind its own OAuth-compliant service).
#     Needs OAUTH_SITE_URL, OAUTH_AUTHORIZE_URL, OAUTH_TOKEN_URL in addition
#     to the client id/secret.
#
# Common env vars (all modes):
#   OAUTH_NAME          - internal slug/name, used in the login URL (/auth/<name>)
#                         and matched to an AuthProvider database record
#   OAUTH_CLIENT_ID
#   OAUTH_CLIENT_SECRET
#
# Generic-mode-only env vars:
#   OAUTH_SITE_URL       - base URL of the portal, e.g. https://portal.example.com
#   OAUTH_AUTHORIZE_URL  - path or full URL for the authorize/login step
#   OAUTH_TOKEN_URL      - path or full URL for the token exchange step
# frozen_string_literal: true

OAUTH_PROVIDER_STRATEGY = ENV.fetch("OAUTH_PROVIDER", "google_oauth2").to_sym
OAUTH_PROVIDER_NAME = ENV.fetch("OAUTH_NAME", "google")

Rails.application.config.middleware.use OmniAuth::Builder do
  case OAUTH_PROVIDER_STRATEGY
  when :oauth2
    provider :oauth2,
             ENV.fetch("OAUTH_CLIENT_ID", nil),
             ENV.fetch("OAUTH_CLIENT_SECRET", nil),
             name: OAUTH_PROVIDER_NAME,
             client_options: {
               site: ENV.fetch("OAUTH_SITE_URL", nil),
               authorize_url: ENV.fetch("OAUTH_AUTHORIZE_URL", nil),
               token_url: ENV.fetch("OAUTH_TOKEN_URL", nil)
             }

  when :openid_connect
    provider :openid_connect,
             name: OAUTH_PROVIDER_NAME,
             issuer: ENV.fetch("OAUTH_ISSUER"),
             discovery: true,
             scope: [:openid, :email, :profile],
             response_type: :code,
             client_options: {
               identifier: ENV.fetch("OAUTH_CLIENT_ID"),
               secret: ENV.fetch("OAUTH_CLIENT_SECRET"),
               redirect_uri: ENV.fetch("OAUTH_REDIRECT_URI")
             }

  else
    provider OAUTH_PROVIDER_STRATEGY,
             ENV.fetch("OAUTH_CLIENT_ID", nil),
             ENV.fetch("OAUTH_CLIENT_SECRET", nil),
             name: OAUTH_PROVIDER_NAME,
             scope: "email,profile"
  end
end

