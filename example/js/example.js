window.onload = function() {
  var editor = new Taylor('#target', {
    height: '1600px'
    // tools: []
    /*
    onLoad: function(taylor, options) {
      console.log('Firing onLoad.', taylor, options);
    }
    */
  });

  // console.log(editor)

  document.getElementById('export-btn').addEventListener('click', function() {
    editor.export();
    console.log(data);
  });

  document.getElementById('clear-btn').addEventListener('click', function() {
    editor.clear();
  });
}
