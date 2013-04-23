@HackerIo.module "Views", (Views, App, Backbone, Marionette, $, _) ->

  _.extend Marionette.View::,

    templateHelpers: ->

      currentUser:
        App.request("get:current:user").toJSON()

      linkTo: (name, url, options = {}) ->
        _.defaults options,
          external: false
        optionsString = ''
        optionsString += "#{key}='#{val}'" for key, val of options

        "<a href='#{url}' #{optionsString}>#{name}</a>"

      imageTag: (src, options = {}) ->
        optionsString = ''
        optionsString += "#{key}='#{val}'" for key, val of options

        "<img src='#{src}' #{optionsString}>"