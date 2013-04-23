#window.App =
#  Models: {}
#  Collections: {}
#  Views: {}
#  Controllers: {}
#  redirectHashBang: ->
#    window.location = window.location.hash.substring(2)
#  Routers: {}
#  initialize: ->
#    console.log('Backbone init')
#    App.start()
@App = new Backbone.Marionette.Application

App.module 'Models'
App.module 'Collections'
App.module 'Views'
App.module 'Controllers'
App.module 'Routers'
App.redirectHashBang = ->
    window.location = window.location.hash.substring(2)


App.addInitializer ->
  App.addRegions(mainRegion: '#projects')
  controller = new App.Controllers.Projects
  window.router = new App.Routers.Projects(controller: controller)
  Backbone.history.start({ pushState: true })

# DOM is ready, are we routing a #!?
$ ->
  if window.location.hash.indexOf('!') > -1
    return App.redirectHashBang()
  # else... continue on with initialization

$(document).ready ->
  App.start()

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
    window.router.navigate url, { trigger: true }

    false