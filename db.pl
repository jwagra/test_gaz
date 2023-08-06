use DBI;

$host = '127.0.0.1';
$port = 5432;
$dbname = 'postgres';
$username = 'postgres';
$password = 'postgres';

$dbh = DBI->connect("dbi:Pg:dbname=$dbname;host=$host;port=$port", $username, $password) or die "Can't connect to db";