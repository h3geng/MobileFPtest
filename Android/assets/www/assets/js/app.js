(function(global){
    
    var App = App || {};
	App.PLATFORM = 'desk'; // desk-desktop version, bb10 - blackberry 10 device, andr - android device
	App.rippleLoaded = false;
	App.batchScan = false;
	global.App = App;
	
	App.deviceReady = false;
	switch (App.PLATFORM) {
		case 'bb10':
			$.getScript("local:///chrome/webworks.js", function() {
				$.getScript("assets/js/lib/barcodescanner.js", function() {
					document.addEventListener("webworksready", onDeviceReady, false);
					$("<link/>", {
						rel: "stylesheet",
						type: "text/css",
						href: "assets/css/bb.css"
					}).appendTo("head");
				});
			});
			
			$('div[data-grid="b"]').attr('data-grid', 'a');
			$('a[data-rel="grabba"]').remove();
			break;
		case 'andr':
			$.getScript("cordova.js", function() {
				$.getScript("assets/js/lib/barcodescanner.js", function() {
					document.addEventListener('deviceready', onDeviceReady, false);
				});
			});
			$.getScript("assets/js/lib/grabbascanner.js", function() {});
			break;
		default:
			window.setTimeout(onDeviceReady, 2000);
			break;
	}
	
	function onBBDeviceReady() {
		if (App.rippleLoaded) {
			return;
		}
		App.rippleLoaded = true;

		blackberry.event.addEventListener("pause", onPause);
		blackberry.event.addEventListener("resume", onResume);
		
		onDeviceReady();
	}
	
	function onPause() {
		if (window.plugins.barcodeScanner.scanTimeout !== null) {
			window.plugins.barcodeScanner.showResumeToast = true;
			window.plugins.barcodeScanner.stopBarcodeRead();
		}
	}

	function onResume() {
		if (window.plugins.barcodeScanner.showResumeToast === true) {
			window.plugins.barcodeScanner.showResumeToast = false;
		}
	}
	
	function onDeviceReady() {
        App.deviceReady = true;
		$('#deviceready .listening').html('Device ready.<br>Loading regions...');
		
		App.regions.getAll(function(args){
			$('#deviceready').remove();
			$('#btnLoginPage').show();
			App.deviceReady = true;
			$.mobile.changePage($('#login'));
			
			$('#select-region').selectmenu('refresh');
			$('#remember').checkboxradio('refresh');
		}, function(args){
			args.statusText = 'Could not load regions... ' + args.statusText;
			App.showError(args);
		});
    }
	
	$(document).on("pageinit", "[data-role='page']", function() {
		var page = "#" + $(this).attr('id');
		$(document).on("swiperight", page, function() {
			$.mobile.back();
		});
	});
	
	// error handling
	App.showError = function(args) {
        $.mobile.hidePageLoadingMsg();
        
        $.mobile.showPageLoadingMsg($.mobile.pageLoadErrorMessageTheme, args.statusText, true);
        setTimeout($.mobile.hidePageLoadingMsg, 4000);
    }
	
	App.showInfo = function(args) {
        $.mobile.hidePageLoadingMsg();
        
        $.mobile.showPageLoadingMsg($.mobile.pageLoadErrorMessageTheme, args.statusText, true);
        setTimeout($.mobile.hidePageLoadingMsg, 4000);
    }
	
	App.createAddress = function(addressObject) {
		var addressString = '';
		
		if (addressObject) {
			addressString += addressObject.Address + ', ' || '';
			addressString += addressObject.City + ', ' || '';
			addressString += addressObject.Province || '';
			addressString += addressObject.Postal || '';
		}
		
		addressString = $.trim(addressString);
		if (addressString.lastIndexOf(',') == addressString.length - 1) {
			addressString = addressString.substr(0, addressString.length - 1);
		}
		
		if (addressString === '') {
			addressString = 'No Address';
		}
		
		return addressString;
	}
	
	App.getContactType = function(contactTypeString) {
		var typeCode = '';
		
		$.each (App.contactTypes, function(){
			if (this.Value === contactTypeString) {
				typeCode = this.Id;
			}
		});
		
		return typeCode;
	}
	
	$('div[data-role="page"]').on('pagebeforeshow', function(args){
		if (args.target.id !== 'splash' && args.target.id !== 'login') {
			if (!App.user) {
				$.mobile.changePage($('#login'));
			}
		}
	});
	
	$("#jobEquipment").on("pagebeforeshow", function() {
		App.activeJob.refreshEquipment();
	});
	
	// login screen
	$("#login").on("pagebeforeshow", function() {
        var storedEmail = window.localStorage.getItem('email');
        if (storedEmail && $.trim(storedEmail) != '') {
            $('#email').val(storedEmail);
            $('#remember').prop('checked', true);
        } else {
            $('#email').val('');
            $('#remember').prop('checked', false);
        }
        
        $('#remember').checkboxradio('refresh');
    });
	
	$("#employees").on("pagebeforeshow", function() {
		App.batchScan = false;
		$('#employees h1').html('Find Employee');
	});
	
	$('#searchEmployeeSubmit').on('submit', function() {
		var term = $('#searchEmployee').val();
		
		App.contacts.search(term, '01', '.employeeslist');
		return false;
	});
	
	$("#companies").on("pagebeforeshow", function() {
		App.batchScan = false;
		App.api.post({
			'base' : 'mobileService.svc',
			'path' : 'getCompanyTypes',
			'params' : '{ "sessionId" : "' + App.user.sessionId + '"}',
			'successCallback' : function(args){
				//console.log(args);
				$('#searchCompanyTypes').find('option').remove();
				//$.tmpl("<option value=''>All</option>", { }).appendTo("#searchCompanyTypes");
				$.each (args.getCompanyTypesResult, function(){
					$.tmpl("<option value='${id}'>${value}</option>", { "id" : this.Id, "value" : this.Value }).appendTo("#searchCompanyTypes");
					//console.log(this);
				});
				$('#searchCompanyTypes').selectmenu('refresh');
			},
			'errorCallback' : function(args){ App.showError({'statusText' : 'Could not load company types.'}); }
		});
	});
	
	$("#contacts").on("pagebeforeshow", function() {
		App.batchScan = false;
		App.api.post({
			'base' : 'mobileService.svc',
			'path' : 'getContactTypes',
			'params' : '{ "sessionId" : "' + App.user.sessionId + '"}',
			'successCallback' : function(args){
				//console.log(args);
				$('#searchContactTypes').find('option').remove();
				//$.tmpl("<option value=''>All</option>", { }).appendTo("#searchContactTypes");
				$.each (args.getContactTypesResult, function(){
					$.tmpl("<option value='${id}'>${value}</option>", { "id" : this.Id, "value" : this.Value }).appendTo("#searchContactTypes");
					//console.log(this);
				});
				$('#searchContactTypes').selectmenu('refresh');
			},
			'errorCallback' : function(args){ App.showError({'statusText' : 'Could not load contact types.'}); }
		});
	});
	
	$('#searchContactSubmit').on('submit', function() {
		var term = $('#searchContact').val();
		var type = $('#searchContactTypes').val() || '';
		
		App.contacts.search(term, type);
		return false;
	});
	
	$('#searchContactTypes').on('change', function() {
		if ($('#searchContactTypes').val().length > 2) {
			$('#searchContactSubmit').submit();
		}
	});
	
	$('#searchCompanySubmit').on('submit', function() {
		var term = $('#searchCompany').val();
		var type = $('#searchCompanyTypes').val() || '';
		
		App.companies.search(term, type);
		return false;
	});
	
	$('#searchCompanyTypes').on('change', function() {
		if ($('#searchCompany').val().length > 2) {
			$('#searchCompanySubmit').submit();
		}
	});
    
	// general click handlers
    $(document).on('click', '.toolbar-logout', function(){
        if (confirm('Are you sure?')) {
			if (App.user != undefined) {
				App.user.logout(userLogoutCallback);
			} else {
				userLogoutCallback();
			}
		}
    });
    
    $(document).on('click', '.btnSearchList', function(){
		$.mobile.hidePageLoadingMsg();
        $.mobile.changePage($('#jobList'));
    });
    
    $(document).on('click', '.pending-transactions', function(){
		$.mobile.hidePageLoadingMsg();
        $.mobile.changePage($('#transactions'));
    });
    
    $(document).on('click', '.removeEquipment', function(){
        if (confirm('Are you sure?')) {
            var id = $(this).attr('data-rel');
            
            $.mobile.activePage.find('li#' + id).remove();
            var $currentList = $.mobile.activePage.find('[data-role="listview"]');
            $currentList.listview('refresh');
            
            App.transaction.remove(id);
            
            if ($currentList.html() == "") {
                $('.transaction-process').hide();
            }
        }
    });
    
    $(document).on('click', '.toolbar-item', function(){
		App.activeTimesheet = 0;
		App.batchScan = false;
		
		$.mobile.hidePageLoadingMsg();
        $('.toolbar-item').removeClass('ui-btn-active');
        $.mobile.changePage($($(this).attr('data-rel')));
    });
    
    $(document).on('click', '.toolbar-timesheets', function(){
		$.mobile.hidePageLoadingMsg();
		App.activeTimesheet = 1;
        $.mobile.changePage($('#timesheets'));
    });
	
	$(document).on('click', '#btnLoginPageGo', function(){
		$.mobile.changePage($('#login'));
		App.regions.getAll(function(args){
			$.mobile.changePage($('#login'));
			
			$('#select-region').selectmenu('refresh');
			$('#remember').checkboxradio('refresh');
		}, function(args){
			args.statusText = 'Could not load regions... ' + args.statusText;
			App.showError(args);
		});
	});
	
	$(document).on('click', '.eqp-in-transit', function(){
		$.mobile.hidePageLoadingMsg();
		if (confirm('Are you sure?')) {
			App.transaction.commitOnce(App.activeScan, {'type':'transit'}, function(args) {
				App.activeScan.reload(function(){
					$('.equipmentDetailsItems').slideUp('fast', function(){
						App.activeScan.showDetails();
						//App.activeScan.showFunctions();
						
						$('.equipmentDetailsItems').slideDown();
						
						App.activeScan = null;
					});
				});
			}, function(args) {
				args.statusText = "Could not update status.";
				app.showError(args);
			});
		}
    });
	
	$(document).on('click', '.eqp-return-branch', function(){
		$.mobile.hidePageLoadingMsg();
        if (confirm('Are you sure?')) {
			App.transaction.commitOnce(App.activeScan, {'type':'idle'}, function(args) {
				App.activeScan.reload(function(){
					$('.equipmentDetailsItems').slideUp('fast', function(){
						App.activeScan.showDetails();
						//App.activeScan.showFunctions();
						
						$('.equipmentDetailsItems').slideDown();
						
						App.activeScan = null;
					});
				});
			}, function(args) {
				args.statusText = "Could not update status.";
				app.showError(args);
			});
		}
    });
	
	$(document).on('click', '.current-job-link', function(){
		$.mobile.hidePageLoadingMsg();
        var claimIndx = $(this).attr('data-rel');
		
		App.activeJob = new App.Job({'ClaimIndx' : claimIndx});
		App.activeJob.showDetails();
    });
	
	$(document).on('click', '.eqp-issue-job', function(){
		$.mobile.hidePageLoadingMsg();
        if (confirm('Are you sure?')) {
			$.mobile.changePage("#jobList");
		}
    });
	
	$(document).on('click', '.eqp-branch-transfer', function(){
		$.mobile.hidePageLoadingMsg();
		if (confirm('Are you sure?')) {
			$.mobile.changePage("#branches");
		}
    });
	
	$(document).on('change', '#select-dep', function(){
		if ($(this).val() == "PM") {
			$('.alert-pm-container').show();
		} else {
			$('.alert-pm-container').hide();
		}
	});
	
	$(document).on('click', '.eqp-receive-item', function(){
		$.mobile.hidePageLoadingMsg();
        if (confirm('Are you sure?')) {
			App.transaction.commitOnce(App.activeScan, {'type':'idle'}, function(args) {
				App.activeScan.reload(function(){
					$('.equipmentDetailsItems').slideUp('fast', function(){
						App.activeScan.showDetails();
						//App.activeScan.showFunctions();
						
						$('.equipmentDetailsItems').slideDown();
						
						App.activeScan = null;
					});
				});
			}, function(args) {
				args.statusText = "Could not update status.";
				app.showError(args);
			});
		}
    });
	
	$(document).on('click', '.eqp-cancel', function(){
		$.mobile.hidePageLoadingMsg();
        App.showError({'statusText' : 'This feature is not implemented yet...'});
    });
	
	$(document).on('change', '#select-branch', function(){
		$.mobile.hidePageLoadingMsg();
        App.user.branch.Id = $('#select-branch').val();
		App.user.branch.Code = $('#select-branch option[value="' +App.user.branch.Id + '"]').attr('rel');
		App.user.branch.Value = $('#select-branch option[value="' +App.user.branch.Id + '"]').text();
    });
	
	$(document).on('click', '.home-details', function(){
		var path = $(this).attr('data-rel');
		$.mobile.changePage("#" + path);
	});
	
	$(document).on('click', '.job-details', function(){
		var path = $(this).attr('data-rel');
		switch (path) {
			case "jobEquipment":
				App.activeJob.showEquipment();
				break;
			case "jobNotes":
				App.activeJob.showNotes();
				break;
			case "jobPhotos":
				App.activeJob.showPictures();
				break;
			case "jobTimesheet":
				App.activeTimesheet = 1;
				App.timesheetJob = App.activeJob;
				$('.timesheet-job').text(App.activeJob.ClaimNumber);
				$('.timesheet-job').attr('data-rel', App.activeJob.ClaimIndx);
				
				$('#timesheet-phase').html('<option value="0"></option>');
				$.each (App.activeJob.PhaseList, function(){
					$.tmpl("<option value='${id}'>${value}</option>", { "id" : this.PhaseIndx, "value" : this.PhaseCode }).appendTo("#timesheet-phase");
				});
				$("#timesheet-phase").val($("#timesheet-phase option:first").val());
				//$('#timesheet-phase').selectmenu('refresh', true);
				
				$.mobile.changePage($('#timesheets'));
				break;
			default:
				$.mobile.changePage("#" + path);
				break;
		}
	});
	// end
    
	$('#timesheets').on("pagebeforeshow", function() {
		App.batchScan = false;
        $('#timesheets h1').html('Timesheet');
    });
	
	$('#jobList').on("pagebeforeshow", function() {
        $('#jobList h1').html('Search for Jobs');
    });
	
    $('#trucks').on("pagebeforeshow", function() {
        $('#trucks h1').html('Scan To: Transit');
    });
	
	$('#companies').on("pagebeforeshow", function() {
		App.batchScan = false;
        $('#companies h1').html('Find Company');
    });
	
	$('#contacts').on("pagebeforeshow", function() {
		App.batchScan = false;
        $('#contacts h1').html('Find Contact');
    });
    
    $('#equipmentDetails').on("pagebeforeshow", function() {
		App.batchScan = false;
        if (App.activeScan) {
            App.activeScan.showFunctions();
        }
    });
    
    $('#idle').on("pagebeforeshow", function() {
        $('#idle h1').html('Scan To: Return');
    });
	
	$('#jobPhotos').on("pagebeforeshow", function() {
		$('#select-img-ph').html('<option value="0">All</option>');
		if (App.activeJob && App.activeJob.PhaseList) {
			$.each (App.activeJob.PhaseList, function(){
				$.tmpl("<option value='${id}'>${value}</option>", { "id" : this.PhaseIndx, "value" : this.PhaseCode }).appendTo("#select-img-ph");
			});	
		}
		$("#select-img-ph").val($("#select-img-ph option:first").val());
		$('#select-img-ph').selectmenu('refresh', true);
	});
	
	$('#jobPhotoPreview').on("pagebeforeshow", function() {
		$('#select-img-ph-preview').html('<option value="0">All</option>');
		if (App.activeJob && App.activeJob.PhaseList) {
			$.each (App.activeJob.PhaseList, function(){
				$.tmpl("<option value='${id}'>${value}</option>", { "id" : this.PhaseIndx, "value" : this.PhaseCode }).appendTo("#select-img-ph-preview");
			});
		}
		$("#select-img-ph-preview").val($("#select-img-ph-preview option:first").val());
		$('#select-img-ph-preview').selectmenu('refresh', true);
	});
	
	$('#jobMoisture').on("pagebeforeshow", function() {
		App.batchScan = false;
		$('#jobMoisture h1').html('Moisture Readings');
	});
	
	$('#jobSchedule').on("pagebeforeshow", function() {
		App.batchScan = false;
		$('#jobSchedule h1').html('Schedule');
	});
	
	$('#addNote').on("pagebeforeshow", function() {
		App.batchScan = false;
		App.api.post({
			'base' : 'Messaging.aspx',
			'path' : 'Get_NoteDepartments',
			'params' : '{ "sessionId" : "' + App.user.sessionId + '", "regionId" : ' + App.user.regionId + '}',
			'successCallback' : function(args) {
				if (args.d) {
					console.log(App.activeJob);
					$('#select-dep').html('<option value="">Select a Department</option>');
					$.each (args.d, function(){
						$.tmpl("<option value='${id}'>${value}</option>", { "id" : this.Id, "value" : this.Value }).appendTo("#select-dep");
					});
					$("#select-dep").val($("#select-dep option:first").val());
					$('#select-dep').selectmenu('refresh', true);
					
					$('#select-ph').html('<option value="0"></option>');
					$.each (App.activeJob.PhaseList, function(){
						$.tmpl("<option value='${id}'>${value}</option>", { "id" : this.PhaseIndx, "value" : this.PhaseCode }).appendTo("#select-ph");
					});
					$("#select-ph").val($("#select-ph option:first").val());
					$('#select-ph').selectmenu('refresh', true);
					$('#noteMessage').val('');
				}
			},
			'errorCallback' : function() {
				$('#select-dep').html('');
				$('#select-ph').html('<option value=""></option>');
				$('#select-dep').selectmenu('refresh', true);
				$('#select-ph').selectmenu('refresh', true);
				$('#noteMessage').val('');
			}
		});
	});
    
    // page event handlers
    $("#transactions").on("pagebeforeshow", function() {
		App.batchScan = false;
		$('#transactions h1').html('Pending transactions');
        if (App.transaction.items.length === 0) {
            $('#transactions .transaction-process').hide();
        } else {
            $('#transactions .transaction-process').show();
        }
        var cont = '.pending';
        $(cont).html('');
        
        $.each(App.transaction.items, function(i, item){
            //console.log(item);
            var options = {};
            options.commands = {'refresh': function(){ $(cont).listview('refresh'); }};
            options.container = cont;
            options.templateFunctions = {
                
                getNewStatus: function() {
                    var ret = "";
                    switch (item.object.type) {
                        case "transit":
                            ret = "Transit";
                            break;
                        case "branch":
                            ret = "Inter-Branch Transit";
                            break;
                        case "job":
                            ret = "Issued To Job";
                            break;
                        case "idle":
                            ret = "Available";
                            break;
                    }
                    return ret;
                },
                getDetails: function() {
                    var ret = "";
                    switch (item.object.type) {
                        case "branch":
                            ret = ' - ' + item.object.branchData.Value + '(' + item.object.branchData.Code + ')';
                            break;
                        case "job":
                            ret = ' - Claim: ' + item.object.ClaimNumber + ', Phase: ' + item.equipment.phase;
                            break;
                    }
                    return ret;
                }
                
            };
            
            App.template.build(
                'equipmentPending',
                item.equipment,
                options
            );
        });
    });
    
    $('#settings').on('pagebeforeshow', function() {
		App.batchScan = false;
		$('#settings h1').html('Settings');
		if (App.branches.items.length === 0) {
			App.api.post({
				'base' : 'mobileService.svc',
				'path' : 'getBranches',
				'params' : '{ "sessionId" : "' + App.user.sessionId + '", "regionId" : ' + App.user.regionId + '}',
				'successCallback' : function(args) {
					App.branches.fill(args.getBranchesResult);
					
					$('#select-branch').html('');
					$.each (App.branches.items, function(){
						$.tmpl("<option value='${id}' rel='${code}'>${value}</option>", { "id" : this.branchData.Id, "code" : this.branchData.Code, "value" : this.branchData.Value }).appendTo("#select-branch");
					});
					
					$('#select-branch').val(parseInt(App.user.branch.Id));
					$('#select-branch').selectmenu('refresh');
				},
				'errorCallback' : function(args) {
					console.log(args);
				}
			});
		}
	});
	
	$('#jobDetails').on('pagebeforeshow', function() {
		App.batchScan = false;
		App.activeTimesheet = 0;
	});
    
    $('#home').on('pagebeforeshow', function() {
		App.batchScan = false;
		App.activeTimesheet = 0;
		$('#home h1').html('mobileFP Home');
        var c_u = $('.current-user');
        if (c_u.html() === "") {
            $('.current-region').html($('#select-region option[value="' + App.user.regionId + '"]').text());
            c_u.html(App.user.name);
			//console.log(App.user.currentCredential);
			//$('.ct-user').html('<a class="current-user-cred" href="#">' + App.user.currentCredential.CTUserCode + '</a>');
        }
		
		if (App.user.branch && App.user.branch.Value != "") {
			$('.current-branch').html('<a href="#settings" class="current-branch-link" data-role="button" data-mini="true" data-inline="true">' + App.user.branch.Value + '</a>');
		} else {
			$('.current-branch').html('<a href="#settings">[no home branch]</a>');
		}
		$('.current-branch-link').button();
		
		if (App.user.credentials.length > 1) {
			$('.ct-users-home').html('');
			
			$.each(App.user.credentials, function(i, cred){
				$.tmpl('<li class="ct-user-line" data-rel="${code}"><a href="#">${code}</a></li>', { code: cred.CTUserCode }).appendTo(".ct-users-home");
			});
			
			$('.ct-users-home').listview('refresh');
		}
		
		$('.pending-transactions-line').find('.ui-li-count').html(App.transaction.items.length);
    });
	
	$("#branches").on("pagebeforeshow", function() {
		$('#branches h1').html('Batch Scan To Branch');
    });
    
    $("#branches").on("pageshow", function() {
        buildBranchList();
    });
    
    $("#scan").on("pagebeforeshow", function() {
		$('#scan h1').html('Batch Scan To Status');
    });
    
    $("#camera").on("pagebeforeshow", function() {
		$('#camera h1').html('Single Scan Mode');
        $('.waitmessage').html('');
        $('#cameraCode').val('');
		if (App.activeScan === null) {
			$('.scanresult').html('');
			$('.scan-manual-set').hide();
		}
		
		//console.log(App.activeScan);
    });
    // end page event handlers
    
    // branch list related functions
    function buildBranchList() {
        if (App.branches.items.length === 0) {
            $.mobile.showPageLoadingMsg();
            
            App.api.post({
                'path' : 'getBranches',
                'params' : '{ "sessionId" : "' + App.user.sessionId + '", "regionId" : ' + App.user.regionId + '}',
                'successCallback' : buildBranchListSuccessCallback,
                'errorCallback' : App.showError
            });
        }
    }
    
    function buildBranchListSuccessCallback(args) {
        $.mobile.hidePageLoadingMsg();
        
        App.branches.fill(args.d);
        App.branches.buildList('.branchlist');
    }
    // end branch list related functions
    
    // scan screen and quick links navigation
    $('.link-truck').on('click', function() {
		App.activeScan = null;
		App.batchScan = true;
        $.mobile.changePage($('#trucks'));
    });
    
    $('.link-branch').on('click', function() {
		App.activeScan = null;
		App.batchScan = true;
        $.mobile.changePage($('#branches'));
    });
    
    $('.link-job').on('click', function() {
		App.activeScan = null;
		App.batchScan = true;
        $.mobile.changePage($('#jobList'));
    });
	
	$('.link-job-home').on('click', function() {
		App.activeScan = null;
		App.batchScan = false;
        $.mobile.changePage($('#jobList'));
    });
    
    $('.link-idle').on('click', function() {
		App.activeScan = null;
		App.batchScan = true;
        $.mobile.changePage($('#idle'));
    });
	// end scan screen and quick links navigation
    
    $('.toolbar-camera-link').on('click', function() {
        $('.scan-manual-set').hide();
		App.activeScan = null;
		
        $('#camera .scanresult').html('');
        $.mobile.changePage($('#camera'));
    });
    // end scan screen and quick links navigation

    // scan related functions
    $('.scan-camera').on('click', function() {
		$.mobile.hidePageLoadingMsg();
        var mode = $(this).attr('data-rel');
        var manual = $('#camera .scan-manual-set');
        
		// remove footer active state
		$.mobile.activePage.find('.ui-footer a.ui-btn-active').removeClass('ui-btn-active');
		
        if (mode === 'manual') {
            manual.slideDown();
        } else {
            manual.slideUp('fast', function(){
                App.scanner.scan({
                    'type' : mode,
                    'container' : '#camera',
                    'successCallback' : scanResultSuccessCallback,
                    'errorCallback' : scanResultErrorCallback
                });
            });
        }
    });
    
    $("#cameraScan").on("submit", function() {
        $('.scanresult').html('');
        $('.waitmessage').html('Waiting...');
        
        App.scanner.scan({
            'type' : 'manual',
            'code' : $('#cameraCode').val(),
            'container' : '#camera',
            'successCallback' : scanResultSuccessCallback,
            'errorCallback' : scanResultErrorCallback
        });
        
        return false;
    });
    
    function scanResultSuccessCallback(args) {
        $('.waitmessage').html('');
        $.mobile.hidePageLoadingMsg();
		
        //console.log(args.container);
        if (args.d && args.d.Id > 0) {
            $('.scanresults').html('');
            $('#cameraCode').val('');
            
            var eqp = new App.Equipment(args.d);
            
            var options = {};
            options.templateBindings = {'click': function() { eqp.showDetails(); }};
            options.commands = {
                'col_set': function(){ $('.equipmentscannedcontainer').collapsibleset(); },
                'col': function(){ $('.equipmentscannedcontainerdata').collapsible(); },
                'list': function(){ $('.equipmentscanned').listview(); }
            };
            options.container = '.scanresults';
            
            App.template.build(
                'scanResult',
                eqp,
                options
            );
        } else {
            args.statusText = "Item not found...";
            scanResultErrorCallback(args);
        }
    }
    
    function scanResultErrorCallback(args) {
		if (args.statusText === "GRB-0") {
			args.statusText = "Nothing Scanned";
		}
		
        $('.waitmessage').html('');
        App.showError(args);
    }
    // end scan related functions
    
    // job scan related functions
    $('.scan-job').on('click', function() {
		$.mobile.hidePageLoadingMsg();
		
		// remove footer active state
		$.mobile.activePage.find('.ui-footer a.ui-btn-active').removeClass('ui-btn-active');
		
        // check for phase index
        var phase = $('#phaseList').val();
        
        if (phase !== '') {
            var mode = $(this).attr('data-rel');
            var manual = $('#jobEquipment .scan-manual-set');
            
            if (mode === 'manual') {
                manual.slideDown();
            } else {
                manual.slideUp('fast', function(){
                    App.scanner.scan({
                        'type' : mode,
                        'successCallback' : scanJobResultSuccessCallback,
                        'errorCallback' : scanResultErrorCallback
                    });
                });
            }
        } else {
            var args = {'statusText' : 'Please select a phase before scan.'};
            App.showError(args);
        }
    });
    
    $("#jobScan").on("submit", function() {
        $('.waitmessage').html('Waiting...');
        
        App.scanner.scan({
            'type' : 'manual',
            'code' : $('#jobCode').val(),
            'container' : '#jobDetails',
            'successCallback' : scanJobResultSuccessCallback,
            'errorCallback' : scanResultErrorCallback
        });
        
        return false;
    });
    
    function scanJobResultSuccessCallback(args) {
        $('.waitmessage').html('');
        $.mobile.hidePageLoadingMsg();
        
        if (args.d && args.d.Id > 0) {
            $('#jobCode').val('');
            
            var eqp = new App.Equipment(args.d);
			eqp.commited = 'not-committed';
            
            if (App.transaction.checkExists(eqp)) {
                alert('This equipment already in transaction.');
            } else {
                if (App.activeJob.checkEquipment(eqp)) {
					alert('This equipment already assigned to this job.');
				} else {
					var options = {};
					options.commands = {'refresh': function(){ $('.jobequipment').listview('refresh'); }};
					options.container = '.jobequipment';
					
					App.template.build(
						'equipmentRemove',
						eqp,
						options
					);
					
					App.activeJob.equipment.push(eqp);
					App.transaction.append(eqp, App.activeJob);
					$('#jobEquipment .transaction-process').show();
					
					if (App.batchScan && args.type && (args.type === 'camera' || args.type === 'grabba')) {
						App.scanner.scan({
							'type' : args.type,
							'successCallback' : scanJobResultSuccessCallback,
							'errorCallback' : scanResultErrorCallback
						});
					}
				}
            }
        } else {
            args.statusText = "Item not found...";
            scanResultErrorCallback(args);
        }
    }
    // end scan related functions
    
    // truck scan mode
    $('.scan-trucks').on('click', function() {
		$.mobile.hidePageLoadingMsg();
        var mode = $(this).attr('data-rel');
        var manual = $('#trucks .scan-manual-set');
        
		// remove footer active state
		$.mobile.activePage.find('.ui-footer a.ui-btn-active').removeClass('ui-btn-active');
		
        if (mode === 'manual') {
            manual.slideDown();
        } else {
            manual.slideUp('fast', function(){
                doBatchScanTruck(mode);
            });
        }
    });
    
    function doBatchScanTruck(type) {
        App.scanner.scan({
            'type' : type,
            'successCallback' : scanTruckResultSuccessCallback,
            'errorCallback' : scanTruckResultErrorCallback
        });
    }
    
    $("#truckScan").on("submit", function() {
        $('.waitmessage').html('Waiting...');
        
        App.scanner.scan({
            'type' : 'manual',
            'code' : $('#truckCode').val(),
            'container' : '#trucks',
            'successCallback' : scanTruckResultSuccessCallback,
            'errorCallback' : scanResultErrorCallback
        });
        
        return false;
    });
    
    function scanTruckResultSuccessCallback(args) {
        $('.waitmessage').html('');
        $.mobile.hidePageLoadingMsg();
        
        if (args.d && args.d.Id > 0) {
            $('#truckCode').val('');
            
            var eqp = new App.Equipment(args.d);
            
            if (App.transaction.checkExists(eqp)) {
                alert('This equipment already in transaction.');
            } else {
                var options = {};
                options.commands = {'refresh': function(){ $('.trucklist').listview('refresh'); }};
                options.container = '.trucklist';
                
                App.template.build(
                    'equipmentRemove',
                    eqp,
                    options
                );
                
                App.transaction.append(eqp, {'type' : 'transit'});
				$('#trucks .transaction-process').show();
            }
            
            if (args.type !== 'manual') {
				setTimeout(function() {
					doBatchScanTruck(args.type);
				}, 1000);
            }
        } else {
            if (args.type !== 'manual') {
                setTimeout(function() {
					doBatchScanTruck(args.type);
				}, 1000);
            } else {
                args.statusText = "Item not found...";
                scanResultErrorCallback(args);
            }
        }
    }
    
    function scanTruckResultErrorCallback(args) {
        if (!args.cancelled && args.statusText !== "GRB-0") {
            setTimeout(function() {
				doBatchScanTruck(args.type);
			}, 1000);
        }
    }
    // end truck scan mode
    
    // idle scan mode
    $('.scan-idle').on('click', function() {
		$.mobile.hidePageLoadingMsg();
        var mode = $(this).attr('data-rel');
        var manual = $('#idle .scan-manual-set');
		
		// remove footer active state
		$.mobile.activePage.find('.ui-footer a.ui-btn-active').removeClass('ui-btn-active');
        
        if (mode === 'manual') {
            manual.slideDown();
        } else {
            manual.slideUp('fast', function(){
                App.scanner.scan({
                    'type' : mode,
                    'successCallback' : scanIdleResultSuccessCallback,
                    'errorCallback' : scanResultErrorCallback
                });
            });
        }
    });
    
    $("#idleScan").on("submit", function() {
        $('.waitmessage').html('Waiting...');
        
        App.scanner.scan({
            'type' : 'manual',
            'code' : $('#idleCode').val(),
            'container' : '#idle',
            'successCallback' : scanIdleResultSuccessCallback,
            'errorCallback' : scanResultErrorCallback
        });
        
        return false;
    });
    
    function scanIdleResultSuccessCallback(args) {
        $('.waitmessage').html('');
        $.mobile.hidePageLoadingMsg();
        
        if (args.d && args.d.Id > 0) {
            $('#idleCode').val('');
            
            var eqp = new App.Equipment(args.d);
            
            if (App.transaction.checkExists(eqp)) {
                alert('This equipment already in transaction.');
            } else {
                var options = {};
                options.commands = {'refresh': function(){ $('.idlelist').listview('refresh'); }};
                options.container = '.idlelist';
                
                App.template.build(
                    'equipmentRemove',
                    eqp,
                    options
                );
                
                App.transaction.append(eqp, {'type' : 'idle'});
                $('#idle .transaction-process').show();
            }
        } else {
            args.statusText = "Item not found...";
            scanResultErrorCallback(args);
        }
    }
    // end idle scan mode
    
    // branch scan mode
    $('.branch-camera').on('click', function() {
        var mode = $(this).attr('data-rel');
        var manual = $('#branchDetails .scan-manual-set');
		
		// remove footer active state
		$.mobile.activePage.find('.ui-footer a.ui-btn-active').removeClass('ui-btn-active');
        
        if (mode === 'manual') {
            manual.slideDown();
        } else {
            manual.slideUp('fast', function(){
                App.scanner.scan({
                    'type' : mode,
                    'successCallback' : scanBranchResultSuccessCallback,
                    'errorCallback' : scanResultErrorCallback
                });
            });
        }
    });
    
    $("#branchScan").on("submit", function() {
        $('.waitmessage').html('Waiting...');
        
        App.scanner.scan({
            'type' : 'manual',
            'code' : $('#branchCode').val(),
            'container' : '#branchDetails',
            'successCallback' : scanBranchResultSuccessCallback,
            'errorCallback' : scanResultErrorCallback
        });
        
        return false;
    });
    
    function scanBranchResultSuccessCallback(args) {
        $('.waitmessage').html('');
        $.mobile.hidePageLoadingMsg();
        
        if (args.d && args.d.Id > 0) {
            $('#branchCode').val('');
            
            var eqp = new App.Equipment(args.d);
            
            if (App.transaction.checkExists(eqp)) {
                alert('This equipment already in transaction.');
            } else {
                var options = {};
                options.commands = {'refresh': function(){ $('.branchequipments').listview('refresh'); }};
                options.container = '.branchequipments';
                
                App.template.build(
                    'equipmentRemove',
                    eqp,
                    options
                );
                
                App.activeBranch.equipments.push(eqp);
                App.transaction.append(eqp, App.activeBranch);
				$('#branchDetails .transaction-process').show();
            }
        } else {
            args.statusText = "Item not found...";
            scanResultErrorCallback(args);
        }
    }
    // end branch scan mode
	
	// timesheet events
	$(".timesheet-job").on("click", function() {
		$.mobile.changePage("#jobList");
	});
	
    $(".timesheet-cancel").on("click", function() {
		if (confirm("Are you sure?")) {
			App.activeTimesheet = 0;
			$.mobile.changePage("#home");
		}
	});
	
	$(".timesheet-ok").on("click", function() {
		var opts = {};
		
		opts.claimIndx = $('.timesheet-job').attr('data-rel');
		opts.phaseIndx = $('#timesheet-phase').val();
		opts.dateWorked = $('#timesheet-date').val();
		opts.hours = $('#timesheet-hours').val();
		opts.note = $('#timesheet-note').val();
		
		var timesheet = new App.Timesheet(opts);
		timesheet.release();
		
		//$('.timesheet-job').attr('data-rel', '0');
		//$('.timesheet-job .ui-btn-text').text("Select a Job");
		
		//$('#timesheet-phase').html('<option value="0"></option>');
		$('#timesheet-date').val('');
		$('#timesheet-hours').val('');
		$('#timesheet-note').val('');
		
		//App.activeTimesheet = 0;
		//$.mobile.changePage("#home");
	});
	// end timesheet events
    
    // transaction events
    $(".transaction-cancel").on("click", function() {
		if (confirm('Are you sure?')) {
			var type = $(this).attr('data-rel');
			if (type === 'job') {
				App.transaction.clean({'type' : type, 'id' : App.activeJob.ClaimIndx});
			} else {
				App.transaction.clean({'type' : type});
			}
			
			switch (type) {
				case "transit":
					$('.trucklist').html('');
					break;
				case "idle":
					$('.idlelist').html('');
					break;
				case "branch":
					$('.branchequipments').html('');
					break;
				case "job":
					App.activeJob.clean();
					App.activeJob.showEquipment();
					break;
				case "pending":
					$('.pending').html('');
					break;
			}
			
			$('.transaction-process').hide();
			
			if (App.activeScan && type != 'job') {
				$.mobile.changePage("#equipmentDetails");
			}
		}
    });
    
    $(".transaction-ok").on("click", function() {
		if (confirm('Are you sure?')) {
			var type = $(this).attr('data-rel');
			$('span.error').remove();
			
			if (App.activeScan) {
				var obj;
				switch (type) {
					case "branch":
						obj = App.activeBranch;
						obj.type = 'branch';
						break;
					case "job":
						var phase = $('#phaseList').val();
						
						if (phase === '') {
							var args = {'statusText' : 'Please select a phase before commit.'};
							App.showError(args);
							return;
						} 
						obj = App.activeJob;
						obj.type = 'job';
						break;
					default:
						obj = {'type' : 'idle'};
						break;
				}
				
				App.transaction.commitOnce(App.activeScan, obj, function(args) {
					App.activeScan.reload(function(){
						$('.equipmentDetailsItems').slideUp('fast', function(){
							$('.transaction-process').hide();
							
							App.activeScan.showDetails();
							//App.activeScan.showFunctions();
							
							$('.equipmentDetailsItems').slideDown();
							
							App.activeScan = null;
						});
					});
				}, function(args) {
					args.statusText = "Could not update status.";
					App.showError(args);
				});
				
				$.mobile.changePage("#equipmentDetails");
			} else {
				App.transaction.commit({'type' : type}, processTransaction, processTransaction);
				
				// remove footer active state
				$.mobile.activePage.find('.ui-footer a.ui-btn-active').removeClass('ui-btn-active');
			}
		}
    });
    
    function processTransaction(args) {
        var results = args.d.Results;
        var clean = true;
		//console.log(results);
        $.each(results, function(i, item){
            if (item.Message !== null) {
                $.mobile.activePage.find('li#' + item.itemId + ' a p.ui-li-desc:last').append('<span class="error">' + item.Message + '</span>');
                clean = false;
            } else {
                App.transaction.remove(item.itemId);
                if (args.type != 'job') {
                    $.mobile.activePage.find('li#' + item.itemId).remove();
                    $.mobile.activePage.find('[data-role="listview"]').listview('refresh');
                }
            }
        });
        
        if (clean) {
            App.transaction.clean({'type' : args.type});
			switch (args.type) {
				case "transit":
					$('.trucklist').html('');
					break;
				case "idle":
					$('.idlelist').html('');
					break;
				case "branch":
					$('.branchequipments').html('');
					break;
				case "job":
					App.activeJob.commit();
					App.activeJob.showEquipment();
					break;
				case "pending":
					$('.pending').html('');
					break;
			}
            $('.transaction-process').hide();
        }
        
		App.transaction.store();
    }
    // end transaction events
    
})(this);