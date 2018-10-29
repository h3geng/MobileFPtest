(function(){
    
    /**
     * Transaction class for all application transactions
     */
    
    var Transaction = function() {
        
        this.items = [];
        
    }
	
	Transaction.prototype.checkExists = function(equipment) {
		var _self = this;
		
		var exists = false;
		$.each(_self.items, function(i, item){
            if (item.equipment.id == equipment.id) {
				exists = true;
			}
		});
		
		return exists;
	}
	
	Transaction.prototype.append = function(equipment, object) {
		var _self = this;
		
		var obj = {};
		obj.regionId = App.user.regionId;
		obj.branchId = App.user.branch.Id;
		obj.userId = App.user.userId;
		obj.deliveredById = App.user.userId;
		obj.itemId = equipment.id;
		obj.longitude = App.location.longitude;
		obj.latitude = App.location.latitude;
		
		switch(object.type) {
			case "transit":
				obj.statusId = 7;
				break;
			case "idle":
				obj.statusId = 1;
				break;
			case "branch":
				obj.branchId = object.branchData.Id;
				obj.statusId = 6;
				break;
			case "job":
				obj.statusId = 2;
				obj.claimIndx = object.ClaimIndx;
				obj.phaseIndx = $('#phaseList').val();
				equipment.phase = $('#phaseList option[value="' + obj.phaseIndx + '"]').text();
				break;
		}
		
        this.items = this.items.concat({ 'equipment' : equipment, 'object' : object, 'toSend' : obj });
		this.store();
    }
	
	Transaction.prototype.remove = function(id) {
		var _self = this;
		
        $.each(_self.items, function(i, item){
            if (item && item.equipment.id == id) {
				_self.items.splice(i, 1);
			}
		});
		
		this.store();
    }
	
	Transaction.prototype.clean = function(object) {
		var _self = this;
		if (object.type === 'pending') {
			_self.items = [];
		} else {
			if (object.id) {
				_self.items = $.grep(_self.items, function(o,i) { return (o.object.type === object.type) && (o.object.ClaimIndx == object.id); }, true);
			} else {
				_self.items = $.grep(_self.items, function(o,i) { return o.object.type === object.type; }, true);
			}
		}
		this.store();
	}
	
	Transaction.prototype.commit = function(object, successCallback) {
		var _self = this;
		var itemsToCommit = [];
		$.each(_self.items, function(i, item){
            if (item.object.type === object.type || object.type === 'pending') {
				itemsToCommit = itemsToCommit.concat(item);
			}
        });
		
		var list = [];
		/*switch(object.type) {
			case "transit":
				$.each(itemsToCommit, function(i, item){
					var object = {};
					object.regionId = App.user.regionId;
					object.branchId = App.user.branch.Id;
					object.userId = App.user.userId;
					object.deliveredById = App.user.userId;
					object.itemId = item.equipment.id;
					object.statusId = 7;
					
					list = list.concat(object);
				});
				break;
			case "idle":
				$.each(itemsToCommit, function(i, item){
					var object = {};
					object.regionId = App.user.regionId;
					object.branchId = App.user.branch.Id;
					object.userId = App.user.userId;
					object.deliveredById = App.user.userId;
					object.itemId = item.equipment.id;
					object.statusId = 1;
					
					list = list.concat(object);
				});
				break;
			case "branch":
				$.each(itemsToCommit, function(i, item){
					var object = {};
					object.regionId = App.user.regionId;
					object.branchId = item.object.branchData.Id;
					object.userId = App.user.userId;
					object.deliveredById = App.user.userId;
					object.itemId = item.equipment.id;
					object.statusId = 6;
					
					list = list.concat(object);
				});
				break;
			case "job":
				$.each(itemsToCommit, function(i, item){
					var object = {};
					object.regionId = App.user.regionId;
					object.branchId = App.user.branch.Id;
					//console.log(item.object);
					object.userId = App.user.userId;
					object.deliveredById = App.user.userId;
					object.itemId = item.equipment.id;
					object.statusId = 2;
					object.claimIndx = item.object.ClaimIndx;
					object.phaseIndx = $.mobile.activePage.find('select.phaseList').val();
					
					list = list.concat(object);
				});
				break;
		}*/
		
		$.each(itemsToCommit, function(i, item){
			item.committed = '';
			list = list.concat(item.toSend);
		});
		
		App.api.post({
			'path' : 'updateStatus',
			'params' : '{ "sessionId" : "' + App.user.sessionId + '", "transactionList" : ' + JSON.stringify(list) + '}',
			'successCallback' : function(args) {
				args.type = object.type;
				if (typeof successCallback === 'function') {
                    successCallback(args);
                }
			},
			'errorCallback' : function(args) {
				args.type = object.type;
				if (typeof errorCallback === 'function') {
                    errorCallback(args);
                }
			}
		});
	}
	
	Transaction.prototype.commitOnce = function(equipment, object, successCallback, errorCallback) {
		var obj = {};
		obj.regionId = App.user.regionId;
		obj.branchId = App.user.branch.Id;
		obj.userId = App.user.userId;
		obj.deliveredById = App.user.userId;
		obj.itemId = equipment.id;
		
		switch(object.type) {
			case "transit":
				obj.statusId = 7;
				break;
			case "idle":
				obj.statusId = 1;
				break;
			case "branch":
				obj.branchId = object.branchData.Id;
				obj.statusId = 6;
				break;
			case "job":
				obj.statusId = 2;
				obj.claimIndx = object.ClaimIndx;
				obj.phaseIndx = $('#phaseList').val();
				equipment.phase = $('#phaseList option[value="' + obj.phaseIndx + '"]').text();
				break;
		}
		
		var list = [];
		list[0] = obj;
		
		App.api.post({
			'path' : 'updateStatus',
			'params' : '{ "sessionId" : "' + App.user.sessionId + '", "transactionList" : ' + JSON.stringify(list) + '}',
			'successCallback' : function(args) {
				args.type = object.type;
				if (typeof successCallback === 'function') {
                    successCallback(args);
                }
			},
			'errorCallback' : function(args) {
				args.type = object.type;
				if (typeof errorCallback === 'function') {
                    errorCallback(args);
                }
			}
		});
	}
	
	Transaction.prototype.store = function() {
		var _self = this;
		var itemsToStore = [];
		$.each(_self.items, function(i, item){
			itemsToStore = itemsToStore.concat(JSON.stringify(item));
        });
		
		window.localStorage.setItem('pending', itemsToStore);
	}
	
	Transaction.prototype.getOffline = function() {
		var _self = this;
		
		var retrievedObject = window.localStorage.getItem('pending');
		//var parsed = $.parseJSON(retrievedObject);
		//console.log(parsed);
	}
    
    // Application wide jobs
    App.transaction = new Transaction();

})();