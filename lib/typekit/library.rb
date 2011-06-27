module Typekit
  class Library
    include MassAssignment
    attr_accessor :id, :name
    #Typekit::Library.new isn't expected usage
    private :initialize
    
    class << self 
      # Gets a list of all the Typekit libraries
      def all
        Client.get('/libraries').inject([]) do |libraries, attributes|
          libraries << Library.new(attributes)
        end
      end
      # Gets the families listed in a library
      # @param params [Hash] Pagination variables
      def find(id, params)
        library = Client.get("/libraries/#{id}", :query => { :page => params['page'], :per_page => params['per_page'] } )
        library['families'].inject([]) do |families, attributes|
          families << Family.new(attributes)
        end
      end
    end
  end
end