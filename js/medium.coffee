MediumEditor = (elements, options) ->
  "use strict"
  @init elements, options
module.exports = MediumEditor  if typeof module is "object"
((window, document) ->
  extend = (b, a) ->
    prop = undefined
    return a  if b is 'undefined'
    for prop of a
      b[prop] = a[prop]  if a.hasOwnProperty(prop) and b.hasOwnProperty(prop) is false
    b

  # http://stackoverflow.com/questions/5605401/insert-link-in-contenteditable-element
  # by Tim Down
  saveSelection = ->
    i = undefined
    len = undefined
    ranges = undefined
    sel = window.getSelection()
    if sel.getRangeAt and sel.rangeCount
      ranges = []
      i = 0
      len = sel.rangeCount

      while i < len
        ranges.push sel.getRangeAt(i)
        i += 1
      return ranges
    null
  restoreSelection = (savedSel) ->
    i = undefined
    len = undefined
    sel = window.getSelection()
    if savedSel
      sel.removeAllRanges()
      i = 0
      len = savedSel.length

      while i < len
        sel.addRange savedSel[i]
        i += 1

  # http://stackoverflow.com/questions/1197401/how-can-i-get-the-element-the-caret-is-in-with-javascript-when-using-contentedi
  # by You
  getSelectionStart = ->
    node = document.getSelection().anchorNode
    startNode = ((if node and node.nodeType is 3 then node.parentNode else node))
    startNode

  # http://stackoverflow.com/questions/4176923/html-of-selected-text
  # by Tim Down
  getSelectionHtml = ->
    i = undefined
    html = ""
    sel = undefined
    len = undefined
    container = undefined
    if window.getSelection isnt 'undefined'
      sel = window.getSelection()
      if sel.rangeCount
        container = document.createElement("div")
        i = 0
        len = sel.rangeCount

        while i < len
          container.appendChild sel.getRangeAt(i).cloneContents()
          i += 1
        html = container.innerHTML
    else html = document.selection.createRange().htmlText  if document.selection.type is "Text"  if document.selection isnt 'undefined'
    html
  "use strict"
  MediumEditor:: =
    defaults:
      allowMultiParagraphSelection: true
      anchorInputPlaceholder: "Paste or type a link"
      buttons: ["bold", "italic", "underline", "anchor", "header1", "header2", "quote"]
      buttonLabels: false
      delay: 0
      diffLeft: 0
      diffTop: -10
      disableReturn: false
      disableToolbar: false
      firstHeader: "h3"
      forcePlainText: true
      placeholder: "Type your text"
      secondHeader: "h4"
      targetBlank: false

    init: (elements, options) ->
      @elements = (if typeof elements is "string" then document.querySelectorAll(elements) else elements)
      return  if @elements.length is 0
      @isActive = true
      @parentElements = ["p", "h1", "h2", "h3", "h4", "h5", "h6", "blockquote", "pre"]
      @id = document.querySelectorAll(".medium-editor-toolbar").length + 1
      @options = extend(options, @defaults)
      @initElements().bindSelect().bindPaste().setPlaceholders().bindWindowActions()

    initElements: ->
      i = undefined
      addToolbar = false
      i = 0
      while i < @elements.length
        @elements[i].setAttribute "contentEditable", true
        @elements[i].setAttribute "data-placeholder", @options.placeholder  unless @elements[i].getAttribute("data-placeholder")
        @elements[i].setAttribute "data-medium-element", true
        @bindParagraphCreation(i).bindReturn(i).bindTab i
        addToolbar = true  if not @options.disableToolbar and not @elements[i].getAttribute("data-disable-toolbar")
        i += 1

      # Init toolbar
      @initToolbar().bindButtons().bindAnchorForm()  if addToolbar
      this

    serialize: ->
      i = undefined
      elementid = undefined
      content = {}
      i = 0
      while i < @elements.length
        elementid = (if (@elements[i].id isnt "") then @elements[i].id else "element-" + i)
        content[elementid] = value: @elements[i].innerHTML.trim()
        i += 1
      content

    bindParagraphCreation: (index) ->
      self = this
      @elements[index].addEventListener "keyup", (e) ->
        node = getSelectionStart()
        tagName = undefined
        document.execCommand "formatBlock", false, "p"  if node and node.getAttribute("data-medium-element") and node.children.length is 0 and not (self.options.disableReturn or node.getAttribute("data-disable-return"))
        if e.which is 13 and not e.shiftKey
          node = getSelectionStart()
          tagName = node.tagName.toLowerCase()
          if not (self.options.disableReturn or @getAttribute("data-disable-return")) and tagName isnt "li" and not self.isListItemChild(node)
            document.execCommand "formatBlock", false, "p"
            document.execCommand "unlink", false, null  if tagName is "a"

      this

    isListItemChild: (node) ->
      parentNode = node.parentNode
      tagName = parentNode.tagName.toLowerCase()
      while @parentElements.indexOf(tagName) is -1 and tagName isnt "div"
        return true  if tagName is "li"
        parentNode = parentNode.parentNode
        if parentNode and parentNode.tagName
          tagName = parentNode.tagName.toLowerCase()
        else
          return false
      false

    bindReturn: (index) ->
      self = this
      @elements[index].addEventListener "keypress", (e) ->
        e.preventDefault()  if self.options.disableReturn or @getAttribute("data-disable-return")  if e.which is 13

      this

    bindTab: (index) ->
      @elements[index].addEventListener "keydown", (e) ->
        if e.which is 9

          # Override tab only for pre nodes
          tag = getSelectionStart().tagName.toLowerCase()
          if tag is "pre"
            e.preventDefault()
            document.execCommand "insertHtml", null, "    "


    buttonTemplate: (btnType) ->
      buttonLabels = @getButtonLabels(@options.buttonLabels)
      buttonTemplates =
        bold: "<li><button class=\"medium-editor-action medium-editor-action-bold\" data-action=\"bold\" data-element=\"b\">" + buttonLabels.bold + "</button></li>"
        italic: "<li><button class=\"medium-editor-action medium-editor-action-italic\" data-action=\"italic\" data-element=\"i\">" + buttonLabels.italic + "</button></li>"
        underline: "<li><button class=\"medium-editor-action medium-editor-action-underline\" data-action=\"underline\" data-element=\"u\">" + buttonLabels.underline + "</button></li>"
        strikethrough: "<li><button class=\"medium-editor-action medium-editor-action-strikethrough\" data-action=\"strikethrough\" data-element=\"strike\"><strike>A</strike></button></li>"
        superscript: "<li><button class=\"medium-editor-action medium-editor-action-superscript\" data-action=\"superscript\" data-element=\"sup\">" + buttonLabels.superscript + "</button></li>"
        subscript: "<li><button class=\"medium-editor-action medium-editor-action-subscript\" data-action=\"subscript\" data-element=\"sub\">" + buttonLabels.subscript + "</button></li>"
        anchor: "<li><button class=\"medium-editor-action medium-editor-action-anchor\" data-action=\"anchor\" data-element=\"a\">" + buttonLabels.anchor + "</button></li>"
        image: "<li><button class=\"medium-editor-action medium-editor-action-image\" data-action=\"image\" data-element=\"img\">" + buttonLabels.image + "</button></li>"
        header1: "<li><button class=\"medium-editor-action medium-editor-action-header1\" data-action=\"append-" + @options.firstHeader + "\" data-element=\"" + @options.firstHeader + "\">" + buttonLabels.header1 + "</button></li>"
        header2: "<li><button class=\"medium-editor-action medium-editor-action-header2\" data-action=\"append-" + @options.secondHeader + "\" data-element=\"" + @options.secondHeader + "\">" + buttonLabels.header2 + "</button></li>"
        quote: "<li><button class=\"medium-editor-action medium-editor-action-quote\" data-action=\"append-blockquote\" data-element=\"blockquote\">" + buttonLabels.quote + "</button></li>"
        orderedlist: "<li><button class=\"medium-editor-action medium-editor-action-orderedlist\" data-action=\"insertorderedlist\" data-element=\"ol\">" + buttonLabels.orderedlist + "</button></li>"
        unorderedlist: "<li><button class=\"medium-editor-action medium-editor-action-unorderedlist\" data-action=\"insertunorderedlist\" data-element=\"ul\">" + buttonLabels.unorderedlist + "</button></li>"
        pre: "<li><button class=\"medium-editor-action medium-editor-action-pre\" data-action=\"append-pre\" data-element=\"pre\">" + buttonLabels.pre + "</button></li>"

      buttonTemplates[btnType] or false


    # TODO: break method
    getButtonLabels: (buttonLabelType) ->
      customButtonLabels = undefined
      attrname = undefined
      buttonLabels =
        bold: "<b>B</b>"
        italic: "<b><i>I</i></b>"
        underline: "<b><u>U</u></b>"
        superscript: "<b>x<sup>1</sup></b>"
        subscript: "<b>x<sub>1</sup></b>"
        anchor: "<b>#</b>"
        image: "<b>image</b>"
        header1: "<b>H1</b>"
        header2: "<b>H2</b>"
        quote: "<b>&ldquo;</b>"
        orderedlist: "<b>1.</b>"
        unorderedlist: "<b>&bull;</b>"
        pre: "<b>0101</b>"

      if buttonLabelType is "fontawesome"
        customButtonLabels =
          bold: "<i class=\"fa fa-bold\"></i>"
          italic: "<i class=\"fa fa-italic\"></i>"
          underline: "<i class=\"fa fa-underline\"></i>"
          superscript: "<i class=\"fa fa-superscript\"></i>"
          subscript: "<i class=\"fa fa-subscript\"></i>"
          anchor: "<i class=\"fa fa-link\"></i>"
          image: "<i class=\"fa fa-picture-o\"></i>"
          quote: "<i class=\"fa fa-quote-right\"></i>"
          orderedlist: "<i class=\"fa fa-list-ol\"></i>"
          unorderedlist: "<i class=\"fa fa-list-ul\"></i>"
          pre: "<i class=\"fa fa-code fa-lg\"></i>"
      else customButtonLabels = buttonLabelType  if typeof buttonLabelType is "object"
      if typeof customButtonLabels is "object"
        for attrname of customButtonLabels
          buttonLabels[attrname] = customButtonLabels[attrname]  if customButtonLabels.hasOwnProperty(attrname)
      buttonLabels


    #TODO: actionTemplate
    toolbarTemplate: ->
      btns = @options.buttons
      html = "<ul id=\"medium-editor-toolbar-actions\" class=\"medium-editor-toolbar-actions clearfix\">"
      i = undefined
      tpl = undefined
      i = 0
      while i < btns.length
        tpl = @buttonTemplate(btns[i])
        html += tpl  if tpl
        i += 1
      html += "</ul>" + "<div class=\"medium-editor-toolbar-form-anchor\" id=\"medium-editor-toolbar-form-anchor\">" + "    <input type=\"text\" value=\"\" placeholder=\"" + @options.anchorInputPlaceholder + "\">" + "    <a href=\"#\">&times;</a>" + "</div>"
      html

    initToolbar: ->
      return this  if @toolbar
      @toolbar = @createToolbar()
      @keepToolbarAlive = false
      @anchorForm = @toolbar.querySelector(".medium-editor-toolbar-form-anchor")
      @anchorInput = @anchorForm.querySelector("input")
      @toolbarActions = @toolbar.querySelector(".medium-editor-toolbar-actions")
      this

    createToolbar: ->
      toolbar = document.createElement("div")
      toolbar.id = "medium-editor-toolbar-" + @id
      toolbar.className = "medium-editor-toolbar"
      toolbar.innerHTML = @toolbarTemplate()
      document.getElementsByTagName("body")[0].appendChild toolbar
      toolbar

    bindSelect: ->
      self = this
      timer = ""
      i = undefined
      @checkSelectionWrapper = ->
        clearTimeout timer
        timer = setTimeout(->
          self.checkSelection()
        , self.options.delay)

      document.documentElement.addEventListener "mouseup", @checkSelectionWrapper
      i = 0
      while i < @elements.length
        @elements[i].addEventListener "keyup", @checkSelectionWrapper
        @elements[i].addEventListener "blur", @checkSelectionWrapper
        i += 1
      this

    checkSelection: ->
      newSelection = undefined
      selectionElement = undefined
      if @keepToolbarAlive isnt true and not @options.disableToolbar
        newSelection = window.getSelection()
        if newSelection.toString().trim() is "" or (@options.allowMultiParagraphSelection is false and @hasMultiParagraphs())
          @hideToolbarActions()
        else
          selectionElement = @getSelectionElement()
          if not selectionElement or selectionElement.getAttribute("data-disable-toolbar")
            @hideToolbarActions()
          else
            @checkSelectionElement newSelection, selectionElement
      this

    hasMultiParagraphs: ->
      selectionHtml = getSelectionHtml().replace(/<[\S]+><\/[\S]+>/g, "")
      hasMultiParagraphs = selectionHtml.match(/<(p|h[0-6]|blockquote)>([\s\S]*?)<\/(p|h[0-6]|blockquote)>/g)
      (if hasMultiParagraphs then hasMultiParagraphs.length else 0)

    checkSelectionElement: (newSelection, selectionElement) ->
      i = undefined
      @selection = newSelection
      @selectionRange = @selection.getRangeAt(0)
      i = 0
      while i < @elements.length
        if @elements[i] is selectionElement
          @setToolbarButtonStates().setToolbarPosition().showToolbarActions()
          return
        i += 1
      @hideToolbarActions()

    getSelectionElement: ->
      selection = window.getSelection()
      range = selection.getRangeAt(0)
      current = range.commonAncestorContainer
      parent = current.parentNode
      result = undefined
      getMediumElement = (e) ->
        parent = e
        try
          parent = parent.parentNode  until parent.getAttribute("data-medium-element")
        catch errb
          return false
        parent


      # First try on current node
      try
        if current.getAttribute("data-medium-element")
          result = current
        else
          result = getMediumElement(parent)

      # If not search in the parent nodes.
      catch err
        result = getMediumElement(parent)
      result

    setToolbarPosition: ->
      buttonHeight = 50
      selection = window.getSelection()
      range = selection.getRangeAt(0)
      boundary = range.getBoundingClientRect()
      defaultLeft = (@options.diffLeft) - (@toolbar.offsetWidth / 2)
      middleBoundary = (boundary.left + boundary.right) / 2
      halfOffsetWidth = @toolbar.offsetWidth / 2
      if boundary.top < buttonHeight
        @toolbar.classList.add "medium-toolbar-arrow-over"
        @toolbar.classList.remove "medium-toolbar-arrow-under"
        @toolbar.style.top = buttonHeight + boundary.bottom - @options.diffTop + window.pageYOffset - @toolbar.offsetHeight + "px"
      else
        @toolbar.classList.add "medium-toolbar-arrow-under"
        @toolbar.classList.remove "medium-toolbar-arrow-over"
        @toolbar.style.top = boundary.top + @options.diffTop + window.pageYOffset - @toolbar.offsetHeight + "px"
      if middleBoundary < halfOffsetWidth
        @toolbar.style.left = defaultLeft + halfOffsetWidth + "px"
      else if (window.innerWidth - middleBoundary) < halfOffsetWidth
        @toolbar.style.left = window.innerWidth + defaultLeft - halfOffsetWidth + "px"
      else
        @toolbar.style.left = defaultLeft + middleBoundary + "px"
      this

    setToolbarButtonStates: ->
      buttons = @toolbarActions.querySelectorAll("button")
      i = undefined
      i = 0
      while i < buttons.length
        buttons[i].classList.remove "medium-editor-button-active"
        i += 1
      @checkActiveButtons()
      this

    checkActiveButtons: ->
      parentNode = @selection.anchorNode
      parentNode = @selection.anchorNode.parentNode  unless parentNode.tagName
      while parentNode.tagName isnt 'undefined' and @parentElements.indexOf(parentNode.tagName) is -1
        @activateButton parentNode.tagName.toLowerCase()
        parentNode = parentNode.parentNode

    activateButton: (tag) ->
      el = @toolbar.querySelector("[data-element=\"" + tag + "\"]")
      el.className += " medium-editor-button-active"  if el isnt null and el.className.indexOf("medium-editor-button-active") is -1

    bindButtons: ->
      buttons = @toolbar.querySelectorAll("button")
      i = undefined
      self = this
      triggerAction = (e) ->
        e.preventDefault()
        e.stopPropagation()
        self.checkSelection()  if self.selection is 'undefined'
        if @className.indexOf("medium-editor-button-active") > -1
          @classList.remove "medium-editor-button-active"
        else
          @className += " medium-editor-button-active"
        self.execAction @getAttribute("data-action"), e

      i = 0
      while i < buttons.length
        buttons[i].addEventListener "click", triggerAction
        i += 1
      @setFirstAndLastItems buttons
      this

    setFirstAndLastItems: (buttons) ->
      buttons[0].className += " medium-editor-button-first"
      buttons[buttons.length - 1].className += " medium-editor-button-last"
      this

    execAction: (action, e) ->
      if action.indexOf("append-") > -1
        @execFormatBlock action.replace("append-", "")
        @setToolbarPosition()
        @setToolbarButtonStates()
      else if action is "anchor"
        @triggerAnchorAction e
      else if action is "image"
        document.execCommand "insertImage", false, window.getSelection()
      else
        document.execCommand action, false, null
        @setToolbarPosition()

    triggerAnchorAction: ->
      if @selection.anchorNode.parentNode.tagName.toLowerCase() is "a"
        document.execCommand "unlink", false, null
      else
        if @anchorForm.style.display is "block"
          @showToolbarActions()
        else
          @showAnchorForm()
      this

    execFormatBlock: (el) ->
      selectionData = @getSelectionData(@selection.anchorNode)

      # FF handles blockquote differently on formatBlock
      # allowing nesting, we need to use outdent
      # https://developer.mozilla.org/en-US/docs/Rich-Text_Editing_in_Mozilla
      return document.execCommand("outdent", false, null)  if el is "blockquote" and selectionData.el and selectionData.el.parentNode.tagName.toLowerCase() is "blockquote"
      el = "p"  if selectionData.tagName is el
      document.execCommand "formatBlock", false, el

    getSelectionData: (el) ->
      tagName = undefined
      tagName = el.tagName.toLowerCase()  if el and el.tagName
      while el and @parentElements.indexOf(tagName) is -1
        el = el.parentNode
        tagName = el.tagName.toLowerCase()  if el and el.tagName
      el: el
      tagName: tagName

    getFirstChild: (el) ->
      firstChild = el.firstChild
      firstChild = firstChild.nextSibling  while firstChild isnt null and firstChild.nodeType isnt 1
      firstChild

    bindElementToolbarEvents: (el) ->
      self = this
      el.addEventListener "mouseup", ->
        self.checkSelection()

      el.addEventListener "keyup", ->
        self.checkSelection()


    hideToolbarActions: ->
      @keepToolbarAlive = false
      @toolbar.classList.remove "medium-editor-toolbar-active"

    showToolbarActions: ->
      self = this
      timer = undefined
      @anchorForm.style.display = "none"
      @toolbarActions.style.display = "block"
      @keepToolbarAlive = false
      clearTimeout timer
      timer = setTimeout(->
        self.toolbar.classList.add "medium-editor-toolbar-active"  unless self.toolbar.classList.contains("medium-editor-toolbar-active")
      , 100)

    showAnchorForm: ->
      @toolbarActions.style.display = "none"
      @savedSelection = saveSelection()
      @anchorForm.style.display = "block"
      @keepToolbarAlive = true
      @anchorInput.focus()
      @anchorInput.value = ""

    bindAnchorForm: ->
      linkCancel = @anchorForm.querySelector("a")
      self = this
      @anchorForm.addEventListener "click", (e) ->
        e.stopPropagation()

      @anchorInput.addEventListener "keyup", (e) ->
        if e.keyCode is 13
          e.preventDefault()
          self.createLink this

      @anchorInput.addEventListener "blur", ->
        self.keepToolbarAlive = false
        self.checkSelection()

      linkCancel.addEventListener "click", (e) ->
        e.preventDefault()
        self.showToolbarActions()
        restoreSelection self.savedSelection

      this

    setTargetBlank: ->
      el = getSelectionStart()
      i = undefined
      if el.tagName.toLowerCase() is "a"
        el.target = "_blank"
      else
        el = el.getElementsByTagName("a")
        i = 0
        while i < el.length
          el[i].target = "_blank"
          i += 1

    createLink: (input) ->
      restoreSelection @savedSelection
      document.execCommand "createLink", false, input.value
      @setTargetBlank()  if @options.targetBlank
      @showToolbarActions()
      input.value = ""

    bindWindowActions: ->
      timerResize = undefined
      self = this
      window.addEventListener "resize", ->
        clearTimeout timerResize
        timerResize = setTimeout(->
          self.setToolbarPosition()  if self.toolbar.classList.contains("medium-editor-toolbar-active")
        , 100)

      this

    activate: ->
      i = undefined
      return  if @isActive
      @toolbar.style.display = "block"  if @toolbar isnt 'undefined'
      @isActive = true
      i = 0
      while i < @elements.length
        @elements[i].setAttribute "contentEditable", true
        i += 1
      @bindSelect()

    deactivate: ->
      i = undefined
      return  unless @isActive
      @isActive = false
      @toolbar.style.display = "none"  if @toolbar isnt 'undefined'
      document.documentElement.removeEventListener "mouseup", @checkSelectionWrapper
      i = 0
      while i < @elements.length
        @elements[i].removeEventListener "keyup", @checkSelectionWrapper
        @elements[i].removeEventListener "blur", @checkSelectionWrapper
        @elements[i].removeAttribute "contentEditable"
        i += 1

    bindPaste: ->
      return this  unless @options.forcePlainText
      i = undefined
      self = this
      pasteWrapper = (e) ->
        paragraphs = undefined
        html = ""
        p = undefined
        @classList.remove "medium-editor-placeholder"
        if e.clipboardData and e.clipboardData.getData
          e.preventDefault()
          unless self.options.disableReturn
            paragraphs = e.clipboardData.getData("text/plain").split(/[\r\n]/g)
            p = 0
            while p < paragraphs.length
              html += "<p>" + paragraphs[p] + "</p>"  if paragraphs[p] isnt ""
              p += 1
            document.execCommand "insertHTML", false, html
          else
            document.execCommand "insertHTML", false, e.clipboardData.getData("text/plain")

      i = 0
      while i < @elements.length
        @elements[i].addEventListener "paste", pasteWrapper
        i += 1
      this

    setPlaceholders: ->
      i = undefined
      activatePlaceholder = (el) ->
        el.classList.add "medium-editor-placeholder"  if el.textContent.replace(/^\s+|\s+$/g, "") is ""

      placeholderWrapper = (e) ->
        @classList.remove "medium-editor-placeholder"
        activatePlaceholder this  if e.type isnt "keypress"

      i = 0
      while i < @elements.length
        activatePlaceholder @elements[i]
        @elements[i].addEventListener "blur", placeholderWrapper
        @elements[i].addEventListener "keypress", placeholderWrapper
        i += 1
      this
) window, document