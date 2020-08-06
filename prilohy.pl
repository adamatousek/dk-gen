#!/usr/bin/perl

use v5.16;
use strict;
use warnings;
#use utf8;
use Data::Dumper;

my $singles_dir = "_generated";
my $dest_dir = "prilohy";
my $src_prefix = ".";
# my $poskytovna_prefix = "$src_prefix/moss_hw08/poskytovna-";
my $dest_script = "prilohy.sh";
my %sources_dir = ( A => "$src_prefix/11_prikryl_uhlar/",
                    B => "$src_prefix/09_trojice/",
                    C => "$src_prefix/hw12/" );
my %hw_subdirs = ( A => "Uloha_11",
                   B => "Uloha_09",
                   C => "Uloha_12" );
my %hw_prilohy = ( A => "du11_*.py",
                   B => "du09_*.py",
                   C => "" );

open my $out, ">", $dest_script;

say $out "#!/bin/bash\nset -ex\n";

# my @poskytnute = <${poskytovna_prefix}*>;

my @files = <$singles_dir/[1-9]*.tex>;
foreach my $file (@files) {
    open my $fh, $file or die "Could not open $file: $!";
    $file =~ /(\d+)/;
    my $uco = $1;
    $file =~ /\/([^\/]*).tex/;
    my $name = $1;
    my $dest_subdir = "$dest_dir/$name";
    my $content = "# $name\n";
    my $copies = "";
    my %opsal;
    my @odkoho;
    while ( <$fh> ) {
        /\\def\\UCO\{(\d*)\}/ and $1 == $uco || die "UČO mismatch: $uco != $1";
        if ( /\\Podobnost\{(.)\}\{(\d*)\}/ ) {
            $opsal{$1} = 1;
            push @odkoho, $2 if $1 eq 'B';
            $copies .= "cp $sources_dir{$1}$2* $dest_subdir/$hw_subdirs{$1}/\n";
        }
        $opsal{$1} = 1 if /\\KUloze\{(.)\}/;
        # if ( /%.*POSKYTOVNA/ ) {
        #     foreach my $u ($uco, @odkoho) {
        #         foreach my $p (@poskytnute) {
        #             $copies .= "cp $p $dest_subdir/$hw_subdirs{B}/\n" if ( $p =~ /$u/ );
        #         }
        #     }
        # }
        if ( /%.*PŘÍLOHA (.*)/ ) {
            $copies .= "cp $1 $dest_subdir/$hw_subdirs{B}/\n";
        }
    }
    close $fh;
    $content .= "mkdir -p $dest_subdir/$hw_subdirs{$_}\n" for keys %opsal;
    $content .= "cp $sources_dir{$_}$uco* $dest_subdir/$hw_subdirs{$_}/\n" for keys %opsal;
    $content .= "cp $hw_prilohy{$_} $dest_subdir/$hw_subdirs{$_}/\n" for keys %opsal;
    $content .= $copies;
    $content .= "cd $dest_dir\n";
    $content .= "7z a podklady-ib002-$uco.zip $name\n";
    $content .= "cd -\n";
    say $out $content;

}
