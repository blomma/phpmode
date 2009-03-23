%   file     : php.sl
%   author   : Mikael Hultgren <mikael_hultgren@gmx.net>
%   
%   version 2.0.1 (20-Aug-2002)
%
%   $Id: php.sl,v 1.212 2003/02/06 16:42:28 child Exp $
%   $Revision: 1.212 $
%   
%   D e s c r i p t i o n
%   ---------------------
%   This is a mode for editing php files in jed, hence the name phpmode :)
%    
%   The reason for this mode is that the only mode i
%   could find for editing php files under jed was one 
%   i found on dotfiles made by Eric Thelin. 
%   But it didn't work as i wanted, so i grabbed what i
%   could from it, and started from cmode as a template.
%   
%   At the moment it does keyword highlighting and proper
%   indenting, plus a slew of other functionality.
%   
%   -------------------------------------------------------------------------------------------
%   PHP-mode variables:
%   -------------------------------------------------------------------------------------------
%   variable PHP_INDENT      = 4;       % Amount of space to indent within block.
%   variable PHP_BRACE       = 0;       % Amount of space to indent brace
%   variable PHP_BRA_NEWLINE = 0;       % If non-zero, insert a newline first before inserting 
%                                       % a '{'.
%   variable PHP_CONTINUED_OFFSET = 2;  % This variable controls the indentation of statements
%                                       % that are continued onto the next line.
%   variable PHP_COLON_OFFSET = 1;      % Controls the indentation of case inside switch statements.
%   variable PHP_CLASS_OFFSET = 4;      % Controls the amount of indenting inside the class,
%                                       % doesn't apply to the braces
%   variable PHP_SWITCH_OFFSET = 0      % Controls the ammount of extra indention inside switch statements.                                    
%   variable PHP_KET_NEWLINE = 0;       % If non-zero, insert a newline first before inserting 
%                                       % a '}'.
%   variable PHP_Autoinsert_Comments = 1;
%  --------------------------------------------------------------------------------------------
%   
%   T h a n k s  g o  o u t  t o
%   ----------------------------
%   
%    o Eric thelin <eric at thelin.org> for his phpmode that got me started.
%    o David <dstegbauer at post.cz>  who pointed out that php isn't in fact a
%      case sensitive language when it comes to
%      functions ;)
%    o Abraham vd Merwe <abz at blio.net> for his relentless bug-reporting,
%      feature suggestions and beta-tester.
%      Without him my to-do list would be
%      considerable shorter ;)
%    o cmode.sl in jed, without that this mode wouldn't be
%      nearly as feature rich as it is now.
%    o latex.sl for tips on how to do things.
%

% Set all variables to a default value so people who forget to add
% them to their .jedrc doesnt get a error.
custom_variable( "PHP_INDENT", 2 );
custom_variable( "PHP_BRACE", 0 );
custom_variable( "PHP_BRA_NEWLINE", 0 );
custom_variable( "PHP_CONTINUED_OFFSET", 2 );
custom_variable( "PHP_COLON_OFFSET", 1 );
custom_variable( "PHP_CLASS_OFFSET", 4 );
custom_variable( "PHP_SWITCH_OFFSET", 0 );
custom_variable( "PHP_KET_NEWLINE", 0 );
custom_variable( "PHP_Autoinsert_Comments", 0 );

% Set some variables that are used throughout the code.
private variable delim_PHP_start = "<?";
private variable delim_PHP_end   = "?>";
private variable delim_ASP_start = "<%";
private variable delim_ASP_end   = "%>";


define php_revision( )
{
	message("$Revision: 1.212 $");
}

static define php_is_comment( ) %{{{
{
	push_spot( );
	bol_skip_white( );
	0;
	if( orelse
	  { looking_at( "//" ) }
		{ looking_at( "#" ) }
		)	
	{
		pop( );
		what_column( );
	}
	pop_spot( );
}
%}}}
static define php_parse_to_point( ) %{{{
{
	parse_to_point( )
	  or php_is_comment( );
}
%}}}
static variable PHPmode_Fill_Chars = "";
define php_paragraph_sep( ) %{{{
{
	if( strlen( PHPmode_Fill_Chars )) 
	  return 0;
	push_spot( );
	bol_skip_white( );
	
	if( orelse
	  { looking_at( "* " ) }
		{ looking_at( "// " ) }
		{ looking_at( "# " ) }
		)	
	{
		go_right( 2 );
		skip_white( );
		if( looking_at( "@ " )) 
		  eol( );
	}
	
	eolp( ) or ( -2 != parse_to_point( ) );
	pop_spot( );
}
%}}}
define php_format_paragraph( ) %{{{
{
	variable n, dwrap;
	
	PHPmode_Fill_Chars = "";
	if( php_paragraph_sep( ) ) 
	  return;
	push_spot( ); 
	push_spot( ); 
	push_spot( );
	
	while( not( php_paragraph_sep( ) ))
	{
		!if( up_1( ) ) 
		  break;
	}
	if( php_paragraph_sep( ) ) 
	  go_down_1( );
	push_mark( );
	pop_spot( );
	
	while( not( php_paragraph_sep( ) ))
	{
		!if( down_1( ) ) 
		  break;
	}
	
	if( php_paragraph_sep( ) ) 
	  go_up_1( );
	
	narrow( );
	pop_spot( );
	bol( );
	push_mark( );
	skip_white( );
	if( looking_at( "* " )) 
	  go_right( 2 );
	else if( looking_at( "// " )) 
	  go_right( 3 );
	else if( looking_at( "# " )) 
	  go_right( 2 );
	
	PHPmode_Fill_Chars = bufsubstr( );
	dwrap = what_column( );
	bob( );
	do 
	{
		bol_trim( );
		if( looking_at( "* " )) 
		  deln( 2 );
		else if( looking_at( "// " )) 
		  deln( 3 );
		else if( looking_at( "# " )) 
		  deln( 2 );
	}
	
	while( down_1( ) );
	WRAP -= dwrap;
	call( "format_paragraph" );
	WRAP += dwrap;
	bob( );
	do 
	{
		insert( PHPmode_Fill_Chars );
	}
	while( down_1( ) );
	
	bol( );
	go_right( strlen( PHPmode_Fill_Chars ));
	
	skip_white( );
	if( looking_at( "*/" ))
	{
		push_mark( );
		bol_skip_white( );
		del_region( );
	}
	
	PHPmode_Fill_Chars = "";
	widen( );
	pop_spot( );
}
%}}}
define php_in_block( ) %{{{
{
	variable begin = 0, end = 0;	
	variable test;
	
	push_spot( );
	if( bolp( ) )
	{
		if( orelse
		  { looking_at( delim_PHP_start ) }
			{ looking_at( delim_PHP_end ) }
			{ looking_at( delim_ASP_start ) }
			{ looking_at( delim_ASP_end ) }
			)
		{
			pop_spot( );
			return( 1 );
		}
	}
	
	if( looking_at( ">" ))
	{
		go_left( 1 );
		if( orelse
		  { looking_at( "?" ) }
			{ looking_at( "%" ) }
			)
		{
			pop_spot( );
			return( 1 );
		}
	}
	
	forever
	{
		if( orelse
		  { bsearch( delim_PHP_start ) }
			{ bsearch( delim_ASP_start ) }
			)
		{
			if( php_parse_to_point( ) == 0 )
			{
				begin = what_line( );
				break;
			}
			continue;
		} else {
			break;
		}
	}
	
	pop_spot( );
	
	push_spot( );
	forever
	{
		if( orelse
		  { bsearch( delim_PHP_end ) }
			{ bsearch( delim_ASP_end ) }
			)
		{
			if( php_parse_to_point( ) == 0 )
			{
				end = what_line( );
				break;
			}
			continue;
		} else {
			break;
		}
	}
	
	pop_spot( );
	
	if( end < begin )
	{
		return( 1 );
	}
	return( 0 );
}
%}}}

