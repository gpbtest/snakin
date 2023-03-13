#!/usr/bin/perl

use strict;
use DBI;

    my $dsn = "DBI:mysql:awq:localhost";
    my $dbh = DBI->connect($dsn, 'root', '******', {
	mysql_enable_utf8 => 1
    });

    my @message_data;
    my @log_data;
    my @log_email_data;

    my $counter = 0;
    open(fl, '</var/www/status/cgi-bin/out');

     while(my $line = <fl>) {

	my ($str) = $line =~ /^.{19}\s(.*)$/;
	$str =~ s/'/\\'/g;

	if($line =~ /^(.{10})\s(.{8})\s(.{16})\s<=\s.*id=(.*)[\s|]$/) {
	    push @message_data, "('$1 $2','$4','$3','$str')";
	} elsif ($line =~ /^(.{10})\s(.{8})\s(.{16})\s.{2}\s<>\s/) {
	    push @log_data, "('$1 $2','$3','$str')";
	} elsif ($line =~ /^(.{10})\s(.{8})\s(.{16})\s.{2}\s:blackhole:\s<(.+?)>\s/) {
	    push @log_email_data, "('$1 $2','$3','$str','$4')";
	} elsif ($line =~ /^(.{10})\s(.{8})\s(.{16})\s.{2}\s(.+?)[\s|:]/) {
	    push @log_email_data, "('$1 $2','$3','$str','$4')";
	} elsif ($line =~ /^(.{10})\s(.{8})\s(.{16})\s.*/) {
	    push @log_data, "('$1 $2','$3','$str')";
	} else {
	    print $line;
	    $counter ++;
	}
    }

    close(fl);

    $dbh->do('INSERT INTO message (created, id, int_id, str) VALUES ' . join(',', @message_data));
    $dbh->do('INSERT INTO log (created, int_id, str, address) VALUES ' . join(',', @log_email_data));
    $dbh->do('INSERT INTO log (created, int_id, str) VALUES ' . join(',', @log_data));

    print "$counter записей не было обработано\n";

    $dbh->disconnect();

    exit;
