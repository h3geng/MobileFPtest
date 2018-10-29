(function(){
    
    /**
     * Template class to retrieve templates and assign data
     */
    var Template = function() {
        
    }
    
    /**
     * Build the template with given data
     * 
     * @param {String} name Template name to be loaded
     */
    Template.prototype.build = function(name, templateData, options) {
        var templateFunctionsBefore = options.templateFunctionsBefore || {};
        var templateFunctions = options.templateFunctions || {};
        var templateBindings = options.templateBindings || {};
        
        var container = options.container || null;
        var commands = options.commands || {};
        
        $.get('templates/' + name + '.tmpl?t=' + new Date().getTime(), function(data){
            $.template(name + 'Template', data);
            var tmplObject = $.tmpl(name + 'Template', templateData, templateFunctions);
            
            $.each(templateBindings, function(ev, func){
                tmplObject.bind(ev, func);
            });
            
            $.each(templateFunctionsBefore, function(i, func){
                func();
            });
            
            if (container !== null) {
                tmplObject.appendTo(container);
            }
            
            $.each(commands, function(i, cmd){
                cmd();
            });
        });
    }
    
    App.template = new Template();

})();