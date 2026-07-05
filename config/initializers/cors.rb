# Cross-Origin Resource Sharing (CORS) — this only governs browsers (the Flutter *web* build and
# anything else calling from a browser). Native mobile clients and tools like curl do not send an
# Origin header and are unaffected, so CORS is a complement to the API key + rate limiting, not a
# replacement for them.
#
# Set ALLOWED_ORIGINS (comma-separated) in each deployed environment to your web frontend's
# origin(s), e.g. ALLOWED_ORIGINS="https://app.example.com,https://www.example.com". When it is
# unset (development), any localhost/127.0.0.1 port is allowed so `flutter run -d chrome` works
# regardless of the port it picks.
allowed_origins =
  if ENV["ALLOWED_ORIGINS"].present?
    ENV["ALLOWED_ORIGINS"].split(",").map(&:strip).reject(&:blank?)
  else
    [ %r{\Ahttp://localhost(:\d+)?\z}, %r{\Ahttp://127\.0\.0\.1(:\d+)?\z} ]
  end

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*allowed_origins)
    resource "*", headers: :any, methods: %i[get post put patch delete options head],
             expose: [ "Authorization" ]
  end
end
