@HackerIo.module "ProjectsApp.List", (List, App, Backbone, Marionette, $, _) ->

  List.Controller =

    listProjects: ->
      projects = App.request "project:entities"

      @layout = @getLayoutView()

      @layout.on "show", =>
        @showPanel projects
        @showProjects projects

      App.mainRegion.show @layout

    showPanel: (projects) ->
      panelView = @getPanelView projects
      @layout.panelRegion.show panelView

    showProjects: (projects) ->
      projectsView = @getProjectsView projects
      @layout.projectsRegion.show projectsView

    getProjectsView: (projects) ->
      new List.Projects
        collection: projects

    getPanelView: (projects) ->
      new List.Panel
        collection: projects

    getLayoutView: ->
      new List.Layout