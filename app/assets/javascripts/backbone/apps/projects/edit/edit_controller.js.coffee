@HackerIo.module "ProjectsApp.Edit", (Edit, App, Backbone, Marionette, $, _) ->

  Edit.Controller =

    editProject: (id) ->
      project = App.request "project:entity", id

      @layout = @getLayoutView()

      @layout.on "show", =>
        @editHeading project
        @editSubnav project
        @editInnerProjectLayout project

      App.mainRegion.show @layout

    editHeading: (project) ->
      headingView = @getHeadingView project
      @layout.headingRegion.show headingView

    editSubnav: (project) ->
      subnavView = @getSubnavView project
      @layout.subnavRegion.show subnavView

    editDescription: (project) ->
      description = new Edit.Description
        model: project
      @projectView.descriptionRegion.show description

    editMedia: (project) ->
      media = new Edit.Media
        model: project
      @projectView.mediaRegion.show media

    editTeam: (project) ->
      team = new Edit.Team
        model: project
      @projectView.teamRegion.show team

#    editFollowers: (project) ->
#      followers = new Edit.Followers
#        model: project
#      @projectView.followersRegion.edit followers

    editInnerProjectLayout: (project) ->
      @projectView = @getProjectView project

      @projectView.on "show", =>
        @editDescription project
        @editMedia project
        @editTeam project
#        @editFollowers project

      @layout.projectRegion.show @projectView

    getProjectView: (project) ->
      new Edit.Project
        model: project

    getHeadingView: (project) ->
      new Edit.Heading
        model: project

    getSubnavView: (project) ->
      new Edit.Subnav
        model: project

    getLayoutView: ->
      new Edit.Layout