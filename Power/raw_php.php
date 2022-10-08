// Please insert this PHP code in line 52 in the script!
// Otherwise this script may work incorrectly!
// For better understanding, include the "// BEGIN OF EDIT" and "// END OF EDIT" markers.
// For more help, please read this guide: https://github.com/EasyTecRepository/StatuspageAutomation/
// Read the instructions carefully before you start!
//

      // BEGIN OF EDIT
      // edited: export data to .txt file
      $filelocation = 'PLEASE_EDIT_ME.txt'; // Location of .txt (log) file
      $CURRENT_UPS_STATUS = "0"; // Set variable to 0
      $CURRENT_UPS_STATUS = "$status[1]"; // Save current status in variable
      $CURRENT_UPS_STATUS = "$CURRENT_UPS_STATUS \n"; // Add teaching line for .txt file
      $LOG_FILE = fopen("$filelocation", "a"); // Open .txt file
      fwrite($LOG_FILE, $CURRENT_UPS_STATUS); // Write current status in .txt file
      $_filesize = file( $filelocation ); // Determining the number of lines in the .txt file
      $filesize = count($_filesize); // Formatting the determined lines
      if ($filesize > "10") { // 10 => File bigger (or equal) than 11 lines
          $manage = file("$filelocation"); // Read file
          unset( $manage[3], $manage[4], $manage[5] ); // Delete line 4,5 and 6
          file_put_contents("$filelocation", $manage); } // Write text to file
      // END OF EDIT
