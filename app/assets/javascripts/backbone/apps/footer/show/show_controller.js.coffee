@HackerIo.module "FooterApp.Show", (Show, App, Backbone, Marionette, $, _) ->
  
  Show.Controller =
    
    showFooter: ->
      # currentUser = App.request "get:current:user"
      footerView = @getFooterView()
      App.footerRegion.show footerView
    
    getFooterView: ->
      new Show.Footer