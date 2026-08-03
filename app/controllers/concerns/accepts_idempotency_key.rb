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

# Reads the client's Idempotency-Key header for the additive create endpoints (hire, summon) that
# store it in list_entries.request_key. The value is client-controlled and lands in a unique-indexed
# column, so it's bounded to a plausible opaque token (UUID / random id); anything else is treated as
# absent, so a malformed key falls back to a normal non-idempotent create rather than 400ing a
# legitimate hire.
module AcceptsIdempotencyKey
  extend ActiveSupport::Concern

  IDEMPOTENCY_KEY_FORMAT = /\A[A-Za-z0-9._-]{16,128}\z/

  private

  def idempotency_key
    key = request.headers["Idempotency-Key"]
    key if key.is_a?(String) && IDEMPOTENCY_KEY_FORMAT.match?(key)
  end
end
