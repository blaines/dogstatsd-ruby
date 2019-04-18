# frozen_string_literal: true
require_relative 'statsd'
require_relative 'cardinality_counter'

# SafeStatsd is a drop in replacement for Statsd
# and prevents high cardinality metrics
module Datadog
  class SafeStatsd < Statsd

    def send_stats(stat, delta, type, opts=EMPTY_OPTIONS)
      super
      CardinalityCounter.calculate_cardinality(stat, opts[:tags])
    end

  end
end
