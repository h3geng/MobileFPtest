(function(){
    
    // build headers
    var pages = ['scan', 'camera', 'settings', 'addNote', 'noteDetails', 'fileAlerts', 'timesheets'];
    
    $.each(pages, function(i, page) {
        var data = { 'active' : page };
        var options = {};
        options.commands = {
            'header': function(){
                $('#' + page + ' .ui-header').trigger('create');
                if (App.PLATFORM !== 'bb10') {
                    $('.main-back-button').hide();
                }
            }
        };
        options.templateFunctions = {
            
            showPanelLink: function() {
                return 'back-hidden';
            },
            getPanelId: function() {
                return '';
            }
            
        }; 
        options.container = '#' + page + ' .ui-header';
        
        App.template.build(
            'header',
            data,
            options
        );
    });
    
    $('[data-role=page]').on('pagebeforeshow', function() {
        if (window.location.hash != '') {
            $('.nav-custom a').removeClass('ui-btn-active');
            $('.nav-custom a[data-rel="' + window.location.hash + '"]').addClass('ui-btn-active');
        }
    });
    
    // headers for subpages
    pages = ['home', 'companies', 'companyDetails', 'contacts', 'contactDetails', 'employees', 'employeeDetails',  'trucks', 'branches', 'branchDetails', 'jobList', 'jobDetails', 'jobEquipment', 'jobNotes', 'jobPhotos', 'jobMoisture', 'jobPhotoPreview', 'jobSchedule', 'equipmentDetails', 'idle', 'transactions'];
    
    $.each(pages, function(i, page) {
        var options = {};
        options.commands = {
            'header': function(){
                $('#' + page + ' .ui-header').trigger('create');
                if (App.PLATFORM !== 'bb10') {
                    $('.main-back-button').hide();
                }
            }
        };
        options.templateFunctions = {
            
            showPanelLink: function() {
                return 'back-visible';
            },
            getPanelId: function() {
                return page + 'PanelOptions';
            }
            
        }; 
        options.container = '#' + page + ' .ui-header';
        
        App.template.build(
            'header',
            {},
            options
        );
    });
    // end build headers
    
})();