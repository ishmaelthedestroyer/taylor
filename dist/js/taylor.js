/** 
 * taylor-editor - v0.0.0 - 2014-01-22
 * http://taylor-editor.herokuapp.com 
 * 
 * Copyright (c) 2014 ishmaelthedestroyer
 * Licensed  <>
 * */
var Taylor;

Taylor = function(_container, _params) {
  if (!(this instanceof Taylor)) {
    return new Taylor(_container, _params);
  }
  this._container = document.getElementById(_container);
  this._textarea = null;
  this._bold = null;
  this._italic = null;
  this._header = null;
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
  return this._createListeners();
};

Taylor.prototype._createElements = function() {
  var _body, _c, _clear, _controls, _heading, _label, _textarea, _tools;
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
  _controls.appendChild(_c);
  _label = document.createElement('span');
  _label.className = 'glyphicon';
  _label.className += ' glyphicon-bold';
  _c.appendChild(_label);
  _c = document.createElement('li');
  _controls.appendChild(_c);
  _label = document.createElement('span');
  _label.className = 'glyphicon';
  _label.className += ' glyphicon-italic';
  _c.appendChild(_label);
  _c = document.createElement('li');
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
  _textarea = document.createElement('textarea');
  _textarea.className = 'form-control';
  _textarea.rows = this.rows;
  _body.appendChild(_textarea);
  this._textarea = _textarea;
  return this;
};

Taylor.prototype._createListeners = function() {
  var _this = this;
  this._textarea.addEventListener('blur', function(e) {
    console.log('blurred');
    _this._textarea.focus();
    return _this;
  }, false);
  return this;
};

Taylor.prototype["import"] = function() {};

Taylor.prototype.showEditor = function() {};

Taylor.prototype.showPreview = function() {};

Taylor.prototype["export"] = function() {};

Taylor.prototype.exportText = function() {};

Taylor.prototype.exportHTML = function() {};
