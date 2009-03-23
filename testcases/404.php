testing


<?php // DOOH
//
// SourceForge: Breaking Down the Barriers to Open Source Development
// Copyright 1999-2000 (c) The SourceForge Crew
// http://sourceforge.net
//
// $Id: 404.php,v 1.5 2001/01/13 18:32:01 child Exp $

require "pre.php";    // Initial db and session library, opens session
site_header(array(title=>"Requested Page not Found (Error 404)"));

if (session_issecure())
 {
     echo "<a href=\"https://sourceforge.net\">";
 } else {
     echo "<a href=\"http://sourceforge.net\">";
 }

echo "<CENTER><H1>PAGE NOT FOUND</H1></CENTER>";

echo "<P>";

html_box1_top('Search');
menu_show_search_box();
html_box1_bottom();

echo "<P>";

site_footer(array());
site_cleanup(array());


class Dooh
{
     Dooh
}

?>
