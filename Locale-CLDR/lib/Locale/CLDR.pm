package Locale::CLDR;

=encoding utf8

=head1 NAME

Locale::CLDR - A Module to create locale objects with localisation data from the CLDR

=head1 VERSION

Version 0.26.8

=head1 SYNOPSIS

This module provides a locale object you can use to localise your output.
The localisation data comes from the Unicode Common Locale Data Repository.
Most of this code can be used with Perl version 5.10 or above. There are a
few parts of the code that require version 5.18 or above.

=head1 USAGE

 my $locale = Locale::CLDR->new('en_US');

or

 my $locale = Locale::CLDR->new(language_id => 'en', territory_id => 'us');
 
A full locale identifier is
 
C<language>_C<script>_C<territory>_C<variant>_u_C<extension name>_C<extension value>
 
 my $locale = Locale::CLDR->new('en_latn_US_SCOUSE_u_nu_traditional');
 
or
 
 my $locale = Locale::CLDR->new(language_id => 'en', script_id => 'latn', territory_id => 'US', variant => 'SCOUSE', extensions => { nu => 'traditional' } );
 
=cut

use v5.10;
use version;
our $VERSION = version->declare('v0.26.8');

use open ':encoding(utf8)';
use utf8;
use if $^V ge v5.12.0, feature => 'unicode_strings';

use Moose;
use MooseX::ClassAttribute;
with 'Locale::CLDR::ValidCodes', 'Locale::CLDR::EraBoundries', 'Locale::CLDR::WeekData', 
	'Locale::CLDR::MeasurementSystem', 'Locale::CLDR::LikelySubtags', 'Locale::CLDR::NumberingSystems',
	'Locale::CLDR::NumberFormatter', 'Locale::CLDR::TerritoryContainment', 'Locale::CLDR::CalendarPreferences',
	'Locale::CLDR::Currencies', 'Locale::CLDR::Plurals';
	
use Class::Load;
use namespace::autoclean;
use List::Util qw(first);
use Class::MOP;
use DateTime::Locale;
use Unicode::Normalize();
#use Locale::CLDR::Collator();
use File::Spec();

# Backwards compatibility
BEGIN {
	if (defined &CORE::fc) { #v5.16
		*fc = \&CORE::fc;
	}
	else {
		# We only use fc() with code that expects Perl v5.18 or above
		*fc = sub {};
	}
}

=head1 ATTRIBUTES

These can be passed into the constructor and all are optional.

=over 4

=item language_id

A valid language or language alias id, such as C<en>

=cut

has 'language_id' => (
	is			=> 'ro',
	isa			=> 'Str',
	required	=> 1,
);

# language aliases
around 'language_id' => sub {
	my ($orig, $self) = @_;
	my $value = $self->$orig;
	return $self->language_aliases->{$value} // $value;
};

=item script_id

A valid script id, such as C<latn> or C<Ctcl>. The code will pick a likely script
depending on the given language if non is provided.

=cut

has 'script_id' => (
	is			=> 'ro',
	isa			=> 'Str',
	default		=> '',
	predicate	=> 'has_script',
);

=item territory_id

A valid territory id or territory alias such as C<GB>

=cut

has 'territory_id' => (
	is			=> 'ro',
	isa			=> 'Str',
	default		=> '',
	predicate	=> 'has_territory',
);

# territory aliases
around 'territory_id' => sub {
	my ($orig, $self) = @_;
	my $value = $self->$orig;
	return $value if defined $value;
	my $alias = $self->territory_aliases->{$value};
	return (split /\s+/, $alias)[0];
};

=item variant_id

A valid variant id. The code currently ignores this

=cut

has 'variant_id' => (
	is			=> 'ro',
	isa			=> 'Str',
	default		=> '',
	predicate	=> 'has_variant',
);

=item extensions 

A Hashref of extension names and values. You can use this to override
the locales number formatting and calendar by passing in the Unicode
extension names or aliases as keys and the extension value as the hash 
value.

Currently supported extensions are

=over 8

=item nu

=item numbers

The number type can be one of

=over 12

=item arab

Arabic-Indic Digits

=item arabext

Extended Arabic-Indic Digits

=item armn

Armenian Numerals

=item armnlow

Armenian Lowercase Numerals

=item bali

Balinese Digits

=item beng

Bengali Digits

=item brah

Brahmi Digits

=item cakm

Chakma Digits

=item cham

Cham Digits

=item deva

Devanagari Digits

=item ethi

Ethiopic Numerals

=item finance

Financial Numerals

=item fullwide

Full Width Digits

=item geor

Georgian Numerals

=item grek

Greek Numerals

=item greklow

Greek Lowercase Numerals

=item gujr

Gujarati Digits

=item guru

Gurmukhi Digits

=item hanidays

Chinese Calendar Day-of-Month Numerals

=item hanidec

Chinese Decimal Numerals

=item hans

Simplified Chinese Numerals

=item hansfin

Simplified Chinese Financial Numerals

=item hant

Traditional Chinese Numerals

=item hantfin

Traditional Chinese Financial Numerals

=item hebr

Hebrew Numerals

=item java

Javanese Digits

=item jpan

Japanese Numerals

=item jpanfin

Japanese Financial Numerals

=item kali

Kayah Li Digits

=item khmr

Khmer Digits

=item knda

Kannada Digits

=item lana

Tai Tham Hora Digits

=item lanatham

Tai Tham Tham Digits

=item laoo

Lao Digits

=item latn

Western Digits

=item lepc

Lepcha Digits

=item limb

Limbu Digits

=item mlym

Malayalam Digits

=item mong

Mongolian Digits

=item mtei

Meetei Mayek Digits

=item mymr

Myanmar Digits

=item mymrshan

Myanmar Shan Digits

=item native

Native Digits

=item nkoo

N'Ko Digits

=item olck

Ol Chiki Digits

=item orya

Oriya Digits

=item osma

Osmanya Digits

=item roman

Roman Numerals

=item romanlow

Roman Lowercase Numerals

=item saur

Saurashtra Digits

=item shrd

Sharada Digits

=item sora

Sora Sompeng Digits

=item sund

Sundanese Digits

=item takr

Takri Digits

=item talu

New Tai Lue Digits

=item taml

Traditional Tamil Numerals

=item tamldec

Tamil Digits

=item telu

Telugu Digits

=item thai

Thai Digits

=item tibt

Tibetan Digits

=item traditional

Traditional Numerals

=item vaii

Vai Digits

=back

=item ca

=item calendar

You can use this to override a locales default calendar. Valid values are

=over 12

=item buddhist

Buddhist Calendar

=item chinese

Chinese Calendar

=item coptic

Coptic Calendar

=item dangi

Dangi Calendar

=item ethiopic

Ethiopic Calendar

=item ethiopic-amete-alem

Ethiopic Amete Alem Calendar

=item gregorian

Gregorian Calendar

=item hebrew

Hebrew Calendar

=item indian

Indian National Calendar

=item islamic

Islamic Calendar

=item islamic-civil

Islamic Calendar (tabular, civil epoch)

=item islamic-rgsa

Islamic Calendar (Saudi Arabia, sighting)

=item islamic-tbla

Islamic Calendar (tabular, astronomical epoch)

=item islamic-umalqura

Islamic Calendar (Umm al-Qura)

=item iso8601

ISO-8601 Calendar

=item japanese

Japanese Calendar

=item persian

Persian Calendar

=item roc

Minguo Calendar

=back

=back

=cut

has 'extensions' => (
	is			=> 'ro',
	isa			=> 'Undef|HashRef',
	default		=> undef,
	writer		=> '_set_extensions',
);

=back

=head1 Methods

The following methods can be called on the locale object

=over 4

=item id()

The local identifier. This is what you get if you attempt to
stringify a locale object.

=item likely_language()

Given a locale with no language passed in or with the explicit language
code of C<und>, this method attempts to use the script and territory
data to guess the locale's language.

=cut

has 'likely_language' => (
	is			=> 'ro',
	isa			=> 'Str',
	init_arg	=> undef,
	lazy		=> 1,
	builder		=> '_build_likely_language',
);

sub _build_likely_language {
	my $self = shift;
	
	my $language = $self->language();
	
	return $language unless $language eq 'und';
	
	return $self->likely_subtag->language;
}

=item likely_script()

Given a locale with no script passed in this method attempts to use the
language and territory data to guess the locale's script.

=cut

has 'likely_script' => (
	is			=> 'ro',
	isa			=> 'Str',
	init_arg	=> undef,
	lazy		=> 1,
	builder		=> '_build_likely_script',
);

sub _build_likely_script {
	my $self = shift;
	
	my $script = $self->script();
	
	return $script if $script;
	
	return $self->likely_subtag->script || '';
}

=item likely_territory()

Given a locale with no territory passed in this method attempts to use the
language and script data to guess the locale's territory.

=back

=cut

has 'likely_territory' => (
	is			=> 'ro',
	isa			=> 'Str',
	init_arg	=> undef,
	lazy		=> 1,
	builder		=> '_build_likely_territory',
);

sub _build_likely_territory {
	my $self = shift;
	
	my $territory = $self->territory();
	
	return $territory if $territory;
	
	return $self->likely_subtag->territory || '';
}

has 'module' => (
	is			=> 'ro',
	isa			=> 'Object',
	init_arg	=> undef,
	lazy		=> 1,
	builder		=> '_build_module',
);

sub _build_module {
	# Create the new path
	my $self = shift;
	
	my @path = map { ucfirst lc }
		map { $_ ? $_ : 'Any' } (
			$self->language_id,
			$self->script_id,
			$self->territory_id,
		);

	my @likely_path = 
		map { ucfirst lc } (
			$self->has_likely_subtag ? $self->likely_subtag->language_id : 'Any',
			$self->has_likely_subtag ? $self->likely_subtag->script_id : 'Any',
			$self->has_likely_subtag ? $self->likely_subtag->territory_id : 'Any',
		);
	
	for (my $i = 0; $i < @path; $i++) {
		$likely_path[$i] = $path[$i] unless $path[$i] eq 'und' or $path[$i] eq 'Any';
	}
	
	# Note the order we push these onto the stack is important
	@path = join '::', @likely_path;
	push @path, join '::', $likely_path[0], 'Any', $likely_path[2];
	push @path, join '::', @likely_path[0 .. 1];
	push @path, join '::', $likely_path[0];
	
	# Now we go through the path loading each module
	# And calling new on it. 
	my $module;
	foreach my $module_name (@path) {
		$module_name = "Locale::CLDR::Locales::$module_name";
		if (Class::Load::try_load_class($module_name, { -version => $VERSION})) {
			Class::Load::load_class($module_name, { -version => $VERSION});
		}
		else {
			next;
		}
		$module = $module_name->new;
		last;
	}

	# If we only have the root module then we have a problem as
	# none of the language specific data is in the root. So we
	# fall back to the en module

	if ( ref $module eq 'Locale::CLDR::Locales::Root') {
		Class::Load::load_class('Locale::CLDR::Locales::En');
		$module = Locale::CLDR::Locales::En->new
	}

	return $module;
}

class_has 'method_cache' => (
	is			=> 'rw',
	isa			=> 'HashRef[HashRef[ArrayRef[Object]]]',
	init_arg	=> undef,
	default		=> sub { return {}},
);

has 'break_grapheme_cluster' => (
	is => 'ro',
	isa => 'ArrayRef',
	init_arg => undef(),
	lazy => 1,
	default => sub {shift->_build_break('GraphemeClusterBreak')},
);

has 'break_word' => (
	is => 'ro',
	isa => 'ArrayRef',
	init_arg => undef(),
	lazy => 1,
	default => sub {shift->_build_break('WordBreak')},
);

has 'break_line' => (
	is => 'ro',
	isa => 'ArrayRef',
	init_arg => undef(),
	lazy => 1,
	default => sub {shift->_build_break('LineBreak')},
);

has 'break_sentence' => (
	is => 'ro',
	isa => 'ArrayRef',
	init_arg => undef(),
	lazy => 1,
	default => sub {shift->_build_break('SentenceBreak')},
);

=head2 Meta Data

The following methods return, in English, the names if the various 
id's passed into the locales constructor. I.e. if you passed 
C<language =E<gt> 'fr'> to the constructor you would get back C<French>
for the language.

=over 4

=item name

