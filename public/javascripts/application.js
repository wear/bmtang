// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
                                                                             
/* shows and hides ajax indicator */ 
var $j = jQuery;
 
$j.ajaxSetup({'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")} }); 

$j(document).ready(function() { 
	setTimeout(function () { $j('#flash-message').fadeOut(); }, 4000); 
}); 
