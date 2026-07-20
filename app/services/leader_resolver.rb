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

# Resolves flex-Leader demotion for a gang: given its card-reference entries (in list/position order)
# it works out which single entry keeps the Leader keyword, which flex Leaders demote to plain Heroes,
# and — for the ambiguous case — which of those the player could promote instead.
#
# Rules (rulebook, generalized):
# - A hard Leader always keeps the keyword.
# - A *conditional* flex Leader (La Signora, Catalog::Profile#flexible_leader_with) keeps it unless her
#   named partner (Il Capitano) is in the gang; alongside him she demotes, alongside any other Leader
#   she keeps it (so the pair reads as two Leaders — an illegal gang).
# - An *unconditional* flex Leader (The Duke, Prince of Thieves, Sopracomito) keeps it only when no
#   other Leader is *forced* to keep it. When several such Leaders are the only Leaders present, none
#   is forced, so the player picks: the topmost (lowest position) leads and the rest demote — each of
#   those is "promotable" (moving it to the top makes it the Leader instead).
class LeaderResolver
  Result = Struct.new(:effective, :demoted, :promotable, keyword_init: true)

  # `card_ref_entries`: the gang's non-summoned Gang::Entry rows whose catalog row is a
  # Catalog::CardReference, in list (position) order. Their `profile` is expected preloaded.
  def self.call(card_ref_entries)
    new(card_ref_entries).call
  end

  def initialize(card_ref_entries)
    @entries = card_ref_entries
  end

  def call
    leaders = @entries.select { |e| e.profile&.keywords&.include?("Leader") }
    forced = leaders.select { |e| forced?(e) }

    if forced.any?
      # A forced Leader is present, so every flex Leader demotes around it; nothing is promotable
      # (only the forced Leader can lead). Two forced Leaders is an illegal gang, caught by the count.
      Result.new(effective: forced, demoted: leaders - forced, promotable: [])
    else
      # No forced Leader: only unconditional flex Leaders are in play. The topmost leads; the rest
      # demote but may be promoted in its place.
      unconditional = leaders.select { |e| unconditional_flex?(e) }
      effective = unconditional.first(1)
      Result.new(
        effective: effective,
        demoted: leaders - effective,
        promotable: unconditional - effective,
      )
    end
  end

  private

  # A Leader that keeps the keyword no matter what else is in the gang.
  def forced?(entry)
    profile = entry.profile
    return true unless profile.flexible_leader # hard Leader

    partner_id = profile.flexible_leader_with_id
    partner_id.present? && all_profile_ids.exclude?(partner_id) # conditional flex, partner absent
  end

  def unconditional_flex?(entry)
    profile = entry.profile
    profile.flexible_leader && profile.flexible_leader_with_id.nil?
  end

  def all_profile_ids
    @all_profile_ids ||= @entries.filter_map { |e| e.profile&.id }.to_set
  end
end
