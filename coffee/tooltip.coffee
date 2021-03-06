$ ()->
  internalReferenceId = 0 # each target should have a reference id
  window.lab = window.lab or {}
  window.lab.ui = window.lab.ui or {}
  tooltipSelector = '.lab-tooltip'
  tooltipContentSelector = '.tooltip-content'
  tooltipAlignAttribute = 'data-tooltip-align'
  distance = 25
  arrowSize = 10
  alignSet = ['top', 'right', 'left', 'bottom']
  referenceAttribute = 'data-tooltip-ref'
  getCustomSize = null
  checkTouchEvent = ()->
    result = false
    try
      document.createEvent 'TouchEvent'
      result = true
    catch
    return result

  window.isTouchDevice = checkTouchEvent()

  # HTML factory
  generator =
    tooltip: '<div class="lab-tooltip"><div class="content"></div></div>'
    arrow: '<div class="arrow"></div>'

  create = (content)->
    $parent = $ 'body'
    $tooltip = $ generator.tooltip
    $tooltip.find('.content').html content
    $tooltip.append generator.arrow
    $tooltip.appendTo $parent
    $tooltip.click leave
    $tooltip
  hover = ()->
    $target = $ this
    $content = $target.find tooltipContentSelector
    content = $content.html() or $content.text() # html() does not work in different browsers on different elements
    $tooltip = create content
    currentReferenceId = -1
    if not $target.attr referenceAttribute
      currentReferenceId = internalReferenceId++
      $target.attr referenceAttribute, currentReferenceId
    else
      currentReferenceId = $target.attr referenceAttribute
    $tooltip.attr referenceAttribute, currentReferenceId
    $tooltip.addClass $target.attr 'data-tooltip'
    layout.update $tooltip, $target
  leave = ()->
    $tooltip = $ tooltipSelector
    $tooltip.remove()

  $(window).resize leave
  if window.isTouchDevice
    $(document).bind 'touchstart', (e)->
      $tooltip = $ tooltipSelector
      currentReference = $tooltip.attr referenceAttribute
      if currentReference
        try
          $target = $ e.target
          currentTooltipReference = $target.attr referenceAttribute
          if currentReference isnt currentTooltipReference
            $tooltip.remove()
        catch
          $tooltip.remove()

  layout =
    update: ($tooltip, $target)->
      w = #indow
        width: window.innerWidth # window.document.body.clientWidth
        height: window.innerHeight # window.document.body.clientHeight
      client =
        width: window.document.body.clientWidth
        height: window.document.body.clientHeight
      tooltipWidth = $tooltip.width() + 2 * distance
      widthLimit = w.width - 2 * distance
      if widthLimit <= tooltipWidth # then correct the tooltip width
        tooltipWidth = widthLimit
        $tooltip.width tooltipWidth
      # calculate the max width to prevent overlaps
      alignDefinition = $target.attr tooltipAlignAttribute
      maxWidth = 0
      if alignDefinition
        switch alignDefinition
          when 'top'
            maxWidth = window.innerWidth - 2 * distance
          when 'right'
            maxWidth = window.innerWidth - $target.offset().left - $target.width - 2 * distance
          when 'left'
            maxWidth = $target.offset().left - 2 * distance
          when 'bottom'
            maxWidth = window.innerWidth - 2 * distance
      if maxWidth isnt 0
        $tooltip.css 'max-width', maxWidth

      # returns an object with two properties: width, height
      getSize = (object)->
        result =
          width:
            Math.max object.width(), parseInt(object.css 'width')
          height:
            Math.max object.height(), parseInt(object.css 'height')

        if result.width is 0 and result.height is 0 and typeof getCustomSize is 'function'
          result=getCustomSize object
        result

      getAlignment = (tooltipSize, targetSize, targetOffset, containerSize)->
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
      align = undefined

      if not align and $target.is '[' + tooltipAlignAttribute + ']'
        align = $target.attr tooltipAlignAttribute

      if not align
        align = getAlignment tooltipSize, targetSize, targetOffset, containerSize

      if not align # then use the client size instead of window
        containerSize = client
        align = getAlignment tooltipSize, targetSize, targetOffset, containerSize

      if not align # then wtf?
        align = 'bottom'

      calculateNewPosition = (tooltipSize, targetSize, targetOffset, containerSize)->
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
      position = calculateNewPosition tooltipSize, targetSize, targetOffset, containerSize
      $tooltip.offset position

      calculateNewArrowPosition = ()->
        position = {}
        switch align
          when 'top'
            position.left = targetOffset.left + (targetSize.width / 2)
            position.top = targetOffset.top - distance - 1 # overlap
          when 'right'
            position.left = targetOffset.left + targetSize.width + distance - arrowSize + 1 # overlap
            position.top = targetOffset.top + (targetSize.height / 2)
          when 'left'
            targetYCenter = targetOffset.top + (targetSize.height / 2)
            tooltipHalf =  tooltipSize.height / 2
            position.left = targetOffset.left - distance - 1 # overlap
            position.top = targetOffset.top + (targetSize.height / 2)
          when 'bottom'
            position.left = targetOffset.left + (targetSize.width / 2)
            position.top = targetOffset.top + targetSize.height + distance - arrowSize + 1 # overlap
        return position
      position = calculateNewArrowPosition containerSize
      $arrow = $tooltip.find('.arrow');
      for currentAlign in alignSet
        do (currentAlign)->
          $tooltip.removeClass currentAlign
          $arrow.removeClass currentAlign
      $arrow.offset position
      $arrow.addClass align
      $tooltip.addClass align
      animationEffect = 'fadeInDown'
      switch align
        when 'bottom' then animationEffect = 'fadeInUp'
        when 'left' then animationEffect = 'fadeInLeft'
        when 'right' then animationEffect = 'fadeInRight'
        else animationEffect = 'fadeInDown'
      $tooltip.addClass "animated #{animationEffect}"

  class Tooltip
    init: (newSelector, getSize) ->
      getCustomSize = getSize
      selector = newSelector or '[data-tooltip]'
      $targets = $ selector
      $targets.hover hover, leave

  window.lab.ui.tooltip = new Tooltip()
