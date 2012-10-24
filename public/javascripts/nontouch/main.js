/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

var is_verified = false;
var timer_started = false;
var is_in_ajax_call = false;
function showHideDetails()
{
    var display = document.getElementById("packages").style.display;
    
    if(display == "none")
    {
        document.getElementById("packages").style.display= "block";
        document.getElementById("link_name").innerHTML = "Hide Details";
    }
    else
    {
        document.getElementById("packages").style.display= "none";
        document.getElementById("link_name").innerHTML = "Show Details...";
    }
}

function setupCounter(min,sec)
{
    
   document.getElementById("minutes").innerHTML = min;
   document.getElementById("seconds").innerHTML = sec;
   
}
function timeExpired()
{
    //window.location.href='/m/packages/time_expired';
    var res_html = "";
    if(!is_verified)
        {
           res_html = "<h3>VERIFICATION FAILED</h3><p>Package redemption time expired</p><p>You may still honour Nasir Ibrahim's discount </p>" ;
           document.getElementById("verify_response").innerHTML = res_html;
           showResponseToMerchant();
        }
}
function clearTimer()
{
    $("#timer").html("<div id=\"counter\"></div><div class=\"desc\"><div>Minutes</div><div>Seconds</div></div>");
}
function setResetType(type)
{
    document.getElementById("send_link_to").value = type;
}

function validate_package(package_id)
	{
		var req = null;
                if(is_in_ajax_call)
                    return false;

                is_in_ajax_call = true;
		//document.ajax.dyn.value="Started...";
		if(window.XMLHttpRequest)
			req = new XMLHttpRequest();
		else if (window.ActiveXObject)
			req  = new ActiveXObject(Microsoft.XMLHTTP);

		req.onreadystatechange = function()
		{
		       //document.ajax.dyn.value="Wait server...";
                       is_in_ajax_call = false;
			if(req.readyState == 4)
			{
				if(req.status == 200)
				{
					//document.ajax.dyn.value="Received:" + req.responseText;
                                        //alert(req.responseText);
                                        document.getElementById("response").innerHTML= req.responseText;
                                        var message = document.getElementById("message").innerHTML
                                        var error = document.getElementById("error").innerHTML
                                        if(message == "valid")
                                         {
                                          // $("#btnRedeem").attr("disabled",true);
                                           document.getElementById("response").disabled = true;
                                           showTimerScreen();
                                         }
                                       else
                                         {
                                           document.getElementById("error").innerHTML = error;
                                           document.getElementById("response").disabled = true;
                                           
                                         }
                                        //$("#response").html(msg);
                                       //var message = $("#response").find("#message").html();
                                       //var error = $("#response").find("#error").text();
				}
				else
				{
					//document.ajax.dyn.value="Error: returned status code " + req.status + " " + req.statusText;
                                       // alert(req.status+" "+req.statusText)
                                        document.getElementById("error").innerHTML = "Sorry, we could not connect to server. Please check your network settings.";
				}
			}
		};
		req.open("POST", "/m/packages/redeem/"+package_id+".js", true);
		req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		req.send(null);
	}
function showTimerScreen()
{
  document.getElementById("package_timer").style.display ="block";
  document.getElementById("package_details").style.display = "none";
  startTimer();

}

/*TIMER*/

        // Grab the current date.
  var start = 0;
  var allowed_ms = 900300;
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
      //setTimeout("decider()",1000);
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
      timeout = setInterval("decider()", 1000);
    }
    else
    {
      timeExpired();
    }

  }
function startTimer()
{
  start =  0
  timer_started = true;
  //timeout = setInterval("decider()", 1000);
  decider();
}
function selectCode(imgId,code)
{
    document.getElementById("verification_code").value = code;
    verifyCode();
}
 function verifyCode()
  {
    var merchant_code = document.getElementById("verification_code").value;
   // var server_code = document.getElementById("varify").value;
    var package_id = document.getElementById("id").value;
    var redeem_id = document.getElementById("redeem_id").value;
    is_verified = true;
    clearTimeout(timeout);
    //alert(merchant_code+" "+server_code);
    getVerificationResponse(package_id,redeem_id,merchant_code);
    
  }
  function getVerificationResponse(package_id,redeem_id,merchant_code){
    var server_code = document.getElementById("varify").value;
    var req = null;
    //document.ajax.dyn.value="Started...";
    if(is_in_ajax_call)
        return false;
    
    is_in_ajax_call = true;
    if(window.XMLHttpRequest)
            req = new XMLHttpRequest();
    else if (window.ActiveXObject)
            req  = new ActiveXObject(Microsoft.XMLHTTP);

    req.onreadystatechange = function()
    {
        is_in_ajax_call = false;
           //document.ajax.dyn.value="Wait server...";
            if(req.readyState == 4)
            {
                    if(req.status == 200)
                    {
                        document.getElementById("verify_server_response").innerHTML=req.responseText;
                        document.getElementById("verify_response").innerHTML=req.responseText;
                        showResponseToMerchant();
                    }
                    else
                    {
                         var user_name = document.getElementById("user_name").value;
                         var package_title = document.getElementById("package_title").value;
                         var res_html = "";
                        if (server_code == merchant_code)
                          {
                             res_html = " <h3>VERIFICATION SUCCESSFUL</h3><p></p><p>Please give "+user_name+" "+package_title+"</p>" ;
                          }
                          else
                           {
                              res_html = " <h3>VERIFICATION FAILED</h3><p>You have tapped wrong symbol.</p><p>You may still honour "+user_name+"'s discount at your discrection</p>" ;
                           }

                          document.getElementById("verify_response").innerHTML = res_html;
                          showResponseToMerchant();
                    }
            }
    };
    req.open("POST", "/m/packages/verify.js", true);
    req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    req.send("id="+package_id+"&redeem_id="+redeem_id+"&verification_code="+merchant_code);
  }
  function showResponseToMerchant()
   {
        document.getElementById("package_timer").style.display = "none";
        document.getElementById("merchant_verification").style.display = "block";
   }
function showHidePackageDetails()
{
    var display = document.getElementById("merchant_packages").style.display;

    if(display == "none")
    {
        document.getElementById("merchant_packages").style.display= "block";
        document.getElementById("merchant_link_name").innerHTML = "Hide Details";
    }
    else
    {
        document.getElementById("merchant_packages").style.display= "none";
        document.getElementById("merchant_link_name").innerHTML = "Show Details...";
    }
}

      
