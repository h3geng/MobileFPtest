/**
 * A contact class to init the specified contact
 * 
 * @param {Object} data The data of contact
 */

App.Contact = function(data) {
	
    $.extend(this, data);
    this.type = 'contact';
    
}

App.Contact.prototype.load = function(code, id, success, fail) {
	var _self = this;
	
	App.api.post({
		'base' : 'mobileService.svc',
		'path' : 'getContact',
		'params' : '{ "sessionId" : "' + App.user.sessionId + '", "regionId" : ' + App.user.regionId + ', "contactId" : 0, "contactCode" : "' + id + '", "contactType" : "' + code + '"}',
		'successCallback' : function(args){
			$.mobile.hidePageLoadingMsg();
            if (args.getContactResult) {
				$.extend(_self, args.getContactResult);
			}
			success(args);
		},
		'errorCallback' : function(args){ fail(args); }
	});
}

/**
 * Append contact item to list
 * 
 * @param {String} list The list container selector
 */
App.Contact.prototype.appendToList = function(list) {
    var _self = this;
    
    var options = {};
	options.templateFunctions = {
        
        getCompany: function() {
            var company = "";
            if (_self.Company !== null) {
                company += _self.Company.FullName;
            }
            return company;
        }
        
    };
    options.templateBindings = {'click': function() { _self.showDetails(); }};
    options.commands = {'refresh': function(){ $(list).listview('refresh'); }};
    options.container = list;
    
    App.template.build(
        'contact',
        _self,
        options
    );
}

/**
 * Show contact details
 */
App.Contact.prototype.showDetails = function() {
    var _self = this;
	console.log(_self);
	
	var detailsContainer = $('.contactdetails');
	detailsContainer.find('li').remove();
	
	var options = {};
	options.templateFunctions = {
        
        getCompanyName: function() {
            var company = "";
            if (_self.Company !== null) {
                company += _self.Company.FullName;
            }
            return company;
        },
		getCompanyCode: function() {
            var code = "";
            if (_self.Company !== null) {
                code += _self.Company.Code;
            }
            return code;
        },
		getCompanyType: function() {
            var type = "No type";
            if (_self.Company && _self.Company.CompanyType) {
                type = _self.Company.CompanyType;
            }
            return type;
        },
		getCompanyId: function() {
			var id = "0";
            if (_self.Company && _self.Company.Id) {
                id = _self.Company.Id;
            }
            return id;
		},
        getPhone: function() {
			var phone = 'no phone';
			if ($.trim(_self.Phone) !== '') {
				phone = '<a class="phone-link" data-role="button" data-mini="true" data-inline="true" href="tel:+1' + $.trim(_self.Phone) + '">1-' + $.trim(_self.Phone) + '</a>';
			}
			return phone;
		},
		getCell: function() {
			var cell = 'no cell';
			if ($.trim(_self.Cell) !== '') {
				cell = '<a class="phone-link" data-role="button" data-mini="true" data-inline="true" href="tel:+1' + $.trim(_self.Cell) + '">1-' + $.trim(_self.Cell) + '</a>';
			}
			return cell;
		}
    };
	options.container = detailsContainer;
	options.commands = {'refresh': function(){
		
		detailsContainer.listview('refresh');
		$('.phone-link').button();
		$('.contactCompany').button();
		$('.contact-email-link').button();
		
		$('.contact-details-more').collapsibleset();
		$('.contact-details-more-content').collapsible();
		
	}};
	
	App.template.build(
		'contactDetail',
		_self,
		options
	);
	
	$.mobile.changePage($('#contactDetails'));
}

$(document).on('click', '.contactCompany', function(){
	$.mobile.showPageLoadingMsg();
	
	var company = new App.Company({'Id' : $(this).attr('data-rel')});
	company.showDetails();
});