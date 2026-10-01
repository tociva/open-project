
# frozen_string_literal: true

# Custom theme colors, applied unconditionally via plain CSS -- no
# Enterprise token involved, since this doesn't touch OpenProject's
# CustomStyle/DesignColor rendering system at all (that system's output
# is gated behind EnterpriseToken.allows_to?(:define_custom_style), see
# app/helpers/custom_styles_helper.rb#apply_custom_styles?).
#
# Colors are stored in a plain OpenProject Setting (custom_theme_colors,
# a hash), editable via Administration -> Theme (ThemeSettingsController).
# A view hook (view_layouts_base_html_head) writes them out as a <style>
# block with !important on every page load, so they always win regardless
# of theme/dark-mode overrides or Enterprise status.
module CustomTheme
  DEFAULT_COLORS = {
    "header-bg-color" => "#1a67a3",
    "header-item-font-color" => "#ffffff",
    "header-item-bg-hover-color" => "#175a8e",
    "main-menu-bg-color" => "#1e3a51",
    "main-menu-bg-selected-background" => "#2a4a66"
  }.freeze

  def self.colors
    DEFAULT_COLORS.merge(Setting.custom_theme_colors || {})
  end
end

Rails.application.config.to_prepare do
  ::Settings::Definition.add :custom_theme_colors,
                              format: :hash,
                              default: CustomTheme::DEFAULT_COLORS

  class CustomThemeCssHook < OpenProject::Hook::ViewListener
    render_on :view_layouts_base_html_head, partial: "hooks/layouts/custom_theme_css"
  end
end
