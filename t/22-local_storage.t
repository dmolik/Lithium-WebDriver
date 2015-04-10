use strict;
use warnings;

use Test::More;
use t::common;

my $site   = start_depends;
my $DRIVER = Lithium::WebDriver->new(%{driver_conf(site => $site)});
ok($DRIVER->connect, "Driver->connect returns 1 if connected.");
$DRIVER->open(url => '/storage');
is($DRIVER->text('#id1'), "From static: unsaved", "Div text is unaffected on first visit");
$DRIVER->refresh;
is($DRIVER->text('#id1'), "from local storage: Saved", "Div text has changed from localstorage");
ok($DRIVER->disconnect, "Driver->disconnect returns 1 on good disconnect.");

$DRIVER = Lithium::WebDriver->new(%{driver_conf(site => $site)});
ok($DRIVER->connect, "Driver->connect returns 1 if connected.");
$DRIVER->open(url => '/storage');
is($DRIVER->text('#id1'), "From static: unsaved", "Div text has been reset on teardown");
ok($DRIVER->disconnect, "Driver->disconnect returns 1 on good disconnect.");

stop_depends;
done_testing;
