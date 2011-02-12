module Typekit
  class Kit < Typekit::Base
    attr_accessor :name, :id, :analytics, :badge, :domains, :families
    @@defaults = { :analytics => false, :badge => false }
    
    class << self
      def defaults
        @@defaults
      end
      
      def find(id)
        kit = Kit.new(:id => id)
        kit.reload
        kit
      end
  
      def all
        Client.get('/kits').inject([]) do |kits, attributes|
          kits << Kit.new(attributes)
        end
      end
      
      def create(params)
        params = @@defaults.merge(params)
        response = Client.post("/kits", :query => params)
        Kit.new(response)
      end
      
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
    
    def initialize(attributes = {})
      super
    end
  
    def fetch(attribute = nil)
      mass_assign Client.get("/kits/#{@id}")
      instance_variable_get("@#{attribute}") unless attribute.nil?
    end
    alias :reload :fetch
  
    def publish
      Client.post("/kits/#{@id}/publish")
    end
  end
end
