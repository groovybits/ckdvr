<? include 'variables.php' ?>
<HTML>
<HEAD><TITLE>KMOS-TV Linux DVR</TITLE>
<? include 'stylesheet.php' ?>
</HEAD>
<BODY>

<? include 'topbar.php' ?>
<br>

<strong><font size=5>Clip Library:</font></strong><hr solid>
<?
passthru("$DVRCMD l");
?>

<hr solid>
<? include 'footer.php' ?>
</BODY>
</HTML>
