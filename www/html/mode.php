<? include 'variables.php' ?>
<HTML>
<HEAD><TITLE>KMOS-TV Linux DVR</TITLE>
<? include 'stylesheet.php' ?>
</HEAD>
<BODY>

<? include 'topbar.php' ?>
<br>

<?

if($enc == "man") {
  passthru("$DVRCMD manual enc $port >/dev/null");
} else if($enc == "auto") {
  passthru("$DVRCMD auto enc $port >/dev/null");
}
if($dec == "man") {
  passthru("$DVRCMD manual dec $port >/dev/null");
} else if($dec == "auto") {
  passthru("$DVRCMD auto dec $port >/dev/null");
}

if( file_exists("$ENCMANUALMODE.$port")) {
  $enc_man = 'checked';
} else {
  $enc_auto = 'checked';
}
if( file_exists("$DECMANUALMODE.$port")) {
  $dec_man = 'checked';
} else {
  $dec_auto = 'checked';
}

?>

<table border=1 cellpadding=2 cellspacing=1>
<tr><th bgcolor=navy nowrap colspan=3 align=left>
<font color=white>Schedule Mode Port <?echo $port?></font>
</th></tr>

<tr><td align=left valign=top colspan=3 bgcolor=lightgrey>
<form action=mode.php method=post name=porta>
<table border=0><tr><td>
<table border=0><tr><td>
<strong>Recording </strong>
</tr></td><tr><td>
<input type=radio name=enc value="man" <?echo $enc_man?> onClick="javascript:document.porta.submit()">
manual
</tr></td><tr><td>
<input type=radio name=enc value="auto" <?echo $enc_auto?> onClick="javascript:document.porta.submit()">
auto
</tr></td>
</table></td><td>
<table border=0><tr><td>
<strong>Playback </strong>
</tr></td><tr><td>
<input type=radio name=dec value="man" <?echo $dec_man?> onClick="javascript:document.porta.submit()">
manual
</tr></td><tr><td>
<input type=radio name=dec value="auto" <?echo $dec_auto?> onClick="javascript:document.porta.submit()">
auto
</td></tr>
</table>
</tr></td><tr><td colspan=3 align=left>
<input type=hidden name=port value=<?echo $port?>>
<!--input type=submit name=submit value="Set Mode"-->
</form>
<form action=mode.php name=portc>
</tr></td><tr><td colspan=3 align=left>
<? include 'port.php' ?>
<!--input type=submit name=submit value="Switch DVR"-->
</td></tr></table>
</td></tr></table>
</form>
<br>

<? include 'footer.php' ?>
</BODY>
</HTML>
