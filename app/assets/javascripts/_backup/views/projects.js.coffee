class App.Views.ProjectsView extends Backbone.Marionette.ItemView
  tagName: 'li'
  template: JST['projects/project']
  events:
    "click .destroy" : "destroy"
  destroy: () ->
    @model.destroy()

class App.Views.ProjectsIndex extends Backbone.Marionette.CompositeView
  itemView: App.Views.ProjectsView
  template: JST['projects/index']
  appendHtml: (collectionView, itemView) ->
    collectionView.$('.projects').append(itemView.el)

class App.Views.ProjectsShow extends Backbone.Marionette.ItemView
  template: JST['projects/show']
#  el: '#projects'