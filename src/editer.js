$(function(){
      $("#tree").dynatree({
	      // In real life we would call a URL on the server like this:
	      //          initAjax: {
	      //              url: "/getTopLevelNodesAsJson",
	      //              data: { mode: "funnyMode" }
	      //              },
	      // .. but here we use a local file instead:
	      initAjax: {
		  url: "get-json-tree" ,
		      data: {
			  partoche : "au clair de la lune"}
		      },
		  onActivate: function(node) {
		  $("#echoActive").text(node.data.title);
	      },
		  onDeactivate: function(node) {
		  $("#echoActive").text("-");
	      },

		  onLazyRead: function(node){
		  console.log("onLazyRead") ;
		  node.appendAjax({url: node.data.url,
					  data: {
					  key : node.data.key ,
					      }
				  });
	      }
	  });
  });


/*
$(function(){
    // Variant 1:
    $("span.dynatree-edit-icon").live("click", function(e){
        alert("Edit " + $.ui.dynatree.getNode(e.target));
    });
    $("#tree").dynatree({
      onActivate: function(node) {
//        $("#info").text("You activated " + node);
      },
        onRender: function(node, nodeSpan) {
            $(nodeSpan).find('.dynatree-icon')
               .before('<span class="dynatree-icon dynatree-edit-icon"></span>');
        },
        // Variant 2:
        onClick: function(node, e){
            if($(e.target).hasClass("dynatree-edit-icon")){
                $("#info").text("You clicked " + node + ",  url=" + node.url);
            }
        },
      children: [
        {title: "Item 1"},
        {title: "Folder 2", isFolder: true,
          children: [
            {title: "Sub-item 2.1"},
            {title: "Sub-item 2.2"}
          ]
        },
        {title: "Item 3"}
      ]
    });
});
*/
