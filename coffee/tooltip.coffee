# TODO: Create a tooltip container and fill it with data
$ ()->
  window.lab = window.lab or {}
  window.lab.ui = window.lab.ui or {}
  tooltipSelector = '.tooltip'
  tooltipContentSelector = '.tooltip-content'
  # HTML factory
  generator =
    tooltip: '<div class="tooltip"></div>'

  create = (content)->
    $parent = $ 'body'
    $tooltip = $ generator.tooltip
    $tooltip.html content
    $tooltip.appendTo $parent
    # TODO: fade in animation
  hover = ()->
    $target = $ this
    $content = $target.find tooltipContentSelector
    create $content.html()
  leave = ()->
    $tooltip = $ tooltipSelector
    # TODO: fade out animation
    $tooltip.remove()


  class Tooltip
    init: (newSelector) ->
      selector = newSelector or '[data-tooltip]'
      $targets = $ selector
      $targets.hover hover, leave
      return

  window.lab.ui.tooltip = new Tooltip()

  lab.ui.tooltip.init()

  $tooltip = $ '.tooltip'
  defaultWidth = 300
  tooltipWidth = defaultWidth
  clientWidth = window.document.body.clientWidth
  clientHeight = window.document.body.clientHeight

  if clientWidth < defaultWidth # then correct the tooltip width
    tooltipWidth = clientWidth
    $tooltip.width tooltipWidth

  # returns an object with two properties: width, height
  getSize = (object)->
    width:
      object.width()
    height:
      object.height()

  size = getSize $tooltip
