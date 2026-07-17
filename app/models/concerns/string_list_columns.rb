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

# json columns holding a flat list of strings — a profile's keywords and abilities, a weapon's
# abilities. The database will happily take a bare string or a nested hash; every reader (the card
# view, Profile#mage_level, Profile#disciplines) assumes the list. Now that these columns are
# filled in from a form rather than from hand-written seeds, that assumption is enforced.
module StringListColumns
  extend ActiveSupport::Concern

  class_methods do
    def validates_string_list(*names)
      validate do
        names.each do |name|
          value = public_send(name)
          next if value.is_a?(Array) && value.all?(String)

          errors.add(name, "must be a list of strings")
        end
      end
    end

    # Every entry in the list column must name a rule from the Catalog::Ability glossary of the
    # given category ("character" for a profile's abilities, "weapon" for a weapon's) — its base
    # name, once the "(X)" rating is stripped. Keeps the editor from inventing an ability the app
    # has no glossary entry to explain.
    def validates_ability_glossary(attribute, category:)
      validate do
        list = public_send(attribute)
        next unless list.is_a?(Array)

        known = Catalog::Ability.known_names(category)
        list.grep(String).each do |entry|
          base = Catalog::Ability.base_name(entry)
          next if known.include?(base)

          errors.add(attribute, "\"#{entry}\" is not a known #{category} ability")
        end
      end
    end
  end
end
