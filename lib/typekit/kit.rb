module Typekit
  class Kit
    include MassAssignment
    
    # Detailed information about a kit. Lazy loaded when accessed unless
    # the data already exists.
    # @see Kit#fetch
    attr_accessor :name, :domains, :families, :analytics, :badge
    
    # Typekit-defined kit id
    attr_accessor :id
    protected :id=
    
    # Typekit::Kit.new isn't expected usage
    private :initialize
    
    # @todo Allow users to change defaults easily
    @@defaults = { :analytics => false, :badge => false }
    
    class << self
      # Find a kit by id (*not* by name)
      # @param id [String] Typekit Kit ID (can be found via {Kit.all})
      def find(id)
        kit = Kit.new(:id => id)
        kit.reload
        kit
      end
      
      # Get a list of all of the kits available for this Typekit account
      # @todo Support pagination
      def all
        Client.get('/kits').inject([]) do |kits, attributes|
          kits << Kit.new(attributes)
        end
      end
      
      # Create a new kit
      # @param params [Hash] Attributes for the newly create kit
      # @option params [String] :name Required: The name of the kit
      # @option params [Array] :domains Required: An array of the domains that this kit will be used on
      # @option params [Boolean] :analytics (false) Allow Typekit to collect kit-usage data via Google Analytics
      # @option params [Boolean] :badge (false) Show the Typekit colophon badge on websites using this kit
      def create(params)
        params = @@defaults.merge(params)
        response = Client.post("/kits", :query => params)
        Kit.new(response)
      end
      
      private
      def lazy_load(*attributes)
        attributes.each do |attribute|
          define_method :"#{attribute}" do
            instance_variable_defined?("@#{attribute}") ? instance_variable_get("@#{attribute}") : fetch(attribute)
          end
        end
      end
    end
    
    # Lazy load extended information only when it's accessed
    lazy_load :name, :analytics, :badge, :domains, :families
  
    # Get detailed information about this kit from Typekit
    # @note This is called lazily when you access any non-loaded attribute
    #   and doesn't need to be called manually unless you want to reload the
    #   data. This means we can return an array of Kit objects for {Kit.all}
    #   without making N+1 requests to the API.
    # @param attribute [Symbol] Optionally return a single attribute after data is loaded
    def fetch(attribute = nil)
      mass_assign Client.get("/kits/#{@id}")
      instance_variable_get("@#{attribute}") unless attribute.nil?
    end
    alias :reload :fetch
    
    # Typekit maintains the changes you have made to a Kit in a "working" state 
    # until you specify that it is ready to be published. After the state has been
    # changed to "published" your kit will be queued to be pushed out to their CDN
    # and served to new requests. This can take up to 5 minutes when they are under
    # heavy load.
    def publish
      Client.post("/kits/#{@id}/publish")
    end
    alias :save :publish
    
    # Delete a kit from Typekit
    # @note Typekit does not have this functionality in their API at this time. When they do,
    #   the `raise` call in this method can be removed, along with this warning.
    # @raise An error, always, telling you this doesn't work.
    def delete
      raise "The Typekit API does not support deleting a kit at this time."
      Client.delete("/kits/#{@id}")
    end
    alias :destroy :delete
  end
end
