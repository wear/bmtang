// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
                                                                             
/* shows and hides ajax indicator */ 
var $j = jQuery.noConflict();
  
$j.ajaxSetup({'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")} });  

$j(function(){    
	var indicator = $j("#ajax-indicator");
    $j(document).ajaxStart(function() {
            indicator.show();
    });
    $j(document).ajaxStop(function() {
            indicator.hide(); 
   });
});