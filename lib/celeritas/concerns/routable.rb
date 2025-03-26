# frozen_string_literal: true

module Routable
  extend ActiveSupport::Concern

  class_methods do
    def draw(name, route)
      define_method(name) do |**args|
        route.call(**args.transform_values {|component| URI.encode_uri_component(component) })
      end
    end
  end
end
