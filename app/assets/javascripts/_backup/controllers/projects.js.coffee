class App.Controllers.Projects
  constructor: ->
    @collection = new App.Collections.Projects
    main = $('#projects')
    @collection.reset(main.data('collection'))
    window.col = @collection
    main.removeData('collection')

  index: ->
    @view = new App.Views.ProjectsIndex
      collection: @collection
    App.mainRegion.show(@view)

#  newProject: ->
#    @view = new App.Views.ProjectsNewView({collection: @collection})

  show: (id) ->
    project = @collection.get(id)
    @view = new App.Views.ProjectsShow({model: project})
    App.mainRegion.show(@view)

#  edit: (id) ->
#    project = @collection.get(id)
#    @view = new App.Views.ProjectsEditView({model: project})