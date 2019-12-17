setInterval(function()
	   {
	     var match = document.title.match(/^{[^}]+} (.*)/);
	   
	     if (match)
	       document.title = match[1];

	     var selection = '';

	     if (window.getSelection)
	       selection = window.getSelection();
	     else if (document.getSelection)
	       selection = document.getSelection();
	     else if (document.selection)
	       selection = document.selection.createRange().text;

	    selection = selection.toString();

	     if (selection != "" && selection.length < 30)
	     {
	       document.title = "{" + selection + "} " + document.title;}
	   },
	   500);
