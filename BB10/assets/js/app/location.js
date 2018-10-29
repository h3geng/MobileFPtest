(function(){
	var Location = function() {
		this.latitude = '';
		this.longitude = '';
	}

	Location.prototype.getPosition = function() {
		var _self = this;
		
		navigator.geolocation.getCurrentPosition(function(args) {
			_self.latitude = args.coords.latitude;
			_self.longitude = args.coords.longitude;
		}, function(args) {
			_self.latitude = '';
			_self.longitude = '';
		});
	}

	App.location = new Location();
	App.location.getPosition();
	
})();