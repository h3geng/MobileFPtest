/**
 * A branch class to init the specified branch
 * 
 * @param {Object} data The data of branch
 */

App.Branch = function(data) {
    
    var _self = this;
    
    this.branchData = data;
    this.type = 'branch';
    this.equipments = [];
    
}

/**
 * Append branch item to list
 * 
 * @param {String} list The list container selector
 */
App.Branch.prototype.appendToList = function(list) {
    var _self = this;
    
    var options = {};
    options.templateBindings = {'click': function() { _self.showDetails(); }};
    options.commands = {'refresh': function(){ $(list).listview('refresh'); }};
    options.container = list;
    
    App.template.build(
        'branch',
        _self.branchData,
        options
    );
}

/**
 * Show branch details
 */
App.Branch.prototype.showDetails = function() {
    var _self = this;
    App.activeBranch = this;
    
    if (App.activeScan) {
        $('#branchDetails .transaction-process').show();
    }
    
    // build job details
    var detailsContainer = $('.branchdetails');
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
    });
}