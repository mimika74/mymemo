# Puma configuration for containerized deployment.
#
# NOTE: the previous version of this file daemonized Puma, bound to a Unix
# socket and redirected stdout/stderr to log files. That is incompatible with
# running inside a Docker container (the process must stay in the foreground,
# listen on a TCP port and log to STDOUT). The old config is available in git
# history if a non-Docker deploy is ever needed.

max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Bind to all interfaces on PORT (default 3000) so the container is reachable.
port ENV.fetch("PORT") { 3000 }

environment ENV.fetch("RAILS_ENV") { "production" }

pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Clustered mode is opt-in via WEB_CONCURRENCY (0 = single mode, the default).
workers Integer(ENV.fetch("WEB_CONCURRENCY") { 0 })
preload_app! if Integer(ENV.fetch("WEB_CONCURRENCY") { 0 }) > 0

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
