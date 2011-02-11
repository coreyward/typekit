module Typekit
  class Client < Typekit::Base
    include HTTParty
    base_uri 'https://typekit.com/api/v1/json'
    # debug_output
  
    def initialize(token)
      self.class.headers 'X-Typekit-Token' => token
    end
    
    def method_missing(method, *args, &block)
      super unless self.class.respond_to? method
      self.class.class_eval do 
        define_method method do |*args, &block|
          self.class.send(method, *args, &block)
        end
      end
      self.class.send(method, *args, &block)
    end
    
    class << self
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
        Kit.create(params)
      end      
    end
    
  end
end
