<? include 'variables.php' ?>
<HTML>
<HEAD><TITLE>KMOS-TV Linux DVR</TITLE></HEAD>
<BODY>
<? include 'topbar.php' ?>
<PRE><? passthru("$DVRCMD ss"); ?></PRE>

<hr solid>
<? include 'footer.php' ?>
</BODY>
</HTML>
