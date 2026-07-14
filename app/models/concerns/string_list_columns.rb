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
  end
end
