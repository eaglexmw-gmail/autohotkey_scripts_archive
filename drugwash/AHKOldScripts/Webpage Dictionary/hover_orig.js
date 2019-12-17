var start_node;
var timeout = null;


function start_processing_for_hover(node)
{
  timeout = setTimeout(function()
		       {
			 process_for_hover(node);
		       },
		       0);
}


function process_for_hover(node)
{
  // don't know why it happens
  if (!node)
    return;

  if (node.nodeName == "#text")
  {
    var words = node.nodeValue.split(/\s+/);

    for (var i = 0 ; i < words.length ; i++)
    {
      var span = document.createElement("span");
      span.setAttribute("processed_for_hover", true);

      node.parentNode.insertBefore(span, node);
      span.appendChild(document.createTextNode(words[i]));

      if (i != words.length - 1)
	span.appendChild(document.createTextNode(" "));
    }
    
    node.parentNode.removeChild(node);

    start_processing_for_hover(node.parentNode);
  }
  else
  {
    //node.style.border = "medium solid lightgreen";

    var children = node.childNodes;
    var i;

    for (i = 0 ; i < children.length ; i++)
    {
      var child = children[i];

      if (child.nodeName == "#text" ||
	  !child.getAttribute("processed_for_hover"))
      {         
	start_processing_for_hover(child);
	break;
      }
    }
    
    // all children are processed already
    if (i == children.length)
    {
      node.setAttribute("processed_for_hover", true);

      // if it's not the start node then continue processing of parent
      if (node != start_node)
	process_for_hover(node.parentNode);
    }
  }
}


function setstatus(status)
{
  var match = document.title.match(/(.*) \[.*\]/);

  if (match)
    document.title = match[1];

  if (status)
    document.title += " [" + status + "]";
}


document.onmouseover = function (e)
{
  var node = e.target;

  if (node.getAttribute("processed_for_hover"))
  {
    var child = node.firstChild;

    if (child)
      if (child.nodeName != "#text")
	setstatus("FIXME: child of " + node.nodeName + " is not text: " + child.nodeName + " " + child.getAttribute("processed_for_hover"));
      else
      {
	var match = child.nodeValue.match(/^\W*(.*?)\W*$/);

	if (match)
	  setstatus(match[1]);
	else
	  setstatus("FIXME: no match");
      }
  }
  else
  {
    if (timeout)
      clearTimeout(timeout);

    start_node = node;
    start_processing_for_hover(node);
  }
}

