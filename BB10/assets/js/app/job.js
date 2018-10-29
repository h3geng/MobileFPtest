/**
 * A job class to init the specified job
 * 
 * @param {Object} data The data of job
 */

App.Job = function(data) {
    var _self = this;
    
    $.extend(this, data);
    this.type = 'job';
    this.equipment = [];
	this.notes = [];
	this.pictures = [];
}

/**
 * Append job item to list
 * 
 * @param {String} list The list container selector
 */
App.Job.prototype.appendToList = function(list) {
    var _self = this;
    
    var options = {};
    options.templateFunctions = {};
    options.templateBindings = {'click': function() { _self.showDetails(); }};
    options.commands = {'refresh': function(){ $(list).listview('refresh'); }};
    options.container = list;
    
    App.template.build(
        'job',
        _self,
        options
    );
}

/**
 * Show job details
 */
App.Job.prototype.showDetails = function() {
    var _self = this;
    App.activeJob = this;
	
	$.mobile.showPageLoadingMsg();
	
	$('#jobDetails h1').html(_self.ClaimNumber + ' Details');
	
    // loading related equipment
    App.api.post({
        'path' : 'getJob',
        'params' : '{ "sessionId" : "' + App.user.sessionId + '", "regionId" : ' + App.user.regionId + ', "claimIndx" : ' + _self.ClaimIndx + '}',
        'successCallback' : function(args) {
            if (args.d) {
                $.extend(_self, args.d);
            }
			
			//console.log(_self);
            
			if (App.activeTimesheet && App.activeTimesheet == 1) {
				App.timesheetJob = _self;
				$('.timesheet-job .ui-btn-text').text(_self.ClaimNumber);
				$('.timesheet-job').attr('data-rel', _self.ClaimIndx);
				//console.log(_self);
				
				$('#timesheet-phase').html('<option value="0"></option>');
				$.each (_self.PhaseList, function(){
					$.tmpl("<option value='${id}'>${value}</option>", { "id" : this.PhaseIndx, "value" : this.PhaseCode }).appendTo("#timesheet-phase");
				});
				$("#timesheet-phase").val($("#timesheet-phase option:first").val());
				$('#timesheet-phase').selectmenu('refresh', true);
				
				$.mobile.changePage($('#timesheets'));
			} else {
				// build job details
				var detailsContainer = $('.jobdetails');
				detailsContainer.html('');
				
				var options = {};
				options.container = detailsContainer;
				options.commands = {
					'go': function() {
						if (App.activeScan || App.batchScan) {
							_self.showEquipment();
						} else {
							$.mobile.changePage($('#jobDetails'));
							$('.job-details').collapsibleset();
							$('.job-customer').collapsible();
							$('.job-customer-details').listview();
							$('.job-workflow-kpi').collapsible();
							$('.job-workflow-kpi-details').listview();
							$('.claim-details').listview();
						}
					}
				};
				options.templateFunctions = {
					AdjCompanyCode : function() {
						var code = '';
						if (_self.AdjCompany) {
							code = _self.AdjCompany.Code || '';
						}
						return code;
					},
					AdjusterCode : function() {
						var code = '';
						if (_self.Adjuster) {
							code = _self.Adjuster.Id || '';
						}
						return code;
					},
					InsurerCode : function() {
						var code = '';
						if (_self.Insurer) {
							code = _self.Insurer.Code || '';
						}
						return code;
					},
					AdjCompanyAddress : function() {
						return App.createAddress(_self.AdjCompany.Address);
					},
					AdjusterAddress : function() {
						return App.createAddress(_self.Adjuster.Address);
					},
					InsurerAddress : function() {
						return App.createAddress(_self.Insurer.Address);
					},
					ValueWithProperty : function(find, prop) {
						return $.map(_self.KPI.actuals.phaseTimelines, function(val) { return val.phaseCode === find ? val[prop] : ''; })[0];
					},
					ScoreWithProperty : function(find, prop) {
						return $.map(_self.KPI.scores.phaseScores, function(val) { return val.phaseCode === find ? val[prop] : ''; })[0];
					}
				}
				
				App.template.build(
					'jobDetail',
					_self,
					options
				);
			}
        },
        'errorCallback' : function(args) {
            _self.equipment = [];
			_self.notes = [];
			_self.pictures = [];
			
			App.showError({'statusText' : 'Sorry, could not load the selected job details.'});
        }
    });
}

