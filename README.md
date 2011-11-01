Typekit API Client
==================

This is a Ruby client for the [Typekit API](http://typekit.com/docs/api).

There aren't any tests as of yet. Help writing tests would be great, as would feedback on the overall architecture of the 
client. Any suggestions on how to improve it are welcome, and pull requests for improvements are more than welcome.

You can get in touch with me at `corey.atx.at.gmail.com`.

Example
-------

A quick example of how to use the client. 

    # Add FF Meta Web Pro to a Kit with Normal and Bold weights
    typekit = Typekit::Client.new(token)
    kit = typekit.kit('abcdef')
    kit.add_family(typekit.family_by_name('FF Meta Web Pro').id, :variations => ['n4', 'n7'])
    kit.publish
    
    # Change the name of a kit and add a domain
    kit.name = 'Example'
    kit.domains << 'localhost'
    kit.save
    
    # Get the web address to Droid Sans
    typekit.family_by_slug('droid-sans').web_link

Usage
-----

You'll need a Typekit account and a Typekit API token to use the Typekit API. You can generate a new token 
[here](https://typekit.com/account/tokens). You should also familiarize yourself with the 
[terminology](http://typekit.com/docs/api/terminology) that the Typekit API uses and the way [changes are published](http://typekit.com/docs/api/kits).

There are two ways you can work with the Typekit API client: directly through the class variables, or via an
instance of the `Typekit::Client` object. Either way, beware that the token you provide will be assigned to
a class variable (ie. it'll be shared across instances of Typekit::Client). This is due to the way HTTParty works.

### Install

Quick and simple...

    $ gem install typekit

Or just add the gem to your Gemfile and run `bundle install`

    gem 'typekit'


### Getting Started

    # Getting down to business...
    typekit = Typekit::Client.new(token)
  
    # Get a list of kits in your account
    kits = typekit.kits    #=> [<Typekit::Kit @id='abcdef'>, <Typekit::Kit @id='ghijkl', ...]

    # Get detailed information for a kit by ID
    kit = typekit.kit('abcdef')
    #=> <Typekit::Kit @id='abcdef', @name='Test', @analytics=false, @badge=false, @domains=['localhost'], @families=[...]>
    
    # Create a new kit with the default badge settings
    kit = typekit.create_kit(:name => 'My Kit', :domains => ['example.com', 'example.heroku.com'])  #=> <Typekit::Kit @id='abcdef', ...>
    
    # Delete a kit (where `kit` is an instance of Typekit::Kit)
    kit.delete

### Using the API without an instance of Typekit::Client

If you prefer using the class methods directly to query for kits/families, the following is identical to the above methods...

    Typekit::Client.set_token(token)
    Typekit::Kit.all             #=> [<Typekit::Kit @id='abcdef'>, <Typekit::Kit @id='ghijkl', ...]
    Typekit::Kit.find('abcdef')  #=> <Typekit::Kit @id='abcdef', @name="Test", ...>
    Typekit::Kit.create_kit(:name => 'My Kit', :domains => ['example.com', 'example.heroku.com'])

### Lazy Loaded Detailed Attributes    

Detailed information for kits gets loaded lazily when you use `Typekit::Kit.all`. This allows us to create instances
of `Typekit::Kit` without the full set of attributes and without requiring you to manually load that data.

    kits = typekits.all   #=> [...]
    kits.first            #=> <Typekit::Kit @id='abcdef'>
    kits.first.name       #=> "Test"
    kits.first            #=> <Typekit::Kit @id='abcdef', @name='Test', @analytics=false, @badge=false, @domains=['localhost'], @families=[]>

### Updating a Kit

You can make changes to a Kit by altering the attributes and calling `save`:

    kit = typekit.kit('abcdef')
    kit.name = 'Derezzed'
    kit.domains << 'localhost'
    kit.save

#### Publishing Manually

When you call `Typekit::Kit#save`, the kit is also published. If you don't want this to happen, pass `false` as the only argument. You can also manually publish a Kit after making changes.

    kit.name = 'Fashion Nugget'
    kit.save(false)
    # ... later in your application, possibly even in another request
    kit = Typekit::Client.kit('abcdef')
    kit.publish     #=> Finally, changes are published to the Typekit CDN
    
### Getting Library Information

The Typekit API allows you to both list the available libraries and view a list of families within the library. The list
of families does not include the more detailed information found in the family-specific API calls.

    # Get list of libraries
    libraries = typekit.libraries
    
    # Get list of families in a library
    families = typekit.library('full', :page => 1, :per_page => 20)

### Getting Font Family Information

The Typekit API also allows you to find detailed information about any Family in their library, including all available
validations, CSS font names, etc. **If you are not familiar with the terminology Typekit uses throughout their API, you 
really should [give it a read](http://typekit.com/docs/api/terminology) before continuing.**

    # Get a family by ID
    family = typekit.family('brwr')
    
    # Get a family by slug
    family = typekit.family_by_slug('ff-meta-web-pro')
    
    # Get a family by name (gets converted to a slug automatically)
    family = typekit.family_by_name('FF Meta Web Pro')
    
    # List variations available for a given family
    family.variations       #=> [<Typekit::Variation ...>, <Typekit::Variation ...>, ...]
    
    # Get a particular variation (details lazy-loaded)
    variation = typekit.family('brwr').variation('n4') #=> <Typekit::Variation @id="brwr:n4", @name="FF Meta Web Pro Normal">
    
    # View details about a variation
    variation.font_weight    #=> "400"
    variation.to_fvd         #=> "n4"
    variation                #=> <Typekit::Variation @id="brwr:n4", @name="FF Meta Web Pro Normal", @font_weight="400", ...>
    
**Note**: Variations, like Kits, have detailed information loaded lazily. If you would like to load data for a Variation 
without accessing an individual attribute you can simply call `Typekit::Variation#fetch`.

### Adding a Family to a Kit

You can add Families to a kit by specifying the Family ID (which can be found through the `Typekit::Family` methods) and 
which you want to have included in the Kit. These methods *make changes to the "working" copy* of your Kit. In order for them 
to take effect, **you must publish your Kit after adding/updating/removing Families**.
    
    # Add a new Family with the full character subset
    kit = typekit.kit('abcdef')
    kit.add_family('brwr', :variations => ['n4'], :subset => 'all')
    
    # Changing a Family that is already a part of a Kit
    kit.update_family('brwr') do |f|
      f['subset'] = 'default'
      f['variations'] << 'i7'
    end
    
    # Removing a Variation from a Family in your a Kit
    kit.update_family('brwr') do |f|
      f['variations'].delete_if { |v| v == 'n4' }
    end
    
    # Remove a Family from a Kit
    kit.delete_family('brwr')
    
    # Publishing your changes
    kit.publish
    
**Important Note**: Families and Variations that are a part of Kits are passed around as Hashes, not instances of `Typekit::Family` or 
`Typekit::Variation`, which are used solely browse the available Families and their details.
    
Documentation
-------------

Full documentation for the latest version can be found at [RubyDoc](http://rubydoc.info/github/coreyward/typekit).

Contributing
------------

* Fork the project
* Start a feature/bugfix branch
* Add [yard](http://yardoc.org/)-compatible documentation for your changes, where relevant. Follow the existing styles.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
---------

Copyright (c) 2011 Corey Ward. Licensed under the "MIT" license. See LICENSE.txt for
further details.

