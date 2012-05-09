#!/usr/bin/env perl

use strict;
use warnings;
use Cwd;
use Getopt::Long;
use Pod::Usage;
use File::Find;
use Spreadsheet::WriteExcel;

my $ORI_PATH = '/home/gengs/amazon/tmp/fileDiffer/4460/res/res';
my $PRE_PATH = '/home/gengs/amazon/tmp/fileDiffer/mr1/res/res';
my $OUT_FILE = 'result.xls';
my $HELP  = 0;
my $DEBUG = 0;

GetOptions (
    'ori=s'  => \$ORI_PATH,
    'pre=s'  => \$PRE_PATH,
    'xls=s'  => \$OUT_FILE,
    'help|?' => \$HELP,
    'debug'  => \$DEBUG,
) or pod2usage(2);

if ($HELP) {
    pod2usage(1);
    exit 0;
}

-d $ORI_PATH || die "$ORI_PATH: $!\n";
-d $PRE_PATH || die "$PRE_PATH: $!\n";

$ORI_PATH =~ s{(?<!/)$}{/};
$PRE_PATH =~ s{(?<!/)$}{/};
debug($ORI_PATH);
debug($PRE_PATH);

my %result = (
    del => [],
    add => [],
    dif => [],
    sam => [],
);

my @ori_files = file_list($ORI_PATH);
foreach (@ori_files) {
    my ($ori_file, $pre_file) = ($ORI_PATH.$_, $PRE_PATH.$_);
#    debug($ori_file);
    if (-e $pre_file) {
        my $dfstr = `diff '$ori_file' '$pre_file'`;
        if ($dfstr) {
            debug("DIFF : $_");
            push @{$result{dif}}, $_;
        }
        else {
#            debug("SAME : $_");
            push @{$result{sam}}, $_;
        }
    }
    else {
        debug("DELE : $_");
        push @{$result{del}}, $_;
    }
}

my @pre_files = file_list($PRE_PATH);
foreach my $file (@pre_files) {
    unless (grep($_ eq $file, @ori_files)) {
        debug("ADDT : $file");
        push @{$result{add}}, $file;
    }
}

my $workbook = Spreadsheet::WriteExcel -> new($OUT_FILE);
$worksheet = $workbook -> add_worksheet();

while (my ($stats, $files) = each %result) {
    
}

sub file_list {
    my $path = shift;

    my @dirs = ($path);
    my @file_list;
    my ($dir, $file);
    while ($dir = pop(@dirs)) {
        local *DH;

        if (!opendir(DH, $dir)) {
            warn "Cannot opendir $dir: $! $^E";
            next;
        }

        foreach (readdir(DH)) {
            if ($_ eq '.' || $_ eq '..') {
                next;
            }

            $file = $dir.$_;
            if (-d $file) {
                $file .= '/';
                push @dirs, $file ;
            }
            else {
                my $rel_file = $file;
                $rel_file =~ s/$path//;
                push @file_list, $rel_file;
            }
        }
        closedir(DH);
    }

    @file_list;
}

sub debug {
    my $string = shift;
    
    print $string."\n" if $DEBUG;
}

__END__

=head1 NAME

getDiffs.pl

=head1 SYNOPSIS

getDiffs.pl [options]

 Options:
   -ori <Original path>
   -pre <Present path>
   -out <Output file>
   -help
   -debug

=head1 OPTIONS

=over 8

=item B<-ori>

Specified the original path.

=item B<-pre>

Specified the present path.

=item B<-out>

Specified the output file, use result.xls for defauilt.

=item B<-help>

Help.

=item B<-debug>

print debug message when running.

=back

=head1 DESCRIPTION

B<getsDiffs.pl>

=cut