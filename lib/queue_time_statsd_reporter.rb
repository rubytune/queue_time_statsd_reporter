# frozen_string_literal: true

require "queue_time_statsd_reporter/version"

class QueueTimeStatsdReporter
  def initialize(app, statsd, metric_name, tags = [])
    @app = app
    @statsd = statsd
    @metric_name = metric_name
    @tags = tags
  end

  def call(env)
    report_queue_time(env)
    @app.call(env)
  end

  private

  def report_queue_time(env)
    return nil unless env.has_key?("HTTP_X_REQUEST_START")
    @statsd.gauge(
      @metric_name,
      seconds_since_request_start(env["HTTP_X_REQUEST_START"]),
      tags=@tags
    )
  end

  def seconds_since_request_start(header)
    Float((Time.now - request_start_time_from_header(header)))
  end

  # The header will be in the format t=1525393793.115
  def request_start_time_from_header(header_string)
    Float(header_string.strip[2..-1])
  end
end
