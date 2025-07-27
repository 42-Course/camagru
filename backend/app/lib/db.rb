require "pg"
require "uri"
require "connection_pool"

module Database
  class << self
    def pool
      @pool ||= build_pool
    end

    def with_conn(max_retries: 3)
      attempts = 0

      begin
        pool.with do |conn|
          raise PG::ConnectionBad, "Stale PG connection" if conn.finished?

          yield conn
        end
      rescue PG::ConnectionBad => e
        attempts += 1
        warn "[DB] Reconnecting due to: #{e.message} (attempt #{attempts}/#{max_retries})"
        reset_pool
        sleep 0.05 * attempts
        retry if attempts < max_retries
        raise
      end
    end

    # For scripts that run outside app boot (e.g. migrations)
    def temp_conn(&block)
      build_pool.with(&block)
    end

    private

    def database_url
      return ENV["TEST_DATABASE_URL"] || raise("TEST_DATABASE_URL not set") if ENV["RACK_ENV"] == "test"

      ENV["DATABASE_URL"] || raise("DATABASE_URL not set")
    end

    def reset_pool
      @pool = nil
    end

    def build_pool
      conn_info = parse_database_url(database_url)
      ConnectionPool.new(size: 5, timeout: 5) do
        PG.connect(conn_info)
      end
    end

    def parse_database_url(url)
      raise "DATABASE_URL not set" unless url

      uri = URI.parse(url)
      {
        host: uri.host,
        port: uri.port || 5432,
        dbname: uri.path[1..],
        user: uri.user,
        password: uri.password,
        sslmode: "prefer" # or 'require' for production
      }
    end
  end
end
