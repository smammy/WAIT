#                              -*- Mode: Perl -*- 
# base.t -- 
# ITIID           : $ITI$ $Header $__Header$
# Author          : Ulrich Pfeifer
# Created On      : Thu Aug 15 18:47:58 1996
# Last Modified By: Ulrich Pfeifer
# Last Modified On: Sun Nov 22 18:44:31 1998
# Language        : CPerl
# Update Count    : 27
# Status          : Unknown, Use with caution!
# 
# Copyright (c) 1996-1997, Ulrich Pfeifer
# 

BEGIN { $| = 1; print "1..25\n"; }
END {print "not ok 1\n" unless $loaded;}
use WAIT::Filter qw(isolc isouc disolc disouc);
$loaded = 1;
print "ok 1\n";

@mixed = ("Ulrich", "Pfeifer", "Gro\337johann", "B\344uerchen", "\344u\337ersts", "\334bel");
@lower = ("ulrich", "pfeifer", "gro\337johann", "b\344uerchen", "\344u\337ersts", "\374bel");
@upper = ("ULRICH", "PFEIFER", "GRO\337JOHANN", "B\304UERCHEN", "\304U\337ERSTS", "\334BEL");
$test = 2;

my $m;
for $m (@mixed) {
  my $l = shift @lower;
  my $u = shift @upper;
  my ($M,$L,$U) = ($m,$l,$u);
  
  # test nondestructive versions
  print ((isolc($m) eq $l and $m eq $M)? "ok $test\n":"not ok $test\n");$test++;
  print ((isouc($m) eq $u and $m eq $M)? "ok $test\n":"not ok $test\n");$test++;

  # test destructive versions
  print ((disolc($m) eq $l and $m eq $l)?"ok $test\n":"not ok $test\n");$test++;
  print ((disouc($m) eq $u and $m eq $u)?"ok $test\n":"not ok $test\n");$test++;
}
