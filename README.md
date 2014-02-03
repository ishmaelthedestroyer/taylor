#About

<p>Taylor is a lightweight HTML editor ( &lt; 1000 lines) written in Coffeescript and compiled into Javascript for use on the web. It's open-source, MIT-licensed (do whatever the hell you want with it), but please consider contributing to the source code to help better it. The goal is to eventually eliminate all dependencies to make Taylor a standalone text-editor, use primarily targeted towards developers' blogs, hyper-text comment systems, and such.
<br /><br />
The source code can be found at <a href='http://github.com/ishmaelthedestroyer/taylor' target='_blank'>http://github.com/ishmaelthedestroyer/taylor</a>
<br />
The demo can be found at <a href='http://taylor-editor.herokuapp.com' target='_blank'>http://taylor-editor.herokuapp.com</a>
<br />
The beef of the source code (Coffeescript) can be found here:<a href='https://github.com/ishmaelthedestroyer/taylor/blob/master/js/taylor.coffee' target='_blank'>https://github.com/ishmaelthedestroyer/taylor/blob/master/js/taylor.coffee</a></p>

<div class='clear-50'></div>

#TODO

<ul>
  <li>
    <p>Documentation in the works.</p>
  </li>
  <li>
    <p>Methods for importing + exporting text as well as utility functions for basic statistics.</p>
  </li>
  <li>
    <p>Sticky utility bar that sticks to the top after scrolling past.</p>
  </li>
</ul>

<div class='clear-50'></div>

#Dependencies

<p>Taylor requires the Bootstrap 3.0 and Font Awesome CSS + fonts, as well as the included CSS and Javascript files. Taylor does <b>NOT</b> depend on jQuery. Add the dependencies in the head of your document like so: </p>

<pre>&lt;link media='screen' rel='stylesheet' href='/path/to/bootstrap.css' />
&lt;link media='screen' rel='stylesheet' href='/path/to/font-awesome.css' />
&lt;link media='screen' rel='stylesheet' href='/path/to/taylor.css' />
&lt;script src='/path/to/taylor.js'&gt;&lt;/script&gt;</pre>

<div class='clear-50'></div>

#Markup

<pre>&lt;div id='target'&gt;&lt;/div&gt;</pre>



<div class='clear-50'></div>

#Javascript (Initialize)

<pre>&lt;script&gt;
var editor = new Taylor('target', {
height: '1000px'
});
&lt;/script&gt;</pre>


<div class='clear-50'></div>

<p class='lead'>Properties</p>

<table class='table table-hover'>
  <thead>
    <th width='20%'>Attribute</th>
    <th width='40%'>Description</th>
    <th width='40%'>Default</th>
  </thead>
  <tbody>
    <tr>
      <td><b>Width</b></td>
      <td>Width of the editor (takes percentage or pixels).</td>
      <td>100%</td>
    </tr>
    <tr>
      <td><b>Height</b></td>
      <td>Height of the editor (percentage or pixels).</td>
      <td>500px</td>
    </tr>
    <tr>
      <td><b>Buttons</b></td>
      <td>An array of buttons to include in the utility bar.</td>
      <td>Documentation in the works.</td>
    </tr>
  </tbody>
</table>