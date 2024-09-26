#                              -*- Mode: Perl -*-
# $Basename: Server.pm $
# $Revision: 1.5 $
# ITIID           : $ITI$ $Header $__Header$
# Author          : Ulrich Pfeifer
# Created On      : Sat Sep 28 13:53:36 1996
# Last Modified By: Ulrich Pfeifer
# Last Modified On: Sun Nov 22 18:44:38 1998
# Language        : CPerl
# Update Count    : 280
# Status          : Unknown, Use with caution!
#
# Copyright (c) 1996-1997, Ulrich Pfeifer
#

package WAIT::Server;
use vars qw($VERSION @ISA @EXPORT);
use WAIT::Config;
use WAIT::Handle;
use WAIT::Server::Connection;
use IO::Socket;
use IO::Select;
use strict;
use sigtrap qw(handler IGNORE error-signals);
require Exporter;
@ISA    = qw(Exporter);
@EXPORT = qw(server);

my ($ver) = '$ProjectVersion: 18.1 $ ' =~ /([\d.]+)/;
$VERSION = sprintf '%5.3f', $ver / 10;

sub server {
    my %opt  = @_;
    my $port = $opt{port} || $WAIT::Config->{port} || 1404;

    my $lsn = new WAIT::Handle(
        Reuse     => 1,
        Listen    => 5,
        LocalPort => $port,
        Proto     => 'tcp'
    );
    die "Could not connect to port $port: $!\n" unless defined $lsn;

    my $SEL = new IO::Select($lsn);
    my %CON;
    my $fh;
    my @ready;

    print "listening on port $port\n";

    while (1) {
        alarm(0);
        @ready = $SEL->can_read;

       #printf STDERR "=== %s %s\n", unpack ('b*', $SEL->[0]), join ':', @ready;
       #sleep 1;
        alarm(25);
      REQUEST:
        foreach $fh (@ready) {
            if ($fh == $lsn) {
                my $new = $lsn->accept;    # Create a new socket
                $CON{$new} = new WAIT::Server::Connection $new, $VERSION;
                $SEL->add($new);
            }
            else {
                my ($cmd, $func, @args, @cmd);
                my $fno = fileno($fh);

                $cmd = $fh->getline();
                if ($cmd =~ /^post/i) {
                    /`/;
                    my $buf =
                        $cmd
                      . join('', @{ ${*$fh}{'net_cmd_lines'} })
                      . ${*$fh}{'net_cmd_partial'};
                    ($cmd) = ($buf =~ /^Command: (.*)$/m);
                    ($cmd, @cmd) = (split(/:/, $cmd), 'quit');
                    ${*$fh}{'net_cmd_partial'} = '';
                    /`/;
                    $CON{$fh}->{http} = 1;
                }
              COMMAND:
                for $cmd ($cmd, @cmd) {
                    ($func, @args) = split ' ', $cmd;
                    unless (fileno($fh)) {
                        printf STDERR "Shuttig down $fh(%d)\n", $fno;
                        delete $CON{$fh};
                        $SEL->remove($fno);
                        next REQUEST;
                    }
                    $func = lc($func);
                    $func = $CON{$fh}->dispatch($func, @args);
                    if ($func eq 'quit') {
                        printf STDERR "closed\n";
                        $SEL->remove($fh);
                        $CON{$fh}->close;
                        delete $CON{$fh};
                        last COMMAND;
                    }
                }
            }
        }
    }
}