$(document).on('click', '.contactAdjCompany', function() {
	App.activeJob.showAdjCompany();
});

App.Job.prototype.showAdjCompany = function() {
	var _self = this;
	$.mobile.showPageLoadingMsg();
	
	var company = new App.Company({'Id' : _self.AdjCompany.Id});
	company.showDetails();
}

$(document).on('click', '.contactAdj', function() {
	App.activeJob.showAdjuster();
});

App.Job.prototype.showAdjuster = function() {
	var _self = this;
	$.mobile.showPageLoadingMsg();
	
	var id = App.getContactType(_self.Adjuster.ContactType);
	if (id !== '') {
		var contact = new App.Contact({});
		contact.load(id, _self.Adjuster.Id, function(args) {
			contact.showDetails();
		}, function(args) {
			App.showError({'statusText' : 'Could not load contact.'});
		});
	} else {
		App.showError({'statusText' : 'Invalid contact type'});
	}
}

$(document).on('click', '.contactInsurer', function() {
	App.activeJob.showInsurer();
});

App.Job.prototype.showInsurer = function() {
	var _self = this;
	$.mobile.showPageLoadingMsg();
	
	var company = new App.Company({'Id' : _self.Insurer.Id});
	company.showDetails();
}

App.Job.prototype.addEquipment = function(eqp) {
	var _self = this;
	var exists = false;
	$.each(_self.equipment, function(i, equipment){
		if (equipment.id === eqp.id) {
			exists = true;
		}
    });
	
	if (!exists) {
		_self.equipment = _self.equipment.concat(eqp);
	}
}

App.Job.prototype.checkEquipment = function(eqp) {
	var _self = this;
	var exists = false;
	$.each(_self.equipment, function(i, equipment){
		if (equipment.id === eqp.id) {
			exists = true;
		}
    });
	
	return exists;
}

App.Job.prototype.getNotCommitted = function() {
	
	var _self = this;
	
	var notCommitted = [];
	
	$.each(_self.equipment, function(i, equipment){
		if (equipment.commited !== '') {
			notCommitted = notCommitted.concat(equipment);
		}
	});
	
	return notCommitted;
	
}

App.Job.prototype.clean = function() {
	
	var _self = this;
	
	var committed = [];
	
	$.each(_self.equipment, function(i, equipment){
		if (equipment.commited === '') {
			committed = committed.concat(equipment);
		}
	});
	
	_self.equipment = committed;
}

App.Job.prototype.commit = function() {
	
	var _self = this;
	
	var committed = [];
	
	$.each(_self.equipment, function(i, equipment){
		equipment.commited = '';
		committed = committed.concat(equipment);
	});
	
	_self.equipment = committed;
}

App.Job.prototype.showEquipment = function() {
    var _self = this;
	
	$('#phaseList').html('<option value="">Select a Phase</option>');
	$('#phaseList').selectmenu().selectmenu('refresh');
	
	$('.scan-manual-set').hide();
    $('.jobequipment').html('');
	
	if ($.mobile.activePage.attr('id') == 'jobEquipment') {
		_self.refreshEquipment();
	}
	
	if (App.activeScan) {
		App.activeScan.commited = 'not-committed';
		_self.addEquipment(App.activeScan);
	}
	
	$.mobile.changePage("#jobEquipment");
}

