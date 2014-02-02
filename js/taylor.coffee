Taylor = (_container, _options) ->
  if !(@ instanceof Taylor)
    return new Taylor _container, _options

  @_container = document.getElementById _container

  # assign unique ID
  @_id = 'taylor-editor' + document.querySelectorAll('.taylor-editor').length

  @_parentElements = [
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

  _defaults =
    placeholder: '...'
    anchorPlaceholder: '...'
    buttons: [
      'bold'
      'italic'
      'underline'
      'anchor'
      'header1'
      'header2'
      'quote'
      'image'
    ]
    disableReturn: false
    targetBlank: false
    delay: 0
    sticky: true

  # set options, override defaults with parameters
  @_options = @_extend _options, _defaults

  # # # # # # # # # #
  # # # # # # # # # #

  # elements (buttons) on toolbar

  @_bold = null
  @_italic = null
  @_header = null
  @_anchor = null
  @_blockquote = null
  @_unorderedList = null
  @_orderedList = null
  @_image = null

  @_preview = null
  @_help = null

  @_expand = null
  @_collapse = null

  # # # # # # # # # #
  # # # # # # # # # #

  @_textarea = null
  @_editable = null

  # status of textarea and contenteditable
  @_textareaVisible = false
  @_editableVisible = false

  @_selectedStart = null
  @_selectedEnd = null

  _params = _params || {}
  @rows = _params.rows || 10

  @entities =
    '&': '&amp;'
    '>': '&gt;'
    '<': '&lt;'
    '"': '&quot;'
    "'": '&#39;'

  @_init()

  return @

Taylor::_init = () ->
  @_createElements()

  @_bindSelect @_editable
  @_bindPaste @_editable
  @_setPlaceholders @_editable

  # bind events to taylor-editable container
  @_bindFormatting @_editable
  @_bindReturn @_editable
  @_bindTab @_editable

  @_bindButtons()

Taylor::_createElements = () ->
  # if element doesn't exist, throw error
  if @_container is null
    return throw new Error 'Container doesn\'t exist.'

  # # # # #
  # # # # #

  # add classes to container
  @_container.className += ' taylor'
  @_container.className += ' panel'
  @_container.className += ' panel-default'

  # # # # #
  # # # # #

  # add heading
  _heading = document.createElement 'div'
  _heading.className = 'panel-heading'
  _heading.style.height = 'auto'

  @_container.appendChild _heading

  # # # # #
  # # # # #

  # add _controls
  _controls = document.createElement 'ul'
  _controls.className = 'nav'
  _controls.className += ' navbar-nav'

  _heading.appendChild _controls

  # # # # #

  # bold

  _c = document.createElement 'li'
  _c.id = 'taylor-bold-btn'

  @_bold = _c
  _controls.appendChild _c


  _label = document.createElement 'span'
  _label.className = 'glyphicon'
  _label.className += ' glyphicon-bold'

  @_bold = _label

  _c.appendChild _label

  # # # # #

  # italic

  _c = document.createElement 'li'
  _c.id = 'taylor-italic-btn'
  @_italic = _c
  _controls.appendChild _c

  _label = document.createElement 'span'
  _label.className = 'glyphicon'
  _label.className += ' glyphicon-italic'

  _c.appendChild _label

  # # # # #

  # heading

  _c = document.createElement 'li'
  _c.id = 'taylor-header-btn'
  @_header = _c
  _controls.appendChild _c

  _label = document.createElement 'span'
  _label.className = 'glyphicon'
  _label.className += ' glyphicon-header'

  _c.appendChild _label

  # # # # #

  # links

  _c = document.createElement 'li'
  _controls.appendChild _c

  _label = document.createElement 'span'
  _label.className = 'glyphicon'
  _label.className += ' glyphicon-globe'

  _c.style.marginLeft = '75px'

  _c.appendChild _label

  # # # # #

  # quote

  _c = document.createElement 'li'
  _controls.appendChild _c

  _label = document.createElement 'span'
  _label.className = 'glyphicon'
  _label.className += ' glyphicon-comment'

  _c.appendChild _label

  # # # # #

  # image

  _c = document.createElement 'li'
  _controls.appendChild _c

  _label = document.createElement 'span'
  _label.className = 'glyphicon'
  _label.className += ' glyphicon-picture'

  _c.appendChild _label

  # # # # #

  # list

  _c = document.createElement 'li'
  _controls.appendChild _c

  _label = document.createElement 'span'
  _label.className = 'glyphicon'
  _label.className += ' glyphicon-th-list'

  _c.appendChild _label

  # # # # #
  # # # # #

  # add tools for editor

  _tools = document.createElement 'ul'
  _tools.className = 'nav'
  _tools.className += ' navbar-nav'
  _tools.className += ' navbar-right'

  _heading.appendChild _tools

  # # # # #

  _c = document.createElement 'li'
  _c.style.width = 'auto'
  _tools.appendChild _c

  _label = document.createElement 'span'
  _label.className = 'glyphicon'
  _label.className += ' glyphicon-eye-open'
  _label.style.marginRight = '10px'

  _c.appendChild _label

  _label = document.createElement 'span'
  _label.innerHTML = 'Preview'

  _c.appendChild _label

  # # # # #

  # help

  _c = document.createElement 'li'
  _c.style.width = 'auto'
  _tools.appendChild _c

  _label = document.createElement 'span'
  _label.className = 'glyphicon'
  _label.className += ' glyphicon-question-sign'
  _label.style.marginRight = '10px'

  _c.appendChild _label

  _label = document.createElement 'span'
  _label.innerHTML = 'Help'

  _c.appendChild _label

  # # # # #

  # full-screen

  _c = document.createElement 'li'
  _tools.appendChild _c

  _label = document.createElement 'span'
  _label.className = 'glyphicon'
  _label.className += ' glyphicon-fullscreen'

  _c.appendChild _label

  # # # # #
  # # # # #

  # clear-fix
  _clear = document.createElement 'div'
  _clear.style.clear = 'both'

  _heading.appendChild _clear

  # # # # #
  # # # # #

  # add panel body
  _body = document.createElement 'div'
  _body.className = 'panel-body'
  _body.style.height = 'auto'
  _body.style.padding = 0
  _body.style.margin = 0

  @_container.appendChild _body

  # # # # #
  # # # # #

  ###
  _textarea = document.createElement 'textarea'
  _textarea.className = 'form-control'
  _textarea.rows = @rows
  _textarea.style.display = 'none'

  _body.appendChild _textarea
  @_textarea = _textarea
  ###

  # # # # #
  # # # # #

  _editable = document.createElement 'div'
  _editable.className = 'taylor-editable'
  _editable.className += ' form-control'
  _editable.setAttribute 'data-taylor-editable', true
  _editable.style.height = 'auto'

  _editable.contentEditable = true

  _body.appendChild _editable
  @_editable = _editable

  # TODO: add horizontal rule (hr)

  return @

# # # # # # # # # #
# # # # # # # # # #

# HELPER FUNCTIONS
Taylor::_extend = (b, a) ->
  return a if b is undefined

  for prop of a
    if a.hasOwnProperty prop and !b.hasOwnProperty prop
      b[prop] = a[prop]

  return b

Taylor::_saveSelection = () ->
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

Taylor::_restoreSelection = (saved) ->
  sel = window.getSelection()
  if saved
    sel.removeAllRanges()
    i = 0
    len = saved.length

    while i < len
      sel.addRange saved[i]
      i += 1

Taylor::_getSelectionStart = () ->
  node = document.getSelection().anchorNode

  if node and node.nodeType is 3
    startNode = node.parentNode
  else
    startNode = node

  return startNode

Taylor::_getSelectionHtml = () ->
  html = ''

  if window.getSelection
    sel = window.getSelection()
    if sel.rangeCount
      container = document.createElement 'div'
      i = 0
      len = sel.rangeCount

      while i < len
        container.appendChild sel.getRangeAt(i).cloneContents()
        i += 1

      html = container.innerHTML
  else if document.selection
    if document.selection.type is 'Text'
      html = document.selection.createRange().htmlText

  return html

Taylor::_bindFormatting = (element) ->
  console.log '_bindFormatting() fired.'

  element.addEventListener 'keyup', (e) =>
    node = @_getSelectionStart()

    if node and node.getAttribute 'data-taylor-editable' and
    !node.children.length and
    (!@_options.disableReturn or node.getAttribute 'data-disable-return')
      document.execCommand 'formatBlock', false, 'p'

    if e.which is 13 and !e.shiftKey
      node = @_getSelectionStart()
      tagName = node.tagName.toLowerCase()

      if !(@_options.disableReturn ||
      element.getAttribute 'data-disable-return') and
      tagName isnt 'li' and !@_isListItemChild node
        document.execCommand 'formatBlock', false, 'p'

        if tagName is 'a'
          document.execCommand 'unlink', false, null

  return @

Taylor::_bindReturn = (element) ->
  console.log '_bindReturn() fired.'

  element.addEventListener 'keypress', (e) =>
    if e.which is 13
      if @_options.disableReturn || element.getAttribute 'data-disable-return'
        e.preventDefault()

  return @

Taylor::_bindTab = (element) ->
  console.log '_bindTab() fired.'

  element.addEventListener 'keydown', (e) =>
    if e.which is 9
      # override tab for pre nodes
      tag = @_getSelectionStart().tagName.toLowerCase()
      if tag is 'pre'
        e.preventDefault()
        document.execCommand 'insertHTML', null, '    '

  return @

Taylor::_bindSelect = (element) ->
  console.log '_bindSelect() fired.'

  timer = null
  _checkSelection = @_checkSelection

  @_checkSelectionWrapper = () =>
    console.log 'Taylor _checkSelectionWrapper eventListener fired.'

    clearTimeout timer

    timer = setTimeout ->
      _checkSelection()
    , @_options.delay

  _doc = document.documentElement
  _doc.addEventListener 'mouseup', @_checkSelectionWrapper

  element.addEventListener 'keyup', @_checkSelectionWrapper
  element.addEventListener 'blur', @_checkSelectionWrapper

  return @

Taylor::_bindPaste = (element) ->
  console.log '_bindPaste() fired.'

  wrapper = (e) =>
    console.log 'Taylor _bindPaste eventListener fired.'

    html = ''
    element.classList.remove 'taylor-editor-placeholder'
    if e.clipboardData and e.clipboardData.getData
      e.preventDefault()
      if @_options.disableReturn
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

Taylor::_bindWindowActions = () ->
  # TODO: bindWindowActions initialize function
  window.addEventListener 'resize', () =>
    console.log 'Taylor: window resize eventListener fired.'

Taylor::_bindButtons = () ->
  bindButton = (element, action) =>
    console.log 'Binding button: ' + action

    element.addEventListener 'mousedown', (e) =>
      # prevent default events from occuring
      e.preventDefault()
      e.stopPropagation()

      if !@_selection
        @_checkSelection()

      if action.indexOf('append-') > -1
        @_execFormatBlock action.replace('append-', '')
      else if action is 'anchor'
        @_triggerAnchorAction e
      else if action is 'image'
        document.execCommand 'insertImage', false, window.getSelection()
      else
        document.execCommand action, false, null

      return @

  # bind events to buttons
  bindButton @_bold, 'bold'
  bindButton @_italic, 'italic'
  bindButton @_header, 'header1'

  return @

Taylor::_execFormatBlock = (type) ->
  selectionData = @_getselectionData @_selection.anchorNode

  # FF handles blockquote differently on formatBlock
  if type is 'blockquote' and selectionData.el and
  selectionData.el.parentNode.tagName.toLowerCase() is 'blockquote'
    return document.execCommand 'outdent', false, null

  if selectionData.tagName is type
    type = 'p'

  return document.execCommand 'formatBlock', false, type

Taylor::_triggerAnchorAction = () ->
  if @_selection.anchorNode.parentNode.tagName.toLowerCase() is 'a'
    document.execCommand 'unlink', false, null
  else
    # TODO: show anchor form
    console.log 'TODO'

Taylor::_setPlaceholders = (element) ->
  console.log 'Firing _setPlaceholders initialize function.'

  activate = () ->
    console.log 'Firing Taylor::_setPlaceholder::activate()'
    if element.textContent.replace(/^\s+|\s+$/g, '') is ''
      console.log 'Adding placeholder.'
      element.classList.add 'taylor-editor-placeholder'

  wrapper = (e) ->
    console.log 'Firing Taylor::_setPlaceholder::remove()'
    element.classList.remove 'taylor-editor-placeholder'
    if e.type isnt 'keypress'
      activate()

  element.addEventListener 'blur', wrapper
  element.addEventListener 'keypress', wrapper

  return @

Taylor::_checkSelection = () ->
  ###
  newSelection = window.getSelection()
  if newSelection.toString().trim() is '' or
  @_options
  return true
  ###

Taylor::_getSelectionElement = () ->
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

Taylor::_isListItemChild = (node) ->
  parentNode = node.parentNode
  tagName = parentNode.tagName.toLowerCase()

  while @_parentElements.indexOf(tagName) is -1 and tagName isnt 'div'
    return true if tagName is 'li'

    parentNode = parentNode.parentNode
    if parentNode and parentNode.tagName
      tagName = parentNode.tagName.toLowerCase()
    else
      return false

  return false

Taylor::characterCount = () ->

Taylor::wordCount = () ->

Taylor::lineCount = () ->

Taylor::sentenceCount = () ->

Taylor::paragraphCount = () ->

Taylor::clear = () ->

Taylor::undo = () ->

Taylor::redo = () ->

Taylor::import = () ->

Taylor::export = () ->

Taylor::exportText = () ->

Taylor::showEditor = () ->

Taylor::showPreview = () ->

Taylor::export = () ->