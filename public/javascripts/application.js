// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(function(){

    
    $(".number_field").keydown(function(event) {
        validateNumberField(event);
    });



});
function validateNumberField(event)
{
     
        if ( event.keyCode == 46 || event.keyCode == 8 ) {
                // let it happen, don't do anything
        }
        else {
                // Ensure that it is a number and stop the keypress
                if (event.keyCode < 48 || event.keyCode > 57 ) {
                        event.preventDefault();
                }
        }
}
function goToHome()
{
    window.location.href="/login";
}
function showMessagePanel(className)
{
    $("#message_panel").removeClass();
    $("#message_panel").addClass(className);
    $("#message_panel").slideToggle("fast");
    $("#message_panel").fadeIn("slow");
    setTimeout("hideMessagePanel()",5000);
}
function hideMessagePanel()
{
  $("#message_panel").slideToggle("fast");
}
