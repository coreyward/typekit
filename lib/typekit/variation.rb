module Typekit
  # @todo Move lazy loading into a module
  class Variation
    include MassAssignment
    attr_accessor :id, :name, :font_style, :font_variant, :font_weight, :foundry, :libraries, :postscript_name
    
    # Typekit::Variation.new isn't expected usage
    private :initialize
    
    class << self
      private
      def lazy_load(*attributes)
        attributes.each do |attribute|
          define_method :"#{attribute}" do
            instance_variable_defined?("@#{attribute}") ? instance_variable_get("@#{attribute}") : fetch(attribute)
          end
        end
      end
    end
    
    lazy_load :font_style, :font_variant, :font_weight, :foundry, :libraries, :postscript_name
    
    # Get detailed information about this Family Variation from Typekit
    # @note This is called lazily when you access any non-loaded attribute
    #   and doesn't need to be called manually unless you want to reload the
    #   data. This means we can return an array of Variation objects for {Family#variations}
    #   without making N+1 requests to the API.
    # @param attribute [Symbol] Optionally return a single attribute after data is loaded
    # @return Returns @attribute if attribute argument is specified; otherwise returns self
    def fetch(attribute)
      family_id, variation_id = @id.split(':')
      mass_assign Client.get("/families/#{family_id}/#{variation_id}")
      attribute ? instance_variable_get("@#{attribute}") : self
    end
    alias :reload :fetch
    
    def to_fvd
      name.split(':').last
    end
  end
end
