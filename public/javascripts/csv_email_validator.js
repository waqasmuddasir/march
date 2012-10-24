
function validate_email_sent_form()
{
    var package_select = document.getElementById("package_id");

    if (package_select.value=="none"){
        alert("Please Select Package Offer to attach with the email.");
        package_select.focus();
        return false;
    }

    var csv_field = document.getElementById("to");
          
    if (!validate_email_format(csv_field.value))    {
        csv_field.focus();
        return false;
    }

    
    return true;
}


function validate_email_format(csv)
{
    var error_msg = '';

    if(csv == '')
    {
        error_msg = 'Please enter comma seperated email addresses.';
        alert(error_msg);
        return false;
    }

    csv=csv.replace('"','')
    csv=csv.replace("'","")
    csv=csv.replace(/^\s+|\s+$/g,"");
    var csv_array=csv.split(",")
        
    for(i = 0; i < csv_array.length; i++){
       
        if(!validateEmailAddress(csv_array[i].replace(/^\s+|\s+$/g,"")))
        {
            error_msg = 'Please enter Valid Email Addresses comma seperated values, one or more of the email addresses are invalid.';
            alert(error_msg);
            return false;
        }
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