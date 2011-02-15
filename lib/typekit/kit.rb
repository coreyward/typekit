module Typekit
  # @todo Get information for a specific family in the kit (/kits/:kit/families/:family)
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
      # @return [Typekit::Kit] The resulting kit
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
    # @return Returns @attribute if attribute argument is specified; otherwise returns self
    def fetch(attribute = nil)
      mass_assign Client.get("/kits/#{@id}")
      attribute ? instance_variable_get("@#{attribute}") : self
    end
    alias :reload :fetch
    
    # Save kit attributes like name and domains. This does *not* alter the families
    # added to the kit. 
    # @param publish_after_save [Boolean] Commit changes saved to the published kit. See {#publish}.
    # @return [Boolean] Status of the operation (including the publishing, if it is called)
    def save(publish_after_save = true)
      attributes = [:name, :analytics, :badge, :domains].inject({}) { |attributes, x| attributes[x] = instance_variable_get("@#{x}"); attributes }
      result = mass_assign Client.post("/kits/#{@id}", :query => attributes)
      published = publish if publish_after_save
      
      # For the parenthesized statement, true && true or false && false are acceptable.
      # but xor does the exact opposite, so we negate it.
      result && !(publish_after_save ^ published)
    end
    
    # Typekit maintains the changes you have made to a Kit in a "working" state 
    # until you specify that it is ready to be published. After the state has been
    # changed to "published" your kit will be queued to be pushed out to their CDN
    # and served to new requests. This can take up to 5 minutes when they are under
    # heavy load.
    # @return [Time] The date & time that the kit was last published
    def publish
      Client.post("/kits/#{@id}/publish")
    end
    
    # Delete this kit from Typekit
    def delete
      Client.delete("/kits/#{@id}")
    end
    alias :destroy :delete
    
    # Add a family to this kit (does not publish changes)
    # @param id [String] Typekit Font Family id (e.g. 'brwr')
    # @param params [Hash] Attributes for the family to be added
    # @option params [Array] :variations ([]) Font Variation Descriptions ('n4', 'i7', etc.) for the variations to be included
    # @option params [String] :subset ('default') Character subset to be served ('all' or 'default')
    # @return [Boolean] True on success; error raised on failure
    def add_family(id, params = {})
      params = { :variations => [], :subset => 'default' }.merge(params)
      !!Client.post("/kits/#{@id}/families/#{id}", :query => params)
    end
    
    # Update a family on this kit (does not publish changes)
    # @param id [String] Typekit Font Family id (e.g. 'brwr')
    # @param [Block] A block manipulating the family attributes
    # @yieldparam [Hash] family The existing definition for this family
    # @example Updating a font family
    #   Typekit::Kit.update_family('abcdef') do |family|
    #     family['subset'] = 'all'
    #     family['variations'] << 'i3'
    #   end
    # @return [Boolean] True on success; error raised on failure
    def update_family(id)
      raise 'Block required' unless block_given?
      family = Client.get("/kits/#{@id}/families/#{id}")
      yield family
      family.keep_if { |k,v| %w{variations subset}.include? k }
      !!Client.post("/kits/#{@id}/families/#{id}", :query => family)
    end
    
    # Delete a family from this kit (does not publish changes)
    # @param id [String] Typekit Font Family id (e.g. 'brwr')
    # @return [Boolean] True on success; error raised on failure
    def delete_family(id)
      !!Client.delete("/kits/#{@id}/families/#{id}")
    end
    alias :remove_family :delete_family
  end
end
