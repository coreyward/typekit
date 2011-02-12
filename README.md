Typekit API Client
==================

This is a Ruby client for the [Typekit API](http://typekit.com/docs/api). **It is still in development**. Feel free to help out, 
or just watch the project and check it out when it gets closer to completion. Any tips/pointers are much appreciated.

You can get in touch with me at `corey.atx.at.gmail.com`.

Usage
-----

You'll need a Typekit account and a Typekit API token to use the Typekit API. You can generate a new token [here](https://typekit.com/account/tokens).

There are two ways you can work with the Typekit API client: directly through the class variables, or via an
instance of the `Typekit::Client` object. Either way, beware that the token you provide will be assigned to
a class variable (ie. it'll be shared across instances of Typekit::Client). This is due to the way HTTParty works.

    # Getting down to business...let's use an instance of Typekit::Client
    typekit = Typekit::Client.new(token)
  
    # Get a list of kits in your account
    kits = typekit.kits    #=> [<Typekit::Kit @id='abcdef'>, <Typekit::Kit @id='ghijkl', ...]
  
    # Get detailed information for a kit by ID
    typekit.kit('abcdef')
    #=> <Typekit::Kit @id='abcdef', @name='Test', @analytics=false, @badge=false, @domains=['localhost'], @families=[...]>
      
    # If you prefer using the class methods directly, the following is identical to the above...
    Typekit::Client.set_token(token)
    Typekit::Kit.all             #=> [<Typekit::Kit @id='abcdef'>, <Typekit::Kit @id='ghijkl', ...]
    Typekit::Kit.find('abcdef')  #=> <Typekit::Kit @id='abcdef', @name="Test", ...>
    
    
Detailed information for kits gets loaded lazily when you use `Typekit::Kit.all`. This allows us to create instances
of `Typekit::Kit` without the full set of attributes and without requiring you to manually load that data.

    kits = typekits.all   #=> [...]
    kits.first            #=> <Typekit::Kit @id='abcdef'>
    kits.first.name       #=> "Test"
    kits.first            #=> <Typekit::Kit @id='abcdef', @name='Test', @analytics=false, @badge=false, @domains=['localhost'], @families=[]>
    
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