App.Job.prototype.refreshEquipment = function() {
	var _self = this;
	
	// refresh related equipment
    App.api.post({
        'path' : 'getJob',
        'params' : '{ "sessionId" : "' + App.user.sessionId + '", "regionId" : ' + App.user.regionId + ', "claimIndx" : ' + _self.ClaimIndx + '}',
        'successCallback' : function(args) {
            if (args.d) {
                $.extend(_self, args.d);
				
				if (_self.PhaseList) {
					$('#phaseList').html('<option value="">Select a Phase</option>');
					$.each (_self.PhaseList, function(){
						$.tmpl("<option value='${id}'>${value}</option>", { "id" : this.PhaseIndx, "value" : this.PhaseCode }).appendTo("#phaseList");
					});
				}
				
				var notCommitted = _self.getNotCommitted();
				_self.equipment = [];
				
				if (_self.InventoryList) {
					$.each(_self.InventoryList, function(i, equipment){
						_self.equipment = _self.equipment.concat(new App.Equipment(equipment));
					});
				}
				
				$.each(notCommitted, function(i, equipment){
					_self.addEquipment(equipment);
				});
				
				var notCommitted = _self.getNotCommitted();
				
				if (notCommitted.length > 0) {
					$('#jobEquipment .transaction-process').show();
				} else {
					$('#jobEquipment .transaction-process').hide();
				}
				
				// build job equipment
				var equipmentContainer = '.jobequipment';
				$(equipmentContainer).find('li').remove();
				$.each(_self.equipment, function(i, equipment){
					equipment.appendToList(equipmentContainer);
				});
            }
			
			$('#jobEquipment h1').html(_self.ClaimNumber + ' Equipment');
        },
        'errorCallback' : function() {
            _self.equipment = [];
			App.showError({'statusText' : 'Sorry, could not load equipment data.'});
        }
    });
}

App.Job.prototype.showNotes = function(page) {
    var _self = this;
	
	if (!page) {
		page = 1;
	}
	var noteContainer = '.notesdetails';
	$(noteContainer).html('');
	
	$.mobile.showPageLoadingMsg();
	
	App.api.post({
		'base' : 'Messaging.aspx',
        'path' : 'Get_JobNotes',
        'params' : '{ "sessionId" : "' + App.user.sessionId + '", "regionId" : ' + App.user.regionId + ', "claimIndx" : ' + _self.ClaimIndx + ', "phaseIndx" : 0, "deptId" : "", "page" : ' + page + '}',
        'successCallback' : function(args) {
            if (args.d) {
                //console.log(args.d);
				_self.notes = [];
				
				if (args.d.items) {
					$.each(args.d.items, function(i, noteObject){
						_self.notes = _self.notes.concat(new App.Note(noteObject));
					});	
				}
				
				$.mobile.hidePageLoadingMsg();
				
				$('.noteTotalItems').html(args.d.totalItems);
				if (parseInt(args.d.totalItems) > 0) {
					$('#show-page').html(page + ' of ' + Math.ceil(parseInt(args.d.totalItems) / parseInt(args.d.perPage)));
					$('.show-page-option').show();
				} else {
					$('.show-page-option').hide();
				}
				
				// build job photos
				var grp = '';
				$.each(_self.notes, function(i, note){
					var subheader = null;
					if (note.noteData.date != grp) {
						grp = note.noteData.date;
						subheader = $.tmpl('<li data-role="list-divider">${title} <span class="ui-li-count">${count}</span></li>', {
							'title' : function() {
								//return grp;
								var from = grp.split("/");
								var dStr = new Date(from[2], from[0] - 1, from[1]).toDateString();
								return dStr;
							},
							'count' : function() {
								var cnt = 0;
								
								$.each(_self.notes, function(i, n){
									if (n.noteData.date === note.noteData.date) {
										cnt++;
									}
								});
								
								return cnt;
							}
						});
					}
					note.appendToList(subheader, noteContainer);
				});
				
				$('#jobNotes h1').html(_self.ClaimNumber + ' Notes');
				$.mobile.changePage("#jobNotes");
				
				$('#paginationContainer').pagination('destroy');
				
				if (parseInt(args.d.totalItems) > parseInt(args.d.perPage)) {
					// init pagination
					$('#paginationContainer').pagination({
						items: parseInt(args.d.totalItems),
						itemsOnPage: parseInt(args.d.perPage),
						currentPage: page,
						cssStyle: 'light-theme',
						onPageClick: function(pageNumber) {
							_self.showNotes(pageNumber);
						}
					});
				}
            }
        },
        'errorCallback' : function() {
            _self.notes = [];
			App.showError({'statusText' : 'Sorry, could not load notes.'});
        }
    });
}