The locale's name. This is usually built up out of the language, 
script, territory and variant of the locale

=item language

The name of the locale's language

=item script

The name of the locale's script

=item territory

The name of the locale's territory

=item variant

The name of the locale's variant

=back

=head2 Native Meta Data

Like Meta Data above this provides the names of the various id's 
passed into the locale's constructor. However in this case the
names are formatted to match the locale. I.e. if you passed 
C<language =E<gt> 'fr'> to the constructor you would get back 
C<français> for the language.

=over 4

=item native_name

The locale's name. This is usually built up out of the language, 
script, territory and variant of the locale. Returned in the locale's
language and script

=item native_language

The name of the locale's language in the locale's language and script.

=item native_script

The name of the locale's script in the locale's language and script.

=item native_territory

The name of the locale's territory in the locale's language and script.

=item native_variant

The name of the locale's variant in the locale's language and script.

=back

=cut

foreach my $property (qw( name language script territory variant)) {
	has $property => (
		is => 'ro',
		isa => 'Str',
		init_arg => undef,
		lazy => 1,
		builder => "_build_$property",
	);

	no strict 'refs';
	*{"native_$property"} = sub {
		my ($self, $for) = @_;
		
		$for //= $self;
		my $build = "_build_native_$property";
		return $self->$build($for);
	};
}

=head2 Calenders

The Calendar data is built to hook into L<DateTime::Locale> so that 
all Locale::CLDR objects can be used as replacements for DateTime::Locale's 
locale data. To use, say, the French data do

 my $french_locale = Locale::CLDR->new('fr_FR');
 my $french_dt = DateTime->now(locale => $french_locale);
 say "French month : ", $french_dt->month_name; # prints out the current month in French

=over 4

=item month_format_wide 

=item month_format_abbreviated 

=item month_format_narrow

=item month_stand_alone_wide

=item month_stand_alone_abbreviated

=item month_stand_alone_narrow

All the above return an arrayref of month names in the requested style.

=item day_format_wide 

=item day_format_abbreviated 

=item day_format_narrow

=item day_stand_alone_wide

=item day_stand_alone_abbreviated

=item day_stand_alone_narrow

All the above return an array ref of day names in the requested style.

=item quarter_format_wide 

=item quarter_format_abbreviated 

=item quarter_format_narrow

=item quarter_stand_alone_wide

=item quarter_stand_alone_abbreviated

=item quarter_stand_alone_narrow

All the above return an arrayref of quarter names in the requested style.

=item am_pm_wide

=item am_pm_abbreviated

=item am_pm_narrow

All the above return the date period name for AM and PM
in the requested style

=item era_wide

=item era_abbreviated

=item era_narrow

All the above return an array ref of era names. Note that these 
return the first two eras which is what you normally want for 
BC and AD etc. but won't work correctly for Japanese calendars.

=back

=cut

foreach my $property (qw( 
	month_format_wide month_format_abbreviated month_format_narrow
	month_stand_alone_wide month_stand_alone_abbreviated month_stand_alone_narrow
	day_format_wide day_format_abbreviated day_format_narrow
	day_stand_alone_wide day_stand_alone_abbreviated day_stand_alone_narrow
	quarter_format_wide quarter_format_abbreviated quarter_format_narrow
	quarter_stand_alone_wide quarter_stand_alone_abbreviated quarter_stand_alone_narrow
	am_pm_wide am_pm_abbreviated am_pm_narrow
	era_wide era_abbreviated era_narrow
	era_format_wide era_format_abbreviated era_format_narrow
	era_stand_alone_wide era_stand_alone_abbreviated era_stand_alone_narrow
)) {
	has $property => (
		is => 'ro',
		isa => 'ArrayRef',
		init_arg => undef,
		lazy => 1,
		builder => "_build_$property",
		clearer => "_clear_$property",
	);
}

=pod

The next set of methods are not used by DateTime::Locale but CLDR provide
the data and you might want it

=over 4

=item am_pm_format_wide 

=item am_pm_format_abbreviated

=item am_pm_format_narrow

=item am_pm_stand_alone_wide

=item am_pm_stand_alone_abbreviated

=item am_pm_stand_alone_narrow

All the above return a hashref keyed on date period
with the value being the value for that date period

=item era_format_wide 

=item era_format_abbreviated 

=item era_format_narrow
	
=item era_stand_alone_wide 

=item era_stand_alone_abbreviated 

=item era_stand_alone_narrow

All the above return an array ref with I<all> the era data for the
locale formatted to the requested width

=cut

foreach my $property (qw( 
	am_pm_format_wide am_pm_format_abbreviated am_pm_format_narrow
	am_pm_stand_alone_wide am_pm_stand_alone_abbreviated am_pm_stand_alone_narrow
)) {
	has $property => (
		is => 'ro',
		isa => 'HashRef',
		init_arg => undef,
		lazy => 1,
		builder => "_build_$property",
		clearer => "_clear_$property",
	);
}

=item date_format_full 

=item date_format_long 

=item date_format_medium 

=item date_format_short

=item time_format_full

=item time_format_long

=item time_format_medium

=item time_format_short

=item datetime_format_full

=item datetime_format_long

=item datetime_format_medium

=item datetime_format_short

All the above return the CLDR I<date format pattern> for the given 
element and width

=cut

foreach my $property (qw(
	id
	date_format_full date_format_long 
	date_format_medium date_format_short
	time_format_full time_format_long
	time_format_medium time_format_short
	datetime_format_full datetime_format_long
	datetime_format_medium datetime_format_short
)) {
	has $property => (
		is => 'ro',
		isa => 'Str',
		init_arg => undef,
		lazy => 1,
		builder => "_build_$property",
		clearer => "_clear_$property",
	);
}

has '_available_formats' => (
	traits => ['Array'],
	is => 'ro',
	isa => 'ArrayRef',
	init_arg => undef,
	lazy => 1,
	builder => "_build_available_formats",
	clearer => "_clear_available_formats",
	handles => {
		available_formats => 'elements',
	},
);

has 'format_data' => (
	is => 'ro',
	isa => 'HashRef',
	init_arg => undef,
	lazy => 1,
	builder => "_build_format_data",
	clearer => "_clear_format_data",
);

# default_calendar
foreach my $property (qw(
	default_date_format_length default_time_format_length
)) {
	has $property => (
		is => 'ro',
		isa => 'Str',
		init_arg => undef,
		lazy => 1,
		builder => "_build_$property",
		writer => "set_$property" 
	);
}

=item prefers_24_hour_time()

Returns a boolean value, true if the locale has a preference
for 24 hour time over 12 hour

=cut

has 'prefers_24_hour_time' => (
	is => 'ro',
	isa => 'Bool',
	init_arg => undef,
	lazy => 1,
	builder => "_build_prefers_24_hour_time",
);

=item first_day_of_week()

Returns the numeric representation of the first day of the week
With 0 = Saturday

=item get_day_period($time)

This method will calculate the correct
period for a given time and return the period name in
the locale's language and script

=item format_for($date_time_format)

This method takes a CLDR date time format and returns
the localised version of the format.

=cut

has 'first_day_of_week' => (
	is => 'ro',
	isa => 'Int',
	init_arg => undef,
	lazy => 1,
	builder => "_build_first_day_of_week",
);

has 'likely_subtag' => (
	is => 'ro',
	isa => __PACKAGE__,
	init_arg => undef,
	writer => '_set_likely_subtag',
	predicate => 'has_likely_subtag',
);

sub _build_break {
	my ($self, $what) = @_;

	my $vars = $self->_build_break_vars($what);
	my $rules = $self->_build_break_rules($vars, $what);
	return $rules;
}

sub _build_break_vars {
	my ($self, $what) = @_;

	my $name = "${what}_variables";
	my @bundles = $self->_find_bundle($name);
	my @vars;
	foreach my $bundle (reverse @bundles) {
		push @vars, @{$bundle->$name};
	}

	my %vars = ();
	while (my ($name, $value) = (shift @vars, shift @vars)) {
		last unless defined $name;
		if (! defined $value) {
			delete $vars{$name};
			next;
		}

		$value =~ s{ ( \$ \p{ID_START} \p{ID_CONTINUE}* ) }{$vars{$1}}msxeg;
		$vars{$name} = $value;
	}

	return \%vars;
}

sub _build_break_rules {
	my ($self, $vars, $what) = @_;

	my $name = "${what}_rules";
	my @bundles = $self->_find_bundle($name);

	my %rules;
	foreach my $bundle (reverse @bundles) {
		%rules = (%rules, %{$bundle->$name});
	}

	my @rules;
	foreach my $rule_number ( sort { $a <=> $b } keys %rules ) {
		# Test for deleted rules
		next unless defined $rules{$rule_number};

		$rules{$rule_number} =~ s{ ( \$ \p{ID_START} \p{ID_CONTINUE}* ) }{$vars->{$1}}msxeg;
		my ($first, $opp, $second) = split /(×|÷)/, $rules{$rule_number};

		foreach my $operand ($first, $second) {
			if ($operand =~ m{ \S }msx) {
				$operand = _unicode_to_perl($operand);
			}
			else {
				$operand = '.';
			}
		}
		
		no warnings 'deprecated';
		push @rules, [qr{$first}msx, qr{$second}msx, ($opp eq '×' ? 1 : 0)];
	}

	push @rules, [ '.', '.', 0 ];

	return \@rules;
}

sub BUILDARGS {
	my $self = shift;
	my %args;

	# Used for arguments when we call new from our own code
	my %internal_args = ();
	if (@_ > 1 && ref $_[-1] eq 'HASH') {
		%internal_args = %{pop @_};
	}

	if (1 == @_ && ! ref $_[0]) {
		my ($language, $script, $territory, $variant, $extensions)
		 	= $_[0]=~/^
				([a-zA-Z]+)
				(?:[-_]([a-zA-Z]{4}))?
				(?:[-_]([a-zA-Z]{2,3}))?
				(?:[-_]([a-zA-Z0-9]+))?
				(?:[-_]u[_-](.+))?
			$/x;

		foreach ($language, $script, $territory, $variant) {
			$_ = '' unless defined $_;
		}

		%args = (
			language_id		=> $language,
			script_id		=> $script,
			territory_id	=> $territory,
			variant_id		=> $variant,
			extensions		=> $extensions,
		);
	}

	if (! keys %args ) {
		%args = ref $_[0]
			? %{$_[0]}
			: @_
	}

	# Split up the extensions
	if ( defined $args{extensions} && ! ref $args{extensions} ) {
		$args{extensions} = {
			map {lc}
			split /[_-]/, $args{extensions}
		};
	}

	# Fix casing of args
	$args{language_id}	= lc $args{language_id}			if defined $args{language_id};
	$args{script_id}	= ucfirst lc $args{script_id}	if defined $args{script_id};
	$args{territory_id}	= uc $args{territory_id}		if defined $args{territory_id};
	$args{variant_id}	= uc $args{variant_id}			if defined $args{variant_id};
	
	# Set up undefined language
	$args{language_id} //= 'und';

	$self->SUPER::BUILDARGS(%args, %internal_args);
}

sub BUILD {
	my ($self, $args) = @_;

	# Check that the args are valid
	# also check for aliases
	$args->{language_id} = $self->language_aliases->{$args->{language_id}}
		// $args->{language_id};
		
	die "Invalid language" if $args->{language_id}
		&& ! first { $args->{language_id} eq $_ } $self->valid_languages;

	die "Invalid script" if $args->{script_id} 
		&& ! first { ucfirst lc $args->{script_id} eq $_ } $self->valid_scripts;

	die "Invalid territory" if $args->{territory_id} 
		&&  ( !  ( first { uc $args->{territory_id} eq $_ } $self->valid_territories )
			&& ( ! $self->territory_aliases->{$self->{territory_id}} )
		);
    
	die "Invalid variant" if $args->{variant_id}
		&&  ( !  ( first { uc $args->{variant_id} eq $_ } $self->valid_variants )
			&& ( ! $self->variant_aliases->{lc $self->{variant_id}} )
	);
	
	if ($args->{extensions}) {
		my %valid_keys = $self->valid_keys;
		my %key_aliases = $self->key_names;
		my @keys = keys %{$args->{extensions}};

		foreach my $key ( @keys ) {
			my $canonical_key = $key_aliases{$key} if exists $key_aliases{$key};
			$canonical_key //= $key;
			if ($canonical_key ne $key) {
				$args->{extensions}{$canonical_key} = delete $args->{extensions}{$key};
			}

			$key = $canonical_key;
			die "Invalid extension name" unless exists $valid_keys{$key};
			die "Invalid extension value" unless 
				first { $_ eq $args->{extensions}{$key} } @{$valid_keys{$key}};

			$self->_set_extensions($args->{extensions})
		}
	}

	# Check for variant aliases
	if ($args->{variant_id} && (my $variant_alias = $self->variant_aliases->{lc $self->variant_id})) {
		delete $args->{variant_id};
		my ($what) = keys %{$variant_alias};
		my ($value) = values %{$variant_alias};
		$args->{$what} = $value;
	}
	
	# Now set up the module
	$self->_build_module;
}

