#! /usr/local/bin/perl -Tw
#
# Copyright 2018 Oath, Inc.
#
# Originally written by Jan Schaumann <jschauma@netmeister.org> in March 2018.
#
# This tool converts key-value data into json output.
# See the manual page for details.
#
# Licensed under the terms of the BSD License.
# See LICENSE file in project root for terms.
#
# https://github.com/jschauma/kv2json

use 5.008;

use strict;
use File::Basename;
use Getopt::Long;
Getopt::Long::Configure("bundling");

use JSON;

###
### Constants
###

use constant TRUE => 1;
use constant FALSE => 0;

use constant EXIT_FAILURE => 1;
use constant EXIT_SUCCESS => 0;

###
### Globals
###

my $PROGNAME = basename($0);
my %OPTS = (
		"comment"   => "#",
		"object"    => "name",
		"record"    => "",
		"separator" => "=",
	   );

my @J;

###
### Subroutines
###

sub addItemToHash($$$) {
	my ($h, $k, $v) = @_;
	my %hash = %{$h};
	# Multiple values for the same key yield
	# a JSON array rather than overriding
	# previously found keys.
	if (exists($hash{$k})) {
		my @a;

		if (ref($hash{$k}) eq 'ARRAY') {
			@a = @{$hash{$k}};
		} else {
			push(@a, $hash{$k});
		}
		push(@a, $v);
		$hash{$k} = \@a;
	} else {
		$hash{$k} = $v;
	}

	return %hash;
}

sub init() {
	my ($ok);

	$ok = GetOptions(
			"underscore|_"  => \$OPTS{'_'},
			"comment|c=s" 	=> \$OPTS{'comment'},
			"help|h" 	=> \$OPTS{'help'},
			"object|o=s" 	=> \$OPTS{'object'},
			"record|r=s"	=> \$OPTS{'record'},
			"separator|s=s"	=> \$OPTS{'separator'},
			);

	if (scalar(@ARGV)) {
		print STDERR "I can't deal with spurious arguments after flags.  Try -h.\n";
		exit(EXIT_FAILURE);
		# NOTREACHED
	}

	if ($OPTS{'help'} || !$ok) {
		usage($ok);
		exit(!$ok);
		# NOTREACHED
	}
}

sub parseInput() {
	my $sepCounter = 0;
	my %hash;

	foreach my $line (<STDIN>) {
		$line =~ s/^\s*//;
		$line =~ s/\s*$//;

		my $c = $OPTS{'comment'};
		if ($line =~ m/$c/) {
			$line =~ s/$c.*//;
			if ($line =~ m/^$/) {
				next;
			}
		}

		my $r = $OPTS{'record'};
		if ($line =~ m/^$r$/) {
			# Skip over multiple separators only if it's
			# the default to avoid the creation of empty
			# objects.
			if (($r eq "") && ($sepCounter > 0)) {
				next;
			}
			$sepCounter++;
			if (scalar(keys(%hash)) > 0) {
				my %h = %hash;
				push(@J, \%h);
			}
			%hash = ();
			next;
		} else {
			$sepCounter = 0;
		}

		my $s = $OPTS{'separator'};
		if ($line =~ m/$s/) {
			my @kv = split(/$s/, $line, 2);
			my $k = $kv[0];
			my $v = $kv[1];

			$k =~ s/^\s*//;
			$v =~ s/^\s*//;
			$k =~ s/\s*$//;
			$v =~ s/\s*$//;

			if ($OPTS{'_'}) {
				$k =~ s/ /_/g;
			}

			%hash = addItemToHash(\%hash, $k, $v);
		} else {
			%hash = addItemToHash(\%hash, $OPTS{'object'}, $line);
		}
	}

	# Last entry may not have a separator.
	if (scalar(keys(%hash)) > 0) {
		push(@J, \%hash);
	}
}

sub printOutput() {
	if (scalar(@J) > 0) {
		my $json = JSON->new->allow_nonref->canonical(1);
		print $json->pretty->encode(\@J);
	}
}


sub usage($) {
	my ($err) = @_;

	my $FH = $err ? \*STDERR : \*STDOUT;

	print $FH <<EOH
Usage: $PROGNAME [-_h] [-c char] [-o name] [-r sep] [-s sep]
       -_       replace spaces in keys with '_'
       -c char  treat 'char' as a comment character
       -h       print this help and exit
       -o name  specify the object name
       -r sep   specify the record separator
       -s sep   specify the key-value separator
EOH
;

}


sub verbose($;$) {
	my ($msg, $level) = @_;
	my $char = "=";

	return unless $OPTS{'v'};

	$char .= "=" x ($level ? ($level - 1) : 0 );

	if (!$level || ($level <= $OPTS{'v'})) {
		print STDERR "$char> $msg\n";
	}
}


###
### Main
###

init();
parseInput();
printOutput();

exit(0);
