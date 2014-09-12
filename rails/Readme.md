Client-side-encryption
==========
Sample code for client-side encryption using Ruby on Rails

 * Copy/paste the index.html.haml view and the controller in their regular respective directory
 * Setup routes for the payments controler with at least to actions : index (which serves the form) and create (that handles the form POST)
 * Fill in your own credentials in the controller
 * Browse to /payments

A few notes
---

You will need to install HTTParty to perform the API request :

    gem 'httparty'
    
Then bundle install, as usual.


This code is pure demo purpose. You could/should implement a Service or a Model to fully handle the API calls and responses in a clean, modular and maintainable way.