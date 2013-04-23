@HackerIo.module "ProjectsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Layout extends App.Views.Layout
    template: "projects/show/templates/show_layout"
    regions:
      headingRegion: "#heading"
      subnavRegion: "#subnav"
      projectRegion: "#project"

  class Show.Heading extends App.Views.ItemView
    template: "projects/show/templates/heading"
    modelEvents:
      "change" : "render"

  class Show.Subnav extends App.Views.ItemView
    template: "projects/show/templates/subnav"
    modelEvents:
      "change" : "render"

  class Show.Project extends App.Views.Layout
    template: "projects/show/templates/project"
#    modelEvents:
#      "change" : "render"
    regions:
      descriptionRegion: "#description"
      mediaRegion: "#media"
      teamRegion: "#team"

  class Show.Description extends App.Views.ItemView
    template: "projects/show/templates/description"
    modelEvents:
      "change" : "render"

  class Show.Media extends App.Views.ItemView
    template: "projects/show/templates/media"
    modelEvents:
      "change" : "render"

  class Show.TeamMember extends App.Views.ItemView
    template: "projects/show/templates/team_member"
#    modelEvents:
#      "change" : "render"
    tagName: 'li'

  class Show.Team extends App.Views.CompositeView
    template: "projects/show/templates/team"
    itemView: Show.TeamMember
    itemViewContainer: "ul"
    initialize: ->
      @reloadAll()
    modelEvents:
      "change" : "reloadAll"
    reloadAll: ->
      @collection = new App.Entities.TeamMembersCollection @model.get('team_members')
      @render()
