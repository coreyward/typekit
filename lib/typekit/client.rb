module Typekit
  class Client
    include HTTParty
    base_uri 'https://typekit.com/api/v1/json'

    # @param token [String] Your Typekit API token
    def initialize(token)
      set_token token
    end

    # Rather than making laborious calls to `Typekit::Client.kits` you can create an instance
    # of the {Typekit::Client} and call methods on it. Instance methods will be defined for 
    # class methods on their first utilization.
    # @example
    #   typekit = Typekit::Client.new('your token here')
    #   typekit.kits    #=> [...]
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
      # Handle responses from HTTParty calls to the Typekit API with
      # some generic response interpretation and manipulation. 
      # @todo Add individual errors for various HTTP Status codes
      def handle_response(response)
        status = response.headers['status'].to_i
        
        case status
          when 404 then raise ResourceDoesNotExistError, response
          when 400..499 then raise APIError, response
          when 500..599 then raise ServiceError, response
        end

        response.values.first if response.values.any?
      end
      private :handle_response
      
      # Handle all HTTParty responses with some error handling so that our
      # individual methods don't have to worry about it at all (although they)
      # can (and should where relevant) rescue from errors when they are able to.
      [:get, :head, :post, :put, :delete].each do |http_verb|
        define_method http_verb do |*args|
          handle_response super(*args)
        end
      end
      
      # Set the Typekit API token to be used for subsequent calls.
      # @note This is set to a class variable, so all instances of Typekit::Client
      #   will use the same API token. This is due to the way HTTParty works.
      # @param token [String] Your Typekit API token
      # @todo Work around the class variable limitation of HTTParty to allow use of 
      #   the API with multiple tokens.
      def set_token(token)
        headers 'X-Typekit-Token' => token
      end
      
      # List kits available for this account
      # @see Typekit::Kit.all
      def kits
        Kit.all
      end

      # Retrieve a specific kit
      # @see Typekit::Kit.find
      def kit(id)
        Kit.find id
      end
      
      # Create a new kit
      # @see Typekit::Kit.create
      def create_kit(params)
        Kit.create(params)
      end
      
      # Lists available libraries
      # @see Typekit::Library.all
      def libraries
        Library.all
      end
      
      # Retrieve a specific library
      # @see Typekit::Library.find
      def library(id, params = {})
        Library.find(id, params)
      end
      
      # Retrieve a specific Family
      # @see Typekit::Family.find
      # @param id [String] The Typekit Family id (e.g. 'brwr' or 'gkmg')
      def family(id)
        Family.find(id)
      end
      
      # Retrieve a Family by Typekit slug
      # @see Typekit::Family.find_by_slug
      # @param slug [String] The Typekit Family slug for the font family (e.g. 'ff-meta-web-pro' or 'droid-sans')
      def family_by_slug(slug)
        Family.find_by_slug(slug)
      end
      
      # Retrieve a Family by font family name
      # @see Typekit::Family.find_by_name
      # @param name [String] The name of the font family without variation (e.g. 'FF Meta Web Pro' or 'Droid Sans')
      def family_by_name(name)
        Family.find_by_name(name)
      end
    end

    # @todo Put this somewhere better than Typekit::Client
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
