/**
 * Equipment class to init the specified equipment
 * 
 * @param {Object} data The data of equipment
 */

App.Equipment = function(data) {
    this.id = data.Id || 0;
    this.assetTag = data.AssetTag || '';
    this.branch = data.Branch || '';
    this.currentClaim = data.CurrentClaim || '';
    this.currentPhase = data.CurrentPhase || '';
    this.itemClass = data.ItemClass || 'unknown';
    this.itemModel = data.ItemModel || 'unknown';
    this.itemNumber = data.ItemNumber || 'unknown';
    this.openTransaction = data.OpenTransaction || '';
    this.serialNumber = data.SerialNumber || '';
    this.status = data.Status.Value || '';
    this.statusId = data.Status.Id || 0;
    this.transitBranch = data.TransitBranch || '';
    this.commited = '';
}

/**
 * Append equipment item to list
 * 
 * @param {String} list The list container selector
 */
App.Equipment.prototype.appendToList = function(list) {
    var _self = this;
    
    var options = {};
    options.templateBindings = {'click': function() { _self.showDetails(); }};
    options.commands = {'refresh': function(){
            if ($(list)) {
                $(list).listview('refresh');
            }
        }
    };
    options.container = list;
    
    if (_self.commited === '') {
        App.template.build(
            'equipment',
            _self,
            options
        );
    } else {
        App.template.build(
            'equipmentRemove',
            _self,
            options
        );
    }
}

/**
 * Show equipment details
 * 
 */
App.Equipment.prototype.showDetails = function() {
    var _self = this;
    
    _self.reload(
        function(){
            App.activeScan = _self;
            
            //console.log(_self);
            
            // build equipment details header
            var equipmentDetailsHeader = $('.equipmentDetailsHeader');
            equipmentDetailsHeader.html('');
            
            var options = {};
            options.templateFunctions = {
                
                getTransitBranch: function() {
                    var transit = "";
                    if (_self.transitBranch !== _self.branch) {
                        transit = ", Transit Branch: <strong>" + _self.transitBranch + "</strong>";
                    }
                    return transit;
                },
                getClaim: function() {
                    var claim = "";
                    if (_self.statusId == '2') {
                        claim = ", Claim Number: <strong><a href='#' class='current-job-link' data-rel='" + _self.currentClaim.ClaimIndx + "'>" + _self.currentClaim.ClaimNumber + "</a></strong>";
                    }
                    return claim;
                }
                
            };
            options.container = equipmentDetailsHeader;
            
            App.template.build(
                'equipmentHeader',
                _self,
                options
            );
            
            _self.showFunctions();
        },
        function(){
            App.showError({'statusText' : 'Could not load equipment details...'});
        }
    );
}

App.Equipment.prototype.reload = function(successCallback, errorCallback) {
    var _self = this;
    
    App.api.post({
        'path' : 'getItem',
        'params' : '{ "sessionId" : "' + App.user.sessionId + '", "regionId" : ' + App.user.regionId + ', "itemId" : ' + _self.id + '}',
        'successCallback' : function(args) {
            if (args.d) {
                var data = args.d;
                
                _self.id = data.Id || 0;
                _self.assetTag = data.AssetTag || '';
                _self.branch = data.Branch || '';
                _self.currentClaim = data.CurrentClaim || '';
                _self.currentPhase = data.CurrentPhase || '';
                _self.itemClass = data.ItemClass || 'unknown';
                _self.itemModel = data.ItemModel || 'unknown';
                _self.itemNumber = data.ItemNumber || 'unknown';
                _self.openTransaction = data.OpenTransaction || '';
                _self.serialNumber = data.SerialNumber || '';
                _self.status = data.Status.Value || '';
                _self.statusId = data.Status.Id || 0;
                _self.transitBranch = data.TransitBranch || '';
                
                successCallback();
            }
        },
        'errorCallback' : function() {
            errorCallback();
        }
    });
}

App.Equipment.prototype.showFunctions = function() {
    $('.equipmentDetailsItems').html('');
    
    switch (parseInt(App.activeScan.statusId)) {
        case 1: // Available
            $.tmpl('<li class="eqp-in-transit"><a href="#">In Transit</a></li>', { }).appendTo(".equipmentDetailsItems");
            $.tmpl('<li class="eqp-issue-job"><a href="#">Issue To Job</a></li>', { }).appendTo(".equipmentDetailsItems");
            $.tmpl('<li class="eqp-branch-transfer"><a href="#">Branch Transfer</a></li>', { }).appendTo(".equipmentDetailsItems");
            break;
        case 2: // Issued To Job
            $.tmpl('<li class="eqp-in-transit"><a href="#">In Transit</a></li>', { }).appendTo(".equipmentDetailsItems");
            $.tmpl('<li class="eqp-return-branch"><a href="#">Return To Branch</a></li>', { }).appendTo(".equipmentDetailsItems");
            $.tmpl('<li class="eqp-issue-job"><a href="#">Issue To Job</a></li>', { }).appendTo(".equipmentDetailsItems");
            $.tmpl('<li class="eqp-cancel"><a href="#">Cancel</a></li>', { }).appendTo(".equipmentDetailsItems");
            break;
        case 6: // Branch Transfer
            $.tmpl('<li class="eqp-receive-item"><a href="#">Receive Item</a></li>', { }).appendTo(".equipmentDetailsItems");
            $.tmpl('<li class="eqp-cancel"><a href="#">Cancel</a></li>', { }).appendTo(".equipmentDetailsItems");
            break;
        case 7: // In Transit
            $.tmpl('<li class="eqp-issue-job"><a href="#">Issue To Job</a></li>', { }).appendTo(".equipmentDetailsItems");
            $.tmpl('<li class="eqp-return-branch"><a href="#">Return To Branch</a></li>', { }).appendTo(".equipmentDetailsItems");
            $.tmpl('<li class="eqp-cancel"><a href="#">Cancel</a></li>', { }).appendTo(".equipmentDetailsItems");
            break;
    }
    
    $('.equipmentDetailsItems').listview('refresh');
}