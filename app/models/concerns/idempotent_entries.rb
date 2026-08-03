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

# Adds a list_entries row safely under a flaky mobile client that re-sends a create it never got a
# response for (see the app's optimistic sync queue), and under two devices of one account adding at
# once. Two races are closed by one method:
#
#   * Idempotency — a repeated `request_key` (the Idempotency-Key header, minted once per client op
#     and reused across its retries) returns the *existing* row instead of creating a duplicate. The
#     partial unique index on (list_id, request_key) is the guard; the replay handles the window
#     between a committed-but-lost first attempt and its retry.
#   * Position race — two concurrent adds both computing `max(position) + 1` collide on the
#     (list_id, position) unique index; the loser retries with a freshly recomputed position.
#
# The new entry is yielded inside the creating transaction so the caller can add companions / entry
# states atomically with it. Returns the entry (freshly created, or the existing one on replay).
module IdempotentEntries
  extend ActiveSupport::Concern

  MAX_POSITION_RETRIES = 3

  def add_entry_idempotently(request_key: nil, **attrs)
    # Fast replay: a prior attempt with this key already committed its row.
    if request_key && (existing = list_entries.find_by(request_key: request_key))
      return existing
    end

    attempts = 0
    begin
      entry = nil
      transaction do
        entry = list_entries.create!(
          position: (list_entries.maximum(:position) || 0) + 1,
          request_key: request_key,
          **attrs
        )
        yield entry if block_given?
      end
      entry
    rescue ActiveRecord::RecordNotUnique
      # The request_key collided → a concurrent first attempt won the race; replay its row.
      return list_entries.find_by!(request_key: request_key) if request_key && list_entries.exists?(request_key: request_key)

      # Otherwise the (list_id, position) index collided with a concurrent add — recompute and retry.
      raise if (attempts += 1) >= MAX_POSITION_RETRIES

      retry
    end
  end
end
