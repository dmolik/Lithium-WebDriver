#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Test::Deep;
use t::common;
use JSON::XS qw/decode_json/;
use YAML::XS;

my $site   = start_depends;

plan skip_all => "The following custom headers and settings are for phantomjs only support"
	unless is_phantom;

subtest 'Test headers' => sub {
	my $test_obj = {
		test1     =>  1,
		test2     => [ 1, 2, 3 ],
		HTTP_TEST => 'Second header'
	};
	my %config = %{driver_conf(
		site    => $site,
		ua      => 'linux - firefox',
		headers => {
				HTTP_ACCEPT => 'application/json',
				HTTP_TEST   => 'Second header',
			},
	)};
	my $DRIVER = Lithium::WebDriver->new(%config);
	$DRIVER->connect;
	$DRIVER->open(url => '/headers');
	cmp_deeply decode_json($DRIVER->html('pre')), $test_obj, "Is json?";
	$DRIVER->disconnect;

	%config = %{driver_conf(
		site    => $site,
		ua      => 'linux - firefox',
		headers => {
				HTTP_TEST   => 'Second header',
			},
	)};
	$DRIVER = Lithium::WebDriver->new(%config);
	$DRIVER->connect;
	$DRIVER->open(url => '/headers');
	cmp_deeply YAML::XS::Load($DRIVER->html('pre')), $test_obj, "Is yaml?";
	$DRIVER->disconnect;
};

subtest 'Verify UA order' => sub {
	my %config = %{driver_conf(
		site    => $site,
		ua      => 'linux - firefox',
		phantomjs_settings => { userAgent => "HKjgf" },
	)};
	my $DRIVER = Lithium::WebDriver->new(%config);
	$DRIVER->connect;
	is($DRIVER->run(js => "return navigator.userAgent;"),
		"Mozilla/5.0 (X11; Linux x86_64; rv:29.0) Gecko/20100101 Firefox/29.0",
		"Ensure top level ua setting takes precedence over phantomjs setting.");
	$DRIVER->disconnect;

	# frick
	%config = %{driver_conf(
		site    => $site,
		ua => '',
		phantomjs_settings => { userAgent => "HKjgf" },
	)};

	$DRIVER = Lithium::WebDriver->new(%config);
	$DRIVER->connect;
	is($DRIVER->run(js => "return navigator.userAgent;"),
		"HKjgf",
		"Ensure phantomjs_setting object actually works.");
	$DRIVER->disconnect;
};


stop_depends;
done_testing;
