# frozen_string_literal: true
require 'set'

module Datadog
  class CardinalityCounter
    class << self

      attr_accessor :cardinality_count
      
      
      def cardinality_data
        @@cardinality_data
      end

      @@cardinality_data = {}

      def calculate_cardinality(stat, tags=[])
        tag_scope = {}
        if tags
          tags.each do |tag|
            k, v = tag.split(':')
            if tag_scope[k]
              tag_scope[k].merge(Set[v])
            else
              tag_scope[k] = Set[v]
            end
          end
          if @@cardinality_data[stat]
            tag_scope.each do |k,v|
              @@cardinality_data[stat][k].merge(v)x
            end
          else
            @@cardinality_data[stat] = tag_scope
          end
        end
      end

      def report_all
        stat_totals = @@cardinality_data.map do |stat, tags|
          report_stat(stat)
        end
        total = stat_totals.inject(0){|s,x| s + x }
      end

      def report_stat(stat)
        tags = @@cardinality_data[stat]
        multiply = tags.map do |name, value|
          value.length
        end
        multiply.inject(1){|m,x| m * x }
     end
    end
  end
end

# Datadog::CardinalityCounter.calculate_cardinality("basket", ["fruit:apple", "color:green", "color:red"])
# Datadog::CardinalityCounter.calculate_cardinality("basket", ["fruit:orange"])
# Datadog::CardinalityCounter.calculate_cardinality("basket", ["fruit:mango"])
# Datadog::CardinalityCounter.calculate_cardinality("basket", ["fruit:tamarind", "color:brown"])
# Datadog::CardinalityCounter.calculate_cardinality("cart", ["meat:hamachi", "color:white"])
# Datadog::CardinalityCounter.calculate_cardinality("cart", ["meat:chicken", "color:white"])
# Datadog::CardinalityCounter.calculate_cardinality("cart", ["meat:steak", "color:red"])
# Datadog::CardinalityCounter.calculate_cardinality("cart", ["meat:tuna", "color:red"])

# puts Datadog::CardinalityCounter.cardinality_data
# Datadog::CardinalityCounter.report_all
# Datadog::CardinalityCounter.report_stat("cart")

# {
#   :some.second.metric => {
#     :bundle => 
#   }
# }


# {
#   :jobs.processed => {}
# }

# 1 some.first.metric
#   status:success
# 2 status:failure
#   services:database
#   services:api
# 3 services:webserver

# Cardinality: 1 * 2 * 3 = 6

# 1 some.second.metric
#   status:success
# 2 status:failure
#   bundle:3249
#   bundle:3250
#   bundle:3251
#   bundle:3252
#   bundle:3253
#   bundle:3254
#   bundle:3255
# 8 bundle:3256
#   services:database
#   services:api
# 3 services:webserver

# Cardinality: 1 * 2 * 8 * 3 = 48