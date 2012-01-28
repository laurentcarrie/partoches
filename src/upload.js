// trouve sur le web :
// http://www.thecssninja.com/javascript/drag-and-drop-upload
//


var TCNDDU = TCNDDU || {};
		
(function(){
    var dropContainer,
	dropListing;
			
    TCNDDU.setup = function () {
	body = document.getElementsByTagName("body")[0];
	dropListing = document.getElementById("output-listing01");
	dropArea = document.getElementById("drop");
			

	// Check for the various File API support.
	if (window.File && window.FileReader && window.FileList && window.Blob) {
	    // Great success! All the File APIs are supported.
	} else {
	    alert('The File APIs are not fully supported in this browser.');
	}	
	if(typeof window["FileReader"] === "function") {
	    // File API interaction goes here
	    dropArea.addEventListener("dragenter", function(event){event.stopPropagation();event.preventDefault();}, false);
	    dropArea.addEventListener("dragover", function(event){event.stopPropagation();event.preventDefault();}, false);
	    dropArea.addEventListener("drop", function(event){
					  // alert("Your browser supports the File API");event.stopPropagation();event.preventDefault();
					  TCNDDU.handleDrop(event) ;
					  
				      }, 
				      false);
	} else {
	    // No File API support fallback to file input
	    fileInput.type = "file";
	    fileInput.id = "filesUpload";
	    fileInput.setAttribute("multiple",true);
	    dropArea.appendChild(fileInput);
	    fileInput.addEventListener("change", TCNDDU.handleDrop, false);
	}
	body.addEventListener("dragenter",TCNDDU.handleDrag, false);
	body.addEventListener("dragend",TCNDDU.handleDrag, false);
    };
			
    TCNDDU.uploadProgressXHR = function (event) {
	if (event.lengthComputable) {
	    var percentage = Math.round((event.loaded * 100) / event.total);
	    if (percentage < 100) {
		event.target.log.firstChild.nextSibling.firstChild.style.width = (percentage*2) + "px";
		event.target.log.firstChild.nextSibling.firstChild.textContent = percentage + "%";
	    }
	}
    };
			
    TCNDDU.loadedXHR = function (event) {
	var currentImageItem = event.target.log;
				
	currentImageItem.className = "loaded";
	console.log("xhr upload of "+event.target.log.id+" complete");
    };
			
    TCNDDU.uploadError = function (error) {
	console.log("error: " + error);
    };
			
    TCNDDU.processXHR = function (file, index) {
	var xhr = new XMLHttpRequest(),
	container = document.getElementById("item"+index),
	fileUpload = xhr.upload,
	progressDomElements = [
			       document.createElement('div'),
			       document.createElement('p')
			       ];

	progressDomElements[0].className = "progressBar";
	progressDomElements[1].textContent = "0%";
	progressDomElements[0].appendChild(progressDomElements[1]);
				
	container.appendChild(progressDomElements[0]);
				
	fileUpload.log = container;
	fileUpload.addEventListener("progress", TCNDDU.uploadProgressXHR, false);
	fileUpload.addEventListener("load", TCNDDU.loadedXHR, false);
	fileUpload.addEventListener("error", TCNDDU.uploadError, false);

	xhr.open("POST", "upload-file") ;
	xhr.overrideMimeType('text/plain; charset=x-user-defined-binary');
	var reader = new FileReader();

	// Closure to capture the file information.
	reader.onload = (function(theFile) {
			     return function(e) {
				 // Render thumbnail.
				 var span = document.createElement('span');
				 //span.innerHTML = ['<img class="thumb" src="', e.target.result,
				 //	   '" title="', theFile.name, '"/>'].join('');
				 span.innerHTML = ['<a href="work/',theFile.name,'">',theFile.name,'</a>','<br/>'].join('') ;
				 document.getElementById('output-listing01').insertBefore(span, null);
				 xhr.sendAsBinary(e.target.result) ;
			     };
			 })(file);

	// Read in the image file as a data URL.
	reader.readAsBinaryString(file);
	// xhr.sendAsBinary(file.getAsBinary());
    };
			
    TCNDDU.handleDrop = function (event) {
	var dt = event.dataTransfer,
	files = dt.files,
	imgPreviewFragment = document.createDocumentFragment(),
	count = files.length,
	domElements;

	console.log("count = %d",count) ;
					
	event.stopPropagation();
	event.preventDefault();

	for (var i = 0; i < count; i++) {
	    domElements = [
			   document.createElement('li'),
			   document.createElement('a'),
			   document.createElement('img')
			   ];
				
	    // domElements[2].src = files[i].getAsDataURL(); // base64 encodes local file(s)
	    domElements[2].width = 300;
	    domElements[2].height = 200;
	    domElements[1].appendChild(domElements[2]);
	    domElements[0].id = "item"+i;
	    domElements[0].appendChild(domElements[1]);
					
	    imgPreviewFragment.appendChild(domElements[0]);
					
	    dropListing.appendChild(imgPreviewFragment);
					
	    TCNDDU.processXHR(files.item(i), i);
	}
    };
			
    window.addEventListener("load", TCNDDU.setup, false);
})();
