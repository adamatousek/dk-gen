#!/usr/bin/perl

use v5.16;
use strict;
use warnings;
use utf8;
use open qw(:encoding(UTF-8) :std);
use Data::Dumper;

my $f_people = "lidi.csv";
my $f_findings = "zjisteni.tex";
my $dest_dir = "_generated";
my $people_scheme = "‘Učo:Student:Pohlaví’";

my $f_people_tex = "$dest_dir/lidi.tex";

if ( @ARGV > 0 ) {
    print <<"    EOF";
    I am a rather dumb script and I take no arguments.
    Provide me with two files in the working directory:
      • ‘$f_people’ containing $people_scheme (just select the
        right columns in IS and export the list)

      • ‘$f_findings’ containing TeX with some control lines:
           • ‘%HW <tag>’ – switch to homework <tag>;
             <tag> should only use letters (it goes to weird TeX
             places, I think).

           • ‘%GROUP <učo>…’ – switch to a new plagiator group
             (i.e., the following text goes to all the listed učos).
             The učos are also flagged with the current homework tag.
             <učo> is any string starting with an učo; i.e. you can
             use učo-prefixed filenames from homework vault here.
             <učo>s are separated by whatever reasonable, I think.

    The output will be generated into ‘$dest_dir/’.
    EOF
    exit 0;
}

open(my $csvf, '<', $f_people)
    or die "Could not open file ‘$f_people’: $!";

open(my $texf, '<', $f_findings)
    or die "Could not open file ‘$f_findings’: $!";

# Parse CSV with people
my %students;
my $csv_header = <$csvf>;
unless ( $csv_header =~ /^Učo\s*:\s*Student\s*:\s*Pohlaví/ ) {
    print <<"    EOF";
    ERROR: Invalid format of ‘$f_people’.
      Expected ‘$people_scheme’ (incl. this header)
      It is possible to use an unaltered export from IS, if you
      select the right columns to export (i.e., only sex).
    EOF
    exit 1;
}

while ( defined ($_ = <$csvf>) and /^(?<uco>\d*)\s*:(?<name>.*?)\s*:(?<sex>\S*)\s*(?::\[?(?<flags>[^:]*?)\]?)?/ ) {
    my %m = %+;
    $students{$m{uco}} = { name => $m{name}, flags => $m{flags} // "",
        male => !!($m{sex} =~ /^m/i), zjisteni => '', podobnosti => []};
}
close $csvf;

# Create output directory
mkdir $dest_dir or $!{EEXIST} or die "Could not create directory $dest_dir: $!";

# Write people into TeX
open(my $peoplef, '>', $f_people_tex)
    or die "Could not open file ‘$f_people_tex’: $!";

while (my($uco, $st) = each %students) {
    say $peoplef "\\defstudent{$uco}{$st->{name}}";
}
close $peoplef;


# Parse annotated TeX into separate findings
my %findings;
my $hwtag = 'default';
my $finding;
my @ucos;

sub commit {
    return unless @ucos;
    for my $uco (@ucos) {
        $students{$uco}->{zjisteni} .= $finding;
        push @{$students{$uco}->{podobnosti}}, map {[$_, $hwtag]} grep {$_ != $uco} @ucos;
    }
}

while (<$texf>) {
    if ( /^%GROUP/ or /^%HW/ ) {
        commit();
        $hwtag = $1 if ( /^%HW ([a-zA-Z]+)/ );

        # reset
        @ucos = /(?:[,;]|\s)(\d{4,7})/g;
        $finding = "\\KUloze{$hwtag}\n";
    } else {
        $finding .= $_;
    }
}
commit();
close $texf;

$" = "\n"; # List separator
foreach my $uco (keys %students) {
    my $st = $students{$uco};
    my %flags;
    $flags{$_->[1]} = 1 for @{$st->{podobnosti}};
    my $flags = join (",", keys %flags);
    if ($st->{flags}) { $flags .= ", $st->{flags}"; }
    next if not $flags;
    my $zjisteni = $st->{zjisteni};
    chomp $zjisteni for (1..2);
    $zjisteni or $zjisteni = '\textbf{TODO}';

    my $content = <<EOF;
\\input{podani_pkgs}

% $st->{name}
\\def\\UCO{$uco}
\\male@{[$st->{male} ? "true" : "false"]}
@{[map {"\\Podobnost{$_->[1]}{$_->[0]} % $students{$_->[0]}->{name}"} @{$st->{podobnosti}}]}
\\def\\Volby{$flags}
\\long\\def\\Zjisteni{%
$zjisteni
}
\\input{podani_basic}
EOF

    my $name = $st->{name};
    $name =~ s/,? /_/g;
    my $f_out = "$dest_dir/${uco}_$name.tex";
    open (my $outf, '>', $f_out) or die "Could not open $f_out ($!)";
    print $outf $content;
    close $outf;
}
