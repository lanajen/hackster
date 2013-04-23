@HackerIo.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.TeamMember extends Entities.Model

  class Entities.TeamMembersCollection extends Entities.Collection
    model: Entities.TeamMember