window.onload = function() {
  var editor = new Taylor('#target', {
    height: '1600px'
    // tools: []
  });

  // console.log(editor)

  document.getElementById('export-btn').addEventListener('click', function() {
    var data = editor.export();
    console.log(data);
  });
}
