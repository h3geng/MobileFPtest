(function(){
    
    /**
     * Scanner class to deal with device camera and grabba device
     */
    
    var Scanner = function() {
        
        var _self = this;
        
        /**
        * Scanning using the keyboard
        *
        * @param {array} options The set of options to be used for scan
        *
        * @returns {object} result TBD
        */
        var scanManual = function(options) {
            options.code = options.code || "0";
            
            App.api.post({
                'path' : 'findItem',
                'params' : '{ "sessionId" : "' + App.user.sessionId + '", "regionId" : ' + App.user.regionId + ', "branchName" : "", "searchStr" : "' + options.code + '"}',  //"branchName" : "' + App.user.branch.Value + '"
                'successCallback' : function(args) {
                    if (args.d) {
                        var found = args.d;
                        
                        $("#equipmentsFound h1").html('Select Equipment');
                        
                        if (found.length > 1) {
                            $('.eqlist').html('');
                            $.each(found, function(i, eqpData){
                                var eqp = new App.Equipment(eqpData);
                                var opts = {};
                                opts.templateBindings = {'click': function(e) {
                                    e.preventDefault();
                                    options.d = eqpData;
                                    
                                    if (App.transaction.checkExists(eqp)) {
                                        options.statusText = 'This equipment already in transaction.';
                                        options.errorCallback(options);
                                    } else {
                                        options.successCallback(options);
                                        $('#equipmentsFound').dialog("close");
                                    }
                                }};
                                opts.commands = {
                                    'list': function(){ $('.eqlist').listview('refresh'); },
                                    //'open': function(){ $("#equipmentsFound").popup('open', { 'positionTo' : 'window', 'transition' : 'pop' }); }
                                };
                                opts.container = '.eqlist';
                                
                                App.template.build(
                                    'equipment',
                                    eqp,
                                    opts
                                );
                            });
                            $.mobile.changePage("#equipmentsFound", { role: "dialog" });
                        } else {
                            options.d = found[0];
                            options.successCallback(options);
                        }
                    } else {
                        options.statusText = 'No item found';
                        options.errorCallback(options);
                    }
                },
                'errorCallback' : options.errorCallback
            });
        }
        
        /**
        * Scanning using the device camera
        *
        * @param {array} options The set of options to be used for scan
        *
        * @returns {object} result The set of data, text, format, cancelled
        */
        var scanCamera = function(options) {
            window.plugins.barcodeScanner.scan(function(result) {
                if (!result.cancelled) {
                    if (typeof options.successCallback === 'function') {
                        result.type = options.type;
                        var scanned = result.text;
                        if (scanned && scanned.match(/^http([s]?):\/\/.*/)) {
                            var scannedArray = scanned.split('ID=');
                            if (scannedArray.length > 1) {
                                scanned = scannedArray[1];
                            }
                        }
                        App.api.post({
                            'path' : 'findItem',
                            'params' : '{ "sessionId" : "' + App.user.sessionId + '", "regionId" : ' + App.user.regionId + ', "branchName" : "", "searchStr" : "' + scanned + '"}',  //"branchName" : "' + App.user.branch.Value + '"
                            'successCallback' : function(args) {
                                var found = args.d;
                                args.d = found[0];
                                args.type = "camera";
                                args.cancelled = result.cancelled;
                                args.container = options.container;
                                
                                options.successCallback(args);
                            },
                            'errorCallback' : function(args) {
                                args.type = "camera";
                                args.cancelled = result.cancelled;
                                options.errorCallback(args);
                            }
                        });
                    }
                }
            }, function(error) { 
                error.type = "camera";
                if (typeof options.errorCallback === 'function') {
                    options.errorCallback(error);
                }
            });
        }
        
        /**
        * Scanning using the grabba device
        *
        * @param {array} options The set of options to be used for scan
        *
        * @returns {object} result TBD
        */
        var scanGrabba = function(options) {
            window.plugins.grabbaScanner.scan(function(response){
                if (typeof options.successCallback === 'function') {
                    App.api.post({
                        'path' : 'findItem',
                        'params' : '{ "sessionId" : "' + App.user.sessionId + '", "regionId" : ' + App.user.regionId + ', "branchName" : "", "searchStr" : "' + response + '"}',  //"branchName" : "' + App.user.branch.Value + '"
                        'successCallback' : function(args) {
                            var found = args.d;
                            args.d = found[0];
                            args.type = "grabba";
                            args.cancelled = false;
                            args.container = options.container;
                            
                            options.successCallback(args);
                        },
                        'errorCallback' : function(args) {
                            args.type = "grabba";
                            args.cancelled = false;
                            options.errorCallback(args);
                        }
                    });
                }
            }, function(args){
                var error = {};
                error.type = "grabba";
                error.statusText = args;
                if (typeof options.errorCallback === 'function') {
                    options.errorCallback(error);
                }
            });
        }
        
        /**
        * General scan method
        */
        this.scan = function(options){
            options.type = options.type || "manual";
            options.container = options.container || "";
            
            switch (options.type) {
                case "camera":
                    scanCamera(options);
                    break;
                case "grabba":
                    scanGrabba(options);
                    break;
                default:
                    scanManual(options);
                    break;
            }
        }
    }
    
    // Application wide scanner
    App.scanner = new Scanner();

})();