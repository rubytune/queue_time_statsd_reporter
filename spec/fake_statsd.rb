# Mock statsd class to record data during the specs.
class FakeStatsd
  attr_accessor :metrics

  def initialize
    self.metrics = []
  end

  def empty?
    metrics.empty?
  end

  def gauge(*arguments)
    metrics << [:guage, *arguments]
  end
end
