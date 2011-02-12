module Typekit
  # Contains mass assignment functionality for building objects out of hashes.
  # @abstract
  module MassAssignment
    def initialize(attributes = {})
      mass_assign(attributes)
    end
    
    def mass_assign(attributes)
      attributes.each do |attribute, value|
        respond_to?(:"#{attribute}=") && send(:"#{attribute}=", value)
      end
    end
  end
end
