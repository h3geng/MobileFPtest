(function(){
    
    /**
     * Items class to take care of application lists
     */
    
    var Items = function() {
        
        this.items = [];
        
    }
    
    /**
     * Fill items with specified class objects
     * 
     * @param {array} items The array of Objects with predefined class definitions
     */
    Items.prototype.fill = function(items) {
        var _self = this;
        
        $.each(items, function(i, item){
            _self.items = _self.items.concat(new _self.className(item));
        });
    }
    
    /**
     * Build the list based on items
     * 
     * @param {String} selector The list container selector
     */
    Items.prototype.buildList = function(selector) {
        $.each(this.items, function(i, item){
            item.appendToList(selector);
        });
    }
    
    /**
     * Empty items along with container elements
     * 
     * @param {String} selector The list container selector
     */
    Items.prototype.empty = function(selector) {
        this.items = [];
        $(selector).find('li').remove();
    }
    
    App.Items = Items;

})();