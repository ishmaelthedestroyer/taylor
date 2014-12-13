var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

(function(window, document) {
  'use strict';
  var Taylor, bindButtons, bindFormatting, bindPaste, bindReturn, bindSelect, bindTab, bindTools, br2nl, checkSelection, checkSelectionElement, createButtons, createElements, createTools, execFormatBlock, extend, getSelectionData, getSelectionElement, getSelectionHtml, getSelectionStart, getSelectionText, initialize, isElement, isListItemChild, isNode, nl2br, parentElements, preview, restoreSelection, saveSelection, selection, selectionRange, setSelectedRange, setTargetBlank, triggerAnchorAction, trim;
  selection = null;
  selectionRange = null;
  parentElements = ['p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'blockquote', 'pre'];
  trim = function(text) {
    return text.replace(/^\s+|\s+$/g, "");
  };
  nl2br = function(str) {
    return str.replace(/\n/g, '<br />');
  };
  br2nl = function(str) {
    return str.replace(/<br\s*\/?>/mg, '\n');
  };
  extend = function(one, two) {
    var k, keys, _i, _len;
    if (!one) {
      return {};
    }
    if (!two || typeof two !== 'object') {
      return one;
    }
    keys = Object.keys(two);
    for (_i = 0, _len = keys.length; _i < _len; _i++) {
      k = keys[_i];
      one[k] = two[k];
    }
    return one;
  };
  isNode = function(o) {
    if (typeof Node === "object") {
      return o instanceof Node;
    } else {
      return o && typeof o === "object" && typeof o.nodeType === "number" && typeof o.nodeName === "string";
    }
  };
  isElement = function(o) {
    if (typeof HTMLElement === "object") {
      return o instanceof HTMLElement;
    } else {
      return o && typeof o === "object" && o !== null && o.nodeType === 1 && typeof o.nodeName === "string";
    }
  };
  saveSelection = function() {
    var i, len, ranges, sel;
    sel = window.getSelection();
    if (sel.getRangeAt && sel.rangeCount) {
      ranges = [];
      i = 0;
      len = sel.rangeCount;
      while (i < len) {
        ranges.push(sel.getRangeAt(i));
        ++i;
      }
      return ranges;
    }
    return null;
  };
  restoreSelection = function(saved) {
    var i, len, sel, _results;
    sel = window.getSelection();
    if (saved) {
      sel.removeAllRanges();
      i = 0;
      len = saved.length;
      _results = [];
      while (i < len) {
        sel.addRange(saved[i]);
        _results.push(++i);
      }
      return _results;
    }
  };
  getSelectionStart = function() {
    var node, startNode;
    node = document.getSelection().anchorNode;
    if (node && node.nodeType === 3) {
      startNode = node.parentNode;
    } else {
      startNode = node;
    }
    return startNode;
  };
  getSelectionText = function() {
    var text;
    text = "";
    if (window.getSelection) {
      text = window.getSelection().toString();
    } else {
      if (document.selection && document.selection.type !== "Control") {
        text = document.selection.createRange().text;
      }
    }
    return text;
  };
  getSelectionHtml = function() {
    var container, html, i, len, sel;
    html = '';
    if (window.getSelection) {
      sel = window.getSelection();
      if (sel.rangeCount) {
        container = document.createElement('div');
        i = 0;
        len = sel.rangeCount;
        while (i < len) {
          container.appendChild(sel.getRangeAt(i).cloneContents());
          ++i;
        }
        html = container.innerHTML;
      }
    } else if (document.selection) {
      if (document.selection.type === 'Text') {
        html = document.selection.createRange().htmlText;
      }
    }
    return html;
  };
  setSelectedRange = function(element, start, end) {
    var normalizedVal, range;
    element.focus();
    if (element.setSelectionRange) {
      return element.setSelectionRange(start, end);
    } else {
      if (element.createTextRange) {
        normalizedVal = element.value.replace(/\r\n/g, "\n");
        start -= normalizedVal.slice(0, start).split("\n").length - 1;
        end -= normalizedVal.slice(0, end).split("\n").length - 1;
        range = element.createTextRange();
        range.collapse(true);
        range.moveEnd('character', end);
        range.moveStart('character', start);
        return range.select();
      }
    }
  };
  isListItemChild = function(node) {
    var parentNode, tagName;
    parentNode = node.parentNode;
    tagName = parentNode.tagName.toLowerCase();
    while (parentElements.indexOf(tagName) === -1 && tagName !== 'div') {
      if (tagName === 'li') {
        return true;
      }
      parentNode = parentNode.parentNode;
      if (parentNode && parentNode.tagName) {
        tagName = parentNode.tagName.toLowerCase();
      } else {
        return false;
      }
    }
    return false;
  };
  checkSelection = function() {
    var newSelection, selectionElement;
    newSelection = window.getSelection();
    selectionElement = getSelectionElement();
    return checkSelectionElement(newSelection, selectionElement);
  };
  checkSelectionElement = function(newSelection, selectionElement) {
    var e;
    try {
      selection = newSelection;
      selectionRange = selection.getRangeAt(0);
    } catch (_error) {
      e = _error;
    }
  };
  getSelectionElement = function() {
    var current, e, err, getMediumElement, parent, range, result;
    try {
      selection = window.getSelection();
      range = selection.getRangeAt(0);
      current = range.commonAncestorContainer;
      parent = current.parentNode;
      result = null;
    } catch (_error) {
      e = _error;
      return null;
    }
    getMediumElement = function(e) {
      var err;
      parent = e;
      try {
        while (!parent.getAttribute('data-taylor-element')) {
          parent = parent.parentNode;
        }
      } catch (_error) {
        err = _error;
        return false;
      }
      return parent;
    };
    try {
      if (current.getAttribute('data-taylor-element')) {
        result = current;
      } else {
        result = getMediumElement(parent);
      }
    } catch (_error) {
      err = _error;
      result = getMediumElement(parent);
    }
    return result;
  };
  getSelectionData = function(element) {
    var tagName;
    tagName = '';
    if (element && element.tagName) {
      tagName = element.tagName.toLowerCase();
    }
    while (element && parentElements.indexOf(tagName) === -1) {
      element = element.parentNode;
      if (element && element.tagName) {
        tagName = element.tagName.toLowerCase();
      }
    }
    return {
      element: element,
      tagName: tagName
    };
  };
  execFormatBlock = function(type) {
    var selectionData;
    selectionData = getSelectionData(selection.anchorNode);
    if (type === 'blockquote' && selectionData.element && selectionData.element.parentNode.tagName.toLowerCase() === 'blockquote') {
      return document.execCommand('outdent', false, null);
    }
    if (selectionData.tagName === type) {
      type = 'p';
    }
    return document.execCommand('formatBlock', false, type);
  };
  triggerAnchorAction = function(targetBlank) {
    var html, innerText, link;
    if (selection.anchorNode.parentNode.tagName.toLowerCase() === 'a') {
      return document.execCommand('unlink', false, null);
    } else {
      link = prompt('Please enter the url you want to link to.', 'http://');
      if (link.toLowerCase().indexOf('http') === -1) {
        link = 'http://' + link;
      }
      innerText = getSelectionText();
      html = '<a href="' + link + '">' + innerText + '</a>';
      document.execCommand('insertHTML', false, html);
      if (targetBlank) {
        return setTargetBlank();
      }
    }
  };
  setTargetBlank = function() {
    var element, i, _results;
    element = getSelectionStart();
    if (element.tagName.toLowerCase() === "a") {
      return element.target = "_blank";
    } else {
      element = element.getElementsByTagName('a');
      i = 0;
      _results = [];
      while (i < element.length) {
        element[i].target = "_blank";
        _results.push(++i);
      }
      return _results;
    }
  };
  createElements = function(obj) {
    var body, clear, controls, heading, textarea, tools;
    obj._container.className += ' taylor-editor';
    obj._container.className += ' panel';
    obj._container.className += ' panel-default';
    obj._container.style.width = obj._options.width;
    heading = document.createElement('div');
    heading.className = 'panel-heading';
    heading.style.height = 'auto';
    obj._container.appendChild(heading);
    controls = document.createElement('ul');
    controls.className = 'nav';
    controls.className += ' navbar-nav';
    controls.className += ' taylor-controls';
    heading.appendChild(controls);
    tools = document.createElement('ul');
    tools.className = 'nav';
    tools.className += ' navbar-nav';
    tools.className += ' navbar-right';
    tools.className += ' taylor-tools';
    heading.appendChild(tools);
    obj._buttons = createButtons(obj, controls);
    obj._tools = createTools(tools, obj._options.tools);
    clear = document.createElement('div');
    clear.style.clear = 'both';
    heading.appendChild(clear);
    /*
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
    */

    body = obj._editable = document.createElement('div');
    body.className = 'panel-body';
    body.className += ' form-control';
    body.className += ' taylor-editable';
    body.setAttribute('data-taylor-editable', true);
    body.style.height = obj._options.height;
    body.style.overflowY = 'auto';
    body.contentEditable = true;
    body.innerHTML = obj._HTML;
    body.setAttribute('placeholder', obj._options.placeholder);
    obj._container.appendChild(body);
    textarea = obj._textarea = document.createElement('textarea');
    textarea.className = 'textarea';
    textarea.className += ' form-control';
    textarea.className += ' taylor-textarea';
    textarea.style.height = obj._options.height;
    textarea.style.display = 'none';
    textarea.placeholder = obj._options.placeholder;
    obj._container.appendChild(textarea);
    return obj;
  };
  createButtons = function(obj, parent) {
    var buttons, control, createButton, elements, k, key, keys, override, templates, value, _i, _len, _ref;
    buttons = obj._options.buttons;
    templates = {
      bold: {
        name: 'bold',
        action: 'bold',
        element: 'b',
        "class": 'fa fa-bold',
        content: ''
      },
      italic: {
        name: 'italic',
        action: 'italic',
        element: 'i',
        "class": 'fa fa-italic',
        content: ''
      },
      underline: {
        name: 'underline',
        action: 'underline',
        element: 'u',
        "class": 'fa fa-underline',
        content: ''
      },
      strikethrough: {
        name: 'strikethrough',
        action: 'strikethrough',
        element: 'strike',
        "class": 'fa fa-strikethrough',
        content: ''
      },
      h: {
        name: 'h',
        action: 'append-h1',
        content: '<b>H</b>',
        element: 'h1'
      },
      h2: {
        name: 'h2',
        action: 'append-h2',
        content: '<b>H2</b>',
        element: 'h2'
      },
      h3: {
        name: 'h3',
        action: 'append-h3',
        content: '<b>H3</b>',
        element: 'h3'
      },
      h4: {
        name: 'h4',
        action: 'append-h4',
        content: '<b>H2</b>',
        element: 'h4'
      },
      h5: {
        name: 'h5',
        action: 'append-h5',
        content: '<b>H5</b>',
        element: 'h5'
      },
      h6: {
        name: 'h6',
        action: 'append-h6',
        content: '<b>H6</b>',
        element: 'h6'
      },
      subscript: {
        name: 'subscript',
        action: 'subscript',
        element: 'sub',
        "class": 'fa fa-strikethrough',
        content: ''
      },
      blockquote: {
        name: 'blockquote',
        action: 'append-blockquote',
        element: 'blockquote',
        "class": 'fa fa-quote-right',
        content: ''
      },
      unorderedlist: {
        name: 'unorderedlist',
        action: 'insertunorderedlist',
        element: 'ul',
        "class": 'fa fa-list-ul',
        content: ''
      },
      orderedlist: {
        name: 'orderedlist',
        action: 'insertorderedlist',
        element: 'ol',
        "class": 'fa fa-list-ol',
        content: ''
      },
      pre: {
        name: 'pre',
        action: 'append-pre',
        element: 'pre',
        "class": 'fa fa-code',
        content: ''
      },
      anchor: {
        name: 'anchor',
        action: 'anchor',
        element: 'a',
        "class": 'fa fa-link',
        content: ''
      },
      image: {
        name: 'image',
        action: 'image',
        element: 'img',
        "class": 'fa fa-picture-o',
        content: ''
      }
    };
    if (obj._options.templates) {
      _ref = obj._options.templates;
      for (control in _ref) {
        override = _ref[control];
        for (key in override) {
          value = override[key];
          templates[control][key] = value;
        }
      }
    }
    elements = [];
    keys = Object.keys(templates);
    createButton = function(template) {
      var btn, li, span, _ref1;
      if (!(_ref1 = template.name, __indexOf.call(keys, _ref1) >= 0)) {
        throw new Error('That button type does not exist!');
      }
      li = document.createElement('li');
      parent.appendChild(li);
      btn = document.createElement('button');
      btn.className = 'taylor-btn';
      btn.className += ' taylor-btn-' + template.name;
      btn.setAttribute('data-taylor-btn-action', template.action);
      li.appendChild(btn);
      span = document.createElement('span');
      span.className = template["class"];
      span.innerHTML = template.content || '';
      btn.appendChild(span);
      template.element = btn;
      return template;
    };
    elements = [];
    for (_i = 0, _len = buttons.length; _i < _len; _i++) {
      k = buttons[_i];
      elements.push(createButton(templates[k]));
    }
    return elements;
  };
  createTools = function(parent, tools) {
    var createTool, elements, k, templates, _i, _len;
    templates = {
      preview: {
        name: 'preview',
        action: 'preview',
        "class": 'fa fa-eye',
        content: ''
      },
      help: {
        name: 'help',
        action: 'help',
        "class": 'fa fa-question',
        content: ''
      }
    };
    createTool = function(template) {
      var btn, li, span;
      li = document.createElement('li');
      parent.appendChild(li);
      btn = document.createElement('button');
      btn.className = 'taylor-btn';
      btn.className += ' taylor-tool-' + template.name;
      btn.setAttribute('data-taylor-btn-action', template.action);
      li.appendChild(btn);
      span = document.createElement('span');
      span.className = template["class"];
      span.innerHTML = template.content || '';
      btn.appendChild(span);
      template.element = btn;
      return template;
    };
    elements = [];
    for (_i = 0, _len = tools.length; _i < _len; _i++) {
      k = tools[_i];
      elements.push(createTool(templates[k]));
    }
    return elements;
  };
  bindButtons = function(obj, buttons) {
    var btn, overrides, _fn, _i, _len;
    if (obj._options.override) {
      overrides = Object.keys(obj._options.override);
    } else {
      overrides = [];
    }
    _fn = function(btn) {
      if (overrides.indexOf(btn.name) > -1) {
        btn.element.addEventListener('click', obj._options.override[btn.name], false);
        return false;
      }
      return btn.element.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        if (selection) {
          checkSelection();
        }
        if (btn.action.indexOf('append-') > -1) {
          execFormatBlock(btn.action.replace('append-', ''));
        } else if (btn.action === 'anchor') {
          triggerAnchorAction(obj._options.targetBlank);
        } else if (btn.action === 'image') {
          document.execCommand('insertImage', false, window.getSelection());
        } else {
          document.execCommand(btn.action, false, null);
        }
        return this;
      });
    };
    for (_i = 0, _len = buttons.length; _i < _len; _i++) {
      btn = buttons[_i];
      _fn(btn);
    }
  };
  bindTools = function(obj, tools) {
    var tool, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = tools.length; _i < _len; _i++) {
      tool = tools[_i];
      _results.push((function(tool) {
        if (tool.action === 'preview') {
          return tool.element.addEventListener('click', function() {
            return preview(obj);
          });
        }
      })(tool));
    }
    return _results;
  };
  bindSelect = function(element, delay) {
    var doc, timer, wrapper;
    timer = null;
    wrapper = function() {
      clearTimeout(timer);
      return timer = setTimeout(function() {
        return checkSelection();
      }, delay || 0);
    };
    doc = document.documentElement;
    doc.addEventListener('mouseup', wrapper);
    element.addEventListener('keyup', wrapper);
    element.addEventListener('blur', wrapper);
    return this;
  };
  bindPaste = function(element, disableReturn) {
    var wrapper;
    wrapper = function(e) {
      var html, i, paragraphs;
      html = '';
      element.classList.remove('taylor-editor-placeholder');
      if (e.clipboardData && e.clipboardData.getData) {
        e.preventDefault();
        if (disableReturn) {
          paragraphs = e.clipboardData.getData('text/plain').split(/[\r\n]/g);
          i = 0;
          while (i < paragraphs.length) {
            if (paragraphs[i] !== '') {
              html += '<p>' + paragraphs[i] + '</p>';
            }
            ++i;
          }
          return document.execCommand('insertHTML', false, html);
        } else {
          return document.execCommand('insertHTML', false, e.clipboardData.getData('text/plain'));
        }
      }
    };
    element.addEventListener('paste', wrapper);
    return this;
  };
  bindFormatting = function(element, disableReturn) {
    element.addEventListener('keyup', function(e) {
      var node, tagName;
      node = getSelectionStart();
      if (node && node.getAttribute('data-taylor-editable' && !node.children.length && !disableReturn)) {
        document.execCommand('formatBlock', false, 'p');
      }
      if (e.which === 13 && !e.shiftKey) {
        node = getSelectionStart();
        tagName = node.tagName.toLowerCase();
        if (!disableReturn && tagName !== 'li' && !isListItemChild(node)) {
          document.execCommand('formatBlock', false, 'p');
          if (tagName === 'a') {
            return document.execCommand('unlink', false, null);
          }
        }
      }
    });
    return this;
  };
  bindTab = function(element) {
    element.addEventListener('keydown', function(e) {
      var tag;
      if (e.which === 9) {
        e.preventDefault();
        tag = getSelectionStart().tagName.toLowerCase();
        if (tag === 'pre') {
          return document.execCommand('insertHTML', null, '    ');
        } else {
          return document.execCommand('insertHTML', null, '&nbsp;&nbsp;&nbsp;&nbsp;');
        }
      }
    });
    return this;
  };
  bindReturn = function(element, disableReturn) {
    element.addEventListener('keypress', function(e) {
      if (e.which === 13) {
        if (disableReturn || element.getAttribute('data-disable-return')) {
          return e.preventDefault();
        }
      }
    });
    return this;
  };
  initialize = function(obj, options) {
    var defaults;
    if (!obj._container) {
      throw new Error('Taylor target element does not exist!');
    }
    defaults = {
      width: '100%',
      height: '500px',
      placeholder: '',
      anchorPlaceholder: 'Type a URL',
      buttons: ['bold', 'italic', 'underline', 'strikethrough', 'h', 'orderedlist', 'unorderedlist', 'blockquote', 'pre', 'anchor', 'image'],
      tools: ['preview'],
      disableReturn: false,
      targetBlank: true,
      delay: 0,
      sticky: false
    };
    obj._options = extend(defaults, options);
    createElements(obj);
    bindButtons(obj, obj._buttons || []);
    bindTools(obj, obj._tools || []);
    bindSelect(obj._container, obj._options.delay);
    bindPaste(obj._container, obj._options.disableReturn);
    bindFormatting(obj._container, obj._options.disableReturn);
    bindTab(obj._container);
    bindReturn(obj._container);
    return this;
  };
  preview = function(obj) {
    var editable, previewBtn, previewIcon, textarea;
    editable = obj._container.getElementsByClassName('taylor-editable')[0];
    textarea = obj._container.getElementsByClassName('taylor-textarea')[0];
    previewBtn = obj._container.getElementsByClassName('taylor-tool-preview')[0];
    previewIcon = previewBtn.getElementsByClassName('fa')[0];
    if (editable.style.display !== 'none') {
      editable.style.display = 'none';
      textarea.style.display = '';
      textarea.value = br2nl(editable.innerHTML);
      previewIcon.classList.remove('fa-eye');
      return previewIcon.classList.add('fa-eye-slash');
    } else {
      editable.style.display = '';
      textarea.style.display = 'none';
      editable.innerHTML = nl2br(textarea.value);
      previewIcon.classList.add('fa-eye');
      return previewIcon.classList.remove('fa-eye-slash');
    }
  };
  Taylor = function(container, options) {
    var editable;
    if (!(this instanceof Taylor)) {
      return new Taylor(container, options);
    }
    if (isElement(container)) {
      this._container = container;
    } else {
      this._container = document.querySelector(container);
    }
    if (!this._container) {
      throw new Error('Couldn\'t initialize Taylor, element not found!');
    }
    this._HTML = trim(this._container.innerHTML);
    this._editable = null;
    this._textarea = null;
    this._buttons = [];
    if (!this._HTML.length) {
      this._HTML = '<p></p>';
    }
    this._container.innerHTML = '';
    initialize(this, options || {});
    editable = this._container.getElementsByClassName('taylor-editable')[0];
    setSelectedRange(editable, 0, 0);
    this._options.onLoad && this._options.onLoad(this, options);
    return this;
  };
  Taylor.prototype["export"] = function() {
    var editable, textarea;
    editable = this._container.getElementsByClassName('taylor-editable')[0];
    textarea = this._container.getElementsByClassName('taylor-textarea')[0];
    if (editable.style.display !== 'none') {
      return br2nl(editable.innerHTML);
    } else {
      return textarea.value;
    }
  };
  Taylor.prototype.clear = function() {
    var editable, textarea;
    editable = this._container.getElementsByClassName('taylor-editable')[0];
    textarea = this._container.getElementsByClassName('taylor-textarea')[0];
    editable.innerHTML = '';
    return textarea.innerHTML = '';
  };
  Taylor.prototype.set = function(text) {
    var editable, textarea;
    editable = this._container.getElementsByClassName('taylor-editable')[0];
    textarea = this._container.getElementsByClassName('taylor-textarea')[0];
    editable.innerHTML = text;
    return textarea.innerHTML = text;
  };
  Taylor.prototype.insert = function(text) {
    var editable, textarea;
    editable = this._container.getElementsByClassName('taylor-editable')[0];
    textarea = this._container.getElementsByClassName('taylor-textarea')[0];
    editable.innerHTML = editable.innerHTML + text;
    return textarea.innerHTML = textarea.innerHTML + text;
  };
  Taylor.prototype.getSelectionStart = function() {
    return selection;
  };
  Taylor.prototype.isFocused = function() {
    var elementContainsSelection, isOrContains;
    isOrContains = function(node, container) {
      while (node) {
        if (node === container) {
          return true;
        }
        node = node.parentNode;
      }
      return false;
    };
    elementContainsSelection = function(el) {
      var e, i, sel;
      sel = void 0;
      if (window.getSelection) {
        sel = window.getSelection();
        try {
          if (sel.rangeCount > 0) {
            i = 0;
            while (i < sel.rangeCount) {
              if (!isOrContains(sel.getRangeAt(i).commonAncestorContainer, el)) {
                return false;
              }
              ++i;
            }
            return true;
          }
        } catch (_error) {
          e = _error;
          return false;
        }
      } else {
        if ((sel = document.selection) && sel.type !== "Control") {
          return isOrContains(sel.createRange().parentElement(), el);
        }
      }
      return false;
    };
    return elementContainsSelection(this._editable || elementContainsSelection(this._textarea));
  };
  /*
  Taylor::setCursor = (position) ->
    position = 0 if !position
  
    if @_editable.style.display isnt 'none'
      elem = @_editable
    else
      elem = @_textarea
  
    if elem.setSelectionRange
      elem.focus()
      elem.setSelectionRange 0, 0
    else if elem.createTextRange
      range = elem.createTextRange()
      range.moveStart "character", 0
      range.select()
    else
      elem.focus()
  */

  Taylor.prototype.focus = function() {
    var placeCaretAtEnd;
    placeCaretAtEnd = function(el) {
      var range, sel, textRange;
      el.focus();
      if (typeof window.getSelection !== "undefined" && typeof document.createRange !== "undefined") {
        range = document.createRange();
        range.selectNodeContents(el);
        range.collapse(false);
        sel = window.getSelection();
        sel.removeAllRanges();
        return sel.addRange(range);
      } else if (typeof document.body.createTextRange !== "undefined") {
        textRange = document.body.createTextRange();
        textRange.moveToElementText(el);
        textRange.collapse(false);
        return textRange.select();
      }
    };
    if (this._editable.style.display !== 'none') {
      return placeCaretAtEnd(this._editable);
    } else {
      return placeCaretAtEnd(this._textarea);
    }
  };
  return window.Taylor = Taylor;
})(window, document);
