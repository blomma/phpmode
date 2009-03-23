<?php
//
// SourceForge: Breaking Down the Barriers to Open Source Development
// Copyright 1999-2000 (c) The SourceForge Crew
// http://sourceforge.net
//
// $Id: contact.php,v 1.3 2001/01/13 18:32:01 child Exp $

require "pre.php";    // Initial db and session library, opens session
site_header(array('title'=>'Contact Us'));
?>

<P>You may contact any of the <A href="staff.php">staff</A> directly via email.
<P>
All <B>support questions</B> should be submitted through the 
<A HREF="/support/?func=addsupport&group_id=1">Support Manager</A>.
<P>
If you feel you are encountering a <B>bug</B> or unusual error of any kind, 
please <A HREF="/bugs/?func=addbug&group_id=1"><B>submit a bug</B></A>.

<P>All press inquiries should be directed to:
<UL><LI><A href="/sendmessage.php?toaddress=eureka_maillink_valinux.com">Eureka Endo</A>
<BR>Press Relations Manager, VA Linux Systems
<BR>408.542.5754</UL>

<P>All complaints/bugs should be directed to:
<UL><LI><A href="/bugs/?group_id=1">Our Bug Tracking System</A></UL>
<P>If you're especially bored, you can visit our bug tracking system
to see what other people have submitted, too.

<?php
site_footer(array());
?>
