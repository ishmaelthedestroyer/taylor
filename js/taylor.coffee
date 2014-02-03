((window, document) ->
  'use strict'

  # variables for Taylor instances
  selection = null
  selectionRange = null
  parentElements = [
    'p'
    'h1'
    'h2'
    'h3'
    'h4'
    'h5'
    'h6'
    'blockquote'
    'pre'
  ]

  # # # # # # # # # # # # # # # # # # # #
  # # # # # # # # # # # # # # # # # # # #

  # Basic Helper Functions

  extend = (one, two) ->
    # make sure valid objects
    return {} if !one
    return one if !two or typeof two isnt 'object'

    # get keys in object two
    keys = Object.keys two

    # iterate over keys, add to object one
    one[k] = two[k] for k in keys

    # return object
    return one

  saveSelection = () ->
    sel = window.getSelection()

    if sel.getRangeAt and sel.rangeCount
      ranges = []
      i = 0
      len = sel.rangeCount

      while i < len
        ranges.push sel.getRangeAt(i)
        ++i
      return ranges

    return null

  restoreSelection = (saved) ->
    sel = window.getSelection()
    if saved
      sel.removeAllRanges()
      i = 0
      len = saved.length

      while i < len
        sel.addRange saved[i]
        ++i

  getSelectionStart = () ->
    node = document.getSelection().anchorNode

    if node and node.nodeType is 3
      startNode = node.parentNode
    else
      startNode = node

    return startNode

  getSelectionHtml = () ->
    html = ''

    if window.getSelection
      sel = window.getSelection()
      if sel.rangeCount
        container = document.createElement 'div'
        i = 0
        len = sel.rangeCount

        while i < len
          container.appendChild sel.getRangeAt(i).cloneContents()
          ++i

        html = container.innerHTML
    else if document.selection
      if document.selection.type is 'Text'
        html = document.selection.createRange().htmlText

    return html

  # # # # # # # # # # # # # # # # # # # #
  # # # # # # # # # # # # # # # # # # # #

  # Utility / Private Functions

  checkSelection = () ->
    newSelection = window.getSelection()
    selectionElement = getSelectionElement()
    checkSelectionElement newSelection, selectionElement

  # # # # # # # # # #

  checkSelectionElement = (newSelection, selectionElement) ->
    selection = newSelection
    selectionRange = selection.getRangeAt 0

    return

  # # # # # # # # # #

  getSelectionElement = () ->
    selection = window.getSelection()
    range = selection.getRangeAt 0
    current = range.commonAncestorContainer
    parent = current.parentNode
    result = null

    getMediumElement = (e) ->
      parent = e
      try
        while !parent.getAttribute 'data-taylor-element'
          parent = parent.parentNode
      catch err
        return false

      return parent

    # try current node
    try
      if current.getAttribute 'data-taylor-element'
        result = current
      else
        result = getMediumElement parent
    catch err
      result = getMediumElement parent

    return result

  # # # # # # # # # #

  getSelectionData = (element) ->
    tagName = ''

    if element and element.tagName
      tagName = element.tagName.toLowerCase()

    while element and parentElements.indexOf(tagName) is -1
      element = element.parentNode
      if element and element.tagName
        tagName = element.tagName.toLowerCase()

    # return object
    element: element
    tagName: tagName

  # # # # # # # # # #

  execFormatBlock = (type) ->
    selectionData = getSelectionData selection.anchorNode

    # FF handles blockquote differently on formatBlock
    if type is 'blockquote' and selectionData.element and
    selectionData.element.parentNode.tagName.toLowerCase() is 'blockquote'
      return document.execCommand 'outdent', false, null

    if selectionData.tagName is type
      type = 'p'

    return document.execCommand 'formatBlock', false, type

  # # # # # # # # # #

  triggerAnchorAction = () ->
    if selection.anchorNode.parentNode.tagName.toLowerCase() is 'a'
      document.execCommand 'unlink', false, null
    else
      console.log 'TODO: anchors'

  # # # # # # # # # #

  # # # # # # # # # # # # # # # # # # # #
  # # # # # # # # # # # # # # # # # # # #

  # Initializiation Functions

  createElements = (obj) ->
    console.log 'Creating elements.', obj

    obj._container.className += ' taylor-editor'
    obj._container.className += ' panel'
    obj._container.className += ' panel-default'

    # # # # #

    heading = document.createElement 'div'
    heading.className = 'panel-heading'
    heading.style.height = 'auto'

    obj._container.appendChild heading

    # # # # #

    controls = document.createElement 'ul'
    controls.className = 'nav'
    controls.className += ' navbar-nav'
    controls.className += ' taylor-controls'

    heading.appendChild controls

    # # # # #

    # create buttons and insert into heading
    obj._buttons = createButtons controls, obj._options.buttons

    # clear-fix
    clear = document.createElement 'div'
    clear.style.clear = 'both'

    heading.appendChild clear

    # # # # #

    # add panel body
    body = document.createElement 'div'
    body.className = 'panel-body'
    body.style.height = 'auto'
    body.style.padding = 0
    body.style.margin = 0

    obj._container.appendChild body

    # # # # #

    editable = document.createElement 'div'
    editable.className = 'taylor-editable'
    editable.className += ' form-control'
    editable.setAttribute 'data-taylor-editable', true
    editable.style.height = '100%'
    editable.contentEditable = true

    body.appendChild editable

    # # # # #

    return obj

  # # # # # # # # # #

  createButtons = (parent, buttons) ->
    console.log 'Creating buttons.', buttons

    templates =
      bold:
        name: 'bold'
        action: 'bold'
        element: 'b'
        class: 'fa fa-bold'
        content: ''
      italic:
        name: 'italic'
        action: 'italic'
        element: 'i'
        class: 'fa fa-italic'
        content: ''
      underline:
        name: 'underline'
        action: 'underline'
        element: 'u'
        class: 'fa fa-underline'
        content: ''
      strikethrough:
        name: 'strikethrough'
        action: 'strikethrough'
        element: 'strike'
        class: 'fa fa-strikethrough'
        content: ''
      h:
        name: 'h'
        action: 'append-h1'
        content: '<b>H</b>'
        element: 'h1'
      h2:
        name: 'h2'
        action: 'append-h2'
        content: '<b>H2</b>'
        element: 'h2'
      h3:
        name: 'h3'
        action: 'append-h3'
        content: '<b>H3</b>'
        element: 'h3'
      h4:
        name: 'h4'
        action: 'append-h4'
        content: '<b>H2</b>'
        element: 'h4'
      h5:
        name: 'h5'
        action: 'append-h5'
        content: '<b>H5</b>'
        element: 'h5'
      h6:
        name: 'h6'
        action: 'append-h6'
        content: '<b>H6</b>'
        element: 'h6'
      subscript:
        name: 'subscript'
        action: 'subscript'
        element: 'sub'
        class: 'fa fa-strikethrough'
        content: ''
      blockquote:
        name: 'blockquote'
        action: 'append-blockquote'
        element: 'blockquote'
        class: 'fa fa-quote-right'
        content: ''
      unorderedlist:
        name: 'unorderedlist'
        action: 'insertunorderedlist'
        element: 'ul'
        class: 'fa fa-list-ul'
        content: ''
      orderedlist:
        name: 'orderedlist'
        action: 'insertorderedlist'
        element: 'ol'
        class: 'fa fa-list-ol'
        content: ''
      pre:
        name: 'pre'
        action: 'append-pre'
        element: 'pre'
        class: 'fa fa-code'
        content: ''
      anchor:
        name: 'anchor'
        action: 'anchor'
        element: 'a'
        class: 'fa fa-link'
        content: ''
      image:
        name: 'image'
        action: 'image'
        element: 'img'
        class: 'fa fa-picture-o'
        content: ''

    elements = []

    keys = Object.keys templates

    createButton = (template) ->
      if !(template.name in keys)
        return throw new Error 'That button type does not exist!'

      console.log 'Creating button.', template

      li = document.createElement 'li'
      parent.appendChild li

      btn = document.createElement 'button'
      btn.className = 'taylor-btn'
      btn.setAttribute 'data-taylor-btn-action', template.action
      li.appendChild btn

      span = document.createElement 'span'
      span.className = template.class
      span.innerHTML = template.content || ''
      btn.appendChild span

      template.element = btn

      return template

    elements = []

    for k in buttons
      elements.push createButton(templates[k])

    return elements

  # # # # # # # # # #

  bindButtons = (obj, buttons) ->
    for btn in buttons
      ((btn) ->
        btn.element.addEventListener 'click', (e) ->
          console.log 'Firing btn event.', btn.action

          # prevent default events
          e.preventDefault()
          e.stopPropagation()

          checkSelection() if !obj._selection

          if btn.action.indexOf('append-') > -1
            execFormatBlock btn.action.replace('append-', '')
          else if btn.action is 'anchor'
            triggerAnchorAction e
          else if btn.action is 'image'
            document.execCommand 'insertImage', false, window.getSelection()
          else
            document.execCommand btn.action, false, null

          return @
      ) btn

    return

  # # # # # # # # # #

  bindSelect = (element, delay) ->
    console.log '_bindSelect() fired.'

    timer = null

    wrapper = () ->
      console.log 'checkSelectionWrapper fired.'

      clearTimeout timer
      timer = setTimeout ->
        checkSelection()
      , delay || 0

    doc = document.documentElement
    doc.addEventListener 'mouseup', wrapper
    element.addEventListener 'keyup', wrapper
    element.addEventListener 'blur', wrapper

    return @

  # # # # # # # # # #

  initialize = (obj, options) ->
    if !obj._container
      return throw new Error 'Taylor target element does not exist!'

    defaults =
      placeholder: '...'
      anchorPlaceholder: 'Type a URL'
      buttons: [
        'bold'
        'italic'
        'underline'
        'strikethrough'
        'h'
        'orderedlist'
        'unorderedlist'
        'blockquote'
        'pre'
        'anchor'
        'image'
      ]
      targetBlank: false
      delay: 0
      sticky: false

    # extend options, override defaults
    obj._options = extend options, defaults

    console.log 'Got options.', obj._options

    # # # # #

    createElements obj
    bindButtons obj, obj._buttons || []
    bindSelect obj._container, obj._options.delay
    bindPaste obj._container

    # # # # #

    return @

  # # # # # # # # # # # # # # # # # # # #
  # # # # # # # # # # # # # # # # # # # #

  # Taylor Editor

  Taylor = (container, options) ->
    if !(@ instanceof Taylor)
      return new Taylor container, options

    # find element, bind to object
    @_container = document.getElementById container
    @_buttons = []

    # initialize
    initialize @, options || {}

    return @

  # # # # # # # # # # # # # # # # # # # #
  # # # # # # # # # # # # # # # # # # # #

  # expose to window
  window.Taylor = Taylor

) window, document