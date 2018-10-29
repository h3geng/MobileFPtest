/**
 * A user class to enable login/logout feature
 * 
 * @param {String} username The username to login
 * @param {String} password The password of user
 * @param {String} regionId The region id of user
 */
App.User = function(username, password, regionId) {
    
    this.username = username;
    this.password = password;
    this.regionId = regionId;
    
}

/**
 * Login feature
 * 
 * @param {Function} successCallback The success callback function definition
 * @param {Function} errorCallback The error callback function definition
 */
App.User.prototype.login = function(successCallback, errorCallback) {
	if ($.trim(this.username) === '') {
		App.showError({'statusText' : 'Invalid Credentials'});
	} else {
		App.api.post({
			'path' : 'login',
			'params' : '{"username" : "' + this.username + '", "password" : "' + this.password + '", "regionId" : ' + this.regionId + '}',
			'successCallback' : successCallback,
			'errorCallback' : errorCallback
		});
	}
};

/**
 * Logout feature
 * 
 * @param {Function} callback The callback function definition
 */
App.User.prototype.logout = function(callback) {
    App.api.post({
        'path' : 'logout',
        'params' : '{"username" : ' + this.username + ', "password" : ' + this.password + '}',
        'successCallback' : callback,
        'errorCallback' : callback
    });
};

// user login/logout callback functions
$('#btnLogin').on('click', function() {
    App.user = new App.User($('#email').val(), $('#password').val(), $('#select-region').val());
    
    if ($('#remember').prop('checked')) {
        window.localStorage.setItem('email', $('#email').val());
        window.localStorage.setItem('region', $('#select-region').val());
    } else {
        // clear all from storage
        window.localStorage.setItem('email', '');
        window.localStorage.setItem('region', '');
    }
    $.mobile.showPageLoadingMsg();
    App.user.login(userLoginSuccessCallback, userLoginErrorCallback);
});

$(document).on('click', '.ct-user-line', function(){
    var ct = $(this).attr('data-rel');
    
    $.each(App.user.credentials, function(i, cred){
        if (cred.CTUserCode == ct) {
            App.user.currentCredential = {
                CTUserCode: cred.CTUserCode,
                CTUserId: cred.CTUserId,
                PMId: cred.PMId,
                SecurityFlags: cred.SecurityFlags,
                UserType: cred.UserType,
            };
        }
    });
    //console.log(App.user.currentCredential);
    $('.ct-user').html('<a class="current-user-cred" href="#" data-role="button" data-mini="true" data-inline="true">' + App.user.currentCredential.CTUserCode + '</a>');
	$('.current-user-cred').button();
    $.mobile.changePage($('#home'));
    
    // getFileAlertSummary
	App.api.post({
		'path' : 'getFileAlertSummary',
		'params' : '{"sessionId" : "' + App.user.sessionId + '", "CTUserId" : "' + App.user.currentCredential.CTUserCode + '"}',
		'successCallback' : function(success) {
            //console.log(success);
            $('.ct-users-alerts').html('');
            $.each(success.d, function(i, alrt){
                var alertObject = new App.Alert(alrt);
                alertObject.appendToList(".ct-users-alerts");
            });
            
            $('.ct-users-alerts').listview('refresh');
		},
		'errorCallback' : function(error) {
			App.showError({'statusText' : 'Could not load file alerts.'});
		}
	});
});

$(document).on('click', '.current-user-cred', function(){
    $("#ctUsersHome").popup('open', { 'positionTo' : 'window', 'transition' : 'slidedown' });
});

function userLoginSuccessCallback(args) {
	$.mobile.hidePageLoadingMsg();
	
    App.user.department = args.d.DepartmentId;
    App.user.expires = args.d.Expires;
    App.user.name = args.d.Name;
    App.user.regionId = args.d.RegionId;
    App.user.userId = args.d.UserId;
    App.user.userId = 'B2ADAD4C-5132-4A2D-8361-F81807837A8A'; // TODO: remove this after real login implementation
    App.user.sessionId = args.d.SessionId;
    App.user.branch = args.d.Branch;
    
    App.config = {};
    $.each(args.d.AppConfig, function(i, configObject){
		App.config[configObject.Code] = configObject.Value;
	});
	
	// get contact types
	App.api.post({
		'base' : 'mobileService.svc',
		'path' : 'getContactTypes',
		'params' : '{ "sessionId" : "' + App.user.sessionId + '"}',
		'successCallback' : function(args){
			App.contactTypes = args.getContactTypesResult;
		},
		'errorCallback' : function(args){ App.contactTypes = []; }
	});
    
    // get offline transactions
    App.transaction.getOffline();
    
    //AppCredentials
    App.user.credentials = args.d.AppCredentials;
    //console.log(credentials);
    $('.ct-users').html('');
    if (App.user.credentials.length > 1) {
        // show dialog
        $.each(App.user.credentials, function(i, cred){
            $.tmpl('<li class="ct-user-line" data-rel="${code}"><a href="#">${code}</a></li>', { code: cred.CTUserCode }).appendTo(".ct-users");
        });
        
        $('.ct-users').listview('refresh');
        $("#ctUsers").popup('open', { 'positionTo' : 'window', 'transition' : 'slidedown' });
    } else {
        App.user.currentCredential = {
            CTUserCode: App.user.credentials[0].CTUserCode,
            CTUserId: App.user.credentials[0].CTUserId,
            PMId: App.user.credentials[0].PMId,
            SecurityFlags: App.user.credentials[0].SecurityFlags,
            UserType: App.user.credentials[0].UserType,
        };
        
        $.mobile.changePage($('#home'));
    }
	
	//console.log(App.user);
}

function userLoginErrorCallback(args) {
	$.mobile.hidePageLoadingMsg();
	
    args.statusText = "Invalid credentials";
    App.showError(args);
}

function userLogoutCallback() {
    App.user = null;
    
    // reset to defaults
    $('.current-region').html('');
    $('.current-user').html('');
    $('.current-branch').html('');
    
    App.jobs.empty('.joblist');
    App.branches.empty('.branchlist');
    
    $('input[data-type="search"]').val('');
    $('input[data-type="search"]').trigger('change');
    
    $.mobile.changePage($('#login'));
}
// end user login/logout callback functions