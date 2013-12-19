<? include 'variables.php' ?>
<HTML>
<HEAD>
<TITLE>Record File</TITLE>
<? include 'stylesheet.php' ?>
</head>
<body>

<? include 'topbar.php' ?>
<br>

<?

if($minutes != '' && $minutes != "00:00:00") {
  list($hour, $min, $sec) = explode(":",$minutes);
  $seconds = ($hour * 3600) + ($min * 60) + $sec;
} else if($minutes == '') {
  $minutes = "00:00:00";
}

if($encstop != '') {
  passthru("$DVRCMD se $port");
  sleep(3);
}

if($title != '' && $minutes != '') {
?>
<br>
<table valign=top border=1 cellpadding=2 cellspacing=1 bgcolor=lightgrey>
<form action=encoder.php method=post>
<tr><td align=left>
<input type=hidden name=port value=<?echo $port?>>
<input type=hidden name=myport value=<?echo $port?>>
<input type=hidden name=encstop value=stop>
<input type=submit value=Stop name=submit>
</form>
&nbsp;<a href=/>Main</a> &nbsp; 
&nbsp;<a href=/encoder.php>Encoder</a> &nbsp;
</td></tr>
<tr><td align=left bgcolor=navy>
<?
  echo "&nbsp;<font color=white><strong>";
  echo "$port Recording [$title] for $seconds Seconds...\n"; 
  echo "</strong></font>&nbsp;";
?>
</td></tr>
<tr><td align=center bgcolor=white>
<PRE><? passthru("$DVRCMD e $seconds $port $title & ");?></PRE>
</td></tr>
</table>
<br>
<?
  //exit(0);
}

$minutes = "00:00:00";
?>

<?$orig_port = $port?>
<? for($i=0;$i <= $PORTS;$i++) { 
     $port = $i;
?>
<table border=1 cellpadding=2 cellspacing=1 bgcolor=lightgrey>
<tr><th align=left bgcolor=navy>
<font color=white>DVR Recorder <?echo $port?></font>
</th></tr>
<tr><td align=left valign=top colspan=3>
<form action=encoder.php method=post name=encoder>
<input type=hidden name=port value=<?echo $port?>>
<input type=hidden name=myport value=<?echo $port?>>
<strong>Time: </strong>
<input type=text name="minutes" size=8 maxlength=8  value=<?echo $minutes?>>
<strong>Title: </strong>
<input type=text name="title" size=50 maxlength=50 value="">
<input type=submit value=Start name=submit>
</form>
</td></tr>
<tr><td align=left>

<table border=0 cellpadding=2 cellspacing=1 width=%100>
<td align=left bgcolor=#EEEE99>
<?passthru("$DVRCMD sse $port");?>
</td><td bgcolor=lightgrey align=right>
<form action=encoder.php method=post>
<input type=hidden name=port value=<?echo $port?>>
<input type=hidden name=myport value=<?echo $port?>>
<input type=hidden name=encstop value=stop>
<input type=submit value=Stop name=submit>
</form>
</td></table>

</td></tr>

</table>
<br>
<? } ?>

<?$port = $orig_port?>
<? include 'footer.php' ?>
</body>
</html>
