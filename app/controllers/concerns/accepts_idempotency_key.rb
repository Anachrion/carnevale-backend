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
