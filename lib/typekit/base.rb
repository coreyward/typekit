module Typekit
  class Base
    def initialize(attributes = nil)
      mass_assign(attributes)
      yield self if block_given?
    end
    
    def mass_assign(attributes)
      attributes.each do |attribute, value|
        respond_to?(:"#{attribute}=") && send(:"#{attribute}=", value)
      end
    end
  end
end
