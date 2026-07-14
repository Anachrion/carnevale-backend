# A rules PDF the app's Rules page links to, read from config/rules_documents.yml.
#
# Deliberately not an ActiveRecord model and not a Catalog:: type: these are pointers to TT Combat's
# own published PDFs rather than gameplay data we author, so they live in config, where a link that
# has gone stale is fixed by an edit and a deploy instead of a data migration. Serving them from the
# API at all (rather than baking the list into the app) is what keeps a URL change off the app-store
# release path — see the comments in the YAML.
class RulesDocument
  CONFIG_PATH = Rails.root.join("config/rules_documents.yml")

  attr_reader :key, :title, :url

  def initialize(key:, title:, url:)
    @key = key
    @title = title
    @url = url
  end

  # Re-read on every call in development (so editing the YAML shows up without restarting the server)
  # and in test (so a spec can stub the file and actually see its stub). Memoised in production,
  # where the file cannot change under a running process.
  def self.all
    return load_all if Rails.env.local?

    @all ||= load_all
  end

  def self.load_all
    rows = YAML.safe_load_file(CONFIG_PATH)
    documents = rows.map do |row|
      new(key: row.fetch("key"), title: row.fetch("title"), url: row.fetch("url"))
    end

    # A duplicate key would have two documents fighting over one cache slot on the client, which
    # shows up as a PDF that opens the wrong file. Cheaper to fail the boot than to debug that.
    keys = documents.map(&:key)
    duplicates = keys.tally.select { |_, count| count > 1 }.keys
    raise "Duplicate rules document keys in #{CONFIG_PATH}: #{duplicates.join(', ')}" if duplicates.any?

    documents
  end
  private_class_method :load_all

  # What the response ETag is built from. Derived from the content rather than inherited from
  # Object#to_s, whose default carries the object id — that changes every time the YAML is re-read,
  # which would hand every client a fresh ETag and defeat the 304s entirely.
  def cache_key
    "rules_document/#{key}-#{title}-#{url}"
  end

  def as_json(*)
    { key:, title:, url: }
  end
end
