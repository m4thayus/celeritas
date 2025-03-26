# frozen_string_literal: true

module Abstract
  extend ActiveSupport::Concern

  class_methods do
    def abstract_singleton_method(name)
      define_singleton_method(name) do |*args|
        raise NoMethodError.new("Abstract singleton method must be implemented by consumer", name, *args)
      end
    end

    def abstract_method(name)
      define_method(name) do |*args|
        raise NoMethodError.new("Abstract method must be implemented by consumer", name, *args)
      end
    end
  end
end
