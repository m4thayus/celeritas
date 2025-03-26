# frozen_string_literal: true

module FaradayConnection
  class JSON < Base
    include Abstract
    abstract_method :base

    use_middleware ->(builder) { builder.request :json }
    use_middleware ->(builder) { builder.response :json, content_type: %r{\bjson$}, parser_options: { symbolize_names: true } }
  end
end
