# SPDX-License-Identifier: AGPL-3.0-or-later

class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@carnevale-app.com"
  layout "mailer"
end
