/**
 * Photo class to init the specified photo
 * 
 * @param {Object} data The data of photo
 */

App.Photo = function(data) {
    this.claimIndx = data.claimIndx || 0;
	this.dateUploaded = data.dateUploaded || "";
	this.description = data.description || "";
	this.file = data.file || null;
	this.fileBase64 = data.fileBase64 || null;
	this.fileExt = data.fileExt || null;
	this.fileName = data.fileName || null;
	this.fileType = data.fileType || "";
	this.imageURL = data.imageURL || "";
	this.phaseIndx = data.phaseIndx || 0;
	this.regionId = data.regionId || 0;
	this.sendToXAEM = data.sendToXAEM || false;
	this.sendToXARE = data.sendToXARE || false;
	this.sentToXASuccess = data.sentToXASuccess || false;
	this.thumbURL = data.thumbURL || "";
	
	this.uploadPath = 'http://dev.firstonsite.ca/mobileservices/FileUpload.ashx';
}

/**
 * Append photo item to list
 * 
 * @param {String} list The list container selector
 */
App.Photo.prototype.appendToList = function(list) {
    var _self = this;
    
    var options = {};
    options.templateBindings = {'click': function() { _self.showDetails(); }};
    options.container = list;
    
    App.template.build(
        'photo',
        _self,
        options
    );
}

/**
 * Show photo details
 */
App.Photo.prototype.showDetails = function() {
    var _self = this;
	
	$('.photoDetailsContainer').html('<p>Upload Date: <strong>' + _self.dateUploaded + '</strong></p><p>Description: <strong>' + _self.description + '</strong></p>');
	$('#photoDetails h1').html('Photo Details');
	$("#photoDetails").popup('open', { 'positionTo' : 'window', 'transition' : 'slidedown' });
}

/**
 * process & preview new photo
 */
App.Photo.prototype.preview = function(file) {
	$.mobile.changePage("#jobPhotoPreview");
	
	file = 'file://' + file;
	
	$('#imagePreviewDescription').val('');
	$('.previewPhotoContainer').html('<img src="'+file+'" style="width: 100%">');
	$('.transaction-process-preview').show();
}

App.Photo.prototype.doUpload = function() {
    var _self = this;
	
	_self.progress(0);
	var file = _self.pathReceived;
	
	var pureName = file.substr(file.lastIndexOf('/') + 1);
	var ext = pureName.substr(pureName.lastIndexOf('.') + 1);
	ext = ext.substr(0, ext.indexOf('?'));
    
    var fileParams = {
		'sessionId' : App.user.sessionId,
		'regionId' : App.activeJob.RegionId + '',
		'claimIndx' : App.activeJob.ClaimIndx + '',
		'phaseIndx' : $('#select-img-ph-preview').val(),
		'fileType' : "Image",
		'fileName' : pureName.substr(0, pureName.lastIndexOf('.')) || pureName,
        'fileExt' : ext || 'jpg',
		'description' : $('#imagePreviewDescription').val(),
		/*'sendToXAEM' : false,
		'sendToXARE' : false,*/
		'fileBase64' : ""/*,
		'file' : []*/
	}
	
	if (App.PLATFORM === 'bb10') {
		try {
			var options = {
				fileKey : "file",
				fileName : fileParams.fileName + '.' + fileParams.fileExt,
				mimeType : "image/jpeg",
				params : fileParams,
				chunkedMode : true,
				chunkSize : 1024
			};
			blackberry.io.filetransfer.upload(file, _self.uploadPath,
				function(r) {
					if (r.response.Message && r.response.Message !== "") {
						$('#photoUpload').dialog('close');
						alert(r.Message);
					} else {
						App.activeJob.showPictures();
					}
				},
				function(error) {
					var errorMessage = 'Unknown error...';
					switch (error.code) {
						case 1:
							errorMessage = 'The file was not found';
							break;
						case 2:
							errorMessage = 'The URL of the server was invalid';
							break;
						case 3:
							errorMessage = 'The upload failed due to a connection error';
							break;
						case 4:
							errorMessage = 'Application unable to write to target folder due to insufficient permissions';
							break;
					}
					$('#photoUpload').dialog('close');
					alert(errorMessage);
				},
				options
			);
		} catch(e) {
			$('#photoUpload').dialog('close');
			alert("Exception in fileUpload: " + e);
		}
	}
	else{
		var ft = new FileTransfer();
		
		ft.onprogress = function(progressEvent) {
			if (progressEvent.lengthComputable) {
				var percent = progressEvent.loaded / progressEvent.total;
				percent = percent.toFixed(1) * 100;
				_self.progress(percent);
			}
		};
		
		ft.upload(file, _self.uploadPath,
			function(r) {
				if (r.response.Message && r.response.Message !== "") {
					$('#photoUpload').dialog('close');
					navigator.notification.alert(r.Message, null, 'Error...');
				} else {
					App.activeJob.showPictures();
				}
			},
			function(error) {
				$('#photoUpload').dialog('close');
				navigator.notification.alert('Error uploading file: ' + error.code, null, 'Error...');
			},
			{
				fileName: fileParams.fileName,
				params: fileParams
			}
		);
	}
}

