<?

//
// SourceForge: Breaking Down the Barriers to Open Source Development
// Copyright 1999-2000 (c) The SourceForge Crew
//
// $Id: postgres.php,v 1.4 2001/01/13 18:32:01 child Exp $
//
// ?>
/*
 *
 *
 * ?>
 *
 */
require ('/etc/local.inc');

// Hey ho     //{{{
function db_connect ($target)
{
	global $dbhost, $dbname, $port, $conn;
    $conn = @pg_Connect ($dbhost, $port, $dbname);
    return $conn;
    // }
    class Dooh
    {
		global $dbhost;
    }
}
//}}}
if (1)
{
    something;
}

function db_query ($qstring)
{
    global $conn, $pg_curr_row;
    $result = @pg_Exec ($conn, $qstring);
    // This will break if different connections return the
    // same query handle index (probable?). //
    $pg_curr_row[$result] = 0;
    return $result;
    if (1)
    {
		something;
    }
    switch ($i)
    {
		case:
			something;
		case:
			something else;
		default:
			do nothing;
    }
}

function db_numrows ($qhandle)
{
	if ($qhandle) {
		return @pg_NumRows ($qhandle);
	} else {
		return 0;
	}
}

function db_result ($qhandle, $row, $field)
{
	return @pg_Result ($qhandle, $row, $field);
}

function db_numfields ($lhandle) {
	return @pg_NumFields ($lhandle);
}

function db_affected_rows ($qhandle)
{
	return @pg_cmdTuples ($qhandle);
}

function db_fetch_array($qhandle) {
	global $pg_curr_row;
	$numfields = @pg_numFields ($qhandle);
	
	if (@pg_numrows ($qhandle) <= $pg_curr_row[$qhandle]) {
		return 0;
	}
	$row = @pg_Fetch_Array ($qhandle, $pg_curr_row[$qhandle]);
	for ($i = 0; $i < $numfields; $i++) {
		$fieldname = @pg_FieldName ($qhandle, $i);
		$arr[$fieldname] = $row[$i];
	}
	$pg_curr_row[$qhandle] += 1;
	return $arr;
}

function db_insertid ($r)
{
	global $conn;
	
	$oid = @pg_GetLastOID ($r);
	if (!$oid)
	{
		echo @pg_ErrorMessage($dbh) . "\n";
		return "";
	}

	// This will search through all the tables in database keystone to find
	// the row with OID $oid, then return the value of the primary key column
	// for that row.	 This is not exactly what mysql_insertid does, but it
	// fits with the use of db_insertid.
	//
	// Search the system catalogues to find all the tables.
	$query	= "SELECT c.relname "
	  . "  FROM pg_class c "
	  . " WHERE c.relkind = 'r'"
	  . "   AND c.relname !~ '^pg_'";

	$res1 = @pg_Exec ($conn, $query);

	if (!$res1)
	{
		echo @pg_ErrorMessage ($conn) . "\n";
	} else {
		// For each table, query to see if the OID is present.
		for ($idx = 0; $idx < @pg_NumRows ($res1); $idx++) {
			$row   = @pg_Fetch_Row ($res1, $idx);
			$table = $row[0];
			$res2  = @pg_Exec ($conn, "select oid from $table where oid = $oid");
			if (@pg_NumRows ($res2) != 0) {
				// We found the OID in the current table, now find the name of the primary key column
				$query  = "SELECT a.attname FROM pg_class c, pg_attribute a, pg_index i, pg_class c2 "
				  . " WHERE c.relname   = '$table' "
				  . "   AND i.indrelid  = c.oid "
				  . "   AND a.attrelid  = c.oid "
				  . "   AND c2.oid      = i.indexrelid "
				  . "   AND i.indkey[0] = a.attnum "
				  . "   AND c2.relname  ~ '_pkey$'";
				$res2  = @pg_Exec ($conn, $query);
				if ($res2)
				{
					$pkname	= @pg_Result ($res2, 0, 0);
					$res2	= @pg_Exec ("select $pkname from $table where oid = $oid");
					$row	= @pg_Fetch_Row ($res2, 0);
					return $row[0];
				} else {
					return 0;
				}
				break;
			}
		}
	}
}

function db_error()
{
	global $conn;
	return "\n\n<P><B>".@pg_errormessage($conn)."</B><P>\n\n";
}
?>

			<!-- testting -->
