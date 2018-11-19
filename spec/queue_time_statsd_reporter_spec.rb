# frozen_string_literal: true

require 'fake_statsd'

RSpec.describe QueueTimeStatsdReporter do
  let(:app) { proc {[200, {}, ['Hello, world.']]} }
  let(:statsd) { FakeStatsd.new }
  let(:metric_name) { 'foo.bar' }
  let(:tags) { ['foo:bar', 'bar:baz'] }
  let(:stack) { QueueTimeStatsdReporter.new(app, statsd, metric_name, tags) }
  let(:request) { Rack::MockRequest.new(stack) }

  context 'when no timing header is present' do
    it 'completes the request with no error' do
      response = request.get('/')
      expect(response.status).to eq 200
    end
  end

  context 'when a timing header is present' do
    describe 'a request' do
      it 'increases the number of metrics' do
        expect { request.get('/', {'HTTP_X_REQUEST_START' => "t=#{123}"}) }.to change {statsd.metrics.length}.by(1)
      end

      it 'logs time spent in the queue' do
        start_t = Time.at(1525391588.441).to_f
        end_t = Time.at(start_t + 10)

        Timecop.freeze end_t do
          expect { request.get('/', {'HTTP_X_REQUEST_START' => "t=#{start_t}"}) }.to change {statsd.metrics.length}.by(1)
        end

        last_entry = statsd.metrics[-1]
        expect(last_entry.length).to eq(4)
        expect(last_entry[0]).to eq(:guage)
        expect(last_entry[2]).to eq(10.0)
      end

      it 'completes the request with no error' do
        response = request.get('/', {'HTTP_X_REQUEST_START' => 't=1525391588.441'})
        expect(response.status).to eq 200
      end

      it 'logs to the provided metric name' do
        request.get('/', {'HTTP_X_REQUEST_START' => "t=222"})
        last_entry = statsd.metrics[-1]
        expect(last_entry[1]).to eq(metric_name)
      end

      it 'logs with the provided tags' do
        request.get('/', {'HTTP_X_REQUEST_START' => "t=123"})
        last_entry = statsd.metrics[-1]
        expect(last_entry[3]).to eq(tags)
      end
    end
  end
end
