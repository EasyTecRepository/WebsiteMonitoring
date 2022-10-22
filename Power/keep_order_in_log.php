<?PHP
/* Copyright 2022, Easy Tec
 * Before you use this script, read the license and the instructions at the following link carefully!
 * https://github.com/EasyTecRepository/StatuspageAutomation/blob/main/Power/Readme.md
 * https://github.com/EasyTecRepository/StatuspageAutomation/blob/main/LICENSE
 * KEEP LOG CLEAN
 * Please change the $filelocation! - edit "add_your_share_name"
 */
?>
<?PHP
    // order data in .txt file
    $filelocation = '/mnt/user/add_your_share_name/CURRENT_UPS_STATUS.txt'; // Location of .txt (log) file
    $_filesize = file( $filelocation ); // Determining the number of lines in the .txt file
    $filesize = count($_filesize); // Formatting the determined lines
    if ($filesize > "10") { // 10 => File bigger (or equal) than 11 lines
        $manage = file("$filelocation"); // Read file
        unset( $manage[3], $manage[4], $manage[5] ); // Delete line 4,5 and 6
        file_put_contents("$filelocation", $manage); } // Write text to file
?>
