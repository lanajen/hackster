do (Backbone) ->

  _.extend Backbone.Marionette.Application::,

    navigate: (route, options = {}) ->
#      route = "#" + route if route.charAt(0) is "/"
      Backbone.history.navigate route, options

    getCurrentRoute: ->
      Backbone.history.fragment

    redirectHashBang: ->
      window.location = Backbone.history.fragment
#        window.location = window.location.hash.substring(2)
