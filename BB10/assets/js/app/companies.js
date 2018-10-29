(function(){
    
    /**
     * Companies class for all application companies
     */
    
    var Companies = function() {
        
        this.className = App.Company;
        
    }
    
    // Extends from Items
    Companies.prototype = new App.Items();
    
    Companies.prototype.search = function(term, type) {
        var _self = this;
        
        if (term.length > 2) {
			$.mobile.showPageLoadingMsg();
            App.api.post({
                'base' : 'mobileService.svc',
                'path' : 'findCompany',
                'params' : '{ "sessionId" : "' + App.user.sessionId + '", "regionId" : ' + App.user.regionId + ', "typelist" : "' + type + '", "searchStr" : "' + term + '", "page" : 1}',
                'successCallback' : function(args){
                    $.mobile.hidePageLoadingMsg();
                    
                    App.companies.empty('.companieslist');
                    if (args.findCompanyResult == null || args.findCompanyResult.items == null || args.findCompanyResult.items.length === 0) {
                        args.statusText = "No Matches";
                        App.showError(args);
                    } else {
                        App.companies.fill(args.findCompanyResult.items);
                        App.companies.buildList('.companieslist');
                    }
                },
                'errorCallback' : function(args){ App.showError({'statusText' : 'Could not load contacts.'}); }
            });
        } else {
			App.showError({'statusText' : 'Fill in more than 2 characters in search term.'});
		}
    }
    
    // Application wide contacts
    App.companies = new Companies();

})();