#!/usr/bin/perl
# Do not normalise this test file. It has deliberately unnormalised characters in it.
use v5.10;
use strict;
use warnings;
use utf8;
use if $^V ge v5.12.0, feature => 'unicode_strings';

use Test::More tests => 3;
use Test::Exception;

use ok 'Locale::CLDR';

my $locale = Locale::CLDR->new('en');

is ($locale->measurement_system_name('us'), 'US', 'Measurement system US');
is ($locale->measurement_system_name('metric'), 'Metric', 'Measurement system Metric');