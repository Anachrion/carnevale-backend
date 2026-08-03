require_relative "boot"

require "rails/all"

# Middleware is inserted while the app is still initializing, so it can't be autoloaded from lib
# (Zeitwerk ignores the file below in return).
require_relative "../lib/web_app_cache_control"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CarnevaleBackend
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks web_app_cache_control.rb])

    # The Flutter web bundle under /app keeps the same filenames across releases, so it must not
    # inherit the far-future immutable caching public/ gets. Top of the stack, so it has the last
    # word over the header ActionDispatch::Static sets below it.
    config.middleware.insert(0, WebAppCacheControl)

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Internationalization. English stays the default (and the fallback for any key a translation
    # file is missing); French is the first added locale. The API picks a request's locale from the
    # Accept-Language header the Flutter app sends (see Api::V1::BaseController). Only these two are
    # accepted, so an unknown header value falls back to the default rather than 500-ing on a
    # missing locale.
    config.i18n.available_locales = %i[en fr]
    config.i18n.default_locale = :en
    config.i18n.fallbacks = [ :en ]
  end
end
