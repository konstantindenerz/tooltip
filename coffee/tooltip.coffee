# TODO: Create a tooltip container and fill it with data
$ ()->
  window.lab = window.lab or {}
  window.lab.ui = window.lab.ui or {}
  tooltipSelector = '.tooltip'
  tooltipContentSelector = '.tooltip-content'
  tooltipAlignAttribute = 'data-tooltip-align'
  defaultWidth = 300
  distance = 20
  alignSet = ['top', 'right', 'left', 'bottom']

  # HTML factory
  generator =
    tooltip: '<div class="tooltip"></div>'

  create = (content)->
    $parent = $ 'body'
    $tooltip = $ generator.tooltip
    $tooltip.html content
    $tooltip.appendTo $parent
    # TODO: fade in animation
    $tooltip
  hover = ()->
    $target = $ this
    $content = $target.find tooltipContentSelector
    $tooltip = create $content.html()
    layout.update $tooltip, $target
  leave = ()->
    $tooltip = $ tooltipSelector
    # TODO: fade out animation
    $tooltip.remove()

  layout =
    update: ($tooltip, $target)->
      w =
        width: window.innerWidth # window.document.body.clientWidth
        height: window.innerHeight # window.document.body.clientHeight
      client =
        width: window.document.body.clientWidth
        height: window.document.body.clientHeight
      tooltipWidth = defaultWidth
      if client.width < defaultWidth # then correct the tooltip width
        tooltipWidth = client.width
        $tooltip.width tooltipWidth
      # returns an object with two properties: width, height
      getSize = (object)->
        width:
          object.width()
        height:
          object.height()
      size =
      getAlignment = (offset, tooltipSize, targetSize, client)->
        console.log offset, tooltipSize, targetSize, client
        align = undefined
        if tooltipSize.height + distance <= offset.top
          align = 'top'
        else if tooltipSize.width + distance <= client.width - offset.left - targetSize.width
          align = 'right'
        else if tooltipSize.width + distance <= offset.left
          align = 'left'
        else if tooltipSize.height + distance <= client.height - offset.top = targetSize.height
          align = 'bottom'
        return align

      align = getAlignment $target.offset(), getSize($tooltip), getSize($target), w

      if not align and $target.is '[' + tooltipAlignAttribute + ']'
        align = $target.attr tooltipAlignAttribute

      if not align # then use the client size instead of window
        align = getAlignment $target.offset(), getSize($tooltip), getSize($target), client

      if not align # then wtf?
        console.log 'wtf'

  class Tooltip
    init: (newSelector) ->
      selector = newSelector or '[data-tooltip]'
      $targets = $ selector
      $targets.hover hover, leave
      return

  window.lab.ui.tooltip = new Tooltip()

  lab.ui.tooltip.init()
