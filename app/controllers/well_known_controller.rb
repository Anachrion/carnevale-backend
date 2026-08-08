# Carnevale Companion — Backend
# Copyright (C) 2026 Anachrion and contributors
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

# Serves the /.well-known documents that let a mobile OS treat this domain's links as belonging to
# the app, so a /join or /reset-password URL opens the app instead of the browser (CARNEVALEB-74).
#
# Public, like WebAppController: the verifier fetches these anonymously at install time, so they
# must carry no authentication. Served from a controller rather than dropped in public/ because
# public/ is sent with a one-year immutable cache header — pinning a fingerprint that must change
# when a signing key rotates would be hard to undo.
class WellKnownController < ApplicationController
  ANDROID_PACKAGE = "app.carnevale.mobile".freeze

  # Digital Asset Links, fetched by Android at install time for every host declared with
  # `android:autoVerify="true"` in the app manifest. Android enables App Links only if one of the
  # fingerprints below matches the certificate the installed app was actually signed with.
  #
  # That certificate is the one Google holds, not the local upload key: releases are uploaded as an
  # .aab, so Play App Signing re-signs them. The value comes from the Play Console
  # (Setup -> App integrity -> App signing key certificate), which is why it is configuration rather
  # than a constant here. Fingerprints are public information — they are served to anyone who asks —
  # so this is deliberately a plain env var, not a secret.
  def assetlinks
    if fingerprints.empty?
      # Loud rather than silent: a well-formed file with no fingerprints looks fine in a browser but
      # fails verification, and the resulting "links still open the browser" is hard to trace back.
      Rails.logger.warn("assetlinks.json served with no fingerprints — set ANDROID_CERT_FINGERPRINTS")
    end

    render json: [
      {
        relation: [ "delegate_permission/common.handle_all_urls" ],
        target: {
          namespace: "android_app",
          package_name: ANDROID_PACKAGE,
          sha256_cert_fingerprints: fingerprints
        }
      }
    ]
  end

  private

  # Comma-separated so several can be listed at once, which is the normal case: the Play app-signing
  # certificate for installs from the store, plus the upload certificate for a locally-built APK
  # sideloaded during testing. Colons and case are left as the Play Console prints them.
  def fingerprints
    ENV.fetch("ANDROID_CERT_FINGERPRINTS", "").split(",").map(&:strip).reject(&:empty?)
  end
end
