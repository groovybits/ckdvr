<?
if($port == 0 || $port == '') {
  $port_0 = 'checked';
  $port = 0;
} else if($port == 1) {
  $port_1 = 'checked';
} else if($port == 2) {
  $port_2 = 'checked';
} else if($port == 3) {
  $port_3 = 'checked';
}

?>

<table border=1 cellpadding=2 cellspacing=1 bgcolor=lightgrey>
<tr><th bgcolor=lightgrey nowrap align=left>
<font size=2 color=black>DVR: &nbsp;</font>
</th>
<td>
<input type=radio name=port value="0" <?echo $port_0?> onClick=javascript:document.portc.submit()>
0&nbsp;
</td><td>
<input type=radio name=port value="1" <?echo $port_1?> onClick=javascript:document.portc.submit()>
1&nbsp;
</td><td>
<input type=radio name=port value="2" <?echo $port_2?> onClick=javascript:document.portc.submit()>
2&nbsp;
</td><td>
<input type=radio name=port value="3" <?echo $port_3?> onClick=javascript:document.portc.submit()>
3&nbsp;
</td></tr>
</table>

