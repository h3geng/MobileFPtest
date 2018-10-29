(function(){
	var Grabba = function() {
		
	}

	Grabba.prototype.scan = function (successCallback, errorCallback) {
		if (typeof errorCallback !== "function")  {
			console.log("GrabbaScanner.scan failure: failure callback parameter not a function");
			return;
		}
		
		if (typeof successCallback !== "function") {
			console.log("GrabbaScanner.scan failure: success callback parameter not a function");
			return;
		}
		
		cordova.exec(successCallback, errorCallback, "GrabbaScanner", "scan", []);
	};
	
	if (!window.plugins) {
		window.plugins = {};
	}

	if (!window.plugins.grabbaScanner) {
		window.plugins.grabbaScanner = new Grabba();
	}
	
})();