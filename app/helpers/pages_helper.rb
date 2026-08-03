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

# Helpers for the standalone public pages (see PagesController).
module PagesHelper
  # The colour bar next to a faction on the printable-cards page. Reuses the backoffice's own pill
  # colours rather than declaring a second set, so a faction reads the same wherever it is listed —
  # only the background is wanted here, since the swatch carries no text.
  def faction_swatch_style(faction)
    Backoffice::ProfilesHelper::FACTION_PILL_STYLES
      .fetch(faction.to_s, "background:#f3f4f6;")
      .split(";")
      .grep(/\Abackground:/)
      .join(";")
  end
end
