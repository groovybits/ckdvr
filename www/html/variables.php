<?
// Chris Kennedy, September 2003
// KMOS-TV

// Global Configuration of DVR
$stylesheet = "dvr.css";

$PORTS = 3;

// Main Path
$DVRPATH = "/opt/dvr";

// Modules
$DECODER = $DVRPATH . "/bin/decoder";
$ENCODER = $DVRPATH . "/bin/encoder";
$DVRCMD = $DVRPATH . "/bin/dvrcmd";

// Startup Mode
$MODE = "manual";

// File Extension Used
$EXTENSION = "mpg";

// Set Storage Directory
$STORAGE = "/u1/Scratch";

// Set Log Files
$ERRORLOG = $DVRPATH . "/log/error";
$MSGLOG = $DVRPATH . "/log/messages";
$ENCODELOG = $DVRPATH . "/log/encode";
$DECODELOG = $DVRPATH . "/log/decode";
$ARCHIVELOG = $DVRPATH . "/log/archives";

// Schedules
$LIBRARY = $DVRPATH . "/db/library";
$ENCODETODAY = $DVRPATH . "/schedule/encode_today";
$DECODETODAY = $DVRPATH . "/schedule/decode_today";

// Lock Files
$ENCODELOCK = $DVRPATH . "/lock/encode/";
$DECODELOCK = $DVRPATH . "/lock/decode/";
$ENCMANUALMODE = $DVRPATH . "/lock/enc_manual";
$DECMANUALMODE = $DVRPATH . "/lock/dec_manual";

// Encoder
$encoder = $DVRPATH . "/sbin/avviewrec";

// Init load Modules
$init_dvr = $DVRPATH . "/sbin/dvrboot";

// MPLAYER PID
$MPLAYERPID = $DVRPATH . "/lock/decode/mplayer.pid";

// Decoder
$decoder = "/usr/bin/mplayer";
$decoder_args = " -display $DISPLAY -quiet -aspect 4:3 -fs";

// MISC
$NULL = "";

$param_list=array(
'enc',
'dec',
'clips',
'cliptake',
'clipstop',
'title',
'minutes',
'port',
'myport',
'encstop',
'date',
'minutes',
'duration'
);

$video_lan_path = "\\Bcs-dvr\public\apps\vlc-0.6.2\vlc.exe http://153.91.87.102/video/Scratch/";

/* this will work whether it was GET or POST, doesn't make a difference */
foreach($param_list as $param)
   @$$param=${"_$_SERVER[REQUEST_METHOD]"}[$param];


?>
