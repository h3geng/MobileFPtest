App.Timesheet = function(options) {
	this.timeEntry = {};
	
	var dt = new Date();
	var dtStr = dt.getFullYear() + '-' + ((dt.getMonth() + 1) < 10 ? ('0' + (dt.getMonth() + 1)) : dt.getMonth() + 1) + '-' + (dt.getDate() < 10 ? '0' + dt.getDate() : dt.getDate());
	
    this.timeEntry.regionId = App.user.regionId;
    this.timeEntry.claimIndx = parseInt(options.claimIndx) || 0; //Integer
    this.timeEntry.phaseIndx = parseInt(options.phaseIndx) || 0; //Integer
    this.timeEntry.employeeId = App.user.userId || 0; //String 'FOS_COMMON..User.UserGUID
    this.timeEntry.enteredById = App.user.userId || 0; //String
    this.timeEntry.costCategoryId = options.costCategoryId || ""; //String 'not required
    this.timeEntry.dateWorked = options.dateWorked || dtStr; //String 'required
    this.timeEntry.dateStart = options.dateStart || ""; //String = Nothing
    this.timeEntry.dateStop = options.dateStop || ""; //String = Nothing
    this.timeEntry.hours = parseFloat(options.hours) || 0; //Decimal
    this.timeEntry.note = options.note || ""; //String
	
    this.timeEntry.deviceDate = options.deviceDate || dtStr; //String
}

App.Timesheet.prototype.release = function() {
	var _self = this;
	
	//var list = [];
	//list = list.concat(_self.timeEntry);
	//console.log(list);

	App.api.post({
		'base' : 'mobileService.svc',
		'path' : 'saveTimeSheet',
		'params' : '{"sessionId" : "' + App.user.sessionId + '", "timeEntry" : ' + JSON.stringify(_self.timeEntry) + '}',
		'successCallback' : function(success) {
            console.log(success);
			App.showError({'statusText' : 'Timesheet saved!'});
		},
		'errorCallback' : function(error) {
			console.log(error);
			App.showError({'statusText' : 'Could not save the timesheet.'});
		}
	});
}