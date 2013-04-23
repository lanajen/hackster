@HackerIo.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Project extends Entities.Model
    url: -> Routes.project_path(@id)
    schema: {
      name:         { type: 'Text', validators: ['required', 'name'] },
      description:  'Text',
      start_date:   { type: 'Date', validators: ['required', 'start_date'] },
      end_date:     'Date',
      team_members: { type: 'NestedModel', model: Entities.TeamMember }
    }

  class Entities.ProjectsCollection extends Entities.Collection
    model: Entities.Project
    url: -> Routes.projects_path()

  API =
    getProjectEntities: ->
      projects = new Entities.ProjectsCollection
      projects.fetch()
      projects

    getProjectEntity: (id) ->
      project = new Entities.Project
      project.id = id
      project.fetch()
      project

  App.reqres.addHandler "project:entities", ->
    API.getProjectEntities()

  App.reqres.addHandler "project:entity", (id) ->
    API.getProjectEntity(id)