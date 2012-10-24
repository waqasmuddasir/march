
function validate_share_with_friend()
{
    var sender_name = document.getElementById("sender_name");
    var sender_email = document.getElementById("sender_email");
    var friend_name = document.getElementById("friend_name");
    var friend_email = document.getElementById("friend_email");


    if(!validateEmailAddress(sender_email))
    {
        alert("Please enter your Email Address.");
        sender_email.focus();
        return false;
    }

   if(!validateEmailAddress(friend_email))
    {   alert("Please enter your Friends Email Address.");
        friend_email.focus();
        return false;
    }

if(sender_email.value=='')
    {   alert("Please enter your email.");
        sender_email.focus();
        return false;
    }

    if(friend_email.value=='')
    {   alert("Please enter your Friend email.");
        friend_email.focus();
        return false;
    }

   if(sender_name.value=='')
    {   alert("Please enter your Name.");
        sender_name.focus();
        return false;
    }

    if(friend_name.value=='')
    {   alert("Please enter your Friend Name.");
        friend_name.focus();
        return false;
    }


    
    return true;
}



function validateEmailAddress(email_address)
{
    var email = /^[^@]+@[^@.]+\.[^@]*\w\w$/
    if (!email.test(email_address)) {

        return false;
    }

    return true;
}