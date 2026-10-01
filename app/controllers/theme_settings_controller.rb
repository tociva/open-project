# frozen_string_literal: true

# Custom theme settings page. Reads and writes Setting.custom_theme_colors
# (defined in config/initializers/custom_theme.rb), which the
# view_layouts_base_html_head hook renders as plain CSS on every page.
# Deliberately independent of OpenProject's CustomStyle/DesignColor system,
# whose rendering is Enterprise-gated (see custom_styles_helper.rb).
class ThemeSettingsController < ApplicationController
  layout "admin"

  before_action :require_admin

  menu_item :theme_settings

  def show
    @colors = CustomTheme.colors
  end

  def update
    submitted = params.fetch(:colors, {}).permit!.to_h.compact_blank

    Setting.custom_theme_colors = CustomTheme::DEFAULT_COLORS.merge(submitted)

    flash[:notice] = I18n.t(:notice_successful_update)
    redirect_to action: :show
  end

  def reset
    Setting.custom_theme_colors = CustomTheme::DEFAULT_COLORS

    flash[:notice] = I18n.t(:notice_successful_update)
    redirect_to action: :show
  end

  private

  def editable_colors
    {
      "header-bg-color" => "Header background",
      "header-item-font-color" => "Header font colour",
      "header-item-bg-hover-color" => "Header background on hover",
      "main-menu-bg-color" => "Side menu background",
      "main-menu-bg-selected-background" => "Side menu selected background"
    }
  end
  helper_method :editable_colors
end