after 'BUILD' => sub {

	my $self = shift;
	
	# Fix up likely sub tags
	
	my $likely_subtags = $self->likely_subtags;
	my $likely_subtag;
	my ($language_id, $script_id, $territory_id) = ($self->language_id, $self->script_id, $self->territory_id);
	
	unless ($language_id ne 'und' && $script_id && $territory_id ) {
		$likely_subtag = $likely_subtags->{join '_', grep { length() } ($language_id, $script_id, $territory_id)};
		
		if (! $likely_subtag ) {
			$likely_subtag = $likely_subtags->{join '_', $language_id, $territory_id};
		}
	
		if (! $likely_subtag ) {
			$likely_subtag = $likely_subtags->{join '_', $language_id, $script_id};
		}
	
		if (! $likely_subtag ) { 
			$likely_subtag = $likely_subtags->{$language_id};
		}
	
		if (! $likely_subtag ) {
			$likely_subtag = $likely_subtags->{join '_', 'und', $script_id};
		}
	}
	
	my ($likely_language_id, $likely_script_id, $likely_territory_id);
	if ($likely_subtag) {
		($likely_language_id, $likely_script_id, $likely_territory_id) = split /_/, $likely_subtag;
		$likely_language_id		= $language_id 	unless $language_id eq 'und';
		$likely_script_id		= $script_id	if length $script_id;
		$likely_territory_id	= $territory_id	if length $territory_id;
		$self->_set_likely_subtag(__PACKAGE__->new(join '_',$likely_language_id, $likely_script_id, $likely_territory_id));
	}
	
	# Fix up extension overrides
	my $extensions = $self->extensions;
	if (exists $extensions->{ca}) {
		$self->_set_default_ca(($territory_id // $likely_territory_id) => $extensions->{ca});
	}

	if (exists $extensions->{nu}) {
		$self->_clear_default_nu;
		$self->_set_default_nu($extensions->{nu});
	}
};

use overload 
  'bool'	=> sub { 1 },
  '""'		=> sub {shift->id};

sub _build_id {
	my $self = shift;
	my $string = lc $self->language_id;

	if ($self->script_id) {
		$string.= '_' . ucfirst lc $self->script_id;
	}

	if ($self->territory_id) {
		$string.= '_' . uc $self->territory_id;
	}

	if ($self->variant_id) {
		$string.= '_' . uc $self->variant_id;
	}

	if (defined $self->extensions) {
		$string.= '_u';
		foreach my $key (sort keys %{$self->extensions}) {
			my $value = $self->extensions->{$key};
			$string .= "_${key}_$value";
		}
		$string =~ s/_u$//;
	}

	return $string;
}

sub _get_english {
	my $self = shift;
	my $english;
	if ($self->language_id eq 'en') {
		$english = $self;
	}
	else {
		$english = Locale::CLDR->new('en_Latn_US');
	}

	return $english;
}

sub _build_name {
	my $self = shift;

	return $self->_get_english->native_name($self);
}

sub _build_native_name {
	my ($self, $for) = @_;

	return $self->locale_name($for);
}

sub _build_language {
	my $self = shift;

	return $self->_get_english->native_language($self);
}

sub _build_native_language {
	my ($self, $for) = @_;

	return $self->language_name($for) // '';
}

sub _build_script {
	my $self = shift;

	return $self->_get_english->native_script($self);
}

sub _build_native_script {
	my ($self, $for) = @_;

	return $self->script_name($for);
}

sub _build_territory {
	my $self = shift;

	return $self->_get_english->native_territory($self);
}

sub _build_native_territory {
	my ($self, $for) = @_;

	return $self->territory_name($for);
}

sub _build_variant {
	my $self = shift;

	return $self->_get_english->native_variant($self);
}

sub _build_native_variant {
	my ($self, $for) = @_;

	return $self->variant_name($for);
}

# Method to locate the resource bundle with the required data
sub _find_bundle {
	my ($self, $method_name) = @_;
	my $id = $self->has_likely_subtag()
		? $self->likely_subtag()->id()
		: $self->id(); 
		
	
	if ($self->method_cache->{$id}{$method_name}) {
		return wantarray
			? @{$self->method_cache->{$id}{$method_name}}
			: $self->method_cache->{$id}{$method_name}[0];
	}

	foreach my $module ($self->module->meta->linearized_isa) {
		last if $module eq 'Moose::Object';
		if ($module->meta->has_method($method_name)) {
			push @{$self->method_cache->{$id}{$method_name}}, $module->new;
		}
	}

	return unless $self->method_cache->{$id}{$method_name};
	return wantarray
		? @{$self->method_cache->{$id}{$method_name}}
		: $self->method_cache->{$id}{$method_name}[0];
}

=back

=head2 Names

These methods allow you to pass in a locale, either by C<id> or as a
Locale::CLDR object and return an name formatted in the locale of $self.
If you don't pass in a locale then it will use $self.

=over 4 

=item locale_name($name)

Returns the given locale name in the current locale's format. The name can be
a locale id or a locale object or non existent. If a name is not passed in
then the name of the current locale is returned.

=cut

sub locale_name {
	my ($self, $name) = @_;
	$name //= $self;

	my $code = ref $name
		? join ( '_', $name->language_id, $name->territory_id ? $name->territory_id : () )
		: $name;
	
	my @bundles = $self->_find_bundle('display_name_language');

	foreach my $bundle (@bundles) {
		my $display_name = $bundle->display_name_language->($code);
		return $display_name if defined $display_name;
	}

	# $name can be a string or a Locale::CLDR::Locales::*
	if (! ref $name) {
		$name = Locale::CLDR->new($name);
	}

	# Now we have to process each individual element
	# to pass to the display name pattern
	my $language = $self->language_name($name);
	my $script = $self->script_name($name);
	my $territory = $self->territory_name($name);
	my $variant = $self->variant_name($name);

	my $bundle = $self->_find_bundle('display_name_pattern');
	return $bundle
		->display_name_pattern($language, $territory, $script, $variant);
}

=item language_name($language)

Returns the language name in the current locale's format. The name can be
a locale language id or a locale object or non existent. If a name is not
passed in then the language name of the current locale is returned.

=cut

sub language_name {
	my ($self, $name) = @_;

	$name //= $self;

	my $code = ref $name ? $name->language_id : eval { Locale::CLDR->new(language_id => $name)->language_id };

	my $language = undef;
	my @bundles = $self->_find_bundle('display_name_language');
	if ($code) {
		foreach my $bundle (@bundles) {
			my $display_name = $bundle->display_name_language->($code);
			if (defined $display_name) {
				$language = $display_name;
				last;
			}
		}
	}
	# If we don't have a display name for the language we try again
	# with the und tag
	if (! defined $language ) {
		foreach my $bundle (@bundles) {
			my $display_name = $bundle->display_name_language->('und');
			if (defined $display_name) {
				$language = $display_name;
				last;
			}
		}
	}

	return $language;
}

=item all_languages()

Returns a hash ref keyed on language id of all the languages the system 
knows about. The values are the language names for the corresponding id's 

=cut

sub all_languages {
	my $self = shift;

	my @bundles = $self->_find_bundle('display_name_language');
	my %languages;
	foreach my $bundle (@bundles) {
		my $languages = $bundle->display_name_language->();

		# Remove existing languages
		delete @{$languages}{keys %languages};

		# Assign new ones to the hash
		@languages{keys %$languages} = values %$languages;
	}

	return \%languages;
}

=item script_name($script)

Returns the script name in the current locale's format. The script can be
a locale script id or a locale object or non existent. If a script is not
passed in then the script name of the current locale is returned.

=cut

sub script_name {
	my ($self, $name) = @_;
	$name //= $self;

	if (! ref $name ) {
		$name = eval {__PACKAGE__->new(script_id => $name)};
	}

	if ( ref $name && ! $name->script_id ) {
		return '';
	}

	my $script = undef;
	my @bundles = $self->_find_bundle('display_name_script');
	if ($name) {
		foreach my $bundle (@bundles) {
			$script = $bundle->display_name_script->($name->script_id);
			if (defined $script) {
				last;
			}
		}
	}

	if (! $script) {
		foreach my $bundle (@bundles) {
			$script = $bundle->display_name_script->('Zzzz');
			if (defined $script) {
				last;
			}
		}
	}

	return $script;
}

=item all_scripts()

Returns a hash ref keyed on script id of all the scripts the system 
knows about. The values are the script names for the corresponding id's 

=cut

sub all_scripts {
	my $self = shift;

	my @bundles = $self->_find_bundle('display_name_script');
	my %scripts;
	foreach my $bundle (@bundles) {
		my $scripts = $bundle->display_name_script->();

		# Remove existing scripts
		delete @{$scripts}{keys %scripts};

		# Assign new ones to the hash
		@scripts{keys %$scripts} = values %$scripts;
	}

	return \%scripts;
}

=item territory_name($territory)

Returns the territory name in the current locale's format. The territory can be
a locale territory id or a locale object or non existent. If a territory is not
passed in then the territory name of the current locale is returned.

=cut

sub territory_name {
	my ($self, $name) = @_;
	$name //= $self;

	if (! ref $name ) {
		$name = eval { __PACKAGE__->new(language_id => 'und', territory_id => $name); };
	}

	if ( ref $name && ! $name->territory_id) {
		return '';
	}

	my $territory = undef;
	my @bundles = $self->_find_bundle('display_name_territory');
	if ($name) {
		foreach my $bundle (@bundles) {
			$territory = $bundle->display_name_territory->{$name->territory_id};
			if (defined $territory) {
				last;
			}
		}
	}

	if (! defined $territory) {
		foreach my $bundle (@bundles) {
			$territory = $bundle->display_name_territory->{'ZZ'};
			if (defined $territory) {
				last;
			}
		}
	}

	return $territory;
}

=item all_territories

Returns a hash ref keyed on territory id of all the territory the system 
knows about. The values are the territory names for the corresponding ids 

=cut

sub all_territories {
	my $self = shift;

	my @bundles = $self->_find_bundle('display_name_territory');
	my %territories;
	foreach my $bundle (@bundles) {
		my $territories = $bundle->display_name_territory;

		# Remove existing territories
		delete @{$territories}{keys %territories};

		# Assign new ones to the hash
		@territories{keys %$territories} = values %$territories;
	}

	return \%territories;
}

=item variant_name($variant)

Returns the variant name in the current locale's format. The variant can be
a locale variant id or a locale object or non existent. If a variant is not
passed in then the variant name of the current locale is returned.

=cut

sub variant_name {
	my ($self, $name) = @_;
	$name //= $self;

	if (! ref $name ) {
		$name = __PACKAGE__->new(language_id=> 'und', variant_id => $name);
	}

	return '' unless $name->variant_id;
	my $variant = undef;
	if ($name->has_variant) {
		my @bundles = $self->_find_bundle('display_name_variant');
		foreach my $bundle (@bundles) {
			$variant= $bundle->display_name_variant->{$name->variant_id};
			if (defined $variant) {
				last;
			}
		}
	}

	return $variant // '';
}

=item key_name($key)

Returns the key name in the current locale's format. The key must be
a locale key id as a string

=cut

sub key_name {
	my ($self, $key) = @_;

	$key = lc $key;
	
	my %key_aliases = $self->key_aliases;
	my %key_names	= $self->key_names;
	my %valid_keys	= $self->valid_keys;

	my $alias = $key_aliases{$key} // '';
	my $name  = $key_names{$key} // '';

	return '' unless exists $valid_keys{$key} || exists $valid_keys{$alias} || exists $valid_keys{$name};
	my @bundles = $self->_find_bundle('display_name_key');
	foreach my $bundle (@bundles) {
		my $return = $bundle->display_name_key->{$key};
		$return //= $bundle->display_name_key->{$alias}; 
		$return //= $bundle->display_name_key->{$name}; 

		return $return if defined $return && length $return;
	}

	return ucfirst ($key_names{$name} || $key_names{$alias} || $key_names{$key} || $key);
}

=item type_name($key, $type)

Returns the type name in the current locale's format. The key and type must be
a locale key id and type id as a string

=cut

sub type_name {
	my ($self, $key, $type) = @_;

	$key	= lc $key;
	$type	= lc $type;

	my %key_aliases = $self->key_aliases;
	my %valid_keys	= $self->valid_keys;
	my %key_names	= $self->key_names;

	my $alias = $key_aliases{$key} // '';
	my $name  = $key_names{$key}   // '';

	return '' unless exists $valid_keys{$key} || $valid_keys{$alias} || $valid_keys{$name};
	return '' unless first { $_ eq $type } @{$valid_keys{$key} || []}, @{$valid_keys{$alias} || []}, @{$valid_keys{$name} || []};

	my @bundles = $self->_find_bundle('display_name_type');
	foreach my $bundle (@bundles) {
		my $types = $bundle->display_name_type->{$key} // $bundle->display_name_type->{$alias} // $bundle->display_name_type->{$name};
		my $type = $types->{$type};
		return $type if defined $type;
	}

	return '';
}
	
=item measurement_system_name($measurement_system)

Returns the measurement system name in the current locale's format. The measurement system must be
a measurement system id as a string

=cut
	
sub measurement_system_name {
	my ($self, $name) = @_;

	# Fix case of code
	$name = uc $name;
	$name = 'metric' if $name eq 'METRIC';

	my @bundles = $self->_find_bundle('display_name_measurement_system');
	foreach my $bundle (@bundles) {
		my $system = $bundle->display_name_measurement_system->{$name};
		return $system if defined $system;
	}

	return '';
}

=item transform_name($name)

Returns the transform (transliteration) name in the current locale's format. The transform must be
a transform id as a string

=cut

sub transform_name {
	my ($self, $name) = @_;

	$name = lc $name;

	my @bundles = $self->_find_bundle('display_name_transform_name');
	foreach my $bundle (@bundles) {
		my $key = $bundle->display_name_transform_name->{$name};
		return $key if length $key;
	}

	return '';
}

=item code_pattern($type, $locale)

This method formats a language, script or territory name, given as C<$type>
from C<$locale> in a way expected by the current locale. If $locale is
not passed in or is undef() the method uses the current locale.

=cut

sub code_pattern {
	my ($self, $type, $locale) = @_;
	$type = lc $type;

	# If locale is not passed in then we are using ourself
	$locale //= $self;

	# If locale is not an object then inflate it
	$locale = __PACKAGE__->new($locale) unless blessed $locale;

	return '' unless $type =~ m{ \A (?: language | script | territory ) \z }xms;

	my $method = $type . '_name';
	my $substitute = $self->$method($locale);

	my @bundles = $self->_find_bundle('display_name_code_patterns');
	foreach my $bundle (@bundles) {
		my $text = $bundle->display_name_code_patterns->{$type};
		next unless defined $text;
		my $match = qr{ \{ 0 \} }xms;
		$text=~ s{ $match }{$substitute}gxms;
		return $text;
	}

	return '';
}

=item text_orientation($type)

Gets the text orientation for the locale. Type must be one of 
C<lines> or C<characters>

=cut

sub text_orientation {
	my $self = shift;
	my $type = shift;

	my @bundles = $self->_find_bundle('text_orientation');
	foreach my $bundle (@bundles) {
		my $orientation = $bundle->text_orientation;
		next unless defined $orientation;
		return $orientation->{$type};
	}

	return;
}

sub _set_casing {
	my ($self, $casing, $string) = @_;

	my @words = $self->split_words($string);

	if ($casing eq 'titlecase-firstword') {
		# Check to see whether $words[0] is white space or not
		my $firstword_location = 0;
 		if ($words[0] =~ m{ \A \s }msx) {
			$firstword_location = 1;
		}

		$words[$firstword_location] = ucfirst $words[$firstword_location];
	}
	elsif ($casing eq 'titlecase-words') {
		@words = map{ ucfirst } @words;
	}
	elsif ($casing eq 'lowercase-words') {
		@words = map{ lc } @words;
	}

	return join '', @words;
}

=back

=head2 Segmentation

This group of methods allow you to split a string in various ways
Note you need Perl 5.18 or above for this

=over 4

=item split_grapheme_clusters($string)

Splits a string on grapheme clusters using the locale's segmentation rules.
Returns a list of grapheme clusters.

=cut
# Need 5.18 and above
sub _new_perl {
	die "You need Perl 5.18 or later for this functionality\n"
		 if $^V lt v5.18.0;
}

sub split_grapheme_clusters {
	_new_perl();
	
	my ($self, $string) = @_;

	my $rules = $self->break_grapheme_cluster;
	my @clusters = $self->_split($rules, $string, 1);

	return @clusters;
}

=item split_words($string)

Splits a string on word boundaries using the locale's segmentation rules.
Returns a list of words.

=cut

sub split_words {
	_new_perl();
	
	my ($self, $string) = @_;

	my $rules = $self->break_word;
	my @words = $self->_split($rules, $string);

	return @words;
}

=item split_sentences($string)

Splits a string on on all points where a sentence could
end using the locale's segmentation rules. Returns a list
the end of each list element is the point where a sentence
could end.

=cut

sub split_sentences {
	_new_perl();
	
	my ($self, $string) = @_;

	my $rules = $self->break_sentence;
	my @sentences = $self->_split($rules, $string);

	return @sentences;
}

=item split_lines($string)

Splits a string on on all points where a line could
end using the locale's segmentation rules. Returns a list
the end of each list element is the point where a line
could end.

=cut

sub split_lines {
	_new_perl();
	
	my ($self, $string) = @_;

	my $rules = $self->break_line;
	my @lines = $self->_split($rules, $string);

	return @lines;
}

sub _split {
	my ($self, $rules, $string, $grapheme_split) = @_;

	my @split = (scalar @$rules) x (length($string) - 1);

	pos($string)=0;
	# The Unicode Consortium has deprecated LB=Surrogate but the CLDR still
	# uses it, at last in this version.
	no warnings 'deprecated';
	while (length($string) -1 != pos $string) {
		my $rule_number = 0;
		my $first;
		foreach my $rule (@$rules) {
			unless( ($first) = $string =~ m{
				\G
				($rule->[0])
				$rule->[1]
			}msx) {
				$rule_number++;
				next;
			}
			my $location = pos($string) + length($first) -1;
			$split[$location] = $rule_number;
			
			# If the left hand side was part of a grapheme cluster 
			# we have to jump past the entire cluster
			my $length = length $first;
			my ($gc) = $string =~ /\G(\X)/;
			$length = (! $grapheme_split && length($gc)) > $length ? length($gc) : $length;
			pos($string)+= $length;
			last;
		}
	}

	push @$rules,[undef,undef,1];
	@split = map {$rules->[$_][2] ? 1 : 0} @split;
	my $count = 0;
	my @sections = ('.');
	foreach my $split (@split) {
		$count++ unless $split;
		$sections[$count] .= '.';
	}
	
	my $regex = '(' . join(')(', @sections) . ')';
	$regex = qr{ \A $regex \z}msx;
	@split = $string =~ $regex;

	return @split;
}

=back

=head2 Characters

=over 4

=item is_exemplar_character( $type, $character)

=item is_exemplar_character($character)

Tests if the given character is used in the locale. There are 
three possible types; C<main>, C<auxiliary> and C<punctuation>.
If no type is given C<main> is assumed. Unless the C<index> type
is given you will have to have a Perl version of 5.18 or above
to use this method

=cut

sub is_exemplar_character {
	my ($self, @parameters) = @_;
	unshift @parameters, 'main' if @parameters == 1;

	_new_perl() unless $parameters[0] eq 'index';
	
	my @bundles = $self->_find_bundle('characters');
	foreach my $bundle (@bundles) {
		my $characters = $bundle->characters->{lc $parameters[0]};
		next unless defined $characters;
		return 1 if fc($parameters[1])=~$characters;
	}

	return;
}

=item index_characters()

Returns an array ref of characters normally used when creating 
an index and ordered appropriately.

=cut

sub index_characters {
	my $self = shift;

	my @bundles = $self->_find_bundle('characters');
	foreach my $bundle (@bundles) {
		my $characters = $bundle->characters->{index};
		next unless defined $characters;
		return $characters;
	}
	return [];
}

sub _truncated {
	my ($self, $type, @params) = @_;

	my @bundles = $self->_find_bundle('ellipsis');
	foreach my $bundle (@bundles) {
		my $ellipsis = $bundle->ellipsis->{$type};
		next unless defined $ellipsis;
		$ellipsis=~s{ \{ 0 \} }{$params[0]}msx;
		$ellipsis=~s{ \{ 1 \} }{$params[1]}msx;
		return $ellipsis;
	}
}

=back

=head2 Truncation

These methods format a string to show where part of the string has been removed

=over 4

=item truncated_beginning($string)

Adds the locale specific marking to show that the 
string has been truncated at the beginning.

=cut

sub truncated_beginning {
	shift->_truncated(initial => @_);
}

=item truncated_between($string, $string)

Adds the locale specific marking to show that something 
has been truncated between the two strings. Returns a
string comprising of the concatenation of the first string,
the mark and the second string

=cut

sub truncated_between {
	shift->_truncated(medial => @_);
}

=item truncated_end($string)

Adds the locale specific marking to show that the 
string has been truncated at the end.

=cut

sub truncated_end {
	shift->_truncated(final => @_);
}

=item truncated_word_beginning($string)

Adds the locale specific marking to show that the 
string has been truncated at the beginning. This
should be used in preference to C<truncated_beginning>
when the truncation occurs on a word boundary.

=cut

sub truncated_word_beginning {
	shift->_truncated('word-initial' => @_);
}

=item truncated_word_between($string, $string)

Adds the locale specific marking to show that something 
has been truncated between the two strings. Returns a
string comprising of the concatenation of the first string,
the mark and the second string. This should be used in
preference to C<truncated_between> when the truncation
occurs on a word boundary.

=cut

sub truncated_word_between {
	shift->_truncated('word-medial' => @_);
}

=item truncated_word_end($string)

Adds the locale specific marking to show that the 
string has been truncated at the end. This should be
used in preference to C<truncated_end> when the
truncation occurs on a word boundary.

=cut

sub truncated_word_end {
	shift->_truncated('word-final' => @_);
}

=back

=head2 Quoting

=over 4

=item quote($string)

Adds the locale's primary quotation marks to the ends of the string.
Also scans the string for paired primary and auxiliary quotation
marks and flips them.

eg passing C<z “abc” z> to this method for the C<en_GB> locale
gives C<“z ‘abc’ z”>

=cut

sub quote {
	my ($self, $text) = @_;

	my %quote;
	my @bundles = $self->_find_bundle('quote_start');
	foreach my $bundle (@bundles) {
		my $quote = $bundle->quote_start;
		next unless defined $quote;
		$quote{start} = $quote;
		last;
	}

	@bundles = $self->_find_bundle('quote_end');
	foreach my $bundle (@bundles) {
		my $quote = $bundle->quote_end;
		next unless defined $quote;
		$quote{end} = $quote;
		last;
	}

	@bundles = $self->_find_bundle('alternate_quote_start');
	foreach my $bundle (@bundles) {
		my $quote = $bundle->alternate_quote_start;
		next unless defined $quote;
		$quote{alternate_start} = $quote;
		last;
	}

	@bundles = $self->_find_bundle('alternate_quote_end');
	foreach my $bundle (@bundles) {
		my $quote = $bundle->alternate_quote_end;
		next unless defined $quote;
		$quote{alternate_end} = $quote;
		last;
	}

	# Check to see if we need to switch quotes
	foreach (qw( start end alternate_start alternate_end)) {
		$quote{$_} //= '';
	}

	my $from = join ' | ', map {quotemeta} @quote{qw( start end alternate_start alternate_end)};
	my %to;
	@to{@quote{qw( start end alternate_start alternate_end)}}
		= @quote{qw( alternate_start alternate_end start end)};

	my $outer = index($text, $quote{start});
	my $inner = index($text, $quote{alternate_start});

	if ($inner == -1 || ($outer > -1 && $inner > -1 && $outer < $inner)) {
		$text =~ s{ ( $from ) }{ $to{$1} }msxeg;
	}

	return "$quote{start}$text$quote{end}";
}

=back

=head2 Miscellaneous

=over 4

=item more_information()

The more information string is one that can be displayed
in an interface to indicate that more information is
available.

=cut

sub more_information {
	my $self = shift;

	my @bundles = $self->_find_bundle('more_information');
	foreach my $bundle (@bundles) {
		my $info = $bundle->more_information;
		next unless defined $info;
		return $info;
	}
	return '';
}


=item measurement()

Returns the measurement type for the locale

=cut

sub measurement {
	my $self = shift;
	
	my $measurement_data = $self->measurement_system;
	my $territory = $self->territory_id // '001';
	
	my $data = $measurement_data->{$territory};
	
	until (defined $data) {
		$territory = $self->territory_contained_by->{$territory};
		$data = $measurement_data->{$territory};
	}
	
	return $data;
}

=item paper()

Returns the paper type for the locale

=cut

sub paper {
	my $self = shift;
	
	my $paper_size = $self->paper_size;
	my $territory = $self->territory_id // '001';
	
	my $data = $paper_size->{$territory};
	
	until (defined $data) {
		$territory = $self->territory_contained_by->{$territory};
		$data = $paper_size->{$territory};
	}
	
	return $data;
}

=back

=head2 Units

=over 4

=item all_units()

Returns a list of all the unit identifiers for the locale

=cut

sub all_units {
	my $self = shift;
	my @bundles = $self->_find_bundle('units');
	
	my %units;
	foreach my $bundle (reverse @bundles) {
		%units = %units, $bundle->units;
	}
	
	return keys %units;
}

=item unit($number, $unit, $width)

Returns the localised string for the given number and unit formatted for the 
required width. The number must not be the localized version of the number.
The returned string will be in the locale's format, including the number.

=cut

sub unit {
	my ($self, $number, $what, $type) = @_;
	$type //= 'long';
	
	my $plural = $self->plural($number);
	
	my @bundles = $self->_find_bundle('units');
	my $format;
	foreach my $bundle (@bundles) {
		if (exists $bundle->units()->{$type}{$what}{$plural}) {
			$format = $bundle->units()->{$type}{$what}{$plural};
			last;
		}
			
		if (exists $bundle->units()->{$type}{$what}{other}) {
			$format = $bundle->units()->{$type}{$what}{other};
			last;
		}
	}
	
	# Check for aliases
	unless ($format) {
		my $original_type = $type;
		my @aliases = $self->_find_bundle('unit_alias');
		foreach my $alias (@aliases) {
			$type = $alias->unit_alias()->{$original_type};
			next unless $type;
			foreach my $bundle (@bundles) {
				if (exists $bundle->units()->{$type}{$what}{$plural}) {
					$format = $bundle->units()->{$type}{$what}{$plural};
					last;
				}
			
				if (exists $bundle->units()->{$type}{$what}{other}) {
					$format = $bundle->units()->{$type}{$what}{other};
					last;
				}
			}
		}
		$type = $original_type;
	}
	
	# Check for a compound unit that we don't specifically have
	if (! $format && (my ($dividend, $divisor) = $what =~ /^(.+)-per-(.+)$/)) {
		return $self->_unit_compound($number, $dividend, $divisor, $type);
	}
	
	$number = $self->format_number($number);
	return $number unless $format;
	
	$format =~ s/\{0\}/$number/g;
	
	return $format;
}

sub _unit_compound {
	my ($self, $number, $dividend_what, $divisor_what, $type) = @_;
	
	$type //= 'long';
	
	my $dividend = $self->unit($number, $dividend_what, $type);
	my $divisor = $self->_unit_per($divisor_what, $type);
	if ($divisor) {
		my $format = $divisor;
		$format =~ s/\{0\}/$dividend/;
		return $format;
	}
	
	$divisor = $self->unit(1, $divisor_what, $type);
	
	my $one = $self->format_number(1);
	$divisor =~ s/\s*$one\s*//;
	
	my @bundles = $self->_find_bundle('units');
	my $format;
	foreach my $bundle (@bundles) {
		if (exists $bundle->units()->{$type}{per}{''}) {
			$format = $bundle->units()->{$type}{per}{''};
			last;
		}
	}

	# Check for aliases
	unless ($format) {
		my $original_type = $type;
		my @aliases = $self->_find_bundle('unit_alias');
		foreach my $alias (@aliases) {
			$type = $alias->unit_alias()->{$original_type};
			foreach my $bundle (@bundles) {
				if (exists $bundle->units()->{$type}{per}{1}) {
					$format = $bundle->units()->{$type}{per}{1};
					last;
				}
			}
		}
	}
	
	$format =~ s/\{0\}/$dividend/g;
	$format =~ s/\{1\}/$divisor/g;
	
	return $format;
}

=item unit_name($unit_identifier)

This method returns the localised name of the unit

=cut

sub unit_name {
    my ($self, $what) = @_;
	
	my @bundles = $self->_find_bundle('units');
	my $name;
	foreach my $bundle (@bundles) {
		if (exists $bundle->units()->{long}{$what}{name}) {
			return $bundle->units()->{long}{$what}{name};
		}
	}
	
	# Check for aliases
	my $type = 'long';
	my @aliases = $self->_find_bundle('unit_alias');
	foreach my $alias (@aliases) {
		$type = $alias->unit_alias()->{$type};
		next unless $type;
		foreach my $bundle (@bundles) {
			if (exists $bundle->units()->{$type}{$what}{name}) {
				return $bundle->units()->{$type}{$what}{name};
			}
		}
	}
	
	return '';
}

sub _unit_per {
    my ($self, $what, $type) = @_;
	
	my @bundles = $self->_find_bundle('units');
	my $name;
	foreach my $bundle (@bundles) {
		if (exists $bundle->units()->{$type}{$what}{per}) {
			return $bundle->units()->{$type}{$what}{per};
		}
	}
	
	# Check for aliases
	my @aliases = $self->_find_bundle('unit_alias');
	foreach my $alias (@aliases) {
		$type = $alias->unit_alias()->{$type};
		next unless $type;
		foreach my $bundle (@bundles) {
			if (exists $bundle->units()->{$type}{$what}{per}) {
				return $bundle->units()->{$type}{$what}{per};
			}
		}
	}
	
	return '';
}

sub _get_time_separator {
	my $self = shift;

	my @number_symbols_bundles = $self->_find_bundle('number_symbols');
	my $symbols_type = $self->default_numbering_system;
	
	foreach my $bundle (@number_symbols_bundles) {	
		if (exists $bundle->number_symbols()->{$symbols_type}{alias}) {
			$symbols_type = $bundle->number_symbols()->{$symbols_type}{alias};
			redo;
		}
		
		return $bundle->number_symbols()->{$symbols_type}{timeSeparator}
			if exists $bundle->number_symbols()->{$symbols_type}{timeSeparator};
	}
	return ':';
}

=item duration_unit($format, @data)

This method formats a duration. The format must be one of
C<hm>, C<hms> or C<ms> corresponding to C<hour minute>, 
C<hour minute second> and C<minute second> respectively.
The data must correspond to the given format. 

=cut

sub duration_unit {
	# data in hh,mm; hh,mm,ss or mm,ss 
	my ($self, $format, @data) = @_;
	
	my $bundle = $self->_find_bundle('duration_units');
	my $parsed = $bundle->duration_units()->{$format};
	
	my $num_format = '#';
	foreach my $entry ( qr/(hh?)/, qr/(mm?)/, qr/(ss?)/) {
		$num_format = '00' if $parsed =~ s/$entry/$self->format_number(shift(@data), $num_format)/e;
	}
	
	my $time_separator = $self->_get_time_separator;
	
	$parsed =~ s/:/$time_separator/g;
	
	return $parsed;
}

=back

=head2 Yes or No?

=over 4

=item is_yes($string)

Returns true if the passed in string matches the locale's 
idea of a string designating yes. Note that under POSIX
rules unless the locale's word for yes starts with C<Y>
(U+0079) then a single 'y' will also be accepted as yes.
The string will be matched case insensitive.

=cut

sub is_yes {
	my ($self, $test_str) = @_;
	
	my $bundle = $self->_find_bundle('yesstr');
	return $test_str =~ $bundle->yesstr ? 1 : 0;
}

=item is_no($string)

Returns true if the passed in string matches the locale's 
idea of a string designating no. Note that under POSIX
rules unless the locale's word for no starts with C<n>
(U+006E) then a single 'n' will also be accepted as no
The string will be matched case insensitive.

=cut

sub is_no {
	my ($self, $test_str) = @_;
	
	my $bundle = $self->_find_bundle('nostr');
	return $test_str =~ $bundle->nostr ? 1 : 0;
}

=back

=head2 Transliteration

This method requires Perl version 5.18 or above to use and for you to have
installed the optional C<Bundle::CLDR::Transformations>

=over 4

=item transform(from => $from, to => $to, variant => $variant, text => $text)

This method returns the transliterated string of C<text> from script C<from>
to script C<to> using variant C<variant>. If C<from> is not given then the 
current locale's script is used. If C<text> is not given then it defaults to an
empty string. The C<variant> is optional.

=cut

sub transform {
	_new_perl();
	
	my ($self, %params) = @_;
	
	my $from 	= $params{from} // $self;
	my $to 		= $params{to}; 
	my $variant	= $params{variant} // 'Any';
	my $text	= $params{text} // '';
	
	($from, $to) = map {ref $_ ? $_->likely_script() : $_} ($from, $to);
	$_ = ucfirst(lc $_) foreach ($from, $to, $variant);
	
	my $package = __PACKAGE__ . "::Transformations::${variant}::${from}::${to}";
	eval { Class::Load::load_class($package); };
	warn $@ if $@;
	return $text if $@; # Can't load transform module so return original text
	use feature 'state';
	state $transforms;
	$transforms->{$variant}{$from}{$to} //= $package->new();
	my $rules = $transforms->{$variant}{$from}{$to}->transforms();
	
	# First get the filter rule
	my $filter = $rules->[0];
		
	# Break up the input on the filter
	my @text;
	pos($text) = 0;
	while (pos($text) < length($text)) {
		my $characters = '';
		while (my ($char) = $text =~ /($filter)/) {
			$characters .= $char;
			pos($text) = pos($text) + length $char;
		}
		push @text, $characters;
		last unless pos($text) < length $text;
		
		$characters = '';
		while ($text !~ /$filter/) {
			my ($char) = $text =~ /\G(\X)/;
			$characters .= $char;
			pos($text) = pos($text) + length $char;
		}
		push @text, $characters;
	}
	
	my $to_transform = 1;
	
	foreach my $characters (@text) {
		if ($to_transform) {
			foreach my $rule (@$rules[1 .. @$rules -1 ]) {
				if ($rule->{type} eq 'transform') {
					$characters = $self->_transformation_transform($characters, $rule->{data}, $variant);
				}
				else {
					$characters = $self->_transform_convert($characters, $rule->{data});
				}
			}
		}
		$to_transform = ! $to_transform;
	}
	
	return join '', @text;
}

sub _transformation_transform {
	my ($self, $text, $rules, $variant) = @_;
		
	foreach my $rule (@$rules) {
		for (lc $rule->{to}) {
			if ($_ eq 'nfc') {
				$text = Unicode::Normalize::NFC($text);
			}
			elsif($_ eq 'nfd') {
				$text = Unicode::Normalize::NFD($text);
			}
			elsif($_ eq 'nfkd') {
				$text = Unicode::Normalize::NFKD($text);
			}
			elsif($_ eq 'nfkc') {
				$text = Unicode::Normalize::NFKC($text);
			}
			elsif($_ eq 'lower') {
				$text = lc($text);
			}
			elsif($_ eq 'upper') {
				$text = uc($text);
			}
			elsif($_ eq 'title') {
				$text =~ s/(\X)/\u$1/g;
			}
			elsif($_ eq 'null') {
			}
			elsif($_ eq 'remove') {
				$text = '';
			}
			else {
				$text = $self->transform($text, $variant, $rule->{from}, $rule->to);
			}
		}
	}
	return $text;
}

sub _transform_convert {
	my ($self, $text, $rules) = @_;
	
	pos($text) = 0; # Make sure we start scanning at the beginning of the text
		
	CHARACTER: while (pos($text) < length($text)) {
		foreach my $rule (@$rules) {
			next if length $rule->{before} && $text !~ /$rule->{before}\G/;
			my $regex = $rule->{replace};
			$regex .= '(' . $rule->{after} . ')' if length $rule->{after};
			my $result = 'q(' . $rule->{result} . ')';
			$result .= '. $1' if length $rule->{after};
			if ($text =~ s/\G$regex/eval $result/e) {
				pos($text) += length($rule->{result}) - $rule->{revisit};
				next CHARACTER;
			}
		}
		
		pos($text)++;
	}
	
	return $text;
}

=back

=head2 Lists

=over 4

=item list(@data)

Returns C<data> as a string formatted by the locales idea of producing a list
of elements. What is returned can be effected by the locale and the number
of items in C<data>. Note that C<data> can contain 0 or more items.

=cut

sub list {
	my ($self, @data) = @_;
	
	# Short circuit on 0 or 1 entries
	return '' unless @data;
	return $data[0] if 1 == @data;
	
	my @bundles = $self->_find_bundle('listPatterns');
	
	my %list_data;
	foreach my $bundle (reverse @bundles) {
		my %listPatterns = %{$bundle->listPatterns};
		@list_data{keys %listPatterns} = values %listPatterns;
	}
	
	if (my $pattern = $list_data{scalar @data}) {
		$pattern=~s/\{([0-9]+)\}/$data[$1]/eg;
		return $pattern;
	}
	
	my ($start, $middle, $end) = @list_data{qw( start middle end )};
	
	# First do the end
	my $pattern = $end;
	$pattern=~s/\{1\}/pop @data/e;
	$pattern=~s/\{0\}/pop @data/e;
	
	# If there is any data left do the middle
	while (@data > 1) {
		my $current = $pattern;
		$pattern = $middle;
		$pattern=~s/\{1\}/$current/;
		$pattern=~s/\{0\}/pop @data/e;
	}
	
	# Now do the start
	my $current = $pattern;
	$pattern = $start;
	$pattern=~s/\{1\}/$current/;
	$pattern=~s/\{0\}/pop @data/e;
	
	return $pattern;
}

=back

=head2 Pluralisation

=over 4

=item plural($number)

This method takes a number and uses the locale's pluralisation
rules to calculate the type of pluralisation required for
units, currencies and other data that changes depending on
the plural state of the number

=item plural_range($start, $end)

This method returns the plural type for the range $start to $end
$start and $end can either be numbers or one of the plural types
C<zero one two few many other>

=cut

sub _clear_calendar_data {
	my $self = shift;

	foreach my $property (qw(
		month_format_wide month_format_abbreviated month_format_narrow
		month_stand_alone_wide month_stand_alone_abbreviated
		month_stand_alone_narrow day_format_wide day_format_abbreviated
		day_format_narrow day_stand_alone_wide day_stand_alone_abreviated
		day_stand_alone_narrow quater_format_wide quater_format_abbreviated
		quater_format_narrow quater_stand_alone_wide
		quater_stand_alone_abreviated quater_stand_alone_narrow
		am_pm_wide am_pm_abbreviated am_pm_narrow am_pm_format_wide 
		am_pm_format_abbreviated am_pm_format_narrow am_pm_stand_alone_wide 
		am_pm_stand_alone_abbreviated am_pm_stand_alone_narrow era_wide 
		era_abbreviated era_narrow date_format_full date_format_long date_format_medium
		date_format_short time_format_full
		time_format_long time_format_medium time_format_short
		datetime_format_full datetime_format_long
		datetime_format_medium datetime_format_short
		available_formats format_data
	)) {
		my $method = "_clear_$property";
		$self->$method;
	}
}

sub _build_any_month {
	my ($self, $type, $width) = @_;
	my $default_calendar = $self->default_calendar();
	my @bundles = $self->_find_bundle('calendar_months');
	BUNDLES: {
		foreach my $bundle (@bundles) {
			my $months = $bundle->calendar_months;
			if (exists $months->{$default_calendar}{alias}) {
				$default_calendar = $months->{$default_calendar}{alias};
				redo BUNDLES;
			}

			if (exists $months->{$default_calendar}{$type}{$width}{alias}) {
				($type, $width) = @{$months->{$default_calendar}{$type}{$width}{alias}}{qw(context type)};
				redo BUNDLES;
			}
			
			my $result = $months->{$default_calendar}{$type}{$width}{nonleap};
			return $result if defined $result;
		}
		if ($default_calendar ne 'gregorian') {
			$default_calendar = 'gregorian';
			redo BUNDLES;
		}
	}
	return [];
}

sub _build_month_format_wide {
	my $self = shift;
	my ($type, $width) = (qw(format wide));
	
	return $self->_build_any_month($type, $width);
}

sub _build_month_format_abbreviated {
	my $self = shift;
	my ($type, $width) = (qw(format abbreviated));
	
	return $self->_build_any_month($type, $width);
}

sub _build_month_format_narrow {
	my $self = shift;
	my ($type, $width) = (qw(format narrow));
	
	return $self->_build_any_month($type, $width);
}

sub _build_month_stand_alone_wide {
	my $self = shift;
	my ($type, $width) = ('stand-alone', 'wide');
	
	return $self->_build_any_month($type, $width);
}

sub _build_month_stand_alone_abbreviated {
	my $self = shift;
	my ($type, $width) = ('stand-alone', 'abbreviated');
	
	return $self->_build_any_month($type, $width);
}

sub _build_month_stand_alone_narrow {
	my $self = shift;
	my ($type, $width) = ('stand-alone', 'narrow');
	
	return $self->_build_any_month($type, $width);
}

sub _build_any_day {
	my ($self, $type, $width) = @_;
	
	my $default_calendar = $self->default_calendar();

	my @bundles = $self->_find_bundle('calendar_days');
	BUNDLES: {
		foreach my $bundle (@bundles) {
			my $days= $bundle->calendar_days;
			
			if (exists $days->{$default_calendar}{alias}) {
				$default_calendar = $days->{$default_calendar}{alias};
				redo BUNDLES;
			}

			if (exists $days->{$default_calendar}{$type}{$width}{alias}) {
				($type, $width) = @{$days->{$default_calendar}{$type}{$width}{alias}}{qw(context type)};
				redo BUNDLES;
			}
			my $result = $days->{$default_calendar}{$type}{$width};
			return [ @{$result}{qw( mon tue wed thu fri sat sun )} ] if keys %$result;
		}
		if ($default_calendar ne 'gregorian') {
			$default_calendar = 'gregorian';
			redo BUNDLES;
		}
	}

	return [];
}

sub _build_day_format_wide {
	my $self = shift;
	my ($type, $width) = (qw(format wide));
	
	return $self->_build_any_day($type, $width);
}

sub _build_day_format_abbreviated {
	my $self = shift;
	my ($type, $width) = (qw(format abbreviated));
	
	return $self->_build_any_day($type, $width);
}

sub _build_day_format_narrow {
	my $self = shift;
	my ($type, $width) = (qw(format narrow));
	
	return $self->_build_any_day($type, $width);
}

sub _build_day_stand_alone_wide {
	my $self = shift;
	my ($type, $width) = ('stand-alone', 'wide');
	
	return $self->_build_any_day($type, $width);
}

sub _build_day_stand_alone_abbreviated {
	my $self = shift;
	my ($type, $width) = ('stand-alone', 'abbreviated');

	return $self->_build_any_day($type, $width);
}

sub _build_day_stand_alone_narrow {
	my $self = shift;
	my ($type, $width) = ('stand-alone', 'narrow');
	
	return $self->_build_any_day($type, $width);
}

sub _build_any_quarter {
	my ($self, $type, $width) = @_;
	
	my $default_calendar = $self->default_calendar();

	my @bundles = $self->_find_bundle('calendar_quarters');
	BUNDLES: {
		foreach my $bundle (@bundles) {
			my $quarters= $bundle->calendar_quarters;
			
			if (exists $quarters->{$default_calendar}{alias}) {
				$default_calendar = $quarters->{$default_calendar}{alias};
				redo BUNDLES;
			}

			if (exists $quarters->{$default_calendar}{$type}{$width}{alias}) {
				($type, $width) = @{$quarters->{$default_calendar}{$type}{$width}{alias}}{qw(context type)};
				redo BUNDLES;
			}
			
			my $result = $quarters->{$default_calendar}{$type}{$width};
			return [ @{$result}{qw( 0 1 2 3 )} ] if keys %$result;
		}
		if ($default_calendar ne 'gregorian') {
			$default_calendar = 'gregorian';
			redo BUNDLES;
		}
	}

	return [];
}

sub _build_quarter_format_wide {
	my $self = shift;
	my ($type, $width) = (qw( format wide ));
	
	return $self->_build_any_quarter($type, $width);
}

sub _build_quarter_format_abbreviated {
	my $self = shift;
	my ($type, $width) = (qw(format abbreviated));

	return $self->_build_any_quarter($type, $width);
}

sub _build_quarter_format_narrow {
	my $self = shift;
	my ($type, $width) = (qw(format narrow));

	return $self->_build_any_quarter($type, $width);
}

sub _build_quarter_stand_alone_wide {
	my $self = shift;
	my ($type, $width) = ('stand-alone', 'wide');

	return $self->_build_any_quarter($type, $width);
}

sub _build_quarter_stand_alone_abbreviated {
	my $self = shift;
	my ($type, $width) = ('stand-alone', 'abbreviated');
	
	return $self->_build_any_quarter($type, $width);
}

sub _build_quarter_stand_alone_narrow {
	my $self = shift;
	my ($type, $width) = ('stand-alone', 'narrow');

	return $self->_build_any_quarter($type, $width);
}

sub get_day_period {
	# Time in hhmm
	my ($self, $time) = @_;
	
	my $default_calendar = $self->default_calendar();
	
	my $bundle = $self->_find_bundle('day_period_data');
	
	my $day_period = $bundle->day_period_data;
	$day_period = $self->$day_period($default_calendar, $time);
	
	my $am_pm = $self->am_pm_format_abbreviated;
	
	return $am_pm->{$day_period};
}

sub _build_any_am_pm {
	my ($self, $type, $width) = @_;

	my $default_calendar = $self->default_calendar();
	my @result;
	my @bundles = $self->_find_bundle('day_periods');
	my %return;

	BUNDLES: {
		foreach my $bundle (@bundles) {
			my $am_pm = $bundle->day_periods;
	
			if (exists $am_pm->{$default_calendar}{alias}) {
				$default_calendar = $am_pm->{$default_calendar}{alias};
				redo BUNDLES;
			}

			if (exists $am_pm->{$default_calendar}{$type}{alias}) {
				$type = $am_pm->{$default_calendar}{$type}{alias};
				redo BUNDLES;
			}
			
			if (exists $am_pm->{$default_calendar}{$type}{$width}{alias}) {
				$width = $am_pm->{$default_calendar}{$type}{$width}{alias};
				redo BUNDLES;
			}
			
			my $result = $am_pm->{$default_calendar}{$type}{$width};
			
			foreach (keys %$result) {
				$return{$_} = $result->{$_} unless exists $return{$_};
			}
		}
	}

	return \%return;
}

# The first 3 are to link in with Date::Time::Locale
sub _build_am_pm_wide {
	my $self = shift;
	my ($type, $width) = (qw( format wide ));
	
	my $result = $self->_build_any_am_pm($type, $width);
	
	return [ @$result{qw( am pm )} ];
}

sub _build_am_pm_abbreviated {
	my $self = shift;
	my ($type, $width) = (qw( format abbreviated ));

	my $result = $self->_build_any_am_pm($type, $width);
	
	return [ @$result{qw( am pm )} ];
}

sub _build_am_pm_narrow {
	my $self = shift;
	my ($type, $width) = (qw( format narrow ));
	
	my $result = $self->_build_any_am_pm($type, $width);
	
	return [ @$result{qw( am pm )} ];
}

# Now we do the full set of data
sub _build_am_pm_format_wide {
	my $self = shift;
	my ($type, $width) = (qw( format wide ));
	
	return $self->_build_any_am_pm($type, $width);
}

sub _build_am_pm_format_abbreviated {
	my $self = shift;
	my ($type, $width) = (qw( format abbreviated ));

	return $self->_build_any_am_pm($type, $width);
}

sub _build_am_pm_format_narrow {
	my $self = shift;
	my ($type, $width) = (qw( format narrow ));
	
	return $self->_build_any_am_pm($type, $width);
}

sub _build_am_pm_stand_alone_wide {
	my $self = shift;
	my ($type, $width) = ('stand-alone', 'wide');
	
	return $self->_build_any_am_pm($type, $width);
}

sub _build_am_pm_stand_alone_abbreviated {
	my $self = shift;
	my ($type, $width) = ('stand-alone', 'abbreviated');

	return $self->_build_any_am_pm($type, $width);
}

sub _build_am_pm_stand_alone_narrow {
	my $self = shift;
	my ($type, $width) = ('stand-alone', 'narrow');
	
	return $self->_build_any_am_pm($type, $width);
}

sub _build_any_era {
	my ($self, $width) = @_;

	my $default_calendar = $self->default_calendar();
	my @bundles = $self->_find_bundle('eras');
	BUNDLES: {
		foreach my $bundle (@bundles) {
			my $eras = $bundle->eras;
	
			if (exists $eras->{$default_calendar}{alias}) {
				$default_calendar = $eras->{$default_calendar}{alias};
				redo BUNDLES;
			}

			if (exists $eras->{$default_calendar}{$width}{alias}) {
				$width = $eras->{$default_calendar}{$width}{alias};
				redo BUNDLES;
			}
						
			my $result = $eras->{$default_calendar}{$width};
			
			my @result;
			@result[keys %$result] = values %$result;
			
			return \@result if keys %$result;
		}
		if ($default_calendar ne 'gregorian') {
			$default_calendar = 'gregorian';
			redo BUNDLES;
		}
	}

	return [];
}
	
# The next three are for DateDime::Locale
sub _build_era_wide {
	my $self = shift;
	my ($width) = (qw( wide ));

	my $result = $self->_build_any_era($width);
	
	return [@$result[0, 1]];
}

sub _build_era_abbreviated {
	my $self = shift;
	my ($width) = (qw( abbreviated ));

	my $result = $self->_build_any_era($width);
	
	return [@$result[0, 1]];
}

sub _build_era_narrow {
	my $self = shift;
	my ($width) = (qw( narrow ));

	my $result = $self->_build_any_era($width);
	
	return [@$result[0, 1]];
}

# Now get all the era data
sub _build_era_format_wide {
	my $self = shift;
	my ($width) = (qw( wide ));

	return $self->_build_any_era($width);
}

sub _build_era_format_abbreviated {
	my $self = shift;
	my ($width) = (qw( abbreviated ));

	return $self->_build_any_era($width);
}

sub _build_era_format_narrow {
	my $self = shift;
	my ($type, $width) = (qw( narrow ));

	return $self->_build_any_era($type, $width);
}

*_build_era_stand_alone_wide = \&_build_era_format_wide;
*_build_era_stand_alone_abbreviated = \&_build_era_format_abbreviated;
*_build_era_stand_alone_narrow = \&_build_era_format_narrow;

sub _build_any_date_format {
	my ($self, $width) = @_;
	my $default_calendar = $self->default_calendar();
	
	my @bundles = $self->_find_bundle('date_formats');

	BUNDLES: {
		foreach my $bundle (@bundles) {
			my $date_formats = $bundle->date_formats;
			if (exists $date_formats->{alias}) {
				$default_calendar = $date_formats->{alias};
				redo BUNDLES;
			}
			
			my $result = $date_formats->{$default_calendar}{$width};
			return $result if $result;
		}
		if ($default_calendar ne 'gregorian') {
			$default_calendar = 'gregorian';
			redo BUNDLES;
		}
	}
	
	return '';
}

sub _build_date_format_full {
	my $self = shift;
	
	my ($width) = ('full');
	return $self->_build_any_date_format($width);
}

sub _build_date_format_long {
	my $self = shift;
	
	my ($width) = ('long');
	return $self->_build_any_date_format($width);
}

sub _build_date_format_medium {
	my $self = shift;
	
	my ($width) = ('medium');
	return $self->_build_any_date_format($width);
}

sub _build_date_format_short {
	my $self = shift;
	
	my ($width) = ('short');
	return $self->_build_any_date_format($width);
}

sub _build_any_time_format {
	my ($self, $width) = @_;
	my $default_calendar = $self->default_calendar();
	
	my @bundles = $self->_find_bundle('time_formats');

	BUNDLES: {
		foreach my $bundle (@bundles) {
			my $time_formats = $bundle->time_formats;
			if (exists $time_formats->{$default_calendar}{alias}) {
				$default_calendar = $time_formats->{$default_calendar}{alias};
				redo BUNDLES;
			}
			
			my $result = $time_formats->{$default_calendar}{$width};
			if ($result) {
				my $time_separator = $self->_get_time_separator;
				$result =~ s/:/$time_separator/g;
				return $result;
			}
		}
		if ($default_calendar ne 'gregorian') {
			$default_calendar = 'gregorian';
			redo BUNDLES;
		}
	}
	return '';
}

sub _build_time_format_full {
	my $self = shift;
	my $width = 'full';
	
	return $self->_build_any_time_format($width);
}

sub _build_time_format_long {
	my $self = shift;
	
	my $width = 'long';
	return $self->_build_any_time_format($width);
}

sub _build_time_format_medium {
	my $self = shift;
	
	my $width = 'medium';
	return $self->_build_any_time_format($width);
}

sub _build_time_format_short {
	my $self = shift;
	
	my $width = 'short';
	return $self->_build_any_time_format($width);
}

sub _build_any_datetime_format {
	my ($self, $width) = @_;
	my $default_calendar = $self->default_calendar();
	
	my @bundles = $self->_find_bundle('datetime_formats');

	BUNDLES: {
		foreach my $bundle (@bundles) {
			my $datetime_formats = $bundle->datetime_formats;
			if (exists $datetime_formats->{$default_calendar}{alias}) {
				$default_calendar = $datetime_formats->{$default_calendar}{alias};
				redo BUNDLES;
			}
			
			my $result = $datetime_formats->{$default_calendar}{$width};
			return $result if $result;
		}
		if ($default_calendar ne 'gregorian') {
			$default_calendar = 'gregorian';
			redo BUNDLES;
		}
	}
	
	return '';
}	

sub _build_datetime_format_full {
	my $self = shift;
	
	my $width = 'full';
	my $format = $self->_build_any_datetime_format($width);
	
	my $date = $self->_build_any_date_format($width);
	my $time = $self->_build_any_time_format($width);
	
	$format =~ s/\{0\}/$time/;
	$format =~ s/\{1\}/$date/;
	
	return $format;
}

sub _build_datetime_format_long {
	my $self = shift;
		
	my $width = 'long';
	my $format = $self->_build_any_datetime_format($width);
	
	my $date = $self->_build_any_date_format($width);
	my $time = $self->_build_any_time_format($width);
	
	$format =~ s/\{0\}/$time/;
	$format =~ s/\{1\}/$date/;
	
	return $format;
}

sub _build_datetime_format_medium {
	my $self = shift;
	
	my $width = 'medium';
	my $format = $self->_build_any_datetime_format($width);
	
	my $date = $self->_build_any_date_format($width);
	my $time = $self->_build_any_time_format($width);
	
	$format =~ s/\{0\}/$time/;
	$format =~ s/\{1\}/$date/;
	
	return $format;
}

sub _build_datetime_format_short {
	my $self = shift;
	
	my $width = 'short';
	my $format = $self->_build_any_datetime_format($width);
	
	my $date = $self->_build_any_date_format($width);
	my $time = $self->_build_any_time_format($width);
	
	$format =~ s/\{0\}/$time/;
	$format =~ s/\{1\}/$date/;
	
	return $format;
}

sub _build_format_data {
	my $self = shift;
	my $default_calendar = $self->default_calendar();

	my @bundles = $self->_find_bundle('datetime_formats_available_formats');
	foreach my $calendar ($default_calendar, 'gregorian') {
		foreach my $bundle (@bundles) {
			my $datetime_formats_available_formats = $bundle->datetime_formats_available_formats;
			my $result = $datetime_formats_available_formats->{$calendar};
			return $result if $result;
		}
	}

	return {};
}

sub format_for {
	my ($self, $format) = @_;

	my $format_data = $self->format_data;

	return $format_data->{$format} // '';
}

sub _build_available_formats {
	my $self = shift;

	my $format_data = $self->format_data;

	return [keys %$format_data];
}

sub _build_default_date_format_length {
	my $self = shift;
	
	my $default_calendar = $self->default_calendar();

	my @bundles = $self->_find_bundle('date_formats');
	foreach my $calendar ($default_calendar, 'gregorian') {
		foreach my $bundle (@bundles) {
			my $date_formats = $bundle->date_formats;
			my $result = $date_formats->{$calendar}{default};
			return $result if $result;
		}
	}
}

sub _build_default_time_format_length {
	my $self = shift;
	
	my $default_calendar = $self->default_calendar();

	my @bundles = $self->_find_bundle('time_formats');
	foreach my $calendar ($default_calendar, 'gregorian') {
		foreach my $bundle (@bundles) {
			my $time_formats = $bundle->time_formats;
			my $result = $time_formats->{$calendar}{default};
			return $result if $result;
		}
	}
}

sub _build_prefers_24_hour_time {
	my $self = shift;

	return $self->time_format_short() =~ /h|K/ ? 0 : 1;
}

{
	my %days_2_number = (
		mon => 1,
		tue => 2,
		wen => 3,
		thu => 4,
		fri => 5,
		sat => 6,
		sun => 7,
	);

	sub _build_first_day_of_week {

		my $self = shift;

		my $first_day = $self->week_data_first_day;
		
		return $days_2_number{$first_day};
	}
}

# Sub to mangle Unicode regex to Perl regex
# Backwards compatibility hack
*_unicode_to_perl = eval <<'EOT' || \&_new_perl;
sub {
	my $regex = shift;

	return '' unless length $regex;
	$regex =~ s/
		(?:\\\\)*+               	# Pairs of \
		(?!\\)                   	# Not followed by \
		\K                       	# But we don't want to keep that
		(?<set>                     # Capture this
			\[                      # Start a set
				(?:
					[^\[\]\\]+     	# One or more of not []\
					|               # or
					(?:
						(?:\\\\)*+	# One or more pairs of \ without back tracking
						\\.         # Followed by an escaped character
					)
					|				# or
					(?&set)			# An inner set
				)++                 # Do the inside set stuff one or more times without backtracking
			\]						# End the set
		)
	/ _convert($1) /xeg;
	no warnings "experimental::regex_sets";
	no warnings "deprecated"; # Because CLDR uses surrogates
	return qr/$regex/x;
};

EOT

# Backwards compatibility hack
*_convert = eval <<'EOT' || \&_new_perl;
sub {
	my $set = shift;
	
	# Some definitions
	my $posix = qr/(?(DEFINE)
		(?<posix> (?> \[: .+? :\] ) )
		)/x;
	
	# Convert Unicode escapes \u1234 to characters
	$set =~ s/\\u(\p{Ahex}+)/chr(hex($1))/egx;
	
	# Check to see if this is a normal character set
	my $normal = 0;
	
	$normal = 1 if $set =~ /^
		\s* 					# Possible white space
		\[  					# Opening set
		^?  					# Possible negation
		(?:           			# One of
			[^\[\]]++			# Not an open or close set 
			|					# Or
			(?<=\\)[\[\]]       # An open or close set preceded by \
			|                   # Or
			(?:
				\s*      		# Possible white space
				(?&posix)		# A posix class
				(?!         	# Not followed by
					\s*			# Possible white space
					[&-]    	# A Unicode regex op
					\s*     	# Possible white space
					\[      	# A set opener
				)
			)
		)+
		\] 						# Close the set
		\s*						# Possible white space
		$
		$posix
	/x;
	
	# Convert posix to perl
	$set =~ s/\[:(.*?):\]/\\p{$1}/g;
	
	if ($normal) {
		return "$set";
	}
	
	# Fix up [abc[de]] to [[abc][de]]
	$set =~ s/\[ ( (?>\^? \s*) [^\]]+? ) \s* \[/[[$1][/gx;
	
	# Fix up [[ab]cde] to [[ab][cde]]
	$set =~ s/\[ \^?+ \s* \[ [^\]]+? \] \K \s* ( [^\[]+ ) \]/[$1]]/gx;
	
	# Unicode uses ^ to compliment the set where as Perl uses !
	$set =~ s/\[ \^ \s*/[!/gx;
	
	# The above can leave us with empty sets. Strip them out
	$set =~ s/\[\]//g;
	
	# Fixup inner sets with no operator
	1 while $set =~ s/ \] \s* \[ /] + [/gx;
	1 while $set =~ s/ \] \s * (\\p\{.*?\}) /] + $1/xg;
	1 while $set =~ s/ \\p\{.*?\} \s* \K \[ / + [/xg;
	1 while $set =~ s/ \\p\{.*?\} \s* \K (\\p\{.*?\}) / + $1/xg;
	
	# Unicode uses [] for grouping as well as starting an inner set
	# Perl uses ( ) So fix that up now
	
	$set =~ s/. \K \[ (?> (!?) \s*) \[ /($1\[/gx;
	$set =~ s/ \] \s* \] (.) /])$1/gx;
	
	return "(?$set)";
}

EOT

# The following pod is for methods defined in the Moose Role
# files that are automatically generated from the data
=back

=head2 Valid codes

=over 4

=item valid_languages()

This method returns a list containing all the valid language codes

=item valid_scripts()

This method returns a list containing all the valid script codes

=item valid_territories()

This method returns a list containing all the valid territory codes

=item valid_variants()

This method returns a list containing all the valid variant codes

=item key_aliases()

This method returns a hash that maps valid keys to their valid aliases

=item key_names()

This method returns a hash that maps valid key aliases to their valid keys

=item valid_keys()

This method returns a hash of valid keys and the valid type codes you 
can have with each key

=item language_aliases()

This method returns a hash that maps valid language codes to their valid aliases

=item territory_aliases()

This method returns a hash that maps valid territory codes to their valid aliases

=item variant_aliases()

This method returns a hash that maps valid variant codes to their valid aliases

=back

=head2 Information about weeks

There are no standard codes for the days of the weeks so CLDR uses the following
three letter codes to represent unlocalised days

=over 4

=item sun

Sunday

=item mon

Monday

=item tue

Tuesday

=item wed

Wednesday

=item thu

Thursday

=item fri

Friday

=item sat

Saturday

=back

=cut

sub _week_data {
	my ($self, $territory_id, $week_data_hash) = @_;
	
	$territory_id //= ( $self->territory_id || $self->likely_subtag->territory_id );
	
	return $week_data_hash->{$territory_id} if exists $week_data_hash->{$territory_id};
	
	while (1) {
		$territory_id = $self->territory_contained_by()->{$territory_id};
		return unless defined $territory_id;
		return $week_data_hash->{$territory_id} if exists $week_data_hash->{$territory_id};
	}
}

=over 4

=item week_data_min_days($territory_id)

This method takes an optional territory id and returns a the minimum number of days
a week must have to count as the starting week of the new year. It uses the current
locale's territory if no territory id is passed in.

=cut

sub week_data_min_days {
	my ($self, $territory_id) = @_;
	
	my $week_data_hash = $self->_week_data_min_days();
	return _week_data($self, $territory_id, $week_data_hash);
}

=item week_data_first_day($territory_id)

This method takes an optional territory id and returns the three letter code of the 
first day of the week for that territory. If no territory id is passed in then it
uses the current locale's territory.

=cut

sub week_data_first_day {
	my ($self, $territory_id) = @_;
	
	my $week_data_hash = $self->_week_data_first_day();
	return _week_data($self, $territory_id, $week_data_hash);
}

=item week_data_weekend_start()

This method takes an optional territory id and returns the three letter code of the 
first day of the week end for that territory. If no territory id is passed in then it
uses the current locale's territory.

=cut

sub week_data_weekend_start {
	my ($self, $territory_id) = @_;
	my $week_data_hash = $self->_week_data_weekend_start();
	
	return _week_data($self, $territory_id, $week_data_hash);
}

=item week_data_weekend_end()

This method takes an optional territory id and returns the three letter code of the 
first day of the week end for that territory. If no territory id is passed in then it
uses the current locale's territory.

=cut

sub week_data_weekend_end {
	my ($self, $territory_id) = @_;
	my $week_data_hash = $self->_week_data_weekend_end();
	
	return _week_data($self, $territory_id, $week_data_hash);
}

=back

=head2 Territory Containment

=over 4

=item territory_contains()

This method returns a hash ref keyed on territory id. The value is an array ref.
Each element of the array ref is a territory id of a territory immediately 
contained in the territory used as the key

=item territory_contained_by()

This method returns a hash ref keyed on territory id. The value of the hash
is the territory id of the immediately containing territory.

=back

=head2 Numbering Systems

=over 4

=item numbering_system()

This method returns a hash ref keyed on numbering system id which, for a given 
locale, can be got by calling the default_numbering_system() method. The values
of the hash are a two element hash ref the keys being C<type> and C<data>. If the
type is C<numeric> then the data is an array ref of characters. The position in the
array matches the numeric value of the character. If the type is C<algorithmic>
then data is the name of the algorithm used to display numbers in that format.

=back

=head2 Number Formatting

=over 4

=item format_number($number, $format, $currency, $for_cash)

This method formats the number $number using the format $format. If the format contains
the currency symbol C<¤> then the currency symbol for the currency code in $currency
will be used. If $currency is undef() then the default currency code for the locale 
will be used. 

Note that currency codes are based on territory so if you do not pass in a currency 
and your locale did not get passed a territory in the constructor you are going
to end up with the L<likely sub tag's|/likely_subtags> idea of the currency. This
functionality may be removed or at least changed to emit a warning in future 
releases.

$for_cash is only used during currency formatting. If true then cash rounding
will be used otherwise financial rounding will be used. 

This function also handles rule based number formatting. If $format is string equivalent
to one of the current locale's public rule based number formats then $number will be 
formatted according to that rule. 

=item add_currency_symbol($format, $symbol)

This method returns the format with the currency symbol $symbol correctly inserted
into the format

=item parse_number_format($format, $currency, $currency_data, $for_cash)

This method parses a CLDR numeric format string into a hash ref containing data used to 
format a number. If a currency is being formatted then $currency contains the
currency code, $currency_data is a hashref containing the currency rounding
information and $for_cash is a flag to signal cash or financial rounding. 

This should probably be a private function.

=item round($number, $increment, $decimal_digits)

This method returns $number rounded to the nearest $increment with $decimal_digits
digits after the decimal point

=item get_formatted_number($number, $format, $currency_data, $for_cash)

This method takes the $format produced by parse_number_format() and uses it to
parse $number. It returns a string containing the parsed number. If a currency
is being formatted then $currency_data is a hashref containing the currency 
rounding information and $for_cash is a flag to signal cash or financial rounding. 

=item get_digits()

This method returns an array containing the digits used by the locale, The order of the
array is the order of the digits. It the locale's numbering system is C<algorithmic> it
will return C<[0,1,2,3,4,5,6,7,8,9]>

=item default_numbering_system()

This method returns the numbering system id for the locale.

=back

=head2 Measurement Information

=over 4

=item measurement_system()

This method returns a hash ref keyed on territory, the value being the measurement system
id for the territory. If the territory you are interested in is not listed use the
territory_contained_by() method until you find an entry.

=item paper_size()

This method returns a hash ref keyed on territory, the value being the paper size used
in that territory. If the territory you are interested in is not listed use the
territory_contained_by() method until you find an entry.

=back

=head2 Likely Tags

=over 4

=item likely_subtags()

A full locale tag requires, as a minimum, a language, script and territory code. However for
some locales it is possible to infer the missing element if the other two are given, e.g.
given C<en_GB> you can infer the script will be latn. It is also possible to fill in the 
missing elements of a locale with sensible defaults given sufficient knowledge of the layout
of the CLDR data and usage patterns of locales around the world.

This function returns a hash ref keyed on partial locale id's with the value being the locale
id for the most likely language, script and territory code for the key.

=back

=head2 Currency Information

=over 4

=item currency_fractions()

This method returns a hash ref keyed on currency id. The value is a hash ref containing four keys.
The keys are 

=over 8

=item digits

The number of decimal digits normally formatted.

=item rounding

The rounding increment, in units of 10^-digits. 

=item cashdigits

The number of decimal digits to be used when formatting quantities used in cash transactions (as opposed
to a quantity that would appear in a more formal setting, such as on a bank statement).

=item cashrounding

The cash rounding increment, in units of 10^-cashdigits. 

=back

=item default_currency($territory_id)

This method returns the default currency id for the territory id.
If no territory id is given then the current locale's is used

=cut

sub default_currency {
	my ($self, $territory_id) = @_;
	
	$territory_id //= $self->territory_id;
	
	if (! $territory_id) {
		 $territory_id = $self->likely_subtag->territory_id;
		 warn "Locale::CLDR::default_currency:- No territory given using $territory_id at ";
	}
	
	my $default_currencies = $self->_default_currency;
	
	return $default_currencies->{$territory_id} if exists $default_currencies->{$territory_id};
	
	while (1) {
		$territory_id = $self->territory_contained_by($territory_id);
		last unless $territory_id;
		return $default_currencies->{$territory_id} if exists $default_currencies->{$territory_id};
	}
}

=item currency_symbol($currency_id)

This method returns the currency symbol for the given currency id in the current locale.
If no currency id is given it uses the locale's default currency

=cut

sub currency_symbol {
	my ($self, $currency_id) = @_;
	
	$currency_id //= $self->default_currency;
	
	my @bundles = reverse $self->_find_bundle('curriencies');
	foreach my $bundle (@bundles) {
		my $symbol = $bundle->curriencies()->{$currency_id}{symbol};
		return $symbol if $symbol;
	}
	
	return '';
}

=back

=head2 Calendar Information

=over 4

=item calendar_preferences()

This method returns a hash ref keyed on territory id. The values are array refs containing the preferred
calendar id's in order of preference.

=item  default_calendar($territory)

This method returns the default calendar id for the given territory. If no territory id given it 
used the territory of the current locale.

=back

=begin comment

=head2 Collation

=over 4

=item collation()

This method returns a Locale::CLDR::Collator object. This is still in development. Future releases will
try and match the API from L<Unicode::Collate> as much as possible and add tailoring for locales.

=back

=end comment

=cut

=begin comment

sub collation {
	my ($self, %params) = @_;
	
	$params{type} //= $self->_default_collation;
	$params{strength} //= $self->_default_collation_strength;
	
	return Locale::CLDR::Collator->new(locale => $self, %params);
}

sub collation_overrides {
	my ($self, $type) = @_;
	
	my @bundles = reverse $self->_find_bundle('collation');
	
	my $override = '';
	foreach my $bundle (@bundles) {
		last if $override = $bundle->collation()->{$type};
	}
	
	if ($type ne 'standard' && ! $override) {
		foreach my $bundle (@bundles) {
			last if $override = $bundle->collation()->{standard};
		}
	}
	
	return $override || [];
}
	
sub _default_collation {
	return 'standard';
}

sub _default_collation_strength {
	return 3;
}

=end comment

=head1 Locales

Other locales can be found on CPAN. You can install Language packs from the 
Locale::CLDR::Locales::* packages. You can also install language packs for
a given territory by looking for a Bundle::Locale::CLDR::* package

=head1 AUTHOR

John Imrie, C<< <JGNI at cpan dot org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-locale-cldr at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Locale-CLDR>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Locale::CLDR

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Locale-CLDR>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Locale-CLDR>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Locale-CLDR>

=item * Search CPAN

L<http://search.cpan.org/dist/Locale-CLDR/>

=back


=head1 ACKNOWLEDGEMENTS

Everyone at the Unicode Consortium for providing the data.

Karl Williams for his tireless work on Unicode in the Perl 
regex engine.

=head1 COPYRIGHT & LICENSE

Copyright 2009-2014 John Imrie.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1; # End of Locale::CLDR
