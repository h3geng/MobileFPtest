(function(){
    
    /**
     * Contacts class for all application contacts
     */
    
    var Contacts = function() {
        
        this.className = App.Contact;
        
    }
    
    // Extends from Items
    Contacts.prototype = new App.Items();
    
    Contacts.prototype.search = function(term, type, container) {
        var _self = this;
		
		container = container || '.contactslist';
        
        if (term.length > 2) {
			$.mobile.showPageLoadingMsg();
            App.api.post({
				'base' : 'mobileService.svc',
				'path' : 'findContact',
				'params' : '{ "sessionId" : "' + App.user.sessionId + '", "regionId" : ' + App.user.regionId + ', "typelist" : "' + type + '", "searchStr" : "' + term + '", "page" : 1}',
				'successCallback' : function(args){
					$.mobile.hidePageLoadingMsg();
                    
					App.contacts.empty(container);
					if (args.findContactResult == null || args.findContactResult.items == null || args.findContactResult.items.length === 0) {
						args.statusText = "No Matches";
						App.showError(args);
					} else {
						App.contacts.fill(args.findContactResult.items);
						App.contacts.buildList(container);
					}
					
					console.log(App.contacts);
				},
				'errorCallback' : function(args){ App.showError({'statusText' : 'Could not load contacts.'}); }
			});
        } else {
			App.showError({'statusText' : 'Fill in more than 2 characters in search term.'});
		}
    }
    
    // Application wide contacts
    App.contacts = new Contacts();

})();