define php_top_of_function( ) %{{{
{
	push_spot( );
	variable current,end,start_brace;
	current = what_line;
	!if( re_bsearch( "function[ \t]+[a-zA-Z_0-9]+[ \t]?\(.*\)") )
	{
		error( "Cant find top of function" );
	}
	
	% Check to see if were in a comment
	if( php_parse_to_point( ) )
	{
		pop_spot( );
		error( "Cant find top of function" );
	}
	
	!if( fsearch( "{") )
	{
		error( "Missing beginning brace of function." );
	}
	start_brace = what_line;
	if( start_brace > current )
	{
		pop_spot( );
		error( "Missing beginning brace of function." );
	}
	find_matching_delimiter( '{' );
	end = what_line;
	if( end < current )
	{
		pop_spot( );
		error( "Not in function" );
	}
	find_matching_delimiter( '}' );
}
%}}}
define php_end_of_function( ) %{{{
{
	!if( bolp( ) and looking_at_char( '{' ))
	  php_top_of_function( );
	call( "goto_match" );
}
%}}}
define php_mark_function( ) %{{{
{
	php_end_of_function( );
	push_visible_mark( );
	eol( );
	exchange_point_and_mark( );
	php_top_of_function( );
	bol_skip_white( );
	if( looking_at( "{") )
	{
		go_up( 1 );
	}
	bol( );
}
%}}}
define php_mark_matching( ) %{{{
{
	push_spot( );
	if( find_matching_delimiter( 0 ))
	{
		% Found one
		pop_spot( );
		push_visible_mark( );
		find_matching_delimiter( 0 );		
		exchange_point_and_mark( );
	} else {
		pop_spot( );
	}
}
%}}}
define php_bskip_over_comment( ) %{{{
{
	forever 
	{	
		bskip_chars (" \t\n");
		if( bobp( ) )
		  return;
		
		push_mark( );
		while( up_1( ) )
		{	
			go_down_1( );
			break;
		}
		
		bol_skip_white( );
		
		if( orelse
		  { looking_at( delim_PHP_start ) }
			{ looking_at( delim_PHP_end ) }
			{ looking_at( delim_ASP_start ) }
			{ looking_at( delim_ASP_end ) }
			)
		{
			pop_mark_0( );
			continue;
		}
		pop_mark_1( );
		
		!if( blooking_at( "*/" ))
		{
			push_mark( );
			variable ptp = -2;
			
			while( andelse
				 { ptp == -2 }
				   { bfind( "//" ) or bfind( "#" ) }
				   )
			  ptp = parse_to_point ();

			if (ptp == 0)
			{
				pop_mark_0( );
				continue;
			}
			
			bol( );
			!if( bobp( ) )
			{
				if( orelse
				  { looking_at( delim_PHP_start ) }
					{ looking_at( delim_PHP_end ) }
					{ looking_at( delim_ASP_start ) }
					{ looking_at( delim_ASP_end ) }
					)
				{
					pop_mark_0( );
					continue;
				}
			}			
			pop_mark_1( );
			break;
		}
		!if( bsearch( "/*" )) break;
	}
}
%}}}
static define php_looking_at( token ) %{{{
{
	variable cse = CASE_SEARCH, ret = 0;
	CASE_SEARCH = 1;
	
	if( looking_at( token ))
	{
		push_spot( );
		go_right( strlen( token ));
		_get_point( );
		skip_chars( "\t :({" );
		ret = ( _get_point( ) - ( )) or eolp( );
		pop_spot( );
	}
	CASE_SEARCH = cse;
	ret;
}
%}}}
static define php_indent_to( n ) %{{{
{
	bol( );
	% Force a reindent if the line does not contain tabs followed by spaces.
	skip_chars( "\t" );
	skip_chars( " " );
	
	if( ( what_column != n )
		or ( _get_point( ) != ( skip_white( ), _get_point( ))))
	{
		bol_trim( );
		n--;
		whitespace( n );
	}
}
%}}}
static define php_indent_continued_comment( col ) %{{{
{
	push_spot( );
	col++;			       %  add 1 so the we indent under * in /*
	php_indent_to( col );
	
	if( looking_at( "*" )
		or not( eolp( ) ))
	  pop_spot( );
	else
	{
		insert( "* " );
		pop_spot( );
		
		if( what_column( ) <= col )
		{
			goto_column( col + 2 );
		}
	}
}
%}}}
static define php_mode_if_bol_skip_white( ) %{{{
{
	push_mark( );
	bskip_white( );
	1;
	if( bolp( ) )
	{
		pop( );
		skip_white( );
		0;
	}
	pop_mark( ( ) );		       %  take argument from stack
}
%}}}
%#iftrue
% Return true if the spot is inside of a class definition
% Takes the opening brace of the enclosing block as an
% argument.
static define inside_class( bra ) %{{{
{
	push_spot( );
	EXIT_BLOCK
	{
		pop_spot( );
	}
	
	goto_user_mark( bra );
	
	% Assume that class is at the beginning of a line.  We may want to
	% change this assumption later.
	while( re_bsearch( "^\\c[ \t]*\\<class\\>" ))
	{
		if( 0 == parse_to_point( ) )
		{
			while( fsearch( "{" ))
			{
				if( 0 != parse_to_point( ) )
				{
					go_right_1( );
					continue;
				}
				
				if ( bra == create_user_mark( ) )
				  return 1;
				break;
			}
			return 0;
		}
		
		!if( left( 1 ))
		  break;
	}
	
	return 0;
} %}}}
%#endif
define php_indent_line( ) %{{{
{	
	variable val, col, extra_indent = 0;
	variable prep_line = 0;
	variable match_char, match_indent, this_char, match_line;
	variable match_mark;
	variable is_continuation = 0;
	
	% Check whetever we are in a php block or not
	if( php_in_block( ) )
	{
		push_spot( );
		bol_skip_white( );
		
		% Store the character we are standing on
		this_char = what_char( );
		if( -2 == parse_to_point( ) )
		{
			% In a c comment.  Indent it at level of matching /* string
			( ) = bsearch( "/*" );
			col = what_column( );
			pop_spot( );
			php_indent_continued_comment( col );
			php_mode_if_bol_skip_white( );
			return;
		}
		
		EXIT_BLOCK
		{
			php_mode_if_bol_skip_white( );
		}
		
		if( orelse
		  { php_looking_at( "case" ) }
			{ php_looking_at( "default" ) }
			)
		{
			if( ffind_char( ':' ))
			{
				extra_indent -= PHP_INDENT;
				extra_indent += PHP_COLON_OFFSET;
				%message(string(extra_indent));
			}
			bol( );
		} else {
			forever
			{
				php_bskip_over_comment( );
				!if( orelse
				   { blooking_at( ";" ) }
					 { blooking_at( "{" ) }
					 { blooking_at( "}" ) }
					 { blooking_at( ")," ) }
					 { blooking_at( "}," ) }
					 { blooking_at( ":" ) }
					 { bobp( ) }
					 )
				{	
					% This needs to be here to make sure were still in the phpblock
					if( php_in_block( ) )
					{
						% message("hej2");
						if( is_continuation )
						{
							% message("hej");
							extra_indent += PHP_CONTINUED_OFFSET;
						} 
						else 
						{
							% message("hej3");
							push_spot( );
							bol_skip_white( );
							% fsearch( "{" );
							% !if( blooking_at( ")" )
							extra_indent += PHP_CONTINUED_OFFSET;
							pop_spot( );
						}
					
						% extra_indent += PHP_CONTINUED_OFFSET;					
						is_continuation++;
						% is_continuation++;
					}
				}
				
				!if( blooking_at( ")" ))
				  break;
				push_mark( );
				go_left_1( );
				if( 1 != find_matching_delimiter( ')' ))
				{
					pop_mark_1( );
					break;
				}
				
				php_bskip_over_comment( );
				
				push_spot( );
				if( ( 1 == find_matching_delimiter( ')' )), pop_spot( ) )
				{
					pop_mark_1( );
					break;
				}
				
				pop_mark_0( );
				bol ( );
			}
		}
		
		val = find_matching_delimiter( ')' );
		match_mark = create_user_mark( );
		
		match_char = what_char( );
		match_line = what_line( );
		
		if( ( val < 0 ) and looking_at( "/*" ))
		  val = -2;
		else if( val == 1 )
		{
			go_right( 1 );
			skip_white( );
		}
		
		col = what_column( );

		bol_skip_white( );
		match_indent = what_column( );
		if( what_line( ) < prep_line )
		{
			match_char = 0;
		}
		
		pop_spot( );
		
		switch( val )
		{
		 case 0:			       %  mismatch
			if( match_char == '{' )
			{
				push_spot( );
				goto_user_mark( match_mark );
				
				bskip_chars( "\n\t " );				
				if( blooking_at( ")" ))
				{
					variable same_line = ( what_line == match_line );
					
					go_left_1( );
					if( 1 == find_matching_delimiter( ')' ))
					{
						bol_skip_white( );
						
						if( same_line )
						  match_indent = what_column( );
						
						% NOTE: This needs work.
						if( ( this_char != '}' )
							and looking_at( "switch" ))
						  match_indent += PHP_SWITCH_OFFSET;
					}
				}
				
				pop_spot( );
				col = match_indent;
#ifexists PHP_CLASS_OFFSET
				if( this_char == '}' )
				  col += PHP_INDENT;
				else if( inside_class( match_mark ))
				  col += PHP_CLASS_OFFSET;
				else
				  col += PHP_INDENT;
#else
				col += PHP_INDENT;
#endif
			} else if( match_char == '[' ) {
				push_spot( );
				php_indent_to( col + 1 );
				pop_spot( );
				return;
			} else {
				push_spot( );
				bol_skip_white( );
				if( looking_at_char( '{' ))
				  extra_indent = PHP_BRACE;
				extra_indent++;
				php_indent_to( extra_indent );
				pop_spot( );				
				return;
			}
		}
		{
		case 1:
			extra_indent = 0;	       %  match found
		}
		{
		case -2:			       %  inside comment
			if( this_char != '\\' ) 
			  col++;
			php_indent_continued_comment( col );
			return;
		}
		{
		 case 2:
			push_spot_bol( );
			trim( );
			pop_spot( );
			return;
		}
		
		switch( this_char )
		{
		 case '}':
			col -= PHP_INDENT;
		}
		{
		 case '{':			
			col += PHP_BRACE;
			if( is_continuation )
			  col -= PHP_CONTINUED_OFFSET;
			col += extra_indent;
		}
		{
			col += extra_indent;
		}
		
		push_spot( );
		php_indent_to( col );
		pop_spot( );
	} else {
		% Not in PHP block
		%insert( "\t" );
	}
	
}
%}}}
define php_indent_region_or_line( ) %{{{
{
	!if( is_visible_mark )
	  php_indent_line( );
	else
	{
		variable now,start,stop;
		check_region( 1 );
		stop = what_line( );
		pop_mark_1( );
		start = what_line( );
		push_mark( );
		forever
		{
			now = what_line( );
			if( now >= stop )
			  break;
			php_indent_line( );
			down_1( );
		}
		pop_spot( );
		flush( sprintf( "processed %d/%d lines.", start( ), stop ));		
	}
}
%}}}
define php_indent_buffer( ) %{{{
{
	variable col, max_line;
	push_spot( );
	eob( );
	max_line = what_line( );
	bob( );
	do
	{
		bol_skip_white( );
		indent_line( );
	} while( down_1( ) );
	
	trim_buffer( );
	flush( sprintf( "processed %d/%d lines.", what_line( ), max_line ));
	pop_spot( );
}
%}}}
define php_newline_and_indent( ) %{{{
{	
	variable PhpCcComment = "//";
	variable PhpBashComment = "#";
	
	if( bolp ( ) )
	{
		newline( );
		php_indent_line( );
		return;
	}
	
	variable col;
	variable PhpCcComment_len = strlen( PhpCcComment );
	variable PhpBashComment_len = strlen( PhpBashComment );
	
	if( PHP_Autoinsert_Comments )
	{
		col = what_column( );
		push_spot_bol( );
		if( looking_at( PhpCcComment ))
		{
			push_mark( );
			go_right( PhpCcComment_len );
			skip_white( );
			PhpCcComment = bufsubstr( );
			pop_spot( );
			newline( );
			if( col > PhpCcComment_len )
			  insert( PhpCcComment );
			return;
		} else if( looking_at( PhpBashComment )) {
			push_mark( );
			go_right( PhpBashComment_len );
			skip_white( );
			PhpBashComment = bufsubstr( );
			pop_spot( );
			newline( );
			if( col > PhpBashComment_len )
			  insert( PhpBashComment );
			return;
		}		  
		pop_spot( );
	}
	
	col = php_is_comment( );
	newline( );
	if( col )
	{
		php_indent_to( col );
		insert( "" );
	}
	else php_indent_line( );
}
%}}}
define php_insert_bra( ) %{{{
{
	if( php_parse_to_point( ) )
	  insert_char( '{' );
	else {
		push_spot( );
		php_bskip_over_comment( 0 );
		if( blooking_at( "," ), pop_spot( ) )
		{
			insert_char( '{' );
		} else { 
			push_spot( );
			skip_white( );
			if( eolp( ) )
			{
				bskip_white( );
				if( not( bolp( ) ) and PHP_BRA_NEWLINE, pop_spot( ) ) 
				  newline( );
				push_spot( );
				bskip_white( );
				bolp( );	       %  on stack
				pop_spot( );
				insert_char( '{' );
				if( ( ) ) 
				  php_indent_line( );   %  off stack
				eol( );
				if( PHP_BRA_NEWLINE ) 
				  php_newline_and_indent( );
			} else  {
				pop_spot( );
				insert_char( '{' );
			}
		}
	}
}
%}}}
define php_insert_ket( ) %{{{
{
	variable status = php_parse_to_point( );
	variable line = what_line( );
	
	push_spot( );
	skip_white( );
	push_spot( );
	if( status 
		or not( eolp( ) )
		or( 1 == find_matching_delimiter( '}' )) and( line == what_line( ) ))
		%or (bol_skip_white ( ), looking_at_char ('{')), pop_spot ( ))
	{
		pop_spot( );
		pop_spot( );
		if( PHP_KET_NEWLINE )
		{
			insert( "\n}" );
			php_indent_line( );
		}
		else
		  insert( "}" );
		blink_match( );
		return;
	}
	
	pop_spot( );
	bskip_white( );
	if( bolp( ), pop_spot( ) )
	{
		insert_char( '}' );
		trim( );
	} else {
		eol( );
		if( PHP_KET_NEWLINE )
		  insert( "\n}" );
		else
		  insert( "}" );
	}
	php_indent_line( );
	eol( ); 
	blink_match( );
	if( PHP_BRA_NEWLINE )
	  php_newline_and_indent( );
}
%}}}
define php_insert_colon( ) %{{{
{
	insert_char( ':' );
	!if( php_parse_to_point( ) )
	  php_indent_line( );
}
%}}}
define php_getname( tellstring ) %{{{
{
	variable gname = read_mini( tellstring, Null_String, Null_String );
	return gname;
}
%}}}
define php_ins_tn( str ) %{{{
{
	insert( str );
	php_indent_line( );
	insert( "\n" );
}
%}}}
define php_insert_function( ) %{{{
{
	variable name = php_getname( "function:" );
	php_ins_tn( sprintf( "function %s ( )", name ));
	php_ins_tn( "{" );
	php_ins_tn( "" );	
	php_ins_tn( "}" );
	bsearch( ")" );	
}
%}}}
define php_insert_class( ) %{{{
{
	variable name = php_getname( "class:" );
	php_ins_tn(sprintf( "class %s", name ));
	php_ins_tn( "{" );
	php_ins_tn( "" );	
	php_ins_tn( "}" );	
}
%}}}
define php_insert_tab( ) %{{{
{
	insert( "\t" );
}
%}}}
static define php_init_menu( menu ) %{{{
{
	menu_append_item( menu, "&Top of function", "php_top_of_function" );
	menu_append_item( menu, "&End of function", "php_end_of_function" );
	menu_append_item( menu, "&Mark function", "php_mark_function" );
	menu_append_item( menu, "&Mark matching", "php_mark_matching" );
	menu_append_separator( menu );
	menu_append_item( menu, "&Indent buffer", "php_indent_buffer" );
	menu_append_separator( menu );
	menu_append_item( menu, "&Insert class", "php_insert_class" );
	menu_append_item( menu, "&Insert function", "php_insert_function" );
	menu_append_item( menu, "&Insert brace", "php_insert_bra" );
	menu_append_item( menu, "&Insert ket", "php_insert_ket" );
	menu_append_item( menu, "&Insert colon", "php_insert_colon" );
	menu_append_separator( menu );
	menu_append_item( menu, "&Format paragraph", "php_format_paragraph" );
	menu_append_item( menu, "&Goto Match", "goto_match" );
	menu_append_item( menu, "&Insert TAB", "php_insert_tab" );
}
%}}}
$1 = "PHP";

!if( keymap_p( $1 )) 
  make_keymap( $1 ); %{{{
definekey( "indent_line", "\t", $1 );
definekey( "php_top_of_function", "\e^A", $1 );
definekey( "php_end_of_function", "\e^E", $1 );
definekey( "php_mark_function", "\e^H", $1 );
definekey( "php_mark_matching", "\e^M", $1 );
definekey( "php_insert_bra", "{", $1 );
definekey( "php_insert_ket", "}", $1 );
definekey( "php_insert_colon", ":", $1 );
definekey( "php_format_paragraph", "\eq", $1 );
definekey( "php_newline_and_indent", "\r", $1 );

definekey_reserved( "php_indent_region_or_line", "^R", $1 );
definekey_reserved( "php_indent_buffer", "^B", $1 );
definekey_reserved( "php_insert_class", "^C", $1 );
definekey_reserved( "php_insert_function", "^F", $1 );
definekey_reserved( "php_insert_tab","^I", $1 );
%}}}

% Now create and initialize the syntax tables. %{{{
create_syntax_table( $1 );
define_syntax( "/*", "*/", '%', $1 );          % comments
define_syntax( "#", "", '%', $1 );             % comments
define_syntax( "//", "", '%', $1 );            % comments
%define_syntax ("<>", '<', $1);
define_syntax( "([{", ")]}", '(', $1 );        % parentheses
define_syntax( '"', '"', $1 );                 % strings
define_syntax( '\'', '\'', $1 );               % strings
define_syntax( '\\', '\\', $1 );               % escape character
define_syntax( "0-9a-zA-Z_", 'w', $1 );        % words
define_syntax( "-+0-9a-fA-F.xXL", '0', $1 );   % numbers
define_syntax( ",;.:", ',', $1 );              % delimiters
define_syntax( "+-*/%=.&|^~<>!?@`", '+', $1 ); % operators
set_syntax_flags( $1, 0x05 );
%}}}

#ifdef HAS_DFA_SYNTAX %{{{
%%% DFA_CACHE_BEGIN %%%
static define setup_dfa_callback( name )
{
	dfa_enable_highlight_cache( "php.dfa", name );
	dfa_define_highlight_rule( "<%", "Qpreprocess", name );          % Asp style start tag
	dfa_define_highlight_rule( "%>", "Qpreprocess", name );          % Asp style end tag
	dfa_define_highlight_rule( "<\\?|<\\?php", "preprocess", name ); % Php style start tag 
	dfa_define_highlight_rule( "\\?>", "Qpreprocess", name ); % Php style end tag
	dfa_define_highlight_rule ("<!\\-\\-.*\\-\\-[ \t]*>", "Qcomment", name); % HTML comments
	dfa_define_highlight_rule ("<!\\-\\-", "comment", name); % HTML comments
	dfa_define_highlight_rule ("\\-\\-[ \t]*>", "comment", name); % HTML comments
	dfa_define_highlight_rule( "#.*", "comment", name );             % Shell style comment
	dfa_define_highlight_rule( "//.*", "comment", name );            % C++ style comment
	dfa_define_highlight_rule( "/\\*.*\\*/", "Qcomment", name );     % C style comment
	dfa_define_highlight_rule( "^([^/]|/[^\\*])*\\*/", "Qcomment", name ); % C style comment
	dfa_define_highlight_rule( "/\\*.*", "comment", name );          % C style comment
	dfa_define_highlight_rule( "^[ \t]*\\*+([ \t].*)?$", "comment", name ); % C style comment
	dfa_define_highlight_rule( "[A-Za-z_\\$][A-Za-z_0-9\\$]*", "Knormal", name );
	dfa_define_highlight_rule( "[ \t]+", "normal", name );
	dfa_define_highlight_rule( "[0-9]+(\\.[0-9][LlUu]*)?([Ee][\\+\\-]?[0-9]*)?","number", name );
	dfa_define_highlight_rule( "0[xX][0-9A-Fa-f]*[LlUu]*", "number", name );
	dfa_define_highlight_rule( "[\\(\\[{}\\]\\),;\\.:]", "delimiter", name ); % Delimiters:  ([{}]) 
	dfa_define_highlight_rule( "[%@\\?\\.\\-\\+/&\\*=<>\\|!~\\^]", "operator", name ); % Operators:  %@?.-+/&*=<>|!~^ 
	dfa_define_highlight_rule( "\"([^\"\\\\]|\\\\.)*\"", "string", name );
	dfa_define_highlight_rule( "\"([^\"\\\\]|\\\\.)*\\\\?$", "string", name );
	dfa_define_highlight_rule( "'([^'\\\\]|\\\\.)*'", "string", name );
	dfa_define_highlight_rule( "'([^'\\\\]|\\\\.)*\\\\?$", "string", name );
	dfa_build_highlight_table( name );
}
dfa_set_init_callback( &setup_dfa_callback, "PHP" );
%%% DFA_CACHE_END %%%
#endif
%}}}

