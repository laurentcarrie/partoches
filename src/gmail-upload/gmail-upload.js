		var TCNDDU = TCNDDU || {};
		
		(function(){
			var dropListing,
				dropArea,
				fileInput = document.createElement("input"),
				body,
				reader;
			
			TCNDDU.setup = function () {
				body = document.getElementsByTagName("body")[0];
				dropListing = document.getElementById("output-listing01");
				dropArea = document.getElementById("drop");
				
				if(typeof window["FileReader"] === "function") {
					// File API interaction goes here
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
			
			TCNDDU.handleDrag = function (evt) {
				var type = evt.type,
					dropStyle = dropArea.style,
					dragNode = evt.target.nodeName.toLowerCase();
				
				if(type == "dragenter") {
					dropStyle.visibility = "visible";
				}
			};
			
			TCNDDU.handleDrop = function (evt) {
				var files = evt.target.files,
					filesFragment = document.createDocumentFragment(),
					domElements;
				
				dropArea.style.visibility = "hidden";
				dropListing.style.display = "block";
				dropListing.innerHTML = "";
				console.log(files);
				
				for(var i = 0, len = files.length; i < len; i++) {
					// Stop people trying to upload massive files don't need for demo to work
					if(files[i].fileSize < 1048576) {
						// Check for duplicate files and skip iteration if so. Safari bug.
						//if(i != 0 && files[0].fileName === files[i].fileName) continue;
						
						domElements = [
							document.createElement('li'),
							document.createElement('span')
						];
						
						domElements[1].appendChild(document.createTextNode(files[i].fileName + " " + Math.round((files[i].fileSize/1024*100000)/100000)+"K "));
						domElements[0].id = "item"+i;
						domElements[0].appendChild(domElements[1]);
						
						filesFragment.appendChild(domElements[0]);
						
						dropListing.appendChild(filesFragment);
						
						// Use xhr to send files to server async both Chrome and Safari support xhr2 upload and progress events
						TCNDDU.processXHR(files[i], i);
					} else {
						alert("Please don't kill my server by uploading large files, anything below 1mb will work");
					}
				}
			};
			
			TCNDDU.processXHR = function (file, index) {
				var xhr = new XMLHttpRequest(),
					container = document.getElementById("item"+index),
					loader;
					fileUpload = xhr.upload,
					progressDomElements = [
						document.createElement('div'),
						document.createElement('p')
					];
				
				progressDomElements[0].className = "loader01";
				progressDomElements[0].appendChild(progressDomElements[1]);
				
				container.appendChild(progressDomElements[0]);
				loader = document.getElementsByClassName("loader01");
				
				fileUpload.addEventListener("progress", function(event) {
					if (event.lengthComputable) {
						var percentage = Math.round((event.loaded * 100) / event.total),
						loaderIndicator = container.firstChild.nextSibling.firstChild;
						if (percentage < 100) {
							loaderIndicator.style.width = percentage + "px";
						}
					}
				}, false);
				
				fileUpload.addEventListener("load", function(event) {
					loader[index].style.display = "none";
					console.log("xhr upload of "+container.id+" complete");
				}, false);
				
				fileUpload.addEventListener("error", function(evt) {
					console.log("error: " + evt.code);
				}, false);

				xhr.open("POST", "upload.php");
				xhr.setRequestHeader("If-Modified-Since", "Mon, 26 Jul 1997 05:00:00 GMT");
				xhr.setRequestHeader("Cache-Control", "no-cache");
				xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
				xhr.setRequestHeader("X-File-Name", file.fileName);
				xhr.setRequestHeader("X-File-Size", file.fileSize);
				xhr.setRequestHeader("Content-Type", "multipart/form-data");
				xhr.send(file);
			};
			
			window.addEventListener("load", TCNDDU.setup, false);
		})();

