require 'rubygems'
require 'httparty'

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
  
  class Client < Typekit::Base
    include HTTParty
    base_uri 'https://typekit.com/api/v1/json'
    # debug_output
  
    def initialize(token)
      self.class.default_params :token => token
    end
    
    def kits
      Kit.list
    end
    
    def kit(id)
      Kit.find id
    end
    
    def family(id)
      Family.find id
    end
    
    def create_kit(params)
      params = Kit.defaults.merge(params)
      response = Client.post("/kits/", :query => params)['kit']
      Kit.new(response)
    end
  end
  
  # def method_missing(method, *args, &block)
  #   if self.class.respond_to? method
  #     self.class.send(method, *args, &block)
  #   else
  #     super
  #   end
  # end
  
  class Kit < Typekit::Base
    attr_accessor :name, :id, :analytics, :badge, :domains, :families
    @@defaults = { :analytics => false, :badge => false }
    
    # Lazy load extended information only when it's accessed
    [:name, :analytics, :badge, :domains, :families].each do |attribute|
      define_method :"#{attribute}" do
        instance_variable_defined?("@#{attribute}") ? instance_variable_get("@#{attribute}") : info(attribute)
      end
    end
    
    class << self
      def defaults
        @@defaults
      end
      
      def find(id)
        Client.get("/kits/#{id}")
      end
  
      def list
        Client.get('/kits')['kits'].inject([]) do |kits, attributes|
          kits << Kit.new(attributes)
        end
      end
    end
    
    def initialize(attributes = {})
      attributes = self.class.defaults.merge(attributes)
      super
    end
  
    def info(attribute = nil)
      mass_assign(Client.get("/kits/#{@id}")['kit'])
      instance_variable_get("@#{attribute}") unless attribute.nil?
    end
    alias :reload :info
  
    def publish
      Client.post("/kits/#{kit}/publish")
    end
  end
end

# response = TypeKit::Request.new('c2891c22edfd29b4d14890a7b141cc76b262bd48').kits
# response['kits'].each do |kit|
  # p kit
# end

# p response['kits']

tk = Typekit::Client.new('c2891c22edfd29b4d14890a7b141cc76b262bd48')

# list kits
# tk.kits

# grab a kit
# tk.kit('id')
# tk.kit
