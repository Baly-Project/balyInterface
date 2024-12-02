# Baly Digital Gallery Rails App
This folder (balyInterface/interface) contains the source code for the Baly Gallery web app. While this is the main folder in balyInterface, there are also some good tools for testing and further development in the repository. Check out the repository overview [here](../README.md). For setting up a server to run the website, use [these configuration instructions](../configuration.md). This document will contain an overview of the code structure and flow of data in the website, as well as some things to keep in mind during further development.

## Code Overview

### Models
The foundation of a rails app is the Model-View-Controller architecture (see [Rails guide](https://guides.rubyonrails.org/getting_started.html) and [wiki](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller)). This app is a bit untraditional for a rails app, in the sense that not all of the files in the app/models/ folder are part of the M-V-C system, so some models do not inherit from ApplicationRecord or do not have a representation on the website. This is to promote simplicity, so that all the custom classes and helpers are in one place instead of hidden in various subfolders. 

This unorthodox configuration is necessary because rather than store the entire Baly Collection database locally on a server, or rely completely on an API, we take a hybrid approach, where we store a 'skeleton' of the collection, collecting all of the structure and associations that Digital Kenyon doesn't actually track, but are implicit in the data. This allows us to quickly generate this structure for a site visitor, allowing them to explore the various collections of slides without calling the API (and waiting a couple seconds for a response). Then, when a slide is actually selected, we load the full data record for that image from the API, splicing this together with the stored data to give a full presentation. Since we only ever call the API on a single record, it is quicker than if we called it for the full collection, and since we store as little and possible on our own host server, it will stay small even as the full collection is uploaded, around 17,000 items. 

This gives us the division below, between the 'standard' models for the  structure and display from the database, the 'invisible' models responsible for generating that database, and the special Slide model, that works as an intermediate stage between the API and the local structure, being used both in generating the structure and in displaying a full record to the user.

With that overview in mind, lets begin with the standard models.
These are
- city.rb
- collection.rb
- country.rb
- keyword.rb
- location.rb
- month.rb
- preview.rb
- region.rb
- stamp.rb
- year.rb

These models form the structure mentioned above and represent the various groups of slides by shared information (like place,date, etc.). They all have corresponding controllers in the [app/controllers/](/interface/app/controllers/) folder, and most of them have independent views in the app/views folder, although some are combined (months are never displayed alone, only as part of their year). Most importantly, they each have a table in the database that stores and indexes all of the associated data we need to know about them. As far as the model files themselves, they contain some information on the model's relationship to the other models (has_many, belongs_to tags) as well as a few methods that relate directly to their display. These methods are exclusively called in the associated controllers and views to each model. Detailed information about each of these models and their methods can be found in the comments of the files themselves.

Next, we will cover the 'invisible' models, which are
- [api_handler.rb](/interface/app/models/api_handler.rb)
- [custom_pattern.rb](/interface/app/models/custom_pattern.rb)
- [enhanced_date.rb](/interface/app/models/enhanced_date.rb)
- [enhanced_time.rb](/interface/app/models/api_handler.rb)
- [flexdate.rb](/interface/app/models/flexdate.rb)
- [print_logger.rb](/interface/app/models/print_logger.rb)
- [range_parser.rb](/interface/app/models/range_parser.rb)
- [safe_deleter.rb](/interface/app/models/safe_deleter.rb)
- [updater.rb]

These models all contribute some aspect to building the structure, which we will refer to as the 'update process', when the structure is synced with the new data available on Digital Kenyon. The main algorithm of the update process is contained in updater.rb, while the rest of the classes contribute important functionality or extend key classes to make this update process as simple as possible. Detailed information about each can be found in the comments of the files, except for updater.rb, which will be covered in full later on.

Finally, we have the Slide class, contained in slide.rb. Essentialy this is  the ruby implementation of the records stored on Digital Kenyon, and actually inherits a built-in ruby class called OpenStruct, which allows us to load Slide objects directly from the JSON that is generated by the API. This makes it the most complicated 'visible' model by far, due to the significant amount of reformatting between the API output and the end view. For the main slide view, contained in [app/views/slides/show.html.erb](/interface/app/views/slides/show.html.erb) the Slide class works together with the Preview class, where the Slide class serves and formats detailed information like descriptions and location data, while the Preview class provides the data of how that slide fits into the larger structure. 

### Javascript
Contained in app/javascript, the following files carefully control the presentation and interaction of each page. Note that **all** the javascript is sent to each visitor to the webpage, so concision is especially important. (On this note, if add_jquery.js is still included, then it is an open problem to de-jquerify the rest of the javascript. It has been used sparingly so far, but was deemed essential due for the slide effect when expanding tabs on the slide page. Jquery takes an enormous amount of space, and this would likely improve the initial load time of the website significantly). 

The javascript is separated into controllers and add-ons, with [application.js](/interface/app/javascript/application.js) being the file that is ultimately sent to the user (although in practice it imports all its code from the other files in the javascript/ folder).

In addition to application.js, we also have the controllers/ folder, add_jquery.js, and rotated_marker.js. The controllers are the main instrument for managing code. Called Stimulus Controllers, they watch for keywords in the HTML to control specific elements and listen for certain events. This makes them easy to duplicate around the site, for example the orient_controller, which is used on every slide thumbnail to make sure it is sized correctly for its orientation. Detailed information on each controller is in the comments. The two files outside this folder are external add-ins, each providing a specific and necessary function to the controllers. 

Note that while controllers are perfect for making repeatable widgets, certain functionality, especially if it is restricted to a specific view, is better placed inline in the bottom of the html.erb file, and called directly.

**Important:** Before changes to javascript take effect, you need to run 
```rb
rails assets:precompile
```
in the terminal (in the interface folder or a subdirectory).

### Assets
The assets are for everything else that might need to get sent to the user for rendering, such as images, fonts, and most importantly, stylesheets. The stylesheets, contained in app/assets/stylesheets/ work much the same as the javascript, and loosely correspond to a specific view. However this division into files is only simulated for development, and just like javascript are assembled into a single file before being sent to a web visitor. Therefore we have 
- ```application.bootstrap.scss``` controlling the assembly of stylesheets into a single file.
- ```fixedpages.scss``` controlling the styling of views in app/views/pages/, that is the homepage, timeline, and about pages.
- ```mobile.scss``` adding special styles to make it display well on small screens.
- ```navbar.scss``` controlling the navbar contained in app/views/layouts/application.html.erb.
