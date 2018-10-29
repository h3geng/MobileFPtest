/**
 * A company class to init the specified company
 * 
 * @param {Object} data The data of company
 */

App.Company = function(data) {
	
    $.extend(this, data);
    this.type = 'company';
    
}

/**
 * Append company item to list
 * 
 * @param {String} list The list container selector
 */
App.Company.prototype.appendToList = function(list) {
    var _self = this;
    
    var options = {};
	options.templateFunctions = {
        
        getName: function() {
            var name = "";
            return name;
        }
        
    };
    options.templateBindings = {'click': function() { _self.showDetails(); }};
    options.commands = {'refresh': function(){ $(list).listview('refresh'); }};
    options.container = list;
    
    App.template.build(
        'company',
        _self,
        options
    );
}

/**
 * Show company details
 */
App.Company.prototype.showDetails = function() {
    var _self = this;
	//console.log(_self);
	
	var detailsContainer = $('.companydetails');
	
	App.api.post({
		'base' : 'mobileService.svc',
        'path' : 'getCompany',
        'params' : '{ "sessionId" : "' + App.user.sessionId + '", "regionId" : ' + App.user.regionId + ', "companyId" : ' + _self.Id + ', "incContacts" : true, "incBranches" : true}',
        'successCallback' : function(args) {
			//console.log(args);
			if (args.getCompanyResult) {
				$.extend(_self, args.getCompanyResult);
			}
			console.log(_self);
			
            detailsContainer.find('li').remove();
			
			var options = {};
			options.templateFunctions = {
				
				getAddress: function() {
					var address = 'no address';
					if (_self.address) {
						address = _self.Address + ', ' + City + ' ' + Province + ', ' + Postal;
					}
					return address;
				},
				getPhone: function() {
					var phone = 'no phone';
					if ($.trim(_self.Phone) !== '') {
						phone = '<a class="phone-link" data-role="button" data-mini="true" data-inline="true" href="tel:+1' + $.trim(_self.Phone) + '">' + $.trim(_self.Phone) + '</a>';
					}
					return phone;
				},
				getProfile: function() {
					var profile = '';
					if ($.trim(_self.Profile) !== '') {
						profile = '<li><p>&nbsp;</p><p>' + $.trim(_self.Profile) + '</p><p>&nbsp;</p></li>';
					}
					return profile.replace(/\n/g, '<br />');
				}
				
			};
			options.container = detailsContainer;
			options.commands = {'refresh': function(){
				
				detailsContainer.listview('refresh');
				$('.phone-link').button();
				
			}};
			
			App.template.build(
				'companyDetail',
				_self,
				options
			);
			
			$.mobile.changePage($('#companyDetails'));
        },
        'errorCallback' : function(args) {
			App.showError({'statusText' : 'Sorry, could not load the selected company details.'});
        }
    });
}