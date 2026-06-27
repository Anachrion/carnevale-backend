namespace :db do
  task :terminate_connections do
    Rake::Task[:environment].invoke
    db_name = ActiveRecord::Base.connection_db_config.database
    quoted = ActiveRecord::Base.connection.quote(db_name)
    ActiveRecord::Base.connection.execute(
      "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = #{quoted} AND pid <> pg_backend_pid()"
    )
    puts "Terminated open connections to '#{db_name}'."
  rescue => e
    warn "Could not terminate connections: #{e.message}"
  end
end

Rake::Task["db:drop"].enhance(["db:terminate_connections"])