% Type 0 keywords (keywords and constants) %{{{
() = define_keywords_n ($1,
"dlpi",
2,1);

() = define_keywords_n ($1,
"abschrcosdieendexpkeylogmaxminordpospow"
+ "sintan",
3,1);

() = define_keywords_n ($1,
"acosasinatanceilchopcopycoshdateeach"
+ "echoeregevalexecexitfeoffilefmodftokglob"
+ "is_ajoinlinklistmailmsqlnextpackprevrand"
+ "sinhsortsqrtstattanhtimetrim",
4,1);

() = define_keywords_n ($1,
"acosharrayasinhasortatanhbcaddbcdiv"
+ "bcmodbcmulbcpowbcsubchdirchgrpchmodchown"
+ "countcryptemptyeregifgetcfgetsflockfloor"
+ "flushfopenfputsfreadfseekfstatftellgzeof"
+ "hw_cphw_mvhypoticonvissetksortlstatltrim"
+ "mhashmkdirpopenprintrangeresetrmdirround"
+ "rsortrtrimsleepsplitsrandstrtrtouchumask"
+ "unsetusort",
5,1);

() = define_keywords_n ($1,
"arsortassertbccompbcsqrtbindecbzopen"
+ "bzreadchrootdblistdecbindechexdecoctdefine"
+ "deletefclosefflushfgetssfscanffwritegetcwd"
+ "getenvgetoptgmdategmp_orgzfilegzgetcgzgets"
+ "gzopengzputsgzreadgzseekgztellheaderhebrev"
+ "hexdechw_whoifx_dointvalis_diris_intis_nan"
+ "krsortmktimeoctdecora_dopclosepg_ttyprintf"
+ "putenvrecoderenamereturnrewindsizeofspliti"
+ "sscanfstrchrstrcmpstrlenstrposstrrevstrspn"
+ "strstrstrtokstrvalsubstrsyslogsystemuasort"
+ "uksortuniqidunlinkunpackusleepyp_allyp_cat",
6,1);

() = define_keywords_n ($1,
"bcscalebzclosebzerrnobzerrorbzflush"
+ "bzwritecom_getcom_setcompactcurrentdbmopen"
+ "defineddirnameexplodeextractfgetcsvfilepro"
+ "fnmatchfprintfftp_getftp_putftp_pwdgd_info"
+ "getdategetmxrrgettextgettypegmp_absgmp_add"
+ "gmp_andgmp_cmpgmp_comgmp_divgmp_gcdgmp_mod"
+ "gmp_mulgmp_neggmp_powgmp_subgmp_xorgzclose"
+ "gzgetssgzwritehebrevchw_infohw_roothw_stat"
+ "imagegdimagesximagesyimplodeincludeini_get"
+ "ini_setis_boolis_fileis_linkis_longis_null"
+ "is_realmb_eregmcve_btmcve_glmcve_qcmcve_ub"
+ "mt_randnatsortodbc_doopendiropenlogpdf_arc"
+ "pdf_newpg_hostpg_pingpg_portphpinfoprint_r"
+ "readdirrequiresem_getsettypeshufflesnmpget"
+ "snmpsetsoundexsprintfstr_padstrcollstrcspn"
+ "stristrstrncmpstrrchrstrrposswffillswffont"
+ "swftextsymlinktempnamtmpfileucfirstucwords"
+ "virtualvprintfyp_next",
7,1);

() = define_keywords_n ($1,
"basenamebcpowmodbzerrstrcal_info"
+ "ccvs_addccvs_newclosedircloselogcom_load"
+ "constantcpdf_arcdba_listdba_opendba_sync"
+ "dbmclosedbmfetchdbx_sortdgettextdio_open"
+ "dio_readdio_seekdio_statfdf_openfdf_save"
+ "filesizefiletypefloatvalftp_cdupftp_exec"
+ "ftp_fgetftp_fputftp_mdtmftp_pasvftp_quit"
+ "ftp_siteftp_sizegetmygidgetmypidgetmyuid"
+ "gmmktimegmp_factgmp_initgmp_powmgmp_sign"
+ "gmp_sqrtgzencodegzrewindhw_closehw_dummy"
+ "hw_errorhw_mapidimagearcimagegifimagepng"
+ "imap_uidin_arrayircg_msgis_arrayis_float"
+ "jdtounixldap_addlinkinfomb_eregimb_split"
+ "mcve_gftmcve_gutmsg_sendmt_srandngettext"
+ "ob_cleanob_flushob_startocierrorocifetch"
+ "ocilogonociparseora_bindora_execora_open"
+ "overloadpassthrupathinfopdf_arcnpdf_clip"
+ "pdf_fillpdf_openpdf_rectpdf_savepdf_show"
+ "pdf_skewpg_closepg_querypg_tracereadfile"
+ "readlinereadlinkrealpathsnmpwalkstrftime"
+ "swfmorphswfmovieswfshapeudm_findunixtojd"
+ "var_dumpvsprintfwordwrapyaz_hitsyaz_scan"
+ "yaz_sortyaz_waityp_errnoyp_firstyp_match"
+ "yp_orderzip_openzip_read",
8,1);

() = define_keywords_n ($1,
"aggregatearray_maparray_padarray_pop"
+ "array_sumcal_to_jdccvs_authccvs_doneccvs_init"
+ "ccvs_saleccvs_voidcheckdatecpdf_clipcpdf_fill"
+ "cpdf_opencpdf_rectcpdf_savecpdf_showcpdf_text"
+ "curl_execcurl_initdba_closedba_fetchdba_popen"
+ "dbmdeletedbmexistsdbminsertdbx_closedbx_error"
+ "dbx_querydcgettextdio_closedio_fcntldio_write"
+ "dngettextdoublevalerror_logfdf_closefdf_errno"
+ "fdf_errorfileatimefilectimefilegroupfileinode"
+ "filemtimefileownerfilepermsfpassthrufsockopen"
+ "ftp_chdirftp_closeftp_loginftp_mkdirftp_nlist"
+ "ftp_rmdirftruncateget_classgetrusagegmp_div_q"
+ "gmp_div_rgzdeflategzinflatehw_insdochw_unlock"
+ "ifx_closeifx_errorifx_queryimagecharimagecopy"
+ "imagefillimagejpegimagelineimagewbmpimap_body"
+ "imap_listimap_lsubimap_mailimap_openimap_ping"
+ "imap_sortini_alteriptcembediptcparseircg_join"
+ "ircg_kickircg_nickircg_partis_doubleis_finite"
+ "is_objectis_scalaris_stringlcg_valueldap_bind"
+ "ldap_listldap_readldap_sortlocaltimemb_strcut"
+ "mb_strlenmb_strposmb_substrmcal_openmcve_ping"
+ "mcve_salemcve_voidmetaphonemicrotimeocicancel"
+ "ocicommitocilogoffocinlogonociplogonociresult"
+ "odbc_execora_closeora_errorora_fetchora_logon"
+ "ora_parseparse_strparse_urlpdf_closepdf_scale"
+ "pg_dbnamepg_deletepg_insertpg_selectpg_update"
+ "php_unamepreg_grepproc_openqdom_treequotemeta"
+ "rewinddirserializesetcookiesetlocalestrnatcmp"
+ "strtotimeswf_orthoswf_scaleswfactionswfbitmap"
+ "swfbuttonswfspriteudm_errnoudm_errorurldecode"
+ "urlencodexml_parsexptr_evalxslt_freeyaz_close"
+ "yaz_errnoyaz_erroryaz_rangeyp_masterzip_close",
9,1);

() = define_keywords_n ($1,
"addslashesarray_diffarray_fill"
+ "array_fliparray_keysarray_pusharray_rand"
+ "array_walkaspell_newbzcompressccvs_count"
+ "checkdnsrrcom_addrefcom_invokecom_isenum"
+ "cpdf_closecpdf_scalecurl_closecurl_errno"
+ "curl_errorcyrus_binddba_deletedba_exists"
+ "dba_insertdbase_opendbase_packdbmnextkey"
+ "dbmreplacedbplus_adddbplus_aqldbplus_sql"
+ "dbplus_tcldcngettextdns_get_mxezmlm_hash"
+ "fdf_createfdf_get_apfdf_headerfdf_set_ap"
+ "frenchtojdftp_deleteftp_nb_getftp_nb_put"
+ "ftp_renamegetlastmodgetmyinodegetrandmax"
+ "gmp_clrbitgmp_div_qrgmp_gcdextgmp_intval"
+ "gmp_invertgmp_jacobigmp_randomgmp_setbit"
+ "gmp_sqrtrmgmp_strvalgmstrftimegzcompress"
+ "gzpassthruhw_connecthw_gettexthw_inscoll"
+ "imagetypesimap_checkimap_closeimap_msgno"
+ "ircg_topicircg_whoisis_integeris_numeric"
+ "jdtofrenchjdtojewishjdtojulianjewishtojd"
+ "juliantojdldap_closeldap_errnoldap_error"
+ "localeconvmb_strrposmcal_closemcal_popen"
+ "mcrypt_cbcmcrypt_cfbmcrypt_ecbmcrypt_ofb"
+ "mcve_forcemcve_setipmcve_uwaitmsql_close"
+ "msql_errormsql_querymssql_bindmssql_init"
+ "muscat_getmysql_infomysql_pingmysql_stat"
+ "ncurses_nlnotes_bodyocicollmaxociexecute"
+ "ociloadlobocinumcolsocisavelobodbc_close"
+ "odbc_errorora_commitora_logoffora_plogon"
+ "pcntl_execpcntl_forkpdf_circlepdf_concat"
+ "pdf_deletepdf_linetopdf_movetopdf_rotate"
+ "pdf_strokepfpro_initpfsockopenpg_connect"
+ "pg_convertpg_copy_topg_get_pidpg_lo_open"
+ "pg_lo_readpg_lo_seekpg_lo_tellpg_options"
+ "pg_untracephpcreditsphpversionposix_kill"
+ "preg_matchpreg_quotepreg_splitproc_close"
+ "pspell_newqdom_errorreadgzfilesem_remove"
+ "session_idshell_execshm_attachshm_detach"
+ "shm_removeshmop_openshmop_readshmop_size"
+ "str_repeatstrcasecmpstrip_tagsstrtolower"
+ "strtoupperswf_lookatswf_nextidswf_rotate"
+ "textdomaintoken_nameuser_errorvar_export"
+ "xpath_evalxslt_errnoxslt_erroryaz_record"
+ "yaz_schemayaz_searchyaz_syntax",
10,1);

() = define_keywords_n ($1,
"addcslashesapache_notearray_chunk"
+ "array_mergearray_shiftarray_slicecal_from_jd"
+ "ccvs_deleteccvs_lookupccvs_reportccvs_return"
+ "ccvs_statuschunk_splitcom_propgetcom_propput"
+ "com_propsetcom_releasecount_charscpdf_circle"
+ "cpdf_linetocpdf_movetocpdf_rotatecpdf_stroke"
+ "crack_checkctype_alnumctype_alphactype_cntrl"
+ "ctype_digitctype_graphctype_lowerctype_print"
+ "ctype_punctctype_spacectype_uppercurl_setopt"
+ "cyrus_closecyrus_querydba_nextkeydba_replace"
+ "dbase_closedbmfirstkeydbplus_currdbplus_find"
+ "dbplus_infodbplus_lastdbplus_nextdbplus_open"
+ "dbplus_prevdbplus_rzapdbplus_undodbx_compare"
+ "dbx_connectdeaggregatedebugger_ondotnet_load"
+ "easter_dateeaster_daysfbsql_closefbsql_errno"
+ "fbsql_errorfbsql_queryfdf_set_optfile_exists"
+ "ftp_connectftp_nb_fgetftp_nb_fputftp_rawlist"
+ "ftp_systypeget_browserget_cfg_vargmp_hamdist"
+ "hw_childrenhw_edittexthw_errormsghw_identify"
+ "hw_pconnecthwapi_hgcspibase_closeibase_query"
+ "ibase_transifx_connectifx_prepareimagecharup"
+ "imagecreateimageftbboximagefttextimagepsbbox"
+ "imagepstextimagerotateimagestringimap_alerts"
+ "imap_appendimap_binaryimap_deleteimap_errors"
+ "imap_headerimap_qprintimap_reopenimap_search"
+ "imap_setaclimap_statusimap_threadini_get_all"
+ "ini_restoreircg_noticeis_callableis_infinite"
+ "is_readableis_resourceis_writablejddayofweek"
+ "jdmonthnameldap_deleteldap_get_dnldap_modify"
+ "ldap_renameldap_searchldap_unbindlevenshtein"
+ "mb_get_infomb_languagemb_strwidthmcal_reopen"
+ "mcal_snoozemcve_chkpwdmcve_returnmcve_setssl"
+ "mcve_settlemhash_countmsg_receivemsql_dbname"
+ "msql_dropdbmsql_resultmssql_closemssql_query"
+ "muscat_givemysql_closemysql_errnomysql_error"
+ "mysql_querynatcasesortncurses_endncurses_raw"
+ "nl_langinfoocicollsizeocicolltrimocifreedesc"
+ "ocirollbackocirowcountodbc_commitodbc_cursor"
+ "odbc_resultodbc_tablesora_numcolsora_numrows"
+ "pdf_curvetopdf_endpathpdf_restorepdf_setdash"
+ "pdf_setflatpdf_setfontpdf_setgraypdf_show_xy"
+ "pg_end_copypg_last_oidpg_lo_closepg_lo_write"
+ "pg_num_rowspg_pconnectpg_put_lineposix_times"
+ "posix_unamerecode_filesem_acquiresem_release"
+ "sesam_queryshm_get_varshm_put_varshmop_close"
+ "shmop_writeshow_sourcesnmpwalkoidsocket_bind"
+ "socket_readsocket_recvsocket_sendsql_regcase"
+ "str_replacestr_shufflestrncasecmpswf_setfont"
+ "swfgradientunserializexslt_createyaz_addinfo"
+ "yaz_connectyaz_elementyaz_present",
11,1);

() = define_keywords_n ($1,
"array_filterarray_reducearray_search"
+ "array_splicearray_uniquearray_valuesaspell_check"
+ "base_convertbzdecompressccvs_commandccvs_reverse"
+ "class_existscpdf_curvetocpdf_newpathcpdf_restore"
+ "cpdf_rlinetocpdf_rmovetocpdf_setdashcpdf_setflat"
+ "cpdf_setgraycpdf_show_xyctype_xdigitcurl_getinfo"
+ "curl_versioncyrus_unbinddba_firstkeydba_handlers"
+ "dba_optimizedbase_createdbplus_chdirdbplus_close"
+ "dbplus_errnodbplus_firstdbplus_flushdbplus_rkeys"
+ "dbplus_ropendebugger_offdio_truncateereg_replace"
+ "fbsql_commitfbsql_resultfdf_get_filefdf_set_file"
+ "func_get_arggetimagesizegettimeofdaygmp_divexact"
+ "gmp_legendregmp_popcountgzuncompressheaders_sent"
+ "htmlentitieshw_getobjecthw_getremotehw_api->copy"
+ "hw_api->findhw_api->infohw_api->linkhw_api->lock"
+ "hw_api->movehw_api->useribase_commitibase_errmsg"
+ "ifx_errormsgifx_get_blobifx_get_charifx_getsqlca"
+ "ifx_num_rowsifx_pconnectimagecoloratimagedestroy"
+ "imageellipseimagepolygonimagesettileimagettfbbox"
+ "imagettftextimap_expungeimap_headersimap_num_msg"
+ "include_onceingres_closeingres_queryis_writeable"
+ "ldap_compareldap_connectldap_mod_addldap_mod_del"
+ "mb_parse_strmb_send_mailmcal_expungemcve_adduser"
+ "mcve_chngpwdmcve_connectmcve_delusermcve_getcell"
+ "mcve_monitormcve_numrowsmcve_preauthmcve_text_cv"
+ "money_formatmsession_getmsession_incmsession_set"
+ "msql_connectmsql_drop_dbmsql_listdbsmsql_numrows"
+ "msql_regcasemssql_resultmuscat_closemuscat_setup"
+ "mysql_resultncurses_beepncurses_bkgdncurses_echo"
+ "ncurses_inchncurses_initncurses_movencurses_nonl"
+ "ncurses_putpncurses_scrlnotes_searchnotes_unread"
+ "ob_end_cleanob_end_flushob_get_levelob_gzhandler"
+ "ocifetchintoocinewcursorodbc_binmodeodbc_columns"
+ "odbc_connectodbc_executeodbc_prepareopenssl_open"
+ "openssl_sealopenssl_signora_commitonora_rollback"
+ "ovrimos_execpcntl_signalpdf_add_notepdf_end_page"
+ "pdf_findfontpdf_get_fontpdf_open_gifpdf_open_pdi"
+ "pdf_open_pngpdf_set_fontpdf_set_infopdf_setcolor"
+ "pg_copy_frompg_fetch_allpg_fetch_rowpg_field_num"
+ "pg_lo_createpg_lo_exportpg_lo_importpg_lo_unlink"
+ "pg_meta_dataposix_getcwdposix_getgidposix_getpid"
+ "posix_getsidposix_getuidposix_isattyposix_mkfifo"
+ "posix_setgidposix_setsidposix_setuidpreg_replace"
+ "printer_listprinter_openpspell_checkrawurldecode"
+ "rawurlencoderequire_oncesesam_commitsession_name"
+ "shmop_deletesimilar_textsnmprealwalksocket_close"
+ "socket_readvsocket_writestripslashessubstr_count"
+ "swf_addcolorswf_endshapeswf_fontsizeswf_getframe"
+ "swf_mulcolorswf_openfileswf_posroundswf_setframe"
+ "swf_shapearcswf_viewportswftextfieldsybase_close"
+ "sybase_queryudm_cat_listudm_cat_pathudm_free_res"
+ "xslt_processxslt_set_logyaz_ccl_confyaz_database"
+ "zend_version",
12,1);

() = define_keywords_n ($1,
"apache_setenvarray_reversearray_unshift"
+ "cpdf_end_textcpdf_finalizecpdf_set_fontcyrus_connect"
+ "dbplus_rquerydbplus_updatedio_tcsetattrdiskfreespace"
+ "eregi_replacefbsql_connectfbsql_drop_dbfbsql_stop_db"
+ "fdf_get_valuefdf_set_flagsfdf_set_valuefunc_get_args"
+ "func_num_argsget_meta_tagsgetallheadersgethostbyaddr"
+ "gethostbynamegetservbynamegetservbyportgregoriantojd"
+ "hw_getanchorshw_getandlockhw_getparentshw_getrellink"
+ "hw_api_objectibase_connectibase_executeibase_prepare"
+ "ibase_timefmtifx_copy_blobifx_fetch_rowifx_free_blob"
+ "ifx_free_charimagecolorsetimageloadfontimagesetbrush"
+ "imagesetpixelimagesetstyleimagestringupimap_listscan"
+ "imap_undeleteingres_commitircg_pconnectircg_set_file"
+ "is_executablejdtogregorianmb_ereg_matchmb_http_input"
+ "mb_strimwidthmb_strtolowermb_strtouppermcve_edituser"
+ "mcve_initconnmcve_overridemcve_text_avsmcve_transnew"
+ "method_existsming_setscalemsession_findmsession_list"
+ "msession_lockmsession_uniqmsg_get_queuemsg_set_queue"
+ "msql_createdbmsql_fieldlenmsql_list_dbsmsql_num_rows"
+ "msql_pconnectmsql_selectdbmssql_connectmssql_execute"
+ "mt_getrandmaxmysql_connectmysql_db_namemysql_drop_db"
+ "ncurses_addchncurses_clearncurses_delchncurses_erase"
+ "ncurses_flashncurses_getchncurses_hlinencurses_insch"
+ "ncurses_instrncurses_keyokncurses_mvcurncurses_napms"
+ "ncurses_norawncurses_vlinenotes_copy_dbnotes_drop_db"
+ "notes_versionnumber_formatob_get_lengthob_get_status"
+ "ocibindbynameocicollappendocicollassignocicolumnname"
+ "ocicolumnsizeocicolumntypeocifreecursorodbc_errormsg"
+ "odbc_num_rowsodbc_pconnectodbc_rollbackora_commitoff"
+ "ora_errorcodeora_getcolumnovrimos_closepcntl_waitpid"
+ "pdf_close_pdipdf_closepathpdf_get_valuepdf_open_file"
+ "pdf_open_jpegpdf_open_tiffpdf_set_valuepdf_setmatrix"
+ "pdf_translatepfpro_cleanuppfpro_processpfpro_version"
+ "pg_field_namepg_field_sizepg_field_typepg_get_notify"
+ "pg_get_resultpg_last_errorpg_num_fieldspg_send_query"
+ "php_logo_guidphp_sapi_nameposix_ctermidposix_getegid"
+ "posix_geteuidposix_getpgidposix_getpgrpposix_getppid"
+ "posix_setegidposix_seteuidposix_setpgidposix_ttyname"
+ "printer_abortprinter_closeprinter_writereadline_info"
+ "recode_stringsesam_connectsesam_execimmsession_start"
+ "session_unsetsocket_acceptsocket_createsocket_listen"
+ "socket_selectsocket_sendtosocket_writevstream_select"
+ "stripcslashesstrnatcasecmpswf_closefileswf_endbutton"
+ "swf_endsymbolswf_fontslantswf_polarviewswf_popmatrix"
+ "swf_showframeswf_textwidthswf_translatesybase_result"
+ "token_get_alltrigger_errorwddx_add_varsxmlrpc_decode"
+ "xmlrpc_encodexslt_set_baseyaz_ccl_parseyaz_itemorder"
+ "yp_err_string",
13,1);

() = define_keywords_n ($1,
"aggregate_infoaspell_suggest"
+ "assert_optionsbindtextdomaincall_user_func"
+ "ccvs_textvalueclearstatcachecpdf_closepath"
+ "cpdf_page_initcpdf_set_titlecpdf_translate"
+ "crack_opendictcybercash_decrcybercash_encr"
+ "dbplus_errcodedbplus_getlockdbplus_lockrel"
+ "dbplus_rchpermdbplus_rcreatedbplus_resolve"
+ "dbplus_rrenamedbplus_runlinkdbplus_savepos"
+ "dbplus_tremovedns_get_recorddomxml_new_doc"
+ "domxml_versiondomxml_xmltreeescapeshellarg"
+ "escapeshellcmdexif_imagetypeexif_read_data"
+ "exif_thumbnailfbsql_databasefbsql_db_query"
+ "fbsql_hostnamefbsql_list_dbsfbsql_num_rows"
+ "fbsql_passwordfbsql_pconnectfbsql_rollback"
+ "fbsql_start_dbfbsql_usernamefbsql_warnings"
+ "fdf_get_statusfdf_set_statusftp_get_option"
+ "ftp_set_optionget_class_varsgethostbynamel"
+ "getprotobynamegmp_prob_primehighlight_file"
+ "hw_childrenobjhw_docbyanchorhw_getusername"
+ "hw_setlinkroothw_api->dbstathw_api->dcstat"
+ "hw_api->ftstathw_api->hwstathw_api->insert"
+ "hw_api_contenthw_api->objecthw_api->remove"
+ "hw_api->unlockibase_blob_addibase_blob_get"
+ "ibase_pconnectibase_rollbackifx_fieldtypes"
+ "ifx_nullformatifx_num_fieldsimagecopymerge"
+ "imagefilledarcimagefontwidthimageinterlace"
+ "imagerectangleimap_fetchbodyimap_get_quota"
+ "imap_mail_copyimap_mail_moveimap_set_quota"
+ "imap_subscribeingres_connectis_subclass_of"
+ "ldap_start_tlsmb_ereg_searchmb_http_output"
+ "mcrypt_decryptmcrypt_encryptmcrypt_generic"
+ "mcve_getheadermcve_liststatsmcve_listusers"
+ "mcve_text_codemcve_transsendmsession_count"
+ "msg_stat_queuemsql_create_dbmsql_data_seek"
+ "msql_fetch_rowmsql_fieldnamemsql_fieldtype"
+ "msql_numfieldsmsql_select_dbmsql_tablename"
+ "mssql_num_rowsmssql_pconnectmysql_db_query"
+ "mysql_list_dbsmysql_num_rowsmysql_pconnect"
+ "ncurses_addstrncurses_attronncurses_border"
+ "ncurses_cbreakncurses_delwinncurses_filter"
+ "ncurses_has_icncurses_has_ilncurses_insstr"
+ "ncurses_mvinchncurses_newwinncurses_noecho"
+ "ocicollgetelemocicolumnscaleocisavelobfile"
+ "ocisetprefetchodbc_close_allodbc_fetch_row"
+ "odbc_field_lenodbc_field_numodbc_setoption"
+ "openssl_verifyora_columnnameora_columnsize"
+ "ora_columntypeora_fetch_intoovrimos_commit"
+ "ovrimos_cursorovrimos_resultparse_ini_file"
+ "pcntl_wstopsigpcntl_wtermsigpdf_begin_page"
+ "pdf_get_bufferpdf_open_ccittpdf_open_image"
+ "pdf_setlinecappdf_show_boxedpg_fetch_array"
+ "pg_fetch_assocpg_free_resultpg_last_notice"
+ "pg_lo_read_allpg_result_seekposix_getgrgid"
+ "posix_getgrnamposix_getloginposix_getpwnam"
+ "posix_getpwuidpreg_match_allpspell_suggest"
+ "read_exif_datasesam_errormsgsesam_rollback"
+ "sesam_seek_rowsession_decodesession_encode"
+ "set_time_limitshm_remove_varsocket_connect"
+ "socket_recvmsgsocket_sendmsgstr_word_count"
+ "substr_replaceswf_actionplayswf_actionstop"
+ "swf_definefontswf_definelineswf_definepoly"
+ "swf_definerectswf_definetextswf_labelframe"
+ "swf_pushmatrixswf_startshapeswfdisplayitem"
+ "sybase_connectudm_free_agentvpopmail_error"
+ "xml_set_objectyaz_get_optionyaz_set_option"
+ "zend_logo_guidzip_entry_namezip_entry_open"
+ "zip_entry_read",
14,1);

() = define_keywords_n ($1,
"array_intersectarray_multisort"
+ "cpdf_begin_textcpdf_setlinecapcrack_closedict"
+ "create_functiondbase_numfieldsdbplus_freelock"
+ "dbplus_rcrtlikedbplus_setindexdbplus_unselect"
+ "dbplus_xlockreldebug_backtracedisk_free_space"
+ "domnode->prefixdomxml_open_memerror_reporting"
+ "fbsql_create_dbfbsql_data_seekfbsql_db_status"
+ "fbsql_fetch_rowfbsql_field_lenfbsql_insert_id"
+ "fbsql_read_blobfbsql_read_clobfbsql_select_db"
+ "fbsql_tablenamefdf_get_versionfdf_open_string"
+ "fdf_save_stringfdf_set_versionftp_nb_continue"
+ "ftp_ssl_connectfunction_existsget_object_vars"
+ "hw_changeobjecthw_deleteobjecthw_getchildcoll"
+ "hw_insertobjecthw_modifyobjecthw_new_document"
+ "hw_pipedocumenthw_api->checkinhw_api->content"
+ "hw_api->parentshw_api->replaceibase_blob_echo"
+ "ibase_blob_infoibase_blob_openibase_fetch_row"
+ "ifx_create_blobifx_create_charifx_free_result"
+ "ifx_update_blobifx_update_charifxus_free_slob"
+ "ifxus_open_slobifxus_read_slobifxus_seek_slob"
+ "ifxus_tell_slobimagecolorexactimagedashedline"
+ "imagefontheightimagepscopyfontimagepsfreefont"
+ "imagepsloadfontimap_bodystructimap_headerinfo"
+ "imap_last_errorimap_num_recentingres_num_rows"
+ "ingres_pconnectingres_rollbackircg_disconnect"
+ "ircg_ignore_addircg_ignore_delircg_set_on_die"
+ "ldap_explode_dnldap_get_optionldap_get_values"
+ "ldap_next_entryldap_set_optionmb_convert_case"
+ "mb_convert_kanamb_detect_ordermb_ereg_replace"
+ "mb_substr_countmcal_date_validmcal_event_init"
+ "mcal_time_validmcve_adduserargmcve_enableuser"
+ "mcve_getuserargmcve_initenginemcve_numcolumns"
+ "mcve_returncodemcve_settimeoutmcve_transparam"
+ "msession_createmsession_pluginmsession_unlock"
+ "msql_field_seekmsql_fieldflagsmsql_fieldtable"
+ "msql_freeresultmsql_listfieldsmsql_listtables"
+ "msql_num_fieldsmssql_data_seekmssql_fetch_row"
+ "mssql_select_dbmysql_create_dbmysql_data_seek"
+ "mysql_fetch_rowmysql_field_lenmysql_insert_id"
+ "mysql_select_dbmysql_tablenamemysql_thread_id"
+ "ncurses_addnstrncurses_attroffncurses_attrset"
+ "ncurses_bkgdsetncurses_has_keyncurses_mvaddch"
+ "ncurses_mvdelchncurses_mvgetchncurses_mvhline"
+ "ncurses_mvvlinencurses_qiflushncurses_refresh"
+ "ncurses_resettyncurses_savettyncurses_scr_set"
+ "ncurses_timeoutncurses_ungetchncurses_use_env"
+ "ncurses_vidattrnotes_create_dbnotes_find_note"
+ "notes_list_msgsnotes_mark_readob_get_contents"
+ "ocicolumnisnullocidefinebynameodbc_autocommit"
+ "odbc_fetch_intoodbc_field_nameodbc_field_type"
+ "odbc_num_fieldsodbc_proceduresodbc_result_all"
+ "odbc_statisticsopenssl_csr_newovrimos_connect"
+ "ovrimos_executeovrimos_preparepcntl_wifexited"
+ "pdf_add_outlinepdf_add_pdflinkpdf_add_weblink"
+ "pdf_attach_filepdf_close_imagepdf_end_pattern"
+ "pdf_fill_strokepdf_place_imagepdf_set_leading"
+ "pdf_setlinejoinpdf_setpolydashpdf_setrgbcolor"
+ "pdf_stringwidthpg_cancel_querypg_escape_bytea"
+ "pg_fetch_objectpg_fetch_resultpg_field_prtlen"
+ "pg_result_errorposix_getgroupsposix_getrlimit"
+ "printer_end_docsesam_fetch_rowsession_destroy"
+ "set_file_buffersocket_recvfromsocket_shutdown"
+ "socket_strerrorswf_enddoactionswf_getfontinfo"
+ "swf_onconditionswf_perspectiveswf_placeobject"
+ "swf_shapelinetoswf_shapemovetoswf_startbutton"
+ "swf_startsymbolsybase_num_rowssybase_pconnect"
+ "udm_alloc_agentudm_api_versionudm_open_stored"
+ "version_comparevpopmail_passwdwddx_packet_end"
+ "xml_parser_freexmlrpc_get_typexmlrpc_set_type"
+ "yaz_scan_resultzip_entry_close",
15,1);

() = define_keywords_n ($1,
"aggregation_infoarray_diff_assoc"
+ "array_key_existsaspell_check_rawcall_user_method"
+ "com_load_typelibcpdf_add_outlinecpdf_fill_stroke"
+ "cpdf_import_jpegcpdf_rotate_textcpdf_set_creator"
+ "cpdf_set_leadingcpdf_set_subjectcpdf_setlinejoin"
+ "cpdf_setrgbcolorcpdf_stringwidthcybermut_testmac"
+ "dbase_add_recorddbase_get_recorddbase_numrecords"
+ "dbplus_getuniquedbplus_rcrtexactdbplus_rsecindex"
+ "dbplus_unlockreldisk_total_spacedns_check_record"
+ "domxml_open_fileextension_loadedfbsql_autocommit"
+ "fbsql_field_namefbsql_field_seekfbsql_field_type"
+ "fbsql_num_fieldsfdf_add_templatefdf_get_encoding"
+ "fdf_set_encodingfilepro_retrievefilepro_rowcount"
+ "get_current_userget_defined_varsget_parent_class"
+ "getprotobynumberhighlight_stringhtmlspecialchars"
+ "hw_document_sizehw_free_documenthw_getanchorsobj"
+ "hw_getparentsobjhw_incollectionshw_insertanchors"
+ "hw_api_attributehw_api->checkouthw_api->children"
+ "hw_api->identifyhw_api->userlistibase_blob_close"
+ "ibase_field_infoibase_free_queryibase_num_fields"
+ "ifxus_close_slobifxus_write_slobimagecolorstotal"
+ "imagecopyresizedimagepalettecopyimagepsslantfont"
+ "imap_fetchheaderimap_listmailboximap_scanmailbox"
+ "imap_unsubscribeingres_fetch_rowircg_html_encode"
+ "ircg_set_currentis_uploaded_fileldap_first_entry"
+ "ldap_free_resultldap_get_entriesldap_mod_replace"
+ "mb_eregi_replacemcal_day_of_weekmcal_day_of_year"
+ "mcal_fetch_eventmcal_list_alarmsmcal_list_events"
+ "mcal_store_eventmcrypt_create_ivmcve_checkstatus"
+ "mcve_deletetransmcve_destroyconnmcve_disableuser"
+ "mcve_setblockingmcve_setdropfilemdecrypt_generic"
+ "msession_connectmsession_destroymsession_getdata"
+ "msession_listvarmsession_randstrmsession_setdata"
+ "msession_timeoutmsg_remove_queuemsql_fetch_array"
+ "msql_fetch_fieldmsql_free_resultmsql_list_fields"
+ "msql_list_tablesmssql_field_namemssql_field_seek"
+ "mssql_field_typemssql_num_fieldsmuscat_setup_net"
+ "mysql_field_namemysql_field_seekmysql_field_type"
+ "mysql_num_fieldsncurses_addchstrncurses_baudrate"
+ "ncurses_clrtobotncurses_clrtoeolncurses_curs_set"
+ "ncurses_deletelnncurses_doupdatencurses_echochar"
+ "ncurses_flushinpncurses_getmousencurses_insdelln"
+ "ncurses_insertlnncurses_isendwinncurses_killchar"
+ "ncurses_longnamencurses_mvaddstrncurses_nocbreak"
+ "ncurses_scr_dumpncurses_scr_initncurses_slk_attr"
+ "ncurses_slk_initncurses_standendncurses_standout"
+ "ncurses_termnamencurses_wrefreshnotes_nav_create"
+ "ob_iconv_handlerocicolumntyperawocifreestatement"
+ "ociinternaldebugocinewcollectionocinewdescriptor"
+ "ociserverversionocistatementtypeodbc_data_source"
+ "odbc_fetch_arrayodbc_field_scaleodbc_foreignkeys"
+ "odbc_free_resultodbc_gettypeinfoodbc_longreadlen"
+ "odbc_next_resultodbc_primarykeysopenssl_csr_sign"
+ "openssl_free_keyopenssl_pkey_newovrimos_num_rows"
+ "ovrimos_rollbackpcntl_wifstoppedpdf_add_bookmark"
+ "pdf_end_templatepdf_get_fontnamepdf_get_fontsize"
+ "pdf_initgraphicspdf_set_durationpdf_set_text_pos"
+ "pdf_setgray_fillpdf_setlinewidthpg_affected_rows"
+ "pg_escape_stringpg_field_is_nullpg_result_status"
+ "printer_draw_bmpprinter_draw_pieprinter_end_page"
+ "sesam_diagnosticsesam_disconnectsesam_field_name"
+ "sesam_num_fieldssession_readonlysession_register"
+ "socket_iovec_addsocket_iovec_setswf_actiongeturl"
+ "swf_definebitmapswf_fonttrackingswf_modifyobject"
+ "swf_removeobjectswf_shapecurvetoswf_shapefilloff"
+ "sybase_data_seeksybase_fetch_rowsybase_select_db"
+ "udm_check_storedudm_close_storedwddx_deserialize"
+ "xml_error_stringxptr_new_context",
16,1);

() = define_keywords_n ($1,
"aggregate_methodsapache_lookup_uri"
+ "cal_days_in_monthconnection_statuscpdf_save_to_file"
+ "cpdf_set_keywordscpdf_set_text_poscpdf_setgray_fill"
+ "cpdf_setlinewidthdbplus_freerlocksdbplus_restorepos"
+ "dbplus_xunlockreldbx_escape_stringdomnode->set_name"
+ "fbsql_change_userfbsql_create_blobfbsql_create_clob"
+ "fbsql_fetch_arrayfbsql_fetch_assocfbsql_fetch_field"
+ "fbsql_field_flagsfbsql_field_tablefbsql_free_result"
+ "fbsql_list_fieldsfbsql_list_tablesfbsql_next_result"
+ "file_get_contentsfilepro_fieldnamefilepro_fieldtype"
+ "get_class_methodsget_resource_typehw_docbyanchorobj"
+ "hw_insertdocumenthw_api->srcsofdstibase_blob_cancel"
+ "ibase_blob_createibase_blob_importibase_free_result"
+ "ifx_affected_rowsifx_byteasvarcharifx_textasvarchar"
+ "ifxus_create_slobignore_user_abortimagecolorclosest"
+ "imagecolorresolveimagecreatefromgdimagefilltoborder"
+ "imagegammacorrectimagepsencodefontimagepsextendfont"
+ "imagesetthicknessimap_getmailboxesimap_mail_compose"
+ "imap_setflag_fullingres_autocommitingres_field_name"
+ "ingres_field_typeingres_num_fieldsircg_channel_mode"
+ "ircg_get_usernameldap_parse_resultmb_output_handler"
+ "mb_regex_encodingmcal_append_eventmcal_date_compare"
+ "mcal_delete_eventmcal_is_leap_yearmcal_week_of_year"
+ "mcrypt_list_modesmcve_getcellbynummcve_getuserparam"
+ "mcve_returnstatusmcve_transinqueuemime_content_type"
+ "msql_fetch_objectmssql_fetch_arraymssql_fetch_assoc"
+ "mssql_fetch_batchmssql_fetch_fieldmssql_free_result"
+ "mssql_guid_stringmssql_next_resultmysql_change_user"
+ "mysql_fetch_arraymysql_fetch_assocmysql_fetch_field"
+ "mysql_field_flagsmysql_field_tablemysql_free_result"
+ "mysql_list_fieldsmysql_list_tablesncurses_addchnstr"
+ "ncurses_color_setncurses_erasecharncurses_halfdelay"
+ "ncurses_init_pairncurses_mousemaskncurses_mvaddnstr"
+ "ncurses_mvwaddstrncurses_noqiflushncurses_slk_clear"
+ "ncurses_slk_colorncurses_slk_touchncurses_termattrs"
+ "ncurses_typeaheadnotes_create_notenotes_header_info"
+ "notes_mark_unreadob_implicit_flushocicollassignelem"
+ "ocifetchstatementocifreecollectionociwritelobtofile"
+ "odbc_fetch_objectovrimos_fetch_rowovrimos_field_len"
+ "ovrimos_field_numpcntl_wexitstatuspcntl_wifsignaled"
+ "pdf_add_locallinkpdf_add_thumbnailpdf_begin_pattern"
+ "pdf_continue_textpdf_get_parameterpdf_get_pdi_value"
+ "pdf_makespotcolorpdf_open_pdi_pagepdf_set_parameter"
+ "pdf_set_text_risepdf_setmiterlimitpfpro_process_raw"
+ "pg_unescape_byteaprinter_create_dcprinter_delete_dc"
+ "printer_draw_lineprinter_draw_textprinter_start_doc"
+ "pspell_new_configsesam_fetch_arraysesam_field_array"
+ "sesam_free_resultsession_save_pathset_error_handler"
+ "socket_get_optionsocket_get_statussocket_iovec_free"
+ "socket_last_errorsocket_set_optionswf_getbitmapinfo"
+ "swf_startdoactionsybase_field_seeksybase_num_fields"
+ "udm_check_charsetudm_get_doc_countudm_get_res_field"
+ "udm_get_res_paramvpopmail_add_uservpopmail_del_user"
+ "wddx_packet_startxml_parser_createxpath_new_context"
+ "xslt_set_encoding",
17,1);

() = define_keywords_n ($1,
"array_count_valuesconnection_aborted"
+ "connection_timeoutconvert_cyr_stringcpdf_continue_text"
+ "cpdf_finalize_pagecpdf_output_buffercpdf_set_text_rise"
+ "cpdf_setmiterlimitcyrus_authenticatedbplus_undoprepare"
+ "domattribute->namedomnode->dump_nodedomnode->node_name"
+ "domnode->node_typefbsql_fetch_objectfbsql_set_lob_mode"
+ "fdf_get_attachmentfilepro_fieldcountfilepro_fieldwidth"
+ "get_included_filesget_required_filesgmp_perfect_square"
+ "html_entity_decodehw_connection_infohw_getchildcollobj"
+ "hw_getchilddoccollhw_getsrcbydestobjhw_output_document"
+ "hw_api->dstanchorshw_api->srcanchorsibase_fetch_object"
+ "iconv_get_encodingiconv_set_encodingifx_htmltbl_result"
+ "imagealphablendingimagecolorallocateimagecopymergegray"
+ "imagecopyresampledimagecreatefromgifimagecreatefrompng"
+ "imagecreatefromxbmimagecreatefromxpmimagefilledellipse"
+ "imagefilledpolygonimap_createmailboximap_deletemailbox"
+ "imap_get_quotarootimap_getsubscribedimap_renamemailbox"
+ "ingres_fetch_arrayingres_field_scaleircg_is_conn_alive"
+ "ldap_count_entriesmailparse_msg_freemb_detect_encoding"
+ "mb_ereg_search_posmcal_days_in_monthmcal_event_set_end"
+ "mcrypt_generic_endmcrypt_get_iv_sizemcrypt_module_open"
+ "mcve_destroyenginemcve_initusersetupmcve_responseparam"
+ "mcve_transactioncvmcve_transactionidmcve_verifysslcert"
+ "ming_useswfversionmove_uploaded_filemsession_get_array"
+ "msession_set_arraymsql_affected_rowsmssql_fetch_object"
+ "mssql_field_lengthmysql_fetch_objectncurses_define_key"
+ "ncurses_has_colorsncurses_init_colorncurses_mvaddchstr"
+ "ncurses_slk_attronncurses_ungetmouseocicolumnprecision"
+ "openssl_csr_exportovrimos_fetch_intoovrimos_field_name"
+ "ovrimos_field_typeovrimos_num_fieldsovrimos_result_all"
+ "pdf_add_annotationpdf_add_launchlinkpdf_begin_template"
+ "pdf_close_pdi_pagepdf_place_pdi_pagepdf_set_info_title"
+ "pdf_setgray_strokepg_client_encodingpg_connection_busy"
+ "printer_create_penprinter_delete_penprinter_draw_chord"
+ "printer_get_optionprinter_select_penprinter_set_option"
+ "printer_start_pagepspell_config_modepspell_config_repl"
+ "sesam_fetch_resultsession_unregistersocket_clear_error"
+ "socket_create_pairsocket_getpeernamesocket_getsockname"
+ "socket_iovec_allocsocket_iovec_fetchsocket_set_timeout"
+ "stream_get_filtersstream_set_timeoutswf_shapefillsolid"
+ "swf_shapelinesolidswfbutton_keypresssybase_fetch_array"
+ "sybase_fetch_fieldsybase_free_resultvpopmail_alias_add"
+ "vpopmail_alias_delvpopmail_alias_getvpopmail_auth_user"
+ "xml_get_error_codezip_entry_filesize",
18,1);

() = define_keywords_n ($1,
"cpdf_add_annotationcpdf_set_action_url"
+ "cpdf_setgray_strokedbase_delete_recorddbplus_freealllocks"
+ "domattribute->valuedomelement->tagnamedomnode->attributes"
+ "domnode->clone_nodedomnode->last_childdomnode->node_value"
+ "fbsql_affected_rowsfbsql_fetch_lengthsfdf_next_field_name"
+ "get_extension_funcshw_document_bodytaghw_document_content"
+ "hw_getobjectbyqueryhw_api_error->counthw_api_reason->type"
+ "ifx_blobinfile_modeifx_fieldpropertiesimagecolorsforindex"
+ "imagecreatefromjpegimagecreatefromwbmpimap_clearflag_full"
+ "imap_fetch_overviewimap_fetchstructureimap_listsubscribed"
+ "imap_mailboxmsginfoingres_fetch_objectingres_field_length"
+ "ldap_get_attributesldap_get_values_lenldap_next_attribute"
+ "ldap_next_referencemailparse_msg_parsemb_convert_encoding"
+ "mb_ereg_search_initmb_ereg_search_regsmcrypt_generic_init"
+ "mcrypt_get_key_sizemcrypt_module_closemcve_deleteresponse"
+ "mcve_maxconntimeoutmcve_transactionavsmhash_get_hash_name"
+ "msession_disconnectmssql_rows_affectedmysql_affected_rows"
+ "mysql_escape_stringmysql_fetch_lengthsmysql_get_host_info"
+ "ncurses_mvaddchnstrncurses_scr_restorencurses_slk_attroff"
+ "ncurses_slk_attrsetncurses_slk_refreshncurses_slk_restore"
+ "ncurses_start_colorodbc_specialcolumnsopenssl_pkey_export"
+ "ovrimos_free_resultovrimos_longreadlenpdf_get_image_width"
+ "pdf_open_image_filepdf_set_border_dashpdf_set_info_author"
+ "pdf_set_text_matrixpg_connection_resetprinter_create_font"
+ "printer_delete_fontprinter_draw_elipseprinter_select_font"
+ "pspell_new_personalsesam_affected_rowssession_module_name"
+ "session_write_closesocket_iovec_deletesocket_set_blocking"
+ "socket_set_nonblockstream_get_wrappersstream_set_blocking"
+ "swf_actiongotoframeswf_actiongotolabelswf_actionnextframe"
+ "swf_actionprevframeswf_actionsettargetswf_addbuttonrecord"
+ "sybase_fetch_objectudm_set_agent_paramvpopmail_add_domain"
+ "vpopmail_del_domainwddx_serialize_vars",
19,1);

() = define_keywords_n ($1,
"aggregate_properties"
+ "call_user_func_arraycpdf_set_text_matrix"
+ "crack_getlastmessagedbase_replace_record"
+ "domdocument->doctypedomnode->child_nodes"
+ "domnode->first_childdomnode->get_content"
+ "domnode->parent_nodedomnode->set_content"
+ "domnode->unlink_nodefdf_set_target_frame"
+ "get_declared_classesget_magic_quotes_gpc"
+ "hw_getremotechildrenhw_api_content->read"
+ "hw_api_error->reasonhw_api->insertanchor"
+ "hw_api_object->counthw_api_object->title"
+ "hw_api_object->valueimagecolorclosesthwb"
+ "imagecolordeallocateimagecolorexactalpha"
+ "imagecreatetruecolorimagefilledrectangle"
+ "ircg_fetch_error_msgircg_nickname_escape"
+ "ldap_first_attributeldap_first_reference"
+ "ldap_parse_referenceldap_set_rebind_proc"
+ "mailparse_msg_createmb_convert_variables"
+ "mb_decode_mimeheadermb_encode_mimeheader"
+ "mb_internal_encodingmb_regex_set_options"
+ "mcal_create_calendarmcal_delete_calendar"
+ "mcal_event_set_alarmmcal_event_set_class"
+ "mcal_event_set_startmcal_event_set_title"
+ "mcal_next_recurrencemcal_rename_calendar"
+ "mcrypt_enc_self_testmcve_connectionerror"
+ "mcve_deleteusersetupmcve_transactionauth"
+ "mcve_transactionitemmcve_transactiontext"
+ "mhash_get_block_sizemssql_free_statement"
+ "mysql_get_proto_infomysql_list_processes"
+ "ncurses_delay_outputodbc_field_precision"
+ "odbc_tableprivilegesopenssl_error_string"
+ "pdf_closepath_strokepdf_get_image_height"
+ "pdf_get_majorversionpdf_get_minorversion"
+ "pdf_set_border_colorpdf_set_border_style"
+ "pdf_set_char_spacingpdf_set_info_creator"
+ "pdf_set_info_subjectpdf_set_word_spacing"
+ "pdf_setrgbcolor_fillpg_connection_status"
+ "printer_create_brushprinter_delete_brush"
+ "printer_select_brushpspell_clear_session"
+ "pspell_config_createpspell_config_ignore"
+ "pspell_save_wordlistreadline_add_history"
+ "sesam_settransactionsession_cache_expire"
+ "snmp_get_quick_printsnmp_set_quick_print"
+ "socket_create_listenstream_filter_append"
+ "stream_get_meta_datasybase_affected_rows"
+ "udm_add_search_limitudm_free_ispell_data"
+ "udm_load_ispell_datawddx_serialize_value"
+ "xml_parser_create_nsxmlrpc_server_create"
+ "xslt_set_sax_handler",
20,1);

() = define_keywords_n ($1,
"array_change_key_case"
+ "array_intersect_assocarray_merge_recursive"
+ "cpdf_closepath_strokecpdf_set_char_spacing"
+ "cpdf_set_current_pagecpdf_set_word_spacing"
+ "cpdf_setrgbcolor_filldomdocument->dump_mem"
+ "domdocument->xincludedomdocumenttype->name"
+ "domnode->append_childdomnode->next_sibling"
+ "domnode->remove_childdomnode->replace_node"
+ "fbsql_set_transactionget_defined_constants"
+ "get_defined_functionsget_loaded_extensions"
+ "hw_getchilddoccollobjhw_api_attribute->key"
+ "hw_api_object->assignhw_api_object->insert"
+ "hw_api_object->removeimagecolortransparent"
+ "imagecreatefromstringingres_field_nullable"
+ "mb_ereg_search_getposmb_ereg_search_setpos"
+ "mcrypt_generic_deinitmcrypt_get_block_size"
+ "mcve_iscommadelimitedmcve_transactionbatch"
+ "mcve_transactionssentmcve_verifyconnection"
+ "mysql_client_encodingmysql_get_client_info"
+ "mysql_get_server_infoncurses_def_prog_mode"
+ "ncurses_mouseintervalodbc_columnprivileges"
+ "odbc_procedurecolumnsopenssl_get_publickey"
+ "pdf_get_pdi_parameterpdf_open_memory_image"
+ "pdf_set_horiz_scalingpdf_set_info_keywords"
+ "php_ini_scanned_filespreg_replace_callback"
+ "pspell_add_to_sessionreadline_list_history"
+ "readline_read_historyrestore_error_handler"
+ "session_cache_limitersession_is_registered"
+ "stream_context_createstream_filter_prepend"
+ "xml_parse_into_structxml_parser_get_option"
+ "xml_parser_set_optionxmlrpc_decode_request"
+ "xmlrpc_encode_requestxmlrpc_server_destroy"
+ "xpath_eval_expressionxslt_set_sax_handlers"
+ "yp_get_default_domain",
21,1);

() = define_keywords_n ($1,
"apache_child_terminate"
+ "apache_request_headerscall_user_method_array"
+ "cpdf_set_font_map_filecpdf_set_horiz_scaling"
+ "domdocument->dump_filedomnode->add_namespace"
+ "domnode->insert_beforedomnode->is_blank_node"
+ "domnode->replace_childdomnode->set_namespace"
+ "domxml_xslt_stylesheetfdf_add_doc_javascript"
+ "hw_document_attributeshw_document_setcontent"
+ "hw_getobjectbyqueryobjhw_api->insertdocument"
+ "hw_api->objectbyanchorimagecolorclosestalpha"
+ "imagecolorresolvealphaingres_field_precision"
+ "ircg_nickname_unescapemailparse_msg_get_part"
+ "mailparse_uudecode_allmb_ereg_search_getregs"
+ "mb_preferred_mime_namemcrypt_enc_get_iv_size"
+ "mcrypt_get_cipher_namemcrypt_list_algorithms"
+ "mcve_getcommadelimitedmcve_preauthcompletion"
+ "ming_setcubicthresholdmssql_get_last_message"
+ "mysql_unbuffered_queryncurses_def_shell_mode"
+ "openssl_get_privatekeyopenssl_public_decrypt"
+ "openssl_public_encryptpdf_set_text_rendering"
+ "pdf_setrgbcolor_strokepg_set_client_encoding"
+ "printer_draw_rectangleprinter_draw_roundrect"
+ "pspell_add_to_personalpspell_config_personal"
+ "readline_clear_historyreadline_write_history"
+ "register_tick_functionstream_register_filter"
+ "swf_actionwaitforframevpopmail_add_domain_ex"
+ "vpopmail_alias_get_allvpopmail_del_domain_ex"
+ "xslt_set_error_handler",
22,1);

() = define_keywords_n ($1,
"apache_response_headers"
+ "bind_textdomain_codesetcpdf_place_inline_image"
+ "cpdf_set_page_animationcpdf_set_text_rendering"
+ "cpdf_setrgbcolor_strokecybermut_creerreponsecm"
+ "dbplus_setindexbynumberdefine_syslog_variables"
+ "domattribute->specifieddomnode->append_sibling"
+ "domnode->owner_documentfbsql_database_password"
+ "hw_getobjectbyquerycollhw_api_attribute->value"
+ "hw_api->dstofsrcanchorsimage_type_to_mime_type"
+ "imagecolorallocatealphaimagetruecolortopalette"
+ "imap_mime_header_decodejava_last_exception_get"
+ "mailparse_stream_encodemb_decode_numericentity"
+ "mb_encode_numericentitymb_substitute_character"
+ "mcal_event_set_categorymcrypt_enc_get_key_size"
+ "mcrypt_module_self_testncurses_slk_noutrefresh"
+ "openssl_pkey_get_publicopenssl_private_decrypt"
+ "openssl_private_encryptpspell_config_save_repl"
+ "quoted_printable_decodestream_register_wrapper"
+ "stream_set_write_bufferswf_actiontogglequality"
+ "swf_shapefillbitmapclipswf_shapefillbitmaptile"
+ "sybase_get_last_messageudm_clear_search_limits"
+ "vpopmail_set_user_quotaxml_set_default_handler"
+ "xml_set_element_handlerxslt_set_scheme_handler",
23,1);

() = define_keywords_n ($1,
"domnode->has_attributess"
+ "domnode->has_child_nodesfbsql_get_autostart_info"
+ "get_magic_quotes_runtimehw_api_attribute->values"
+ "hw_api_content->mimetypehw_api->insertcollection"
+ "import_request_variablesmailparse_msg_parse_file"
+ "mcal_event_add_attributemcrypt_enc_is_block_mode"
+ "mcve_parsecommadelimitedmssql_min_error_severity"
+ "mysql_real_escape_stringncurses_can_change_color"
+ "openssl_pkey_get_privatepspell_store_replacement"
+ "session_set_save_handlerset_magic_quotes_runtime"
+ "unregister_tick_functionxslt_set_scheme_handlers"
+ "zip_entry_compressedsize",
24,1);

() = define_keywords_n ($1,
"aggregate_methods_by_list"
+ "cpdf_set_font_directoriesdomdocumenttype->entities"
+ "domelement->get_attributedomelement->has_attribute"
+ "domelement->set_attributedomnode->previous_sibling"
+ "fdf_set_javascript_actionjava_last_exception_clear"
+ "mcal_event_set_recur_nonemcrypt_enc_get_block_size"
+ "mcrypt_enc_get_modes_namepdf_closepath_fill_stroke"
+ "pspell_config_runtogethersession_get_cookie_params"
+ "session_set_cookie_paramsstream_context_set_option"
+ "stream_context_set_paramssybase_min_error_severity"
+ "vpopmail_add_alias_domainvpopmail_alias_del_domain"
+ "xmlrpc_server_call_method",
25,1);

() = define_keywords_n ($1,
"cpdf_closepath_fill_stroke"
+ "cybermut_creerformulairecmdomdocument->html_dump_mem"
+ "domdocumenttype->notationsdomdocumenttype->public_id"
+ "domdocumenttype->system_iddomxml_xslt_stylesheet_doc"
+ "domxsltstylesheet->processfdf_set_submit_form_action"
+ "get_html_translation_tablehw_getobjectbyquerycollobj"
+ "hw_api_reason->descriptionhw_api->setcommitedversion"
+ "mailparse_msg_extract_partmcal_event_set_description"
+ "mcal_event_set_recur_dailymssql_min_message_severity"
+ "ncurses_use_default_colorsncurses_use_extended_names"
+ "openssl_csr_export_to_fileprinter_logical_fontheight"
+ "register_shutdown_functionstream_context_get_options"
+ "sybase_min_client_severitysybase_min_server_severity"
+ "xml_get_current_byte_index",
26,1);

() = define_keywords_n ($1,
"aggregate_methods_by_regexp"
+ "cpdf_set_viewer_preferencesdbase_get_record_with_names"
+ "domdocument->create_commentdomdocument->create_element"
+ "domxml_xslt_stylesheet_filehw_api_object->attreditable"
+ "ircg_lookup_format_messagesmailparse_msg_get_part_data"
+ "mailparse_msg_get_structuremcal_event_set_recur_weekly"
+ "mcal_event_set_recur_yearlymcrypt_module_is_block_mode"
+ "mcve_completeauthorizationsopenssl_pkey_export_to_file"
+ "sybase_min_message_severityxml_get_current_line_number"
+ "zip_entry_compressionmethod",
27,1);

() = define_keywords_n ($1,
"aggregate_properties_by_list"
+ "domelement->remove_attributereadline_completion_function"
+ "vpopmail_add_alias_domain_ex",
28,1);

() = define_keywords_n ($1,
"domdocument->create_attribute"
+ "domdocument->create_text_nodedomdocument->document_element"
+ "ircg_register_format_messagesmcrypt_enc_is_block_algorithm"
+ "ncurses_assume_default_colorsxml_get_current_column_number"
+ "xml_set_notation_decl_handlerxmlrpc_server_register_method",
29,1);

() = define_keywords_n ($1,
"aggregate_properties_by_regexp"
+ "domdocument->create_element_nsdomdocument->get_element_by_id"
+ "domelement->get_attribute_nodedomprocessinginstruction->data"
+ "hw_api_attribute->langdepvaluemcrypt_enc_get_algorithms_name"
+ "xml_set_character_data_handler",
30,1);

() = define_keywords_n ($1,
"cpdf_global_set_document_limits"
+ "mailparse_msg_extract_part_filemcal_fetch_current_stream_event"
+ "mcrypt_module_get_algo_key_size",
31,1);

() = define_keywords_n ($1,
"domdocumenttype->internal_subset"
+ "domprocessinginstruction->targetmcrypt_module_is_block_algorithm"
+ "xmlrpc_parse_method_descriptions",
32,1);

() = define_keywords_n ($1,
"domdocument->create_cdata_section"
+ "mcal_event_set_recur_monthly_mdaymcal_event_set_recur_monthly_wday"
+ "mcrypt_module_get_algo_block_size",
33,1);

() = define_keywords_n ($1,
"domdocument->add_root [deprecated]"
+ "domxsltstylesheet->result_dump_memmcrypt_enc_get_supported_key_sizes"
+ "mcrypt_enc_is_block_algorithm_modexml_set_end_namespace_decl_handler",
34,1);

() = define_keywords_n ($1,
"domelement->get_elements_by_tagname"
+ "domxsltstylesheet->result_dump_filexml_set_external_entity_ref_handler",
35,1);

() = define_keywords_n ($1,
"domdocument->create_entity_reference"
+ "domdocument->get_elements_by_tagnamexml_set_start_namespace_decl_handler"
+ "xml_set_unparsed_entity_decl_handlerxmlrpc_server_add_introspection_data",
36,1);

() = define_keywords_n ($1,
"mcrypt_module_get_supported_key_sizes"
+ "mcrypt_module_is_block_algorithm_mode",
37,1);

() = define_keywords_n ($1,
"mailparse_determine_best_xfer_encoding"
+ "xml_set_processing_instruction_handler",
38,1);

() = define_keywords_n ($1,
"domdocument->create_processing_instruction",
42,1);

() = define_keywords_n ($1,
"xmlrpc_server_register_introspection_callback",
45,1);
%}}}

