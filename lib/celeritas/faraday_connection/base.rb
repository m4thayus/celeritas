# frozen_string_literal: true

module FaradayConnection
  class Base
    include Routable
    include Abstract

    abstract_method :base

    DEFAULT_TIMEOUT = 1.minute

    class_attribute :middlewares,
                    default: [],
                    instance_writer: false,
                    instance_predicate: false

    class << self
      def base(definition)
        define_method(:base) { definition.call }
      end

      def timeout(duration)
        redefine_method(:timeout) { duration }
      end

      def use_middleware(config)
        self.middlewares += [config]
      end
    end

    def index(path, &)
      connection.get(path) do |request|
        yield request if block_given?
      end
    end

    def show(path, &)
      connection.get(path) do |request|
        yield request if block_given?
      end
    end

    def create(path, **payload, &)
      connection.post(path, payload) do |request|
        yield request if block_given?
      end
    end

    # TODO: Add option for PUT
    def update(path, **payload, &)
      connection.patch(path, payload) do |request|
        yield request if block_given?
      end
    end

    def destroy(path, &)
      connection.delete(path) do |request|
        yield request if block_given?
      end
    end

    private

    def connection
      @connection ||= Faraday.new(url: base, request: { timeout: timeout.to_i }) do |builder|
        self.middlewares.each do |config|
          config.call(builder)
        end

        builder.response :raise_error
        builder.response :logger if Rails.env.development?
      end
    end

    def timeout
      DEFAULT_TIMEOUT
    end
  end
end
