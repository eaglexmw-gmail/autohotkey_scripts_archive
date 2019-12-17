setTimeout(function()
      {
        var match = document.title.match(/^{[^}]+} (.*)/);
      
        if (match)
          document.title = match[1];


          var selection = document.selection.createRange().text;
        if (selection != "" && selection.length < 30)
          document.title = "{" + selection + "} " + document.title;
      },
      500);
