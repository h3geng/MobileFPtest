/**
 * Note class to init the specified note
 * 
 * @param {Object} data The data of note
 */

App.Note = function(data) {
    this.noteData = data || {};
	
	this.noteData.enteredByName = data.enteredBy.FullName || $.trim(data.enteredBy.Id);
	this.noteData.phaseCode = data.phase.PhaseCode || data.phase.PhaseIndx || 'No Phase';
	
	// date component
	this.noteData.date = data.dateCreated.substr(0, data.dateCreated.indexOf(' '));
	// time component
	this.noteData.time = data.dateCreated.substr(data.dateCreated.indexOf(' ') + 1);
	
	this.noteData.ampm = this.noteData.time.substr(this.noteData.time.lastIndexOf(' ') + 1);
	this.noteData.time = this.noteData.time.substr(0, this.noteData.time.indexOf(' '));
	this.noteData.time = this.noteData.time.substr(0, this.noteData.time.lastIndexOf(':'));
}

/**
 * Append note item to list
 * 
 * @param {String} list The list container selector
 */
App.Note.prototype.appendToList = function(header, list) {
    var _self = this;
    
    var options = {};
	if (header !== null) {
		options.templateFunctionsBefore = {'addHeader': function(){ header.appendTo(list); }};
	}
    options.templateBindings = {'click': function() { _self.showDetails(); }};
	options.commands = {'refresh': function(){ $(list).listview('refresh'); }};
    options.container = list;
    
    App.template.build(
        'note',
        _self.noteData,
        options
    );
}

/**
 * Show note details
 */
App.Note.prototype.showDetails = function() {
    var _self = this;
	console.log(_self);
	$.mobile.changePage('#noteDetails');
	
	var fullNote = _self.noteData.note.replace(/\n/g, '<br />');
	
	//details
	$('.note-content-claim').html(_self.noteData.claim.ClaimNumber || _self.noteData.claim.ClaimIndx);
	$('.note-content-date').html(_self.noteData.dateCreated);
	$('.note-content-dep').html(_self.noteData.departmentId);
	$('.note-content-entered').html(_self.noteData.enteredBy.FullName || _self.noteData.enteredBy.Id);
	$('.note-content-phase').html(_self.noteData.phaseCode);
	
	$('.full-note').html('<li><h5>' + fullNote + '</h5></li>');
	$('.full-note').listview('refresh');
	
	$('#noteDetails h1').html('Note Details');
}

$(document).on('click', '.add-note', function(){
	$.mobile.hidePageLoadingMsg();
	$('#addNote h1').html('Add Note To ' + App.activeJob.ClaimNumber);
    $.mobile.changePage("#addNote");
});

$(document).on('click', '.note-cancel', function(){
	$.mobile.hidePageLoadingMsg();
	if (confirm('Are you sure?')) {
		App.activeJob.showNotes();
	}
});

$(document).on('click', '.note-ok', function(){
	$.mobile.hidePageLoadingMsg();
		
		//Public Shared Function addNoteToJob(ByVal sessionId As String, ByVal nt As Note) As ItemResult
		
		
		/*Public Property Id As Integer
        Public Property regionId As Integer
        Public Property claim As Claim
        Public Property phase As Phase
        Public Property departmentId As String
        Public Property clientAccess As Boolean
        Public Property alertPM As Boolean
        Public Property note As String
        Public Property enteredBy As Contact
        Public Property dateCreated As String
        Public Property dateRead As String
        Public Property sendToXact As Boolean
        Public Property sendToXactSuccess As Boolean*/
		
		//var nt = {};
		/*nt.Id = 0;
		nt.regionId = App.user.regionId;
		nt.claim = App.activeJob;
		nt.phase = {};//select-ph
		nt.departmentId = $('#select-dep').val();
		nt.clientAccess = true;
		nt.alertPM = false;
		nt.note = $('#noteMessage').text();
		nt.enteredBy = {};
		nt.dateCreated = ""; //new Date().toString();
		nt.dateRead = "";
		nt.sendToXact = false;
		nt.sendToXactSuccess = false;*/
		
		 //addNoteToJob(ByVal sessionId As String, ByVal claimIndx As Integer, phaseIndx As Integer, departmentId As String, note As String, alertPM As Boolean) As ItemResult
		
	if ($('#select-dep').val() == "") {
		App.showError({'statusText' : 'Select please a department.'});
	} else {
		//console.log(App.user);
		
		var alertPM = false;
		if ($('.alert-pm-container').css('display') != 'none') {
			alertPM = $('#alertPM').prop('checked');
		}
		App.api.post({
			'base' : 'Messaging.aspx',
			'path' : 'addNoteToJob',
			'params' : '{ "sessionId" : "' + App.user.sessionId + '", "regionId" : ' + App.user.regionId + ', "claimIndx" : ' + App.activeJob.ClaimIndx + ', "phaseIndx" : ' + parseInt($('#select-ph').val()) + ', "departmentId" : "' + $('#select-dep').val() + '", "note": "'+$('#noteMessage').val()+'", "alertPM" : ' + alertPM + '}',
			'successCallback' : function(args) {
				
				console.log(args);
				
				App.activeJob.showNotes();
				if (args.d && args.d.Message && args.d.Message != "") {
					alert(args.d.Message);
				}
			},
			'errorCallback' : function() {
				console.log(args);
				App.activeJob.showNotes();
				App.showError({'statusText' : 'Note not added...'});
			}
		});
	}
});