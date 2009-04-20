// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
                                                                             
/* shows and hides ajax indicator */
Ajax.Responders.register({
    onCreate: function(){
        if ($('ajax-indicator') && Ajax.activeRequestCount > 0) {
            Element.show('ajax-indicator');
        }
    },
    onComplete: function(){
        if ($('ajax-indicator') && Ajax.activeRequestCount == 0) {
            Element.hide('ajax-indicator');
        }
    }
});