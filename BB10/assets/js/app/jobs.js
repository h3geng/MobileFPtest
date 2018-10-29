(function(){
    
    /**
     * Jobs class for all application jobs
     */
    
    var Jobs = function() {
        
        this.className = App.Job;
        
    }
    
    // Extends from Items
    Jobs.prototype = new App.Items();
    
    // Application wide jobs
    App.jobs = new Jobs();

})();