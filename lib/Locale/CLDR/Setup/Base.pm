package Locale::CLDR::Setup::Base;
use File::Basename;
use File::Path;

# None standard modules
use Unicode::Regex::Parser;

sub create_file_path {
  my $self = shift;
  foreach my $filename ($self->get_file_name()) {
    unless (-e "${filename}.pm") {
      my $dir  = dirname($filename);
      mkpath $dir;
    }
  }
}

sub get_file_name {
  my $self = shift;
  my $filenames = $self->{__cache__}{filenames};
  if (! $filenames) {
    $filenames = $self->_calculate_file_names();
  }
  return wantarray ? @$filenames : $filenames->[0];
}

sub current_file_name {
  my $self = shift;
  if (@_) {
    $self->{__cache__}{current_file_name} = $_[0];
  }
  return $self->{__cache__}{current_file_name};
}

sub _calculate_file_names {
  my $self = shift;
  $self->{__cache__}{filenames} = [File::Spec->catfile(map {length ($_) ? ucfirst lc $_ : 'Any'} ($self->{_section_}, map {$self->{xpath}->findvalue("/ldml/identity/$_/\@type")} qw( language script territory variant)))];
  tr[-][_] foreach @{$self->{__cache__}{filenames}};
  return $self->{__cache__}{filenames};
}

sub create_files {
  my $self = shift;
  foreach my $filename ($self->get_file_name) {
    $self->current_file_name($filename);
    $self->create_file();
  }
}

sub create_file {
  my ($self, $additional_paramaters) = @_;
  my $filename = $self->current_file_name;
  open my $file, '>:utf8', "$filename.pm" or die "Can't open $filename: $!";
  print $file $self->file_header;
  $self->add_data_to_file($file, $additional_paramaters);
  print $file "1;\n";
  close $file;
}

sub version {
  my $self = shift;

  my $version = $self->{xpath}->findvalue('/ldml/identity/version/@number');
  return $self->{version} 
    unless $version;

  ($version) = $version=~/([\d\.]+)/;
  return $version;
}

sub generation_date {
  my $self = shift;

  my $date = $self->{xpath}->findvalue('/ldml/identity/generation/@date');
  ($date) = $date =~/(\d[\d\/ :]+\d)/;
  $date ||= 'Unknown date';
  return $date;
}

sub get_package_name {
  my $self = shift;
  my $package = join '::', (
    qw(Locale CLDR), (
      map {
        length ($_)
	  ? ucfirst lc $_
	  : 'Any'
      } (
        $self->{_section_},
	map {
	  $self->{xpath}->findvalue("/ldml/identity/$_/\@type")
	} qw( language script territory variant)
      )
    )
  );
  return $package;
}

sub file_header {
  my $self = shift();

  my $file_name = $self->{file_name};
  my $version   = $self->version;
  my $date      = $self->generation_date;
  my $package   = $self->get_package_name($file_name);
  my $now = gmtime() . ' GMT';
  return <<EOT;
# This file was autogenerated by $0 on $now
# from the CLDR data file: $file_name generated on $date
# Do NOT Normailze this file. It will break

package $package;
use strict;
use warnings;
use utf8;
our \$VERSION = $version;

EOT
}

sub process_unicode_re {
  my ($self, $re) = @_;
  my $parsed_re = Unicode::Regex::Parser::parse($re);
  return $parsed_re;
}

1;