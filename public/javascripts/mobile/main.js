/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
var is_verified = false;
var timer_started = false;
$(function(){
    putTimerInCenter();
    putCodesInCenter();
      $(window).resize(function(){
      putTimerInCenter();
      putCodesInCenter();
    });    


});

function putTimerInCenter()
{
    var timer = $('#timer');
    timer.css("width","250px")
    var box = $("#timer_box");
    var dif = box.width() - timer.width();
    var rem = dif/2;
    timer.css("margin-left",rem+"px");
}
function putCodesInCenter()
{
    var merchant_codes = $('#merchant_codes');
    var box = $("#main");
    var dif = box.width() - merchant_codes.width();
    var rem = dif/2;
    merchant_codes.css("margin-left",rem+"px");
}
function showHideDetails()
{
    var display = $("#packages").css("display");
    if(display == "none")
    {
        $("#packages").css("display","block");
        $("#link_name").html("Hide Details");
    }
    else
    {
        $("#packages").css("display","none");
        $("#link_name").html("Show Details...");
    }
}
function showHidePackageDetails()
{
    var display = $("#merchant_packages").css("display");
    if(display == "none")
    {
        $("#merchant_packages").css("display","block");
        $("#merchant_link_name").html("Hide Details");
    }
    else
    {
        $("#merchant_packages").css("display","none");
        $("#merchant_link_name").html("Show Details...");
    }
}

function setupCounter(min,sec)
{
    $("#minutes").text(min);
    $("#seconds").text(sec);
}
function timeExpired()
{
    var res_html = "";
    if(!is_verified)
        {
           res_html = "<h3>VERIFICATION FAILED</h3><p>Package redemption time expired</p><p>You may still honour Nasir Ibrahim's discount</p>" ;
           $("#verify_response").html(res_html);
           showResponseToMerchant();
        }

    
}
function clearTimer()
{
    $("#timer").html("<div id=\"counter\"></div><div class=\"desc\"><div></div><div></div></div>");
}
function setResetType(type)
{
    $("#send_link_to").val(type);
}
function showResponseToMerchant()
{
    $("#package_timer").css("display","none");
    $("#merchant_verification").css("display","block");
}
function validate_package(package_id)
{
  $.ajax({
      type: "POST",
      url: '/mobile/packages/redeem/'+package_id,
      data: {id:""},
      dataType: 'html',
      cache: false,
      success:function(msg){
         //$("#live_feed_count").html(msg);
       //  showResults();
       $("#response").html(msg);
       var message = $("#response").find("#message").html();
       var error = $("#response").find("#error").text()
       if(message == "valid")
         {
           $("#btnRedeem").attr("disabled",true);
           showTimerScreen();
         }
       else
         {
           $("#error").html(error);
           $("#btnRedeem").attr("disabled",true);
         }

      },
      error:function (xhr, ajaxOptions, thrownError){
                    $("#error").html("Sorry, we could not connect to server. Please check your network settings.");
                }

    });
}
function showTimerScreen()
{
  $("#package_timer").css("display","block");
  $("#package_details").css("display","none");
  startTimer();

}

/******************************************** TIMER *************************************************/

  var start = 0;
  var allowed_ms = 900300 ;
  var allowed_min = 1;
  var allowed_sec = 30;
  var start_time = new Date();
  var end_time = new Date();
  var timeout;

  function elapsedmilliseconds()// Calculates elapsed time
  {
    var n = new Date();           // Grab new copy of date
    var s = n.getTime();          // Grab current millisecond #    
    var diff = s - start;         // Calculate the difference.
    return diff;                  // Return the difference.
  }
  function decider()
  {
     
    if(!timer_started)
        {
            return false;
        }
    if(start == 0)
        {
            var Now = new Date();
             start =  Now.getTime();    
        }
   var elapsed = elapsedmilliseconds();
    //alert(elapsed);
    if(elapsed <= allowed_ms)
    {
      
      var dif = allowed_ms - elapsed;

      var x = dif / 1000
      var seconds = Math.floor(x % 60);
      x /= 60;
      var minutes = Math.floor(x % 60);

      if(minutes < 9)
      {
        minutes = "0"+minutes;
      }
      if(seconds < 10)
      {
        seconds = "0"+seconds
      }

      //clearTimer();

      setupCounter(minutes,seconds);
      timeout = setTimeout("decider()",1000);

    }
    else
    {
      timeExpired();
    }

  }
  function startTimer()
  {

   
    timer_started = true;
   // timeout = setTimeout("decider()",1000);
    decider();
    //setInterval("decider()", 1000);
    $('div').bind('click dblclick mousedown mouseenter mouseleave mousemove mouseover mouseup touchstart touchmove touchend resize scroll contextmenu',
                    function(e){
                      decider();
                    });
  }
  function selectCode(imgId,code)
  {

    $('.selected_code').each( function(index){
      $(this).removeClass("selected_code");
      $(this).addClass("unselected_code");
    });
    $("#"+imgId).removeClass("unselected_code");
    $("#"+imgId).addClass("selected_code");
    $("#verification_code").val(code);
  }
  function verifyCode()
  {
    var merchant_code = $("#verification_code").val();
    var server_code = $("#varify").val();
    var package_id = $("#id").val();
    var redeem_id = $("#redeem_id").val();
    is_verified = true;
    clearTimeout(timeout);
    //alert(merchant_code+" "+server_code);
    $.ajax({
      type: "POST",
      url: '/mobile/packages/verify/',
      data: {id:package_id,redeem_id:redeem_id,verification_code:merchant_code},
      dataType: 'html',
      cache: false,
      success:function(msg){
         //alert(msg);
       $("#verify_server_response").html(msg);
       $("#verify_response").html(msg);
       showResponseToMerchant();

      },
      error:function (xhr, ajaxOptions, thrownError){
                    //$("#error").html("Sorry, we could not connect to server. Please check your network settings.");
                     var user_name = $("#user_name").val();
                     var package_title = $("#package_title").val();
                     var res_html = "";
                    if (server_code == merchant_code)
                      {
                         res_html = " <h3>VERIFICATION SUCCESSFUL</h3><p></p><p>Please give "+user_name+" "+package_title+"</p>" ;
                      }
                      else
                       {
                          res_html = " <h3>VERIFICATION FAILED</h3><p>You have tapped wrong symbol.</p><p>You may still honour "+user_name+"'s discount at your discrection</p>" ;
                       }

                      $("#verify_response").html(res_html);
                         showResponseToMerchant();

                }

    });
  }

