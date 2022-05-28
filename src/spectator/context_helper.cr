require "spectator"

require "./context_helper/version"

module Spectator::ContextHelper
  module DSL
    macro example_with(__description__ = nil, metadata = nil, shared = nil, **__values__, &block)
      context_with({{ __description__ }}, {{ metadata }}, {{ shared }}, {{ **__values__ }}) do
        it {{ block }}
      end
    end

    macro context_with(__description__ = nil, metadata = nil, shared = nil, **__values__, &block)
      {%
        if metadata.class_name == "TupleLiteral"
          *rest, last = metadata
          if last.class_name == "NamedTupleLiteral"
            tags = rest
            metadata = last
          else
            tags = metadata
            metadata = {} of Symbol => String
          end
        else
          tags = { metadata }
          metadata = {} of Symbol => String
        end
      %}

      {%
        unless __description__
          values_words = __values__.to_a.map { |(k, v)| "#{k} is #{v}" }
          words = values_words
          size = words.size
          if size == 0
            __description__ = ""
          elsif size == 1
            __description__ = "when #{words[0]}"
          elsif size == 2
            __description__ = "when #{words.join(" and ")}"
          else
            *rest, last = words
            __description__ = "when #{[rest.join(", "), last].join(" and ")}"
          end
        end
      %}

      context {{ __description__ }}, {{ *tags }}, {{ **metadata }} do
        {% for key, value in __values__ %}
          let({{ key }}) do
            {% if value.class_name == "ProcLiteral" %}
              {{ value }}.call
            {% else %}
              {{ value }}
            {% end %}
          end
        {% end %}
        {{ block.body }}
      end
    end
  end
end

class SpectatorTestContext < SpectatorContext
  include Spectator::ContextHelper::DSL
end
