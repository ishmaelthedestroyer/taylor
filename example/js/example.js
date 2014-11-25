window.onload = function() {
  var editor = new Taylor('#target', {
    placeholder: 'This is placeholder text...',
    height: '1600px'
    /*
    ,
    override: {
      image: function() {
        alert('boom');
      }
    }
    */
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

  document.getElementById('insert-btn').addEventListener('click', function() {
    editor.insert('<img src="https://i.imgur.com/tZ68b9F.jpg" />');
  });

  document.getElementById('clear-btn').addEventListener('click', function() {
    editor.clear();
  });
};