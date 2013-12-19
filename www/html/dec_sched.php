<? include 'variables.php' ?>
<?
// Todays Date
$today = date("Y/m/d");
$cur_date = date("H:i:s");

if($clips != '') {
  list ($file, $length, $title) = explode(":", $clips);
}

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

// Print Out After Entry Chosen
if($title != '' && $file && $length != '' && $unix_tstart != '') {
?>
<table valign=top border=1 cellpadding=2 cellspacing=1 bgcolor=lightgrey>
<tr><td align=left bgcolor=navy>
<?
  echo "&nbsp;<font color=white><strong>";
  echo "$port Adding [$title] for $length Seconds...\n"; 
  echo "</strong></font>&nbsp;";
?>
</td></tr>
<tr><td align=center bgcolor=white>
<? passthru("$DVRCMD aps $port $unix_tstart $length $file $title  ");?>
</td></tr>
</table>
<br>
<?
  //exit(0);
}

?>

<table border=1 cellpadding=2 cellspacing=1 bgcolor=lightgrey>
<tr><td align=left valign=top colspan=3>
<form action=playschedule.php method=post name=deccoder>
<input type=hidden name=port value=<?echo $port?>>
<input type=hidden name=myport value=<?echo $port?>>
<strong>Date: </strong>
<input type=text name="date" size=10 maxlength=10  value=<?echo $date?>>
<strong>Time: </strong>
<input type=text name="minutes" size=8 maxlength=8  value=<?echo $minutes?>>
</th><td align=left valign=top colspan=1 bgcolor=lightgrey>
<select name="clips" ONCHANGE=javascript:document.decoder.submit()>
<option><?//echo $clips?>
  <?
    // list out Media Library
    $lines = file ("$LIBRARY");
    while (list($line_num, $line) = each ($lines)) {
      list ($sfile, $length, $title)= explode (":", $line);
      echo "<option>$sfile:$length:$title\n";
    }
  ?>
</select>
</td><td>
<input type=submit value=Add name=submit>
</form>
</td></tr>

</table>

