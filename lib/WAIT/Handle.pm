package WAIT::Handle;
use Net::Cmd;
use IO::Socket;
use vars qw(@ISA);
use strict;

@ISA = qw(Net::Cmd IO::Socket::INET);

# Snarfed from Net::Cmd; we don't expect an answer.
sub dataend
{
 my $cmd = shift;

 return 1
    unless(exists ${*$cmd}{'net_cmd_lastch'});

 if(${*$cmd}{'net_cmd_lastch'} eq "\015")
  {
   syswrite($cmd,"\012",1);
   print STDERR "\n"
    if($cmd->debug);
  }
 elsif(${*$cmd}{'net_cmd_lastch'} ne "\012")
  {
   syswrite($cmd,"\015\012",2);
   print STDERR "\n"
    if($cmd->debug);
  }

 print STDERR "$cmd>>> .\n"
    if($cmd->debug);

 syswrite($cmd,".\015\012",3);

 delete ${*$cmd}{'net_cmd_lastch'};

}
