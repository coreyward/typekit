module Typekit
  class Family
    include MassAssignment
    attr_accessor :id, :name, :slug, :web_link, :foundry, :variations, :libraries
    # @todo Handle variations appropriately
    
    class << self
      # Retrieve a specific Family
      # @param id [String] The Typekit Family id (e.g. 'brwr' or 'gkmg')
      def find(id)
        Family.new Client.get("/families/#{id}")
      end
      
      # Retrieve a Family by Typekit slug
      # @param slug [String] The Typekit Family slug for the font family (e.g. 'ff-meta-web-pro' or 'droid-sans')
      # @todo Add error handling
      def find_by_slug(slug)
        find(Client.get("/families/#{slug}")['id'])
      end
      
      # Retrieve a Family by font family name
      # @param name [String] The name of the font family without variation (e.g. 'FF Meta Web Pro' or 'Droid Sans')
      def find_by_name(name)
        find_by_slug name.downcase.gsub(/[^a-z]+/, '-')
      end
    end
  end
end
