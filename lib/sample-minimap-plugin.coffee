SampleMinimapPluginView = require './sample-minimap-plugin-view'

module.exports =
  active: false
  views: {}

  isActive: -> @active

  activate: (state) ->
    minimapPackage = atom.packages.getLoadedPackage('minimap')
    return @deactivate() unless minimapPackage?

    @minimap = require minimapPackage.path
    return @deactivate() unless @minimap.versionMatch('3.x')

    @minimap.registerPlugin 'sample-minimap-plugin', this

  deactivate: ->
    @minimap.unregisterPlugin 'sample-minimap-plugin'
    @minimap = null

  activatePlugin: ->
    return if @active

    @active = true

    @subscription = @minimap.eachMinimapView ({view}) =>
      pluginView = new SampleMinimapPluginView(view)
      @views[view.editor.id] = pluginView

      pluginView.attach()

      view.editor.once 'destroyed', =>
        pluginView.destroy()
        delete @views[view.editor.id]

  deactivatePlugin: ->
    return unless @active

    @active = false
    @destroyViews()
    @subscription.off()

  destroyViews: ->
    view.destroy() for id,view of @views
    @views = {}
