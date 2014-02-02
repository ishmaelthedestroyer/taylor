/** 
 * taylor-editor - v0.0.0 - 2014-02-02
 * http://taylor-editor.herokuapp.com 
 * 
 * Copyright (c) 2014 ishmaelthedestroyer
 * Licensed  <>
 * */
var Taylor;

Taylor = function(_container, _options) {
  var _defaults, _params;
  if (!(this instanceof Taylor)) {
    return new Taylor(_container, _options);
  }
  this._container = document.getElementById(_container);
  this._id = 'taylor-editor' + document.querySelectorAll('.taylor-editor').length;
  this._parentElements = ['p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'blockquote', 'pre'];
  _defaults = {
    placeholder: '...',
    anchorPlaceholder: '...',
    buttons: ['bold', 'italic', 'underline', 'anchor', 'header1', 'header2', 'quote', 'image'],
    disableReturn: false,
    targetBlank: false,
    delay: 0,
    sticky: true
  };
  this._options = this._extend(_options, _defaults);
  this._bold = null;
  this._italic = null;
  this._header = null;
  this._anchor = null;
  this._blockquote = null;
  this._unorderedList = null;
  this._orderedList = null;
  this._image = null;
  this._preview = null;
  this._help = null;
  this._expand = null;
  this._collapse = null;
  this._textarea = null;
  this._editable = null;
  this._textareaVisible = false;
  this._editableVisible = false;
  this._selectedStart = null;
  this._selectedEnd = null;
  _params = _params || {};
  this.rows = _params.rows || 10;
  this.entities = {
    '&': '&amp;',
    '>': '&gt;',
    '<': '&lt;',
    '"': '&quot;',
    "'": '&#39;'
  };
  this._init();
  return this;
};

Taylor.prototype._init = function() {
  this._createElements();
  this._bindSelect(this._editable);
  this._bindPaste(this._editable);
  this._setPlaceholders(this._editable);
  this._bindFormatting(this._editable);
  this._bindReturn(this._editable);
  this._bindTab(this._editable);
  return this._bindButtons();
};

Taylor.prototype._createElements = function() {
  var _body, _c, _clear, _controls, _editable, _heading, _label, _tools;
  if (this._container === null) {
    throw new Error('Container doesn\'t exist.');
  }
  this._container.className += ' taylor';
  this._container.className += ' panel';
  this._container.className += ' panel-default';
  _heading = document.createElement('div');
  _heading.className = 'panel-heading';
  _heading.style.height = 'auto';
  this._container.appendChild(_heading);
  _controls = document.createElement('ul');
  _controls.className = 'nav';
  _controls.className += ' navbar-nav';
  _heading.appendChild(_controls);
  _c = document.createElement('li');
  _c.id = 'taylor-bold-btn';
  this._bold = _c;
  _controls.appendChild(_c);
  _label = document.createElement('span');
  _label.className = 'glyphicon';
  _label.className += ' glyphicon-bold';
  this._bold = _label;
  _c.appendChild(_label);
  _c = document.createElement('li');
  _c.id = 'taylor-italic-btn';
  this._italic = _c;
  _controls.appendChild(_c);
  _label = document.createElement('span');
  _label.className = 'glyphicon';
  _label.className += ' glyphicon-italic';
  _c.appendChild(_label);
  _c = document.createElement('li');
  _c.id = 'taylor-header-btn';
  this._header = _c;
  _controls.appendChild(_c);
  _label = document.createElement('span');
  _label.className = 'glyphicon';
  _label.className += ' glyphicon-header';
  _c.appendChild(_label);
  _c = document.createElement('li');
  _controls.appendChild(_c);
  _label = document.createElement('span');
  _label.className = 'glyphicon';
  _label.className += ' glyphicon-globe';
  _c.style.marginLeft = '75px';
  _c.appendChild(_label);
  _c = document.createElement('li');
  _controls.appendChild(_c);
  _label = document.createElement('span');
  _label.className = 'glyphicon';
  _label.className += ' glyphicon-comment';
  _c.appendChild(_label);
  _c = document.createElement('li');
  _controls.appendChild(_c);
  _label = document.createElement('span');
  _label.className = 'glyphicon';
  _label.className += ' glyphicon-picture';
  _c.appendChild(_label);
  _c = document.createElement('li');
  _controls.appendChild(_c);
  _label = document.createElement('span');
  _label.className = 'glyphicon';
  _label.className += ' glyphicon-th-list';
  _c.appendChild(_label);
  _tools = document.createElement('ul');
  _tools.className = 'nav';
  _tools.className += ' navbar-nav';
  _tools.className += ' navbar-right';
  _heading.appendChild(_tools);
  _c = document.createElement('li');
  _c.style.width = 'auto';
  _tools.appendChild(_c);
  _label = document.createElement('span');
  _label.className = 'glyphicon';
  _label.className += ' glyphicon-eye-open';
  _label.style.marginRight = '10px';
  _c.appendChild(_label);
  _label = document.createElement('span');
  _label.innerHTML = 'Preview';
  _c.appendChild(_label);
  _c = document.createElement('li');
  _c.style.width = 'auto';
  _tools.appendChild(_c);
  _label = document.createElement('span');
  _label.className = 'glyphicon';
  _label.className += ' glyphicon-question-sign';
  _label.style.marginRight = '10px';
  _c.appendChild(_label);
  _label = document.createElement('span');
  _label.innerHTML = 'Help';
  _c.appendChild(_label);
  _c = document.createElement('li');
  _tools.appendChild(_c);
  _label = document.createElement('span');
  _label.className = 'glyphicon';
  _label.className += ' glyphicon-fullscreen';
  _c.appendChild(_label);
  _clear = document.createElement('div');
  _clear.style.clear = 'both';
  _heading.appendChild(_clear);
  _body = document.createElement('div');
  _body.className = 'panel-body';
  _body.style.height = 'auto';
  _body.style.padding = 0;
  _body.style.margin = 0;
  this._container.appendChild(_body);
  /*
  _textarea = document.createElement 'textarea'
  _textarea.className = 'form-control'
  _textarea.rows = @rows
  _textarea.style.display = 'none'
  
  _body.appendChild _textarea
  @_textarea = _textarea
  */

  _editable = document.createElement('div');
  _editable.className = 'taylor-editable';
  _editable.className += ' form-control';
  _editable.setAttribute('data-taylor-editable', true);
  _editable.style.height = 'auto';
  _editable.contentEditable = true;
  _body.appendChild(_editable);
  this._editable = _editable;
  return this;
};

Taylor.prototype._extend = function(b, a) {
  var prop;
  if (b === void 0) {
    return a;
  }
  for (prop in a) {
    if (a.hasOwnProperty(prop && !b.hasOwnProperty(prop))) {
      b[prop] = a[prop];
    }
  }
  return b;
};

Taylor.prototype._saveSelection = function() {
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

Taylor.prototype._restoreSelection = function(saved) {
  var i, len, sel, _results;
  sel = window.getSelection();
  if (saved) {
    sel.removeAllRanges();
    i = 0;
    len = saved.length;
    _results = [];
    while (i < len) {
      sel.addRange(saved[i]);
      _results.push(i += 1);
    }
    return _results;
  }
};

Taylor.prototype._getSelectionStart = function() {
  var node, startNode;
  node = document.getSelection().anchorNode;
  if (node && node.nodeType === 3) {
    startNode = node.parentNode;
  } else {
    startNode = node;
  }
  return startNode;
};

Taylor.prototype._getSelectionHtml = function() {
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
        i += 1;
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

Taylor.prototype._bindFormatting = function(element) {
  var _this = this;
  console.log('_bindFormatting() fired.');
  element.addEventListener('keyup', function(e) {
    var node, tagName;
    node = _this._getSelectionStart();
    if (node && node.getAttribute('data-taylor-editable' && !node.children.length && (!_this._options.disableReturn || node.getAttribute('data-disable-return')))) {
      document.execCommand('formatBlock', false, 'p');
    }
    if (e.which === 13 && !e.shiftKey) {
      node = _this._getSelectionStart();
      tagName = node.tagName.toLowerCase();
      if (!(_this._options.disableReturn || element.getAttribute('data-disable-return')) && tagName !== 'li' && !_this._isListItemChild(node)) {
        document.execCommand('formatBlock', false, 'p');
        if (tagName === 'a') {
          return document.execCommand('unlink', false, null);
        }
      }
    }
  });
  return this;
};

Taylor.prototype._bindReturn = function(element) {
  var _this = this;
  console.log('_bindReturn() fired.');
  element.addEventListener('keypress', function(e) {
    if (e.which === 13) {
      if (_this._options.disableReturn || element.getAttribute('data-disable-return')) {
        return e.preventDefault();
      }
    }
  });
  return this;
};

Taylor.prototype._bindTab = function(element) {
  var _this = this;
  console.log('_bindTab() fired.');
  element.addEventListener('keydown', function(e) {
    var tag;
    if (e.which === 9) {
      tag = _this._getSelectionStart().tagName.toLowerCase();
      if (tag === 'pre') {
        e.preventDefault();
        return document.execCommand('insertHTML', null, '    ');
      }
    }
  });
  return this;
};

Taylor.prototype._bindSelect = function(element) {
  var timer, _checkSelection, _doc,
    _this = this;
  console.log('_bindSelect() fired.');
  timer = null;
  _checkSelection = this._checkSelection;
  this._checkSelectionWrapper = function() {
    console.log('Taylor _checkSelectionWrapper eventListener fired.');
    clearTimeout(timer);
    return timer = setTimeout(function() {
      return _checkSelection();
    }, _this._options.delay);
  };
  _doc = document.documentElement;
  _doc.addEventListener('mouseup', this._checkSelectionWrapper);
  element.addEventListener('keyup', this._checkSelectionWrapper);
  element.addEventListener('blur', this._checkSelectionWrapper);
  return this;
};

Taylor.prototype._bindPaste = function(element) {
  var wrapper,
    _this = this;
  console.log('_bindPaste() fired.');
  wrapper = function(e) {
    var html, i, paragraphs;
    console.log('Taylor _bindPaste eventListener fired.');
    html = '';
    element.classList.remove('taylor-editor-placeholder');
    if (e.clipboardData && e.clipboardData.getData) {
      e.preventDefault();
      if (_this._options.disableReturn) {
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

Taylor.prototype._bindWindowActions = function() {
  var _this = this;
  return window.addEventListener('resize', function() {
    return console.log('Taylor: window resize eventListener fired.');
  });
};

Taylor.prototype._bindButtons = function() {
  var bindButton,
    _this = this;
  bindButton = function(element, action) {
    console.log('Binding button: ' + action);
    return element.addEventListener('mousedown', function(e) {
      e.preventDefault();
      e.stopPropagation();
      if (!_this._selection) {
        _this._checkSelection();
      }
      if (action.indexOf('append-') > -1) {
        _this._execFormatBlock(action.replace('append-', ''));
      } else if (action === 'anchor') {
        _this._triggerAnchorAction(e);
      } else if (action === 'image') {
        document.execCommand('insertImage', false, window.getSelection());
      } else {
        document.execCommand(action, false, null);
      }
      return _this;
    });
  };
  bindButton(this._bold, 'bold');
  bindButton(this._italic, 'italic');
  bindButton(this._header, 'header1');
  return this;
};

Taylor.prototype._execFormatBlock = function(type) {
  var selectionData;
  selectionData = this._getselectionData(this._selection.anchorNode);
  if (type === 'blockquote' && selectionData.el && selectionData.el.parentNode.tagName.toLowerCase() === 'blockquote') {
    return document.execCommand('outdent', false, null);
  }
  if (selectionData.tagName === type) {
    type = 'p';
  }
  return document.execCommand('formatBlock', false, type);
};

Taylor.prototype._triggerAnchorAction = function() {
  if (this._selection.anchorNode.parentNode.tagName.toLowerCase() === 'a') {
    return document.execCommand('unlink', false, null);
  } else {
    return console.log('TODO');
  }
};

Taylor.prototype._setPlaceholders = function(element) {
  var activate, wrapper;
  console.log('Firing _setPlaceholders initialize function.');
  activate = function() {
    console.log('Firing Taylor::_setPlaceholder::activate()');
    if (element.textContent.replace(/^\s+|\s+$/g, '') === '') {
      console.log('Adding placeholder.');
      return element.classList.add('taylor-editor-placeholder');
    }
  };
  wrapper = function(e) {
    console.log('Firing Taylor::_setPlaceholder::remove()');
    element.classList.remove('taylor-editor-placeholder');
    if (e.type !== 'keypress') {
      return activate();
    }
  };
  element.addEventListener('blur', wrapper);
  element.addEventListener('keypress', wrapper);
  return this;
};

Taylor.prototype._checkSelection = function() {
  /*
  newSelection = window.getSelection()
  if newSelection.toString().trim() is '' or
  @_options
  return true
  */

};

Taylor.prototype._getSelectionElement = function() {
  var current, err, getMediumElement, parent, range, result, selection;
  selection = window.getSelection();
  range = selection.getRangeAt(0);
  current = range.commonAncestorContainer;
  parent = current.parentNode;
  result = null;
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

Taylor.prototype._isListItemChild = function(node) {
  var parentNode, tagName;
  parentNode = node.parentNode;
  tagName = parentNode.tagName.toLowerCase();
  while (this._parentElements.indexOf(tagName) === -1 && tagName !== 'div') {
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

Taylor.prototype.characterCount = function() {};

Taylor.prototype.wordCount = function() {};

Taylor.prototype.lineCount = function() {};

Taylor.prototype.sentenceCount = function() {};

Taylor.prototype.paragraphCount = function() {};

Taylor.prototype.clear = function() {};

Taylor.prototype.undo = function() {};

Taylor.prototype.redo = function() {};

Taylor.prototype["import"] = function() {};

Taylor.prototype["export"] = function() {};

Taylor.prototype.exportText = function() {};

Taylor.prototype.showEditor = function() {};

Taylor.prototype.showPreview = function() {};

Taylor.prototype["export"] = function() {};
