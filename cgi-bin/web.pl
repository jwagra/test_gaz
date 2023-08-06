#!/usr/bin/perl
use CGI qw(-utf8);
use JSON;
#use CGI::Carp qw(fatalsToBrowser);
#use warnings;
use lib '/home/kazandaev_iv/learning/perl/';
require "db.pl";

my $log_limit = 100;
my $req = CGI->new;
my $email = '%'. $req->param('email') .'%';
my $sql = "
    WITH source AS (
        SELECT created, str, int_id
        FROM message
        WHERE str ILIKE(?)
        UNION
        SELECT created, str, int_id
        FROM log
        WHERE str ILIKE(?)
    )
";

my $sth = $dbh->prepare($sql ."
    SELECT COUNT(*)
    FROM source
");
$sth->execute($email, $email);
my $count = $sth->fetchrow();

$sth = $dbh->prepare($sql ."
    SELECT created, str
    FROM source
    ORDER BY int_id, created
    LIMIT ?
");
$sth->execute($email, $email, $log_limit);
my @logs = ();
while (($created, $str) = $sth->fetchrow()) {
    push @logs, "$created $str";
}

print $req->header('application/json;charset=UTF-8');
print encode_json({
    'all_count' => $count,
    'data' => \@logs
});