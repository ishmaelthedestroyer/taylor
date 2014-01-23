Taylor = (_container, _params) ->
  if !(@ instanceof Taylor)
    return new Taylor _container, _params

  @_container = document.getElementById _container

  # elements (buttons) on toolbar
  @_textarea = null
  @_bold = null
  @_italic = null
  @_header = null

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
  _controls.appendChild _c

  _label = document.createElement 'span'
  _label.className = 'glyphicon'
  _label.className += ' glyphicon-bold'

  _c.appendChild _label

  # # # # #

  # italic

  _c = document.createElement 'li'
  _controls.appendChild _c

  _label = document.createElement 'span'
  _label.className = 'glyphicon'
  _label.className += ' glyphicon-italic'

  _c.appendChild _label

  # # # # #

  # heading

  _c = document.createElement 'li'
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

  # preview

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

  _body.appendChild _textarea
  @_textarea = _textarea

  return @

Taylor::_createListeners = () ->
  # textarea on blur
  @_textarea.addEventListener 'blur', (e) =>
    console.log 'blurred'
    @_textarea.focus()
    return @
  , false

  return @

Taylor::import = () ->

Taylor::showEditor = () ->

Taylor::showPreview = () ->

Taylor::export = () ->

Taylor::exportText = () ->

Taylor::exportHTML = () ->