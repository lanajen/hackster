class App.Routers.Projects extends Backbone.Marionette.AppRouter
  appRoutes:
    "projects"             : "index"
#    "projects/new"         : "newProject"
    "projects/:id"         : "show"
#    "projects/:id/edit"    : "edit"
    "projects/.*"          : "index"
