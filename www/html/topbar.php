
<table border=1 cellpadding=0 cellspacing=2 bgcolor=lightgrey><tr>
<td align=left bgcolor=lightgrey>

<table border=0 cellpadding=0 cellspacing=0><th >

<table border=1 cellpadding=1 cellspacing=1><th >
&nbsp;<a href="decoder.php?port=<?echo $port?>">Play</a>&nbsp;
</th></table>

</th><th >

<table border=1 cellpadding=1 cellspacing=1><th >
&nbsp;<a href="encoder.php?port=<?echo $port?>">Record</a>&nbsp;
</th></table>

</th><th>

<table border=1 cellpadding=1 cellspacing=1><th >
&nbsp;<a href="mode.php?port=<?echo $port?>">Mode</a>&nbsp;
</th></table>

</th><th>

<table border=1 cellpadding=1 cellspacing=1><th >
&nbsp;<a href="recordings.php?port=<?echo $port?>">Library</a>&nbsp;
</th></table>

</th><th>

<table border=1 cellpadding=1 cellspacing=1><th >
&nbsp;<a href="playschedule.php?port=<?echo $port?>">Play Schedule</a>&nbsp; 
</th></table>

</th><th >

<table border=1 cellpadding=1 cellspacing=1><th >
&nbsp;<a href="recordschedule.php?port=<?echo $port?>">Record Schedule</a>&nbsp;
</th></table>

</th><th>


</th></table>

</tr><tr><td align=left bgcolor=#EEEE99>
 <PRE><font color=black size=2><?passthru("$DVRCMD ss");?></font></PRE>
</td></tr>
</table>

