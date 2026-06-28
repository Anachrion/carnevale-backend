class ListEntryReorderService
  def self.call(entry, new_position)
    new(entry, new_position).call
  end

  def initialize(entry, new_position)
    @entry = entry
    @list = entry.list
    @old_position = entry.position
    @new_position = new_position.clamp(1, @list.list_entries.count)
  end

  def call
    return if @old_position == @new_position

    @entry.update_columns(position: 0)

    if @new_position < @old_position
      @list.list_entries
           .where(position: @new_position..(@old_position - 1))
           .order(position: :desc)
           .each { |e| e.update_columns(position: e.position + 1) }
    else
      @list.list_entries
           .where(position: (@old_position + 1)..@new_position)
           .order(position: :asc)
           .each { |e| e.update_columns(position: e.position - 1) }
    end

    @entry.update_columns(position: @new_position)
  end
end
