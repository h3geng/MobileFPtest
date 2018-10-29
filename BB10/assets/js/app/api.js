(function(){
    
    /**
     * Api class to make calls to REST
     */
    
    var Api = function() {
        
        var _self = this;
        _self.host = '';
        
        /**
        * API call feature, will be called with specified options
        * 
        * @param {array} options The set of options to be used for call
        */
        var call = function(options) {
            var _self = this;
            
            var path = options.path || '';
            var params = options.params || '{}';
            options.base = options.base || 'Default.aspx';
            
            _self.host = 'http://dev.firstonsite.ca/mobileservices/' + options.base + '/';
            
            $.ajax({
                url: _self.host + path,
                type: options.type,
                data: params,
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function(result) {
                    if (typeof options.successCallback === 'function') {
                        options.successCallback(result);
                    }
                },
                error: function(result){  
                    result.status = 'fail';
                    if (typeof options.errorCallback === 'function') {
                        options.errorCallback(result);
                    }
                }
            });
        }
        
        /**
        * API post feature, will be called with specified options
        * 
        * @param {array} options The set of options to be used for call
        */
        this.post = function(options) {
            options.type = 'POST';
            call(options);
        }
        
        /**
        * API get feature, will be called with specified options
        * 
        * @param {array} options The set of options to be used for call
        */
        this.get = function(options) {
            options.type = 'GET';
            call(options);
        }
        
    }
    
    App.api = new Api();

})();