<? include 'variables.php' ?>
<?
if($clipstop != '') {
  passthru("$DVRCMD sf $port");
  sleep(1);
}
if($cliptake != '') {
  list ($name, $length, $title) = explode(":", $cliptake);
  passthru("$DVRCMD pf $name $port & 1>/dev/null");
  sleep(1);
}
?>
<HTML>
<HEAD>
<TITLE>Play File</TITLE>
<? include 'stylesheet.php' ?>
</head>
<body>

<? include 'topbar.php' ?>
<br>

<?$orig_port = $port?>
<? for($i=0;$i <= $PORTS;$i++) {
     $port = $i;
?>
<table border=1 cellpadding=1 cellspacing=1 bgcolor=lightgrey width=%60>
<tr><th align=left bgcolor=navy colspan=3>
<font color=white>DVR Player <?echo $port?></font>
</th></tr>

<tr><th align=left valign=top colspan=1 bgcolor=lightgrey>
<form action=decoder.php method=post name=decoder>
<input type=hidden name=port value=<?echo $port?>>
<input type=hidden name=myport value=<?echo $port?>>
<strong>File:</strong>
</th><td align=left valign=top colspan=1 bgcolor=lightgrey>
<select name="clips" ONCHANGE=javascript:document.decoder.submit()>
<option><?//echo $clips?>
  <?
    // list out Media Library
    $lines = file ("$LIBRARY");
    while (list ($line_num, $line) = each ($lines)) {
      list ($name, $length, $title)= explode (":", $line);
      echo "<option>$name:$length:$title\n";
    }
  ?>
</select>
</td><td align=left bgcolor=lightgrey colspan=1>
<input type=submit value=Load name=submit>

</td></tr>
</form>

<form action=decoder.php>
<input type=hidden name=port value=<?echo $port?>>
<input type=hidden name=myport value=<?echo $port?>>
<? if ($clips != '' && ($myport == $port)) { ?>
<tr><th bgcolor=lightgrey nowrap colspan=1 align=left>
<strong>Preload:</strong> 
</th><td align=left valign=top colspan=1 bgcolor=lightgrey>
<input type=text name=filler size=50 maxlength=50 value="<?echo $clips?>">
</td>
<? } ?>
<td align=left bgcolor=lightgrey colspan=1>
<input type=hidden name=cliptake value=<?echo $clips?>>
<input type=submit value=Take name=submit>
</td></tr>
</form>

<tr><td bgcolor=lightgreen nowrap colspan=3 align=left>
<?passthru("$DVRCMD ssd $port");?>
</td></tr>
<tr><td align=left bgcolor=lightgrey colspan=3>
<table border=0 cellspacing=0 cellpadding=0><td>
<form action=decoder.php>
<input type=hidden name=port value=<?echo $port?>>
<input type=hidden name=myport value=<?echo $port?>>
<input type=hidden name=clipstop value=stop>
<input type=submit value="Take to Null" name=submit>
</form>
</td><td>
<form action=decoder.php>
<input type=hidden name=port value=<?echo $port?>>
<input type=hidden name=myport value=<?echo $port?>>
<input type=submit value="Refresh" name=submit>
</form>
</td></table>
</td></tr>
</table>
<br>
<?
  }
?>
<?$port = $orig_port?>
<? include 'footer.php' ?>
</body>
</html>
