 function validate_file_format()
    {
        alert("hello");
        // CSV files only
       var user_file = document.getElementById("upload_datafile");
          var FileName = user_file.value;
        //  alert(Trim(FileName));
          var isValid = false;
          var error_msg = '';

          if(FileName == '')
            {
              error_msg = 'Please select a file to upload';
             // $("#error").html(error_msg);
             alert(error_msg);
              user_file.focus();
              return false;
            }
          var extArray = new Array(".csv");
          // getting FileName
           File = FileName;
             while (File.indexOf("\\") != -1)
                File = File.slice(File.indexOf("\\") + 1);

          // alert("File name = " + File);
           //getting Extension

           var ext = File.slice(File.indexOf(".")).toLowerCase();

           for (var i = 0; i < extArray.length; i++)
               {
                 if (extArray[i] == ext)
                 {
                   isValid = true;
                 }
               }

              if(isValid == false)
                {
                    error_msg = "Please only upload files that end in types:  "
                            + (extArray.join("  ")) ;
                    //$("#error").html(error_msg);
                    alert(error_msg);
                         user_file.focus();
                      return false;
                }
              else
                {
                 return true;

                }
    }


function validateForgotPassword()
{
    var email_address = $("#forgot_email").val();
    var email_reg = /^[^@]+@[^@.]+\.[^@]*\w\w$/;
    if (!email_reg.test(email_address) || email_address == "") {
           return false;
      }

   return true;
}