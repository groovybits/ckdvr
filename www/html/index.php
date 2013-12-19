<? include 'variables.php' ?>
<?
if($port == '')
  $port = 0;
?>
<HTML>
<HEAD><TITLE>KMOS-TV Linux DVR</TITLE>
<? include 'stylesheet.php' ?>
</HEAD>
<BODY LINK=BLACK ALINK=BLACK VLINK=BLACK>

<table border=1 cellpadding=2 cellspacing=1><tr><th bgcolor=navy>
<font color=white>&nbsp;KMOS-TV Digital Video Recorder&nbsp;</font>
</th></tr>
<tr><td align=left bgcolor=lightgrey>

<table border=0 cellpadding=2 cellspacing=1><th >

<table border=1 cellpadding=1 cellspacing=1><th >
&nbsp;<a href="decoder.php?port=<?echo $port?>">Play</a>&nbsp;
</th></table>

</th><th >

<table border=1 cellpadding=1 cellspacing=1><th >
&nbsp;<a href="encoder.php?port=<?echo $port?>">Record</a>&nbsp;
</th></table>

</th>
<th>
&nbsp;
</th>
<th >

<table border=1 cellpadding=1 cellspacing=1><th >
&nbsp;<a href="mode.php?port=<?echo $port?>">Mode</a>&nbsp;
</th></table>

</th><th>

<table border=1 cellpadding=1 cellspacing=1><th >
&nbsp;<a href="recordings.php?port=<?echo $port?>">Library</a>&nbsp;
</th></table>

</th></table>

<table border=0 cellpadding=2 cellspacing=1><th >

<table border=1 cellpadding=1 cellspacing=1><th >
&nbsp;<a href="playschedule.php?port=<?echo $port?>">Play Schedule</a>&nbsp; 
</th></table>

</th><th >

<table border=1 cellpadding=1 cellspacing=1><th >
&nbsp;<a href="recordschedule.php?port=<?echo $port?>">Record Schedule</a>&nbsp;
</th></table>

</th><th >

</th></table>

</td></tr>

<tr><td align=left bgcolor=#EEEE99><PRE><font color=black size=2><?passthru("$DVRCMD ss");?></font></PRE></td></tr>
</table>

<? include 'footer_f.php' ?>
</BODY>
</HTML>
