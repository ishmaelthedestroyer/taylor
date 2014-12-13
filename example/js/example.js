window.onload = function() {
  var editor = new Taylor('#target', {
    placeholder: 'This is placeholder text...',
    height: '1600px',
    templates: {
      image: {
        // class: 'fa fa-link'
        content: [
          '<form id="taylor-file-input-form">',
          '<input id="taylor-file-input-btn" type="file" style="display: none;" />',
          '</form>'
        ].join('')
      }
    },
    override: {
      image: function() {
        /*
        console.log(document.activeElement);

        if (document.activeElement != document.getElementsByClassName('taylor-editable')[0]) {
          console.log('taylor-editable NOT focused.');
        } else {
          console.log('taylor-editable is focused.');
        }
        */

        if (!editor.isFocused()) {
          console.log('Setting cursor.');
          // editor.setCursor(0);
          editor.focus();
        }

        document.getElementById('taylor-file-input-btn').click();
      }
    },
    onLoad: function() {
      document.getElementById('taylor-file-input-btn').addEventListener('change', function(e) {
        var files = e.target.files; // FileList object

        // Loop through the FileList and render image files as thumbnails.
        for (var i = 0, f; f = files[i]; i++) {
          // Only process image files.
          if (!f.type.match('image.*')) {
            continue;
          }

          console.log('Adding file.', f);

          var reader = new FileReader();
          reader.onload = (function(theFile) {
            return function(e) {
              // Render thumbnail.
              var img = [
                '<img src="',
                e.target.result,
                '"/>'
              ].join('');
              // document.getElementById('list').insertBefore(span, null);
              // editor.insert(img);
              document.execCommand('insertHTML', false, img);
            };
          })(f);

          // Read in the image file as a data URL.
          reader.readAsDataURL(f);
          document.getElementById('taylor-file-input-form').reset();
        }
      });
    }
  });

  // console.log(editor)

  document.getElementById('is-focused-btn').addEventListener('click', function() {
    console.log(editor.isFocused());
  });

  document.getElementById('export-btn').addEventListener('click', function() {
    var data = editor.export();
    console.log(data);
  });

  document.getElementById('selection-btn').addEventListener('click', function() {
    var selection = editor.getSelectionStart();
    console.log(selection);
  });

  document.getElementById('insert-btn').addEventListener('click', function() {
    editor.insert('<img src="https://i.imgur.com/tZ68b9F.jpg" />');
  });

  document.getElementById('clear-btn').addEventListener('click', function() {
    editor.clear();
  });
};