App.Job.prototype.showPictures = function() {
    var _self = this;
	
	//console.log(_self);
	
	var photoContainer = '.currentPhotoContainer';
	$(photoContainer).html('');
	
	$('#jobPhotos h1').html(_self.ClaimNumber + ' Photos');
	$.mobile.changePage("#jobPhotos");
	
	$.mobile.showPageLoadingMsg();
	
	_self.getPictures(0);
}

App.Job.prototype.getPictures = function(phase) {
	var _self = this;
	
	var photoContainer = '.currentPhotoContainer';
	$('.noCurrentPhotoContainer').html('');
	
	App.api.post({
		'base' : 'FileManager.aspx',
        'path' : 'getJobPhotos',
        'params' : '{ "sessionId" : "' + App.user.sessionId + '", "regionId" : ' + App.user.regionId + ', "claimIndx" : ' + _self.ClaimIndx + ', "phaseIndx" : ' + phase + ', "page" : 1}',
        'successCallback' : function(args) {
            if (args.d) {
				_self.pictures = [];
				
				if (args.d.items) {
					$.each(args.d.items, function(i, photoObject){
						_self.pictures = _self.pictures.concat(new App.Photo(photoObject));
					});
				}
				
				$.mobile.hidePageLoadingMsg();
				
				if (_self.pictures.length > 0) {
					// build job photos
					$.each(_self.pictures, function(i, picture){
						picture.appendToList(photoContainer);
					});	
				} else {
					$('.noCurrentPhotoContainer').html('<p>No Photos on File</p>');
				}
            }
        },
        'errorCallback' : function() {
            _self.pictures = [];
			App.showError({'statusText' : 'Sorry, could not load photos.'});
        }
    });
}
    
// job list related functions
$('#searchJobSubmit').on('submit', function() {
    doJobSearch();
    return false;
});

$('#checkboxSearchInside').on('change', function() {
    doJobSearch();
});

$('#checkboxSearchInsideJobs').on('change', function() {
    doJobSearch();
});

function doJobSearch() {
    var searchStr = $('#searchJob').val();
    if (searchStr.length > 2) {
        $.mobile.showPageLoadingMsg();
        
        var branchCode = "";
        if ($('#checkboxSearchInside').prop('checked')) {
            branchCode = App.user.branch.Code;
        }
		var userCode = "";
        if ($('#checkboxSearchInsideJobs').prop('checked')) {
            userCode = App.user.currentCredential.PMId || '';
        }
        
        App.api.post({
            'path' : 'findJob',
            'params' : '{ "sessionId" : "' + App.user.sessionId + '", "regionId" : ' + App.user.regionId + ', "branchCode" : "' + branchCode + '", "userCode" : "' + userCode + '", "searchStr" : "' + searchStr + '"}',
            'successCallback' : buildJobListSuccessCallback,
            'errorCallback' : function(args){ App.showError({'statusText' : 'Could not load results.'}); }
        });
    } else {
		App.showError({'statusText' : 'Fill in more than 2 characters in search term.'});
	}
}

function buildJobListSuccessCallback(args) {
    $.mobile.hidePageLoadingMsg();
    
    App.jobs.empty('.joblist');
    if (args.d != null && args.d.length === 1 && args.d[0].ClaimIndx === 0 || args.d.length === 0) {
        args.statusText = "No Matches";
        App.showError(args);
    } else {
        App.jobs.fill(args.d);
        App.jobs.buildList('.joblist');
		//console.log(App.jobs);
    }
}
// end job list related functions

$(document).on('click', '.kpi-customer-contact', function() {
    if (confirm('Are you sure you want to set the {KPI Date} ?')) {
		var claim = $(this).attr('data-rel');
		//console.log(claim);
	}
});