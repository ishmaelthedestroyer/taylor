Taylor = (_container, _params) ->
  if !(@ instanceof Taylor)
    return new Taylor _container, _params

  @_container = document.getElementById _container

  # elements (buttons) on toolbar
  @_bold = null
  @_italic = null
  @_header = null

  @_textarea = null
  @_preview = null

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
  @_createListeners()

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

  _textarea = document.createElement 'textarea'
  _textarea.className = 'form-control'
  _textarea.rows = @rows
  _textarea.style.display = 'none'

  _body.appendChild _textarea
  @_textarea = _textarea

  # # # # #
  # # # # #

  _preview = document.createElement 'div'
  _preview.className = 'taylor-preview'
  _preview.className += ' form-control'
  # _preview.contentEditable = true

  _body.appendChild _preview
  @_preview = _preview

  # TODO: add horizontal rule (hr)

  return @

Taylor::_createListeners = () ->
  _tagFunc = (e, _element, _tag) =>
    # stop default events
    e.preventDefault()
    e.stopPropagation()

    # get current selected range
    _range = @_getSelectedRange @_textarea

    # get selected text
    _val = @_textarea.value.substring _range.start, _range.end

    # check if already bolded
    _tags = @_getTags _val

    if _tag not in _tags # if not bolded
      # prepare replacement text
      _replacement = '<' + _tag + '>' + _val + '</' + _tag + '>'
    else # already bolded
      # strip bold tags
      _replacement = _val
      _replacement = _replacement.replace '<' + _tag + '>', ''
      _replacement = _replacement.replace '</' + _tag + '>', ''

    # get different in string lengths
    _diff = (_range.end - _range.start) - _replacement.length

    # get text within range
    @_replaceSelectedText _replacement

    # set selection
    @_setSelectedRange @_textarea, _range.start, _range.end - _diff


    return false

  # # # # #
  # # # # #

  # bold event listener
  @_bold.addEventListener 'mousedown', (e) =>
    _tagFunc e, @_textarea, 'b'
  , false

  # italic event listener
  @_italic.addEventListener 'mousedown', (e) =>
    _tagFunc e, @_textarea, 'i'
  , false

  # header event listener
  @_header.addEventListener 'mousedown', (e) =>
    _tagFunc e, @_textarea, 'h1'
  , false

  ###
  @_textarea.onselect = (e) =>
    _range = @_getSelectedRange @_textarea
    console.log 'got range: ' + _range
  ###

  return @

# # # # # # # # # #
# # # # # # # # # #

# HELPER FUNCTIONS

Taylor::_trim = (_text) ->
  _text.replace /^\s+|\s+$/g,""

Taylor::_getTags = (_text) ->
  _tags = []

  # check for bold tags
  if _text.indexOf('<b>') isnt -1 and _text.indexOf('</b>') isnt -1
    _tags.push 'b'

  # check for italic tags
  if _text.indexOf('<i>') isnt -1 and _text.indexOf('</i>') isnt -1
    _tags.push 'i'

  # check for header tags
  if _text.indexOf('<h1>') isnt -1 and _text.indexOf('</h1>') isnt -1
    _tags.push 'h1'

  return _tags

Taylor::_cleanTags = () ->


Taylor::_setFocus = () ->

Taylor::_getSelectedRange = (el) ->
  start = 0
  end = 0
  normalizedValue = undefined
  range = undefined
  textInputRange = undefined
  len = undefined
  endRange = undefined
  if typeof el.selectionStart is "number" and typeof el.selectionEnd is "number"
    start = el.selectionStart
    end = el.selectionEnd
  else
    range = document.selection.createRange()
    if range and range.parentElement() is el
      len = el.value.length
      normalizedValue = el.value.replace(/\r\n/g, "\n")

      # Create a working TextRange that lives only in the input
      textInputRange = el.createTextRange()
      textInputRange.moveToBookmark range.getBookmark()

      # Check if the start and end of the selection are at the very end
      # of the input, since moveStart/moveEnd doesn't return what we want
      # in those cases
      endRange = el.createTextRange()
      endRange.collapse false
      if textInputRange.compareEndPoints("StartToEnd", endRange) > -1
        start = end = len
      else
        start = -textInputRange.moveStart("character", -len)
        start += normalizedValue.slice(0, start).split("\n").length - 1
        if textInputRange.compareEndPoints("EndToEnd", endRange) > -1
          end = len
        else
          end = -textInputRange.moveEnd("character", -len)
          end += normalizedValue.slice(0, end).split("\n").length - 1

  # return object
  start: start
  end: end

Taylor::_setSelectedRange = (_element, _start, _end) ->
  # set focus on element
  _element.focus()

  if _element.setSelectionRange
    _element.setSelectionRange _start, _end
  else
    if _element.createTextRange
      _normalizedVal = _element.value.replace /\r\n/g, "\n"

      _start -= _normalizedVal.slice(0, _start).split("\n").length - 1
      _end -= _normalizedVal.slice(0, _end).split("\n").length - 1

      _range = _element.createTextRange()
      _range.collapse true
      _range.moveEnd 'character', _end
      _range.moveStart 'character', _start
      _range.select()

Taylor::_getSelectedText = () ->

Taylor::_replaceSelectedText = (_t) ->
  if window.getSelection
    sel = window.getSelection()
    activeElement = document.activeElement
    if activeElement.nodeName is "TEXTAREA" or
    (activeElement.nodeName is "INPUT" and
    activeElement.type.toLowerCase() is "text")
      val = activeElement.value
      start = activeElement.selectionStart
      end = activeElement.selectionEnd
      activeElement.value = val.slice(0, start) + _t + val.slice(end)

    #alert("in text area");
    else
      if sel.rangeCount
        range = sel.getRangeAt(0)
        range.deleteContents()
        range.insertNode document.createTextNode(_t)
      else
        sel.deleteFromDocument()
  else if document.selection and document.selection.createRange
    range = document.selection.createRange()
    range.text = _t

Taylor::characterCount = () ->

Taylor::wordCount = () ->

Taylor::lineCount = () ->

Taylor::sentenceCount = () ->

Taylor::clear = () ->

Taylor::undo = () ->

Taylor::redo = () ->

Taylor::import = () ->

Taylor::export = () ->

Taylor::exportText = () ->

Taylor::showEditor = () ->

Taylor::showPreview = () ->

Taylor::export = () ->