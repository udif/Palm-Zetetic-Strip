#!/usr/bin/perl -w
#
# This file is based on strip.pl, which is written by Dave Dribin
# <ddribin@cpan.org>.
#
# This file converts an encrypted Strip database to the
# comma-separated cleartext format used by the import feature of
# OI Safe.  To use:
#
# 1. Ensure you have the three Strip PDF files stored in a directory.
#    (See ../README for more info).
#
# 2. Run this script, with the directory as the only argument.
#    Redirect stdout to a file.
#
# 3. Store that file as "oisafe.csv" in the root of the flash memory
#    of your Android device.
#
# 4. Start OI Safe on your Android device, and select Menu -> More ->
#    Import Database.
#
# Caveat: during this process, all your passwords will be available in
# cleartext format.  It might be a good idea to disconnect your
# computer from all networks during this process if you are paranoid.
# If possible, mount your Android device before running step 3, and
# create the oisafe.csv file on the flash memory, to reduce the number
# of copies you create.

use strict;
use Palm::Zetetic::Strip;
use Term::ReadKey;

my $dir;
my $strip;
my $password;
my @accounts;
my $account;
my @systems;
my $system;

sub emit_quoted
{
    my ($terminator,$string) = @_;
    $string =~ s/"/""/g;
    utf8::encode($string);
    print '"' . $string . '"' . $terminator;
}

$dir = $ARGV[0];

print STDERR "Strip password: ";
ReadMode('noecho');
chomp($password = ReadLine(0));
ReadMode('normal');
print STDERR "\n";

$strip = new Palm::Zetetic::Strip();
$strip->set_directory($dir);

if (! $strip->set_password($password))
{
    print STDERR "Password does not match\n";
    exit(1);
}
$strip->load();

print "\"Category\",\"Description\",\"Website\",\"Username\",\"Password\",\"Notes\"\n";

@systems = $strip->get_systems();
foreach $system (@systems)
{
    @accounts = $strip->get_accounts($system);
    foreach $account (@accounts)
    {
	emit_quoted(",", $system->get_name());
	emit_quoted(",", ($account->get_system() . " - " .
			  $account->get_username()));
	emit_quoted(",", $account->get_system());
	emit_quoted(",", $account->get_username());
	emit_quoted(",", $account->get_password());
	emit_quoted("\n", $account->get_comment());
    }
}
