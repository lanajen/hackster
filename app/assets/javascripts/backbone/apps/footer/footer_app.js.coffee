@HackerIo.module "FooterApp", (FooterApp, App, Backbone, Marionette, $, _) ->
  @startWithParent = false
  
  API =
    showFooter: ->
      FooterApp.Show.Controller.showFooter()
  
  FooterApp.on "start", ->
    API.showFooter()