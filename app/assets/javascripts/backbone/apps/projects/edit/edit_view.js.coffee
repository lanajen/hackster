@HackerIo.module "ProjectsApp.Edit", (Edit, App, Backbone, Marionette, $, _) ->

  class Edit.Layout extends App.Views.Layout
    template: "projects/edit/templates/edit_layout"
    regions:
      headingRegion: "#heading"
      subnavRegion: "#subnav"
      projectRegion: "#project"

  class Edit.Heading extends App.Views.ItemView
    template: "projects/edit/templates/heading"
    modelEvents:
      "change" : "render"
    events:
      "click a.btn-save": "save"
    save: (e) ->
      e.preventDefault()
      @model.set({ name: $('[name="project[name]"]').val()})
      @model.save()
      App.navigate(Routes.project_path(@model.id))
      App.ProjectsApp.Show.Controller.showProject(@model.id)
      false

  class Edit.Subnav extends App.Views.ItemView
    template: "projects/edit/templates/subnav"
    modelEvents:
      "change" : "render"

  class Edit.Project extends App.Views.Layout
    template: "projects/edit/templates/project"
#    modelEvents:
#      "change" : "render"
    regions:
      descriptionRegion: "#description"
      mediaRegion: "#media"
      teamRegion: "#team"

  class Edit.Description extends App.Views.ItemView
    template: "projects/edit/templates/description"
    modelEvents:
      "change" : "render"

  class Edit.Media extends App.Views.ItemView
    template: "projects/edit/templates/media"
    modelEvents:
      "change" : "render"

  class Edit.TeamMember extends App.Views.ItemView
    template: "projects/edit/templates/team_member"
#    modelEvents:
#      "change" : "render"
    tagName: 'li'

  class Edit.Team extends App.Views.CompositeView
    template: "projects/edit/templates/team"
    itemView: Edit.TeamMember
    itemViewContainer: "ul"
    initialize: ->
      @reloadAll()
    modelEvents:
      "change" : "reloadAll"
    reloadAll: ->
      @collection = new App.Entities.TeamMembersCollection @model.get('team_members')
      @render()
