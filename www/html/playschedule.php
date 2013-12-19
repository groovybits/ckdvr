<? include 'variables.php' ?>
<?
?>
<HTML>
<HEAD><TITLE>KMOS-TV Linux DVR</TITLE>
<? include 'stylesheet.php' ?>
</HEAD>
<BODY>

<? include 'topbar.php' ?>
<br>

<table><tr><td>
<form action=playschedule.php method=post name=portc>
<? include 'port.php' ?>
</td><td>
</form>
</td></tr></table>

<? include 'dec_sched.php' ?>

<!--input type=submit value=Change name=Submit->
</form>
</td></tr></table>
<PRE><?  passthru("$DVRCMD ps $port"); ?> </PRE>

<hr solid>

<? include 'footer.php' ?>
</BODY>
</HTML>
