
<?
// Todays Date
$today = date("Y/m/d");
$cur_date = date("H:i:s");

// Default to Port 0
if ($port == '') 
  $port = 0;

// Record Date
if($date != '') {
  list($year, $month, $day) = explode("/", $date);
} else {
  $date = $today;
}

// Record Time
if($minutes != '' && $minutes != "00:00:00") {
  list($hour, $min, $sec) = explode(":",$minutes);
} else if($minutes == '') {
  $minutes = $cur_date;
  #$minutes = "00:00:00";
}

// Calculate UNIX Timestamp
$unix_tstart = mktime($hour, $min, $sec, $month, $day, $year);

// Duration of recording
if($duration != '' && $duration != "00:00:00") {
  list($hour, $min, $sec) = explode(":",$duration);
  $dur_seconds = ($hour * 3600) + ($min * 60) + $sec;
} else if($duration == '') {
  $duration = "00:00:00";
}

// Print Out After Entry Chosen
if($title != '' && $dur_seconds != '' && $unix_tstart != '') {
?>
<table valign=top border=1 cellpadding=2 cellspacing=1 bgcolor=lightgrey>
<tr><td align=left bgcolor=navy>
<?
  echo "&nbsp;<font color=white><strong>";
  echo "$port Adding [$title] for $dur_seconds Seconds...\n"; 
  echo "</strong></font>&nbsp;";
?>
</td></tr>
<tr><td align=center bgcolor=white>
<? passthru("$DVRCMD ars $port $unix_tstart $dur_seconds $title 1>/dev/null & ");?>
</td></tr>
</table>
<br>
<?
  //exit(0);
}

?>

<table border=1 cellpadding=2 cellspacing=1 bgcolor=lightgrey>
<tr><td align=left valign=top colspan=3>
<form action=recordschedule.php method=post name=encoder>
<input type=hidden name=port value=<?echo $port?>>
<input type=hidden name=myport value=<?echo $port?>>
<strong>Date: </strong>
<input type=text name="date" size=10 maxlength=10  value=<?echo $date?>>
<strong>Time: </strong>
<input type=text name="minutes" size=8 maxlength=8  value=<?echo $minutes?>>
<strong>Title: </strong>
<input type=text name="title" size=50 maxlength=50 value="<?echo $title?>">
<strong>Duration: </strong>
<input type=text name="duration" size=8 maxlength=8  value=<?echo $duration?>>
<input type=submit value=Add name=submit>
</form>
</td></tr>

</table>

