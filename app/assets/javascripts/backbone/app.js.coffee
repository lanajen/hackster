@HackerIo = do (Backbone, Marionette) ->

  App = new Marionette.Application

  App.rootRoute = Routes.projects_path()

  App.on "initialize:before", (options) ->
    @currentUser = App.request "set:current:user", options.currentUser

  App.reqres.addHandler "get:current:user", ->
    App.currentUser

  App.addRegions
    headerRegion: "#header"
    mainRegion: "#main"
    footerRegion: "#footer"

  App.addInitializer ->
#    App.module("HeaderApp").start()
#    App.module("FooterApp").start()

  App.on "initialize:after", (options) ->
    if Backbone.history
      Backbone.history.start({ pushState: true })
#      @navigate(@rootRoute, trigger: true) if @getCurrentRoute() is ""

  App

# DOM is ready, are we routing a #!?
$ ->
  if window.location.hash.indexOf('!') > -1
    return @HackerIo.redirectHashBang()
  # else... continue on with initialization

$(document).ready ->
  window.HackerIo.start({ currentUser: window.gon.currentUser })

# Globally capture clicks. If they are internal and not in the pass
# through list, route them through Backbone's navigate method.
$(document).on "click", "a[href^='/']", (event) ->

  href = $(event.currentTarget).attr('href')

  # chain 'or's for other black list routes
  passThrough = href.indexOf('sign_out') >= 0

  # Allow shift+click for new tabs, etc.
  if !passThrough && !event.altKey && !event.ctrlKey && !event.metaKey && !event.shiftKey
    event.preventDefault()

    # Remove leading slashes and hash bangs (backward compatibility)
    url = href.replace(/^\//,'').replace('\#\!\/','')

    # Instruct Backbone to trigger routing events
    window.HackerIo.navigate url, { trigger: true }

    false