# Forces revalidation on the Flutter web bundle under /app.
#
# config.public_file_server.headers marks everything in public/ "public, max-age=1 year, immutable",
# which is right for Rails' digest-stamped assets and for card images (busted by ?v=), but wrong for
# the Flutter bundle: bin/release-web overwrites public/app in place and every file in it keeps the
# same URL from one release to the next — main.dart.js, flutter_bootstrap.js, flutter_service_worker.js,
# assets/*, canvaskit/*. "immutable" tells the browser not even to revalidate, so a visitor who loaded
# the site once kept running that build for a year: a bug fixed and redeployed on the server stayed
# broken in their browser, and the two browsers on one machine disagreed depending on when each first
# loaded the app. "no-cache" still lets the browser store the files; it just has to revalidate, and an
# unchanged bundle answers 304 off the ETag.
#
# Sits at the top of the stack so it rewrites whatever ActionDispatch::Static set further down.
class WebAppCacheControl
  PREFIX = "/app/"
  ROOT = "/app"

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    path = env["PATH_INFO"]
    headers["cache-control"] = "no-cache" if path == ROOT || path.start_with?(PREFIX)
    [ status, headers, body ]
  end
end
