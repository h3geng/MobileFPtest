(function(){
    
    /**
     * Branches class for all application branches
     */
    
    var Branches = function() {
        
        this.className = App.Branch;
        
    }
    
    // Extends from Items
    Branches.prototype = new App.Items();
    
    // Application wide jobs
    App.branches = new Branches();

})();