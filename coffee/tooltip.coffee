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
    tooltip: '<div class="tooltip"><div class="content"></div></div>'

  create = (content)->
    $parent = $ 'body'
    $tooltip = $ generator.tooltip
    $tooltip.find('.content').html content
    $tooltip.appendTo $parent
    $tooltip.click leave
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
      w = #indow
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
      getAlignment = (tooltipSize, targetSize, targetOffset, containerSize)->
        console.log tooltipSize, targetSize, targetOffset, containerSize
        align = undefined
        if tooltipSize.height + distance <= targetOffset.top
          align = 'top'
        else if tooltipSize.width + distance <= containerSize.width - targetOffset.left - targetSize.width
          align = 'right'
        else if tooltipSize.width + distance <= targetOffset.left
          align = 'left'
        else if tooltipSize.height + distance <= containerSize.height - targetOffset.top - targetSize.height
          align = 'bottom'
        return align

      containerSize = w # that should be used to position the tooltip
      tooltipSize = getSize $tooltip
      targetSize = getSize $target
      targetOffset = $target.offset()
      align = getAlignment tooltipSize, targetSize, targetOffset, containerSize

      if not align and $target.is '[' + tooltipAlignAttribute + ']'
        align = $target.attr tooltipAlignAttribute

      if not align # then use the client size instead of window
        containerSize = client
        align = getAlignment tooltipSize, targetSize, targetOffset, containerSize

      if not align # then wtf?
        align = 'bottom'

      calculateNewPosition = ()->
        position = {}
        switch align
          when 'top'
            targetXCenter = targetOffset.left + (targetSize.width / 2)
            tooltipHalf =  tooltipSize.width / 2
            position.left = Math.max distance, Math.min(containerSize.width - distance - tooltipSize.width, targetXCenter - tooltipHalf)
            position.top = targetOffset.top - tooltipSize.height - distance
          when 'right'
            targetYCenter = targetOffset.top + (targetSize.height / 2)
            tooltipHalf =  tooltipSize.height / 2
            position.left = targetOffset.left + targetSize.width + distance
            position.top = Math.max distance, targetYCenter - tooltipHalf
          when 'left'
            targetYCenter = targetOffset.top + (targetSize.height / 2)
            tooltipHalf =  tooltipSize.height / 2
            position.left = targetOffset.left - distance - tooltipSize.width
            position.top = Math.max distance, targetYCenter - tooltipHalf
          when 'bottom'
            targetXCenter = targetOffset.left + (targetSize.width / 2)
            tooltipHalf =  tooltipSize.width / 2
            position.left = Math.max distance, Math.min(containerSize.width - distance - tooltipSize.width, targetXCenter - tooltipHalf)
            position.top = targetOffset.top + targetSize.height + distance
        return position
      position = calculateNewPosition containerSize
      $tooltip.offset position
      console.log position

  class Tooltip
    init: (newSelector) ->
      selector = newSelector or '[data-tooltip]'
      $targets = $ selector
      $targets.hover hover, leave
      return

  window.lab.ui.tooltip = new Tooltip()

  lab.ui.tooltip.init()
