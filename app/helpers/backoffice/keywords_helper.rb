# SPDX-License-Identifier: AGPL-3.0-or-later

# The keyword typo check in the profile editor (CARNEVALEB-88). Keywords are free text, yet the app
# acts on some of them (Leader, Hero, Henchman, Unique, Doctor), so a misspelt one silently breaks
# gang validation. Rather than a hard-coded list, the editor asks for confirmation when a keyword
# added in this edit appears on no other profile: a new keyword is rare, a typo is not.
#
# Kept out of profiles_helper.rb on purpose: that file is part of the card template digest, and
# editing it would mark every card out of date.
module Backoffice::KeywordsHelper
  DISCIPLINE_KEYWORD = /\ADiscipline \((.+)\)\z/

  # What the editor's script compares the typed keywords against: the keywords and discipline names
  # on every other profile, and those this profile already had when it was last saved (a keyword
  # only one profile carries, like Dog, must not ask again on every save of that profile).
  def keyword_check_data(profile, all_profiles)
    others = all_profiles.reject { |p| p.id == profile.id }.flat_map { |p| Array(p.keywords) }
    saved = profile.new_record? ? [] : Array(profile.attribute_in_database(:keywords))
    known = others + saved

    {
      known_keywords: known.grep_v(DISCIPLINE_KEYWORD).uniq.sort,
      known_disciplines: known.filter_map { |k| k[DISCIPLINE_KEYWORD, 1] }
                              .flat_map { |list| list.split(",").map(&:strip) }.uniq.sort
    }
  end
end