App.Photo.prototype.progress = function(percent) {
	var progressBarWidth = percent * $('#progressBar').width() / 100;
	$('#progressBar').find('div').animate({ width: progressBarWidth }, 500);//.html(percent + "%&nbsp;");
}

$(document).on('click', '.preview-cancel', function(){
	if (confirm('Are you sure?')) {
		App.activeJob.showPictures();
	}
});

$(document).on('click', '.preview-ok', function(){
	$.mobile.changePage("#photoUpload", { role: "dialog" });
	App.activePhoto.doUpload();
});

$(document).on('click', '.capture-use-camera', function(){
	$("#photoSource").popup('close');
	$("#jobPhotosPanelOptions").panel('close');
	
	App.activePhoto = new App.Photo({});
	
	if (App.PLATFORM === 'bb10') {
		var details = {
			mode: blackberry.invoke.card.CAMERA_MODE_PHOTO
		};
		blackberry.invoke.card.invokeCamera(details,
			function (path) {
				App.activePhoto.pathReceived = path;
				App.activePhoto.preview(App.activePhoto.pathReceived);
			},
			function (reason) {
				//console.log(reason);
			},
			function (error) {
				if (error) {
					alert('An error occurred during capture: ' + error);
				}
			}
		);
	} else {
		navigator.camera.getPicture(function(imageURI) {
			App.activePhoto.pathReceived = imageURI;
			App.activePhoto.preview(imageURI);
		}, function(error) {
			navigator.notification.alert('An error occurred during capture: ' + error, null, 'Error...');
		}, {
			quality: parseInt(App.config.IMGQ) || 75,
			destinationType: navigator.camera.DestinationType.FILE_URI,
			sourceType: navigator.camera.PictureSourceType.CAMERA,
			encodingType: Camera.EncodingType.JPEG,
			targetWidth: parseInt(App.config.IMGW) || 1024,
			targetHeight: parseInt(App.config.IMGH) || 800,
			correctOrientation: true
		});
	}
});

$(document).on('click', '.capture-use-library', function(){
	$("#photoSource").popup('close');
	$("#jobPhotosPanelOptions").panel('close');
	
	App.activePhoto = new App.Photo({});
	
	if (App.PLATFORM === 'bb10') {
		var details = {
			mode: blackberry.invoke.card.FILEPICKER_MODE_PICKER,
			type: [blackberry.invoke.card.FILEPICKER_TYPE_PICTURE],
			viewMode: blackberry.invoke.card.FILEPICKER_VIEWER_MODE_GRID,
			sortBy: blackberry.invoke.card.FILEPICKER_SORT_BY_NAME,
			sortOrder: blackberry.invoke.card.FILEPICKER_SORT_ORDER_DESCENDING
		};
	  
		blackberry.invoke.card.invokeFilePicker(details,
			function (path) {
				App.activePhoto.pathReceived = path[0];
				App.activePhoto.preview(App.activePhoto.pathReceived);
			},
			function (reason) {
				//console.log(reason);
			},
			function (error) {
				if (error) {
					alert('An error occurred during capture: ' + error);
				}
			}
		);
	}
	else {
		navigator.camera.getPicture(function(imageURI) {
			App.activePhoto.pathReceived = imageURI;
			App.activePhoto.preview(imageURI);
		}, function(error) {
			navigator.notification.alert('An error occurred during capture: ' + error, null, 'Error...');
		}, {
			quality: parseInt(App.config.IMGQ) || 75,
			destinationType: navigator.camera.DestinationType.FILE_URI,
			sourceType: navigator.camera.PictureSourceType.PHOTOLIBRARY,
			encodingType: Camera.EncodingType.JPEG,
			targetWidth: parseInt(App.config.IMGW) || 1024,
			targetHeight: parseInt(App.config.IMGH) || 800,
			correctOrientation: true
		});
	}
});

$(document).on('click', '.capture-photo', function(){
	$.mobile.hidePageLoadingMsg();
	
	$("#photoSource h1").html('Capture Type');
	$("#photoSource").popup('open', { 'positionTo' : 'window', 'transition' : 'slidedown' });
});

$(document).on('change', '#select-img-ph', function(){
	$('.currentPhotoContainer').html('');
	$.mobile.showPageLoadingMsg();
	
	App.activeJob.getPictures($(this).val());
});