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
      def handle_response(response)
        status = response.headers['status'].to_i
        
        case status
          when 404 then raise ResourceDoesNotExistError, response
          when 400..499 then raise APIError, response
          when 500..599 then raise ServiceError, response
        end

        response.values.first if response.values.any?
      end
      
      [:get, :post, :delete].each do |http_verb|
        party_method = :"party_#{http_verb}"
        class_eval %{alias :#{party_method} #{http_verb}}
        define_method http_verb do |*args|
          handle_response send(party_method, *args)
        end
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
        Kit.create(params)
      end
    end

    class APIError < ArgumentError
      attr_reader :response
      
      def initialize(response)
        @response = response
      end
      
      def to_s
        @response['errors'].first if @response['errors'].any?
      end
    end
    
    class ResourceDoesNotExistError < APIError; end
    class ServiceError < APIError; end
  end
end
