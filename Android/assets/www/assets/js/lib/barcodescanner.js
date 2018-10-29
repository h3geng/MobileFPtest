/**
 * cordova is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 *
 * Copyright (c) Matt Kane 2010
 * Copyright (c) 2011, IBM Corporation
 */
if(!window.plugins) {
    window.plugins = {};
}

if (App.PLATFORM === 'andr') {
    cordova.define("cordova/plugins/barcodescanner", 
      function(require, exports, module) {
        var exec = require("cordova/exec");
        var BarcodeScanner = function() {};
        
        //-------------------------------------------------------------------
        BarcodeScanner.prototype.scan = function(successCallback, errorCallback) {
            if (errorCallback == null) { errorCallback = function() {}}
        
            if (typeof errorCallback != "function")  {
                console.log("BarcodeScanner.scan failure: failure parameter not a function");
                return
            }
        
            if (typeof successCallback != "function") {
                console.log("BarcodeScanner.scan failure: success callback parameter must be a function");
                return
            }
        
            exec(successCallback, errorCallback, 'BarcodeScanner', 'scan', []);
        };
        
        //-------------------------------------------------------------------
        BarcodeScanner.prototype.encode = function(type, data, successCallback, errorCallback, options) {
            if (errorCallback == null) { errorCallback = function() {}}
        
            if (typeof errorCallback != "function")  {
                console.log("BarcodeScanner.scan failure: failure parameter not a function");
                return
            }
        
            if (typeof successCallback != "function") {
                console.log("BarcodeScanner.scan failure: success callback parameter must be a function");
                return
            }
        
            exec(successCallback, errorCallback, 'BarcodeScanner', 'encode', [{"type": type, "data": data, "options": options}]);
        };
        
        var barcodeScanner = new BarcodeScanner();
        module.exports = barcodeScanner;
    
    });
    
    cordova.define("cordova/plugin/BarcodeConstants", 
        function(require, exports, module) {
        module.exports = {
            Encode:{
                TEXT_TYPE: "TEXT_TYPE",
                EMAIL_TYPE: "EMAIL_TYPE",
                PHONE_TYPE: "PHONE_TYPE",
                SMS_TYPE: "SMS_TYPE",
            }
        };        
    });
    //-------------------------------------------------------------------
    var BarcodeScanner = cordova.require('cordova/plugin/BarcodeConstants');
    
    if (!window.plugins.barcodeScanner) {
        window.plugins.barcodeScanner = cordova.require("cordova/plugins/barcodescanner");
    }
}
else {
    var BS = function() {
        var gotCode = false;
        var showResumeToast = false;
    };
        
    BS.prototype.scan = function(successCallback, errorCallback) {
        var _self = this;
        
        _self.gotCode = false;
        
        var canvas = $('#barcodeCanvas');
        canvas.show();
        
        blackberry.app.lockOrientation("portrait-primary", false);
        community.barcodescanner.startRead(function(args) {
            if (_self.gotCode === false) {
                _self.gotCode = true;
                _self.stopBarcodeRead();
                
                var audio = new Audio('beep.mp3');
                audio.play();
                successCallback({'text' : args.value});
            }
        }, function(args) {
            errorCallback({'statusText' : args.description});
        }, "barcodeCanvas", function(args){});
        App.scanTimeout = setTimeout(_self.scanTimeoutHalt, 20000);
    }
    
    BS.prototype.stop = function(successCallback, errorCallback) {
        community.barcodescanner.stop(successCallback);
        $('#barcodeCanvas').html('');
        $('#barcodeCanvas').hide();
    }
    
    BS.prototype.stopBarcodeRead = function(){
        var _self = this;
        
        community.barcodescanner.stopRead(function(args){}, function(args){ console.log("Error : "+args.error + " description : "+ args.description); });
        clearTimeout(_self.scanTimeout);
        _self.scanTimeout = null;
        blackberry.app.unlockOrientation();
        $('#barcodeCanvas').html('');
        $('#barcodeCanvas').hide();
    }
    
    BS.prototype.scanTimeoutHalt = function() {
        var audio = new Audio('beep.mp3');
        audio.play();
        
        community.barcodescanner.stopRead(function(args){}, function(args){ console.log("Error : "+args.error + " description : "+ args.description); });
        clearTimeout(App.scanTimeout);
        App.scanTimeout = null;
        blackberry.app.unlockOrientation();
        $('#barcodeCanvas').html('');
        $('#barcodeCanvas').hide();
        
        App.showError({'statusText' : 'Nothing scanned...'});
    }
    
    if (!window.plugins.barcodeScanner) {
        window.plugins.barcodeScanner = new BS();
    }
}