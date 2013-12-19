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
<form action=recordschedule.php method=post name=portc>
<? include 'port.php' ?>
</td><td>
</form>
</td></tr></table>

<? include 'enc_sched.php' ?>

<PRE><?  passthru("$DVRCMD rs $port"); ?></PRE>

<hr solid>
<? include 'footer.php' ?>
</BODY>
</HTML>
