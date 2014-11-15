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

  trim = (text) ->
    return text.replace /^\s+|\s+$/g, ""

  nl2br = (str) ->
    return str.replace /\n/g, '<br />'

  br2nl = (str) ->
    return str.replace /<br\s*\/?>/mg, '\n'

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

  # # # # # # # # # #

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

  # # # # # # # # # #

  restoreSelection = (saved) ->
    sel = window.getSelection()
    if saved
      sel.removeAllRanges()
      i = 0
      len = saved.length

      while i < len
        sel.addRange saved[i]
        ++i

  # # # # # # # # # #

  getSelectionStart = () ->
    node = document.getSelection().anchorNode

    if node and node.nodeType is 3
      startNode = node.parentNode
    else
      startNode = node

    return startNode

  # # # # # # # # # #

  getSelectionText = () ->
    text = ""
    if window.getSelection
      text = window.getSelection().toString()
    else
      if document.selection and document.selection.type isnt "Control"
        text = document.selection.createRange().text
    return text

  # # # # # # # # # #

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

  # # # # # # # # # #

  setSelectedRange = (element, start, end) ->
    # set focus on element
    element.focus()

    if element.setSelectionRange
      element.setSelectionRange start, end
    else
      if element.createTextRange
        normalizedVal = element.value.replace /\r\n/g, "\n"

        start -= normalizedVal.slice(0, start).split("\n").length - 1
        end -= normalizedVal.slice(0, end).split("\n").length - 1

        range = element.createTextRange()
        range.collapse true
        range.moveEnd 'character', end
        range.moveStart 'character', start
        range.select()

  # # # # # # # # # #

  isListItemChild = (node) ->
    parentNode = node.parentNode
    tagName = parentNode.tagName.toLowerCase()

    while parentElements.indexOf(tagName) is -1 and tagName isnt 'div'
      return true if tagName is 'li'

      parentNode = parentNode.parentNode
      if parentNode and parentNode.tagName
        tagName = parentNode.tagName.toLowerCase()
      else
        return false

    return false

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
    if type is 'blockquote' and selectionData.element and selectionData.element.parentNode.tagName.toLowerCase() is 'blockquote'
      return document.execCommand 'outdent', false, null

    if selectionData.tagName is type
      type = 'p'

    return document.execCommand 'formatBlock', false, type

  # # # # # # # # # #

  triggerAnchorAction = (targetBlank) ->
    if selection.anchorNode.parentNode.tagName.toLowerCase() is 'a'
      document.execCommand 'unlink', false, null
    else
      document.execCommand 'createLink', false, getSelectionText()
      setTargetBlank() if targetBlank

  # # # # # # # # # #

  setTargetBlank = () ->
    element = getSelectionStart()

    if element.tagName.toLowerCase() is "a"
      element.target = "_blank"
    else
      element = element.getElementsByTagName 'a'
      i = 0
      while i < element.length
        element[i].target = "_blank"
        ++i

  # # # # # # # # # #

  # # # # # # # # # # # # # # # # # # # #
  # # # # # # # # # # # # # # # # # # # #

  # Initializiation Functions

  createElements = (obj) ->
    obj._container.className += ' taylor-editor'
    obj._container.className += ' panel'
    obj._container.className += ' panel-default'
    obj._container.style.width = obj._options.width

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

    tools = document.createElement 'ul'
    tools.className = 'nav'
    tools.className += ' navbar-nav'
    tools.className += ' navbar-right'
    tools.className += ' taylor-tools'

    heading.appendChild tools

    # # # # #

    # create buttons and insert into heading
    obj._buttons = createButtons controls, obj._options.buttons

    # create tools and insert into heading
    obj._tools = createTools tools, obj._options.tools

    # clear-fix
    clear = document.createElement 'div'
    clear.style.clear = 'both'

    heading.appendChild clear

    # # # # #

    ###
    # add panel body
    body = document.createElement 'div'
    body.className = 'panel-body'
    body.className += ' taylor-body'
    body.style.height = obj._options.height
    body.style.padding = 0
    body.style.margin = 0

    obj._container.appendChild body

    # # # # #

    editable = document.createElement 'div'
    editable.className = 'taylor-editable'
    editable.className += ' form-control'
    editable.setAttribute 'data-taylor-editable', true
    editable.contentEditable = true
    editable.innerHTML = obj._HTML
    editable.style.height = 'auto'

    body.appendChild editable
    ###

    # # # # #

    # add panel body
    body = obj._editable = document.createElement 'div'
    body.className = 'panel-body'
    body.className += ' form-control'
    body.className += ' taylor-editable'
    body.setAttribute 'data-taylor-editable', true
    body.style.height = obj._options.height
    body.contentEditable = true
    body.innerHTML = obj._HTML

    obj._container.appendChild body

    # # # # #

    # add panel body
    textarea = obj._editable = document.createElement 'textarea'
    textarea.className = 'textarea'
    textarea.className += ' form-control'
    textarea.className += ' taylor-textarea'
    textarea.style.height = obj._options.height
    textarea.style.display = 'none'

    obj._container.appendChild textarea

    # # # # #

    return obj

  # # # # # # # # # #

  createButtons = (parent, buttons) ->
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

      li = document.createElement 'li'
      parent.appendChild li

      btn = document.createElement 'button'
      btn.className = 'taylor-btn'
      btn.className += ' taylor-btn-' + template.name
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

  createTools = (parent, tools) ->
    templates =
      preview:
        name: 'preview'
        action: 'preview'
        class: 'fa fa-eye'
        content: ''
      help:
        name: 'help'
        action: 'help'
        class: 'fa fa-question'
        content: ''

    createTool = (template) ->
      li = document.createElement 'li'
      parent.appendChild li

      btn = document.createElement 'button'
      btn.className = 'taylor-btn'
      btn.className += ' taylor-tool-' + template.name
      btn.setAttribute 'data-taylor-btn-action', template.action
      li.appendChild btn

      span = document.createElement 'span'
      span.className = template.class
      span.innerHTML = template.content || ''
      btn.appendChild span

      template.element = btn

      return template

    elements = []

    for k in tools
      elements.push createTool(templates[k])

    return elements

  # # # # # # # # # #

  bindButtons = (obj, buttons) ->
    for btn in buttons
      ((btn) ->
        btn.element.addEventListener 'click', (e) ->
          # prevent default events
          e.preventDefault()
          e.stopPropagation()

          checkSelection() if selection

          if btn.action.indexOf('append-') > -1
            execFormatBlock btn.action.replace('append-', '')
          else if btn.action is 'anchor'
            triggerAnchorAction obj._options.targetBlank
          else if btn.action is 'image'
            document.execCommand 'insertImage', false, window.getSelection()
          else
            document.execCommand btn.action, false, null

          return @) btn

    return

  # # # # # # # # # #

  bindTools = (obj, tools) ->
    for tool in tools
      ((tool) ->
        if tool.action is 'preview'
          tool.element.addEventListener 'click', () ->
            preview obj) tool

  # # # # # # # # # #

  bindSelect = (element, delay) ->
    timer = null

    wrapper = () ->
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

  bindPaste = (element, disableReturn) ->
    wrapper = (e) ->
      html = ''
      element.classList.remove 'taylor-editor-placeholder'
      if e.clipboardData and e.clipboardData.getData
        e.preventDefault()
        if disableReturn
          paragraphs = e.clipboardData.getData('text/plain').split /[\r\n]/g
          i = 0
          while i < paragraphs.length
            if paragraphs[i] isnt ''
              html += '<p>' + paragraphs[i] + '</p>'
            ++i
          document.execCommand 'insertHTML', false, html
        else
          document.execCommand 'insertHTML', false,
            e.clipboardData.getData 'text/plain'

    element.addEventListener 'paste', wrapper

    return @

  # # # # # # # # # #

  bindFormatting = (element, disableReturn) ->
    element.addEventListener 'keyup', (e) ->
      node = getSelectionStart()

      if node and node.getAttribute 'data-taylor-editable' and !node.children.length and !disableReturn
        document.execCommand 'formatBlock', false, 'p'

      if e.which is 13 and !e.shiftKey
        node = getSelectionStart()
        tagName = node.tagName.toLowerCase()

        if !disableReturn and tagName isnt 'li' and !isListItemChild node
          document.execCommand 'formatBlock', false, 'p'

          if tagName is 'a'
            document.execCommand 'unlink', false, null

    return @

  # # # # # # # # # #

  bindTab = (element) ->
    element.addEventListener 'keydown', (e) ->
      if e.which is 9
        e.preventDefault()

        # override tab for pre nodes
        tag = getSelectionStart().tagName.toLowerCase()
        if tag is 'pre'
          document.execCommand 'insertHTML', null, '    '
        else
          document.execCommand 'insertHTML', null, '&nbsp;&nbsp;&nbsp;&nbsp;'
    return @

  # # # # # # # # # #

  bindReturn = (element, disableReturn) ->
    element.addEventListener 'keypress', (e) ->
      if e.which is 13
        if disableReturn || element.getAttribute 'data-disable-return'
          e.preventDefault()

    return @

  # # # # # # # # # #

  initialize = (obj, options) ->
    if !obj._container
      return throw new Error 'Taylor target element does not exist!'

    defaults =
      width: '100%'
      height: '500px'
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
      tools: [
        'preview'
        # 'help'
      ]
      disableReturn: false
      targetBlank: true
      delay: 0
      sticky: false

    # extend options, override defaults
    obj._options = extend defaults, options

    # # # # #

    createElements obj
    bindButtons obj, obj._buttons || []
    bindTools obj, obj._tools || []
    bindSelect obj._container, obj._options.delay
    bindPaste obj._container, obj._options.disableReturn
    bindFormatting obj._container, obj._options.disableReturn
    bindTab obj._container
    bindReturn obj._container

    # # # # #

    return @

  # # # # # # # # # # # # # # # # # # # #
  # # # # # # # # # # # # # # # # # # # #

  # Functions to bind to Taylor

  preview = (obj) ->
    editable = obj._container.getElementsByClassName('taylor-editable')[0]
    textarea = obj._container.getElementsByClassName('taylor-textarea')[0]
    previewBtn = obj._container.getElementsByClassName('taylor-tool-preview')[0]
    previewIcon = previewBtn.getElementsByClassName('fa')[0]

    if editable.style.display isnt 'none'
      editable.style.display = 'none'
      textarea.style.display = ''
      textarea.value = br2nl editable.innerHTML
      previewIcon.classList.remove 'fa-eye'
      previewIcon.classList.add 'fa-eye-slash'
    else
      editable.style.display = ''
      textarea.style.display = 'none'
      editable.innerHTML = nl2br textarea.value
      previewIcon.classList.add 'fa-eye'
      previewIcon.classList.remove 'fa-eye-slash'

  # # # # # # # # # #

  getHTML = (obj) ->


    # # # # # # # # # # # # # # # # # # # #
    # # # # # # # # # # # # # # # # # # # #

    # Taylor Editor

  Taylor = (container, options) ->
    if !(@ instanceof Taylor)
      return new Taylor container, options

    # find element, bind to object
    @_container = document.getElementById container
    @_HTML = trim @_container.innerHTML
    @_editable = null
    @_buttons = []

    # set empty paragraph tags if empty container
    @_HTML = '<p></p>' if !@_HTML.length

    # clear the container's inner html since it is now saved
    @_container.innerHTML = ''

    # initialize
    initialize @, options || {}

    # get editable and focus on it
    editable = @_container.getElementsByClassName('taylor-editable')[0]
    setSelectedRange editable, 0, 0

    return @

  Taylor::export = () ->
    editable = @_container.getElementsByClassName('taylor-editable')[0]
    textarea = @_container.getElementsByClassName('taylor-textarea')[0]

    if editable.style.display isnt 'none'
      return br2nl editable.innerHTML
    else
      return textarea.value

  # # # # # # # # # # # # # # # # # # # #
  # # # # # # # # # # # # # # # # # # # #

  # expose to window
  window.Taylor = Taylor) window, document