@HackerIo.module "ProjectsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  Show.Controller =

    showProject: (id) ->
      project = App.request "project:entity", id

      @layout = @getLayoutView()

      @layout.on "show", =>
        @showHeading project
        @showSubnav project
        @showInnerProjectLayout project

      App.mainRegion.show @layout

    showHeading: (project) ->
      headingView = @getHeadingView project
      @layout.headingRegion.show headingView

    showSubnav: (project) ->
      subnavView = @getSubnavView project
      @layout.subnavRegion.show subnavView

    showDescription: (project) ->
      description = new Show.Description
        model: project
      @projectView.descriptionRegion.show description

    showMedia: (project) ->
      media = new Show.Media
        model: project
      @projectView.mediaRegion.show media

    showTeam: (project) ->
      team = new Show.Team
        model: project
      @projectView.teamRegion.show team

#    showFollowers: (project) ->
#      followers = new Show.Followers
#        model: project
#      @projectView.followersRegion.show followers

    showInnerProjectLayout: (project) ->
      @projectView = @getProjectView project

      @projectView.on "show", =>
        @showDescription project
        @showMedia project
        @showTeam project
#        @showFollowers project

      @layout.projectRegion.show @projectView

    getProjectView: (project) ->
      new Show.Project
        model: project

    getHeadingView: (project) ->
      new Show.Heading
        model: project

    getSubnavView: (project) ->
      new Show.Subnav
        model: project

    getLayoutView: ->
      new Show.Layout