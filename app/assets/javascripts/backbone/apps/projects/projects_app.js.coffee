@HackerIo.module "ProjectsApp", (ProjectsApp, App, Backbone, Marionette, $, _) ->

  class ProjectsApp.Router extends Marionette.AppRouter
    appRoutes:
      "projects" : "listProjects"
      "projects/:id" : "showProject"
      "projects/:id/edit" : "editProject"

  API =
    listProjects: ->
      ProjectsApp.List.Controller.listProjects()
    showProject: (id) ->
      ProjectsApp.Show.Controller.showProject(id)
    editProject: (id) ->
      ProjectsApp.Edit.Controller.editProject(id)

  App.addInitializer ->
    new ProjectsApp.Router
      controller: API