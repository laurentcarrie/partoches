// trouve sur le web :
// http://www.thecssninja.com/javascript/drag-and-drop-upload
//


			var TCNDDU = TCNDDU || {};
		
		(function(){
			var dropContainer,
				dropListing;
			
			TCNDDU.setup = function () {
				dropListing = document.getElementById("output-listing01");
				dropContainer = document.getElementById("output");
				
				dropContainer.addEventListener("dragenter", function(event){dropListing.innerHTML = '';event.stopPropagation();event.preventDefault();}, false);
				dropContainer.addEventListener("dragover", function(event){event.stopPropagation(); event.preventDefault();}, false);
				dropContainer.addEventListener("drop", TCNDDU.handleDrop, false);
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
				xhr.sendAsBinary(file.getAsBinary());
			};
			
			TCNDDU.handleDrop = function (event) {
				var dt = event.dataTransfer,
					files = dt.files,
					imgPreviewFragment = document.createDocumentFragment(),
					count = files.length,
					domElements;
					
				event.stopPropagation();
				event.preventDefault();

				for (var i = 0; i < count; i++) {
					domElements = [
						document.createElement('li'),
						document.createElement('a'),
						document.createElement('img')
					];
				
					domElements[2].src = files[i].getAsDataURL(); // base64 encodes local file(s)
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