%!%+
%\function{php_mode}
%\synopsis{php_mode}
%\usage{Void php_mode ();}
%\description
% This is a mode that is dedicated to faciliate the editing of PHP language files.
% It calls the function \var{php_mode_hook} if it is defined. It also manages
% to recognice whetever it is in a php block or in a html block, for those people
% that doesnt seperate function from form ;)
%
% Functions that affect this mode include:
%#v+
%  function:             default binding:
%  php_top_of_function        ESC Ctrl-A
%  php_end_of_function        ESC Ctrl-E
%  php_mark_function          ESC Ctrl-H
%  php_mark_matching          ESC Ctrl-M
%  php_indent_buffer          Ctrl-C Ctrl-B
%  php_insert_class           Ctrl-C Ctrl-C
%  php_insert_function        Ctrl-C Ctrl-F
%  php_insert_bra             {
%  php_insert_ket             }
%  php_insert_colon           :
%  php_format_paragraph       ESC q
%  indent_line                TAB
%  newline_and_indent         RETURN
%  goto_match                 Ctrl-\
%  php_insert_tab             Ctrl-C Ctrl-I
%#v-
% Variables affecting indentation include:
%#v+
% PHP_INDENT
% PHP_BRACE
% PHP_BRA_NEWLINE
% PHP_KET_NEWLINE
% PHP_COLON_OFFSET
% PHP_CONTINUED_OFFSET
% PHP_CLASS_OFFSET
% PHP_Autoinsert_Comments
% PHP_SWITCH_OFFSET
%#v-
% Hooks: \var{php_mode_hook}
%!%-
define php_mode()
{
	variable kmap = "PHP";
	set_mode( kmap, 2 );
	use_keymap( kmap );
	use_syntax_table( kmap );
	set_buffer_hook( "par_sep", "php_paragraph_sep" );
	set_buffer_hook( "indent_hook", "php_indent_region_or_line" );
	set_buffer_hook( "newline_indent_hook", "php_newline_and_indent" ); 
	
	mode_set_mode_info( "PHP", "fold_info", "//{{{\r//}}}\r\r" );
	mode_set_mode_info( "PHP", "init_mode_menu", &php_init_menu );	
	run_mode_hooks( "php_mode_hook" );
}

provide( "php_mode" );
