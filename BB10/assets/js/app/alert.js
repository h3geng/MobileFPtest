/**
 * An alert class to init the specified alert
 * 
 * @param {Object} data The data of alert
 */

App.Alert = function(data) {
    
    var _self = this;
    
    this.data = data;
    this.type = 'alert';
    this.items = [];
    
}

/**
 * Append alert item to list
 * 
 * @param {String} list The list container selector
 */
App.Alert.prototype.appendToList = function(list) {
    var _self = this;
    
    var options = {};
	options.templateFunctions = {
        
        title : function() {
            var t = _self.data.count;
            t += " " + _self.data.description; 
            return t;
        },
        type: function() {
            if (_self.data.alertCat == 1) {
                return "claim";
            } else {
                return "generic";
            }
        },
        id : function() {
			return _self.data.alertId;
		}
        
    };
    options.templateBindings = {'click': function() { _self.showDetails(); }};
    options.commands = {'refresh': function(){ $(list).listview('refresh'); }};
    options.container = list;
    
    App.template.build(
        'alert',
        _self.data,
        options
    );
}

/**
 * Show alert details
 */
App.Alert.prototype.showDetails = function() {
    var _self = this;
    
    App.api.post({
		'path' : 'getFileAlertDetail',
		'params' : '{"sessionId" : "' + App.user.sessionId + '", "regionId" : ' + App.user.regionId + ', "alertId" : ' + _self.data.alertId + ',"CTUserId" : "' + App.user.currentCredential.CTUserCode + '"}',
		'successCallback' : function(args) {
            if (args.d && args.d.items) {
				_self.items = args.d.items;
				
				$('.file-alert-items').html('');
				
				$.each(_self.items, function(i, item){
					var options = {};
					options.templateBindings = {'click': function() {
						
						App.activeJob = new App.Job({'ClaimIndx' : item.Id, 'ClaimNumber' : item.Code});
						App.activeJob.showDetails();
						
					}};
					options.commands = {'refresh': function(){ $(".file-alert-items").listview('refresh'); }};
					options.container = ".file-alert-items";
					
					App.template.build(
						'jobMini',
						item,
						options
					);
				});
				
				$.mobile.changePage($('#fileAlerts'));
				
				if (_self.data.extraInfo !== '?' && $.trim(_self.data.extraInfo) !== '') {
					$('.extra-info').html('Extra Info: <strong>' + _self.data.extraInfo + '</strong>');
					$('.extra-info').show();
				} else {
					$('.extra-info').hide();
				}
				
				$('.file-alert-items').listview('refresh');
			}
        },
        'errorCallback' : function(error) {
            console.log(error);
			App.showError({'statusText' : 'Could not get alert details...'});
        }
    });
	
    //App.activeBranch = this;
    
    /*if (App.activeScan) {
        $('#branchDetails .transaction-process').show();
    }*/
    
    // build job details
    /*var detailsContainer = $('.branchdetails');
    detailsContainer.find('li').remove();
    
    var options = {};
    options.container = detailsContainer;
    options.commands = {'refresh': function(){ detailsContainer.listview('refresh'); }};
    
    App.template.build(
        'branchDetail',
        _self.branchData,
        options
    );
    
    // build job equipment
    var equipmentsContainer = '.branchequipments';
    $(equipmentsContainer).find('li').remove();
    $.each(_self.equipments, function(i, equipment){
        equipment.appendToList(equipmentsContainer);
    });*/
}