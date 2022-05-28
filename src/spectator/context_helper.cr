require "spectator"

require "./context_helper/version"

module Spectator::ContextHelper
  module DSL
    macro example_with(__description__ = nil, **__values__, &block)
      context_with({{ __description__ }}, {{ **__values__ }}) do
        it {{ block }}
      end
    end

    macro context_with(__description__ = nil, **__values__, &block)
      {% __description__ ||= __values__.to_a.map { |(k, v)| "#{k} is #{v}" }.join(" and ") %}

      context {{ __description__ }} do
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
