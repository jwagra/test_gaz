#!/usr/bin/perl
use Email::Valid;
# use Data::Dumper;
# use warnings;
use lib '/home/kazandaev_iv/learning/perl/';
require "db.pl";

my $logname = 'out';
my @flags = ('<=', '=>', '->', '**', '==');

open(my $fh, '<:encoding(UTF-8)', $logname) or die "Can't read $logname: $!";
# $dbh->do('TRUNCATE TABLE message');
# $dbh->do('TRUNCATE TABLE log');
print "Parsing started..\n";

my $msg_cnt = $log_cnt = $total = 0;
my $start = time;
my %lh = ();
while (my $row = <$fh>) {
    $total++;
    chomp $row;
    my @columns = split(' ', $row);
    if ($#columns >= 3) {
        my $datetime = "$columns[0] $columns[1]";
        my $email = Email::Valid->address($columns[4]) ? $columns[4] : '';
        my $str = join(' ', @columns[2..$#columns]);
        #$columns[3] ~~ @flags
        if (!$lh{$columns[2]}) {
            $lh{$columns[2]} = [[@columns]];
        } else {
            push(@{ $lh{$columns[2]} }, [@columns]);
        }
        if ($columns[3] eq $flags[0] and $email) {
            save_msg($datetime, get_id(@columns), $columns[2], $str);
        } else {
            save_log($datetime, $columns[2], $str, $email);
        }
    }
}
print sprintf("Done for %s sec.: total %s, msg %s, log %s\n", time - $start, $total, $msg_cnt, $log_cnt);
#print Dumper \%lh;
#print_logs();

sub get_id {
    my @columns = @_;
    for (my $i = 0; $i <= $#columns; $i++) {
        if (index($columns[$i], 'id=') == 0) {
            return substr($columns[$i], 3);
        }
    }
}

sub save_msg {
    my $sth = $dbh->prepare('INSERT INTO message (created, id, int_id, str) VALUES (?, ?, ?, ?)');
    if ($sth->execute(@_)) {
        $msg_cnt++;
    }
}

sub save_log {
    my $sth = $dbh->prepare('INSERT INTO log (created, int_id, str, address) VALUES (?, ?, ?, ?)');
    if ($sth->execute(@_)) {
        $log_cnt++;
    }
}

sub print_logs {
    foreach my $key (keys %lh) {
        my $len = @{ $lh{$key} };
        print sprintf("---> $key (%s)\n", $len);
        for (my $i = 0; $i < $len; $i++) {
            print join(' ', @{ $lh{$key}[$i] }), "\n";
        }
    }
}