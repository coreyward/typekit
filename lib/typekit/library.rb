module Typekit
  class Library
    include MassAssignment
    attr_accessor :id, :name
    # Typekit::Library.new isn't expected usage
    private :initialize
    
    class << self 
      # Gets a list of all the Typekit libraries
      def all
        Client.get('/libraries').inject([]) do |libraries, attributes|
          libraries << Library.new(attributes)
        end
      end
      
      # Gets a paginated list of families available in the specified library
      # @option params [Fixnum] :page (1) Page number to retrieve
      # @option params [Fixnum] :per_page (20) Number of results to fetch per page
      # @return [Array] Array of Typekit::Family objects available in the specified library
      def find(id, params = {})
        { :page => 1, :per_page => 20 }.merge!(params)
        library = Client.get("/libraries/#{id}", :query => params)
        library['families'].inject([]) do |families, attributes|
          families << Family.new(attributes)
        end
      end
    end
  end
end