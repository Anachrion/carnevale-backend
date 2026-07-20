# Copyright 2026 Anachrion
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Localizes an API response to the language the client requests via Accept-Language. Included by
# both Api::V1::BaseController and the Devise-derived auth controllers (registrations/sessions/
# passwords), which don't share a base class but emit the most user-facing translatable text there
# is — validation errors and "invalid email or password".
#
# around_action + I18n.with_locale scopes the locale to the current request; setting I18n.locale
# globally would leak into the next request served by the same Puma thread.
module SwitchesLocale
  extend ActiveSupport::Concern

  included do
    around_action :switch_locale
  end

  private

  def switch_locale(&action)
    I18n.with_locale(locale_from_header, &action)
  end

  # Picks the first Accept-Language entry whose primary subtag (e.g. "fr" from "fr-CA,fr;q=0.9") is
  # one we actually support; falls back to the default locale when the header is absent or lists
  # only unsupported languages. Deliberately ignores q-weights — with two locales, first supported
  # match is good enough and keeps this dependency-free.
  def locale_from_header
    header = request.headers["Accept-Language"]
    return I18n.default_locale if header.blank?

    tags = header.split(",").map { |part| part.split(";").first.to_s.strip.split("-").first.downcase }
    tags.map(&:to_sym).find { |tag| I18n.available_locales.include?(tag) } || I18n.default_locale
  end
end
