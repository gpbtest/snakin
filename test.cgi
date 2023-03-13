#!/usr/bin/perl

use strict;
use CGI;
use DBI;


    my $query = new CGI;

    my $rcpt = $query->param("rcpt");

    print "Content-type: text/html\n\n";

    print <<HTML;
	<!DOCTYPE html><html lang="ru">
	<head>
	<meta charset="UTF-8">
	</head>
	<body>
	<form>
	<input type="text" name="rcpt" placeholder="адрес получателя" value="$rcpt">
	<input type="submit">
	</form>
HTML


    if($rcpt) {
	my $dsn = "DBI:mysql:awq:localhost";
	my $dbh = DBI->connect($dsn, 'root', '******', {
	    mysql_enable_utf8 => 1
	});

	my $sth = $dbh->prepare(<<SQL);
	    SELECT
		created,
		str
	    FROM
		log
	    WHERE
		address = ?
	    ORDER BY created, int_id LIMIT 101
SQL
	$sth->execute($rcpt);
	my $html = '<table border="1">';
	my $msg;
	my $counter = 0;
	while(my $row = $sth->fetchrow_hashref) {
	    if($counter < 100) {
		$html .= "<tr><td>$row->{created}</td><td>$row->{str}</td></tr>";
		$msg = 'количество найденных строк превышает указанный лимит';
	    }
	    $counter ++;
	}
	$html .= "</table>";

	print "<p>количество найденных строк превышает указанный лимит</p>" if $counter > 100;

	print $html if $counter > 0;
    }

    print '</body></html>';



exit;

