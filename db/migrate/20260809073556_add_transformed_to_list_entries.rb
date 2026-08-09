# Violent Transformation (Yune Lobravym ⇄ The Beast Within): whether this model is currently in its
# alternate form. One entry rather than two, because the rule has the two forms share their Life,
# Will and Command Points "including any that have been lost" — with a single entry there is a
# single Encounter::EntryState, so that sharing is structural rather than something to keep in sync.
#
# Only ever set during a game; a hired gang always holds the model in its printed form.
class AddTransformedToListEntries < ActiveRecord::Migration[8.1]
  def change
    add_column :list_entries, :transformed, :boolean, default: false, null: false
  end
end
