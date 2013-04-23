@HackerIo.module "ProjectsApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Layout extends App.Views.Layout
    template: "projects/list/templates/list_layout"

    regions:
      panelRegion: "#panel-region"
      projectsRegion: "#projects-region"

  class List.Panel extends App.Views.ItemView
    template: "projects/list/templates/_panel"

  class List.Project extends App.Views.ItemView
    template: "projects/list/templates/_project"
    tagName: "tr"

  class List.Empty extends App.Views.ItemView
    template: "projects/list/templates/_empty"
    tagName: "tr"

  class List.Projects extends App.Views.CompositeView
    template: "projects/list/templates/_projects"
    itemView: List.Project
    emptyView: List.Empty
    itemViewContainer: "tbody"