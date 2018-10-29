(function(){
	
	var Regions = function() {
		
	}

	Regions.prototype.getAll = function(success, fail) {
		App.api.post({
			'base' : 'mobileService.svc',
			'path' : 'getRegions',
			'params' : '{ "sessionId" : " " }',
			'successCallback' : function(args) {
				$('#select-region').html('<option value=""></option>');
				
				$.each (args, function(){
					var regs = this;
					$.each (regs, function(){
						$.tmpl("<option value='${id}'>${value}</option>", { "id" : this.Id, "value" : this.Value }).appendTo("#select-region");
					});
				});
				
				var storedRegion = window.localStorage.getItem('region');
				if (storedRegion && $.trim(storedRegion) != '') {
					$('#select-region').val(parseInt(storedRegion));
					$('#remember').prop('checked', true);
				} else {
					$('#select-region').val('');
					$('#remember').prop('checked', false);
				}
				
				success(args);
			},
			'errorCallback' : function(args) {
				fail(args);
			}
		});
	}

	App.regions = new Regions();
	
})();