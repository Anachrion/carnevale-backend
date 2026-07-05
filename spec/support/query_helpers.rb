# Counts the real SQL queries issued while running a block, so specs can guard against N+1s.
# Schema introspection, transaction-control statements, and cached (memoised) queries are ignored
# so the count reflects only genuine round-trips to the database.
module QueryHelpers
  IGNORED_SQL = /\A\s*(BEGIN|COMMIT|ROLLBACK|SAVEPOINT|RELEASE|PRAGMA)/i

  def count_queries
    count = 0
    counter = lambda do |_name, _start, _finish, _id, payload|
      next if payload[:name] == "SCHEMA" || payload[:cached]
      next if payload[:sql].match?(IGNORED_SQL)

      count += 1
    end
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record") { yield }
    count
  end
end

RSpec.configure do |config|
  config.include QueryHelpers
end
