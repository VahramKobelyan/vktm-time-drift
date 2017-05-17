#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use Pod::Usage;


=head1 SYNOPSIS



 Parse the timestamps and time adjustments from the trace file created by Oracle Database process VKTM
 https://docs.oracle.com/cd/E18283_01/server.112/e17110/bgprocesses.htm
 
 This script currently considers only highres forward time drifts

 See this Oracle Support Note:
 Time Drift Detected. Please Check VKTM Trace File for More Details (Doc ID 1347586.1)

 Time drifts of 1 sec forward are acceptable.
 Time drifts of 5 sec backward are acceptable.

 Drifts outside of these parameters should be investigated


 See this Oracle Support Note for a patch to reduce VKTM messages in 11.2 ASM alert logs
 ASM Instance Is Reporting "Warning: VKTM detected a time drift" (Doc ID 1678120.1)


=cut

=head1 OPTIONS

 -h | --help 
   show options

 --man 
   show all documentation

 --csv-output 
   output CSV format - default is RPT

 --forward-drift-threshold 
   for the standard report, display an arrow next to values exceeding this threshold
	default is 1 (second)

=cut


=head1 VKTM Trace file Format


 *** 2016-12-17 17:46:58.856
 *** SESSION ID:(1.1) 2016-12-17 17:46:58.856
 *** CLIENT ID:() 2016-12-17 17:46:58.856
 *** SERVICE NAME:() 2016-12-17 17:46:58.856
 *** MODULE NAME:() 2016-12-17 17:46:58.856
 *** ACTION NAME:() 2016-12-17 17:46:58.856

 kstmmainvktm: succeeded in setting elevated priority
 highres_enabled

 *** 2016-12-17 17:46:58.866
 VKTM running at (1)millisec precision with DBRM quantum (100)ms
 [Start] HighResTick = 1482014818866063
 kstmrmtickcnt = 0 : ksudbrmseccnt[0] = 1482014818
 kstmchkdrift (kstmhighrestimecntkeeper:highres): Time jumped forward by (1542116)usec at (1482017000433105) whereas (1000000) is allowed
 kstmchkdrift (kstmhighrestimecntkeeper:highres): Time jumped forward by (1457497)usec at (1482025556154868) whereas (1000000) is allowed
 kstmchkdrift (kstmhighrestimecntkeeper:highres): Time jumped forward by (1741601)usec at (1482028279593226) whereas (1000000) is allowed
 kstmchkdrift (kstmhighrestimecntkeeper:highres): Time jumped forward by (1465148)usec at (1482030458886280) whereas (1000000) is allowed
 kstmchkdrift (kstmhighrestimecntkeeper:highres): Time jumped forward by (1198164)usec at (1482031301932289) whereas (1000000) is allowed

 *** 2016-12-17 22:21:42.949
 kstmchkdrift (kstmhighrestimecntkeeper:lowres): Time stalled at 1482031302
 kstmchkdrift (kstmhighrestimecntkeeper:lowres): Stall, backward drift ended at 1482031303 drift: 1

 *** 2016-12-17 22:22:03.505
 kstmchkdrift (kstmhighrestimecntkeeper:highres): Time jumped forward by (4939246)usec at (1482031323505006) whereas (1000000) is allowed
 kstmchkdrift (kstmhighrestimecntkeeper:highres): Time jumped forward by (2850778)usec at (1482037600018932) whereas (1000000) is allowed
 kstmchkdrift (kstmhighrestimecntkeeper:highres): Time jumped forward by (1853895)usec at (1482046620148715) whereas (1000000) is allowed
 kstmchkdrift (kstmhighrestimecntkeeper:highres): Time jumped forward by (1183737)usec at (1482048031506463) whereas (1000000) is allowed
 kstmchkdrift (kstmhighrestimecntkeeper:highres): Time jumped forward by (2284330)usec at (1482056954557624) whereas (1000000) is allowed
 kstmchkdrift (kstmhighrestimecntkeeper:highres): Time jumped forward by (1800835)usec at (1482058839861395) whereas (1000000) is allowed

=cut

my $outputType = 'RPT';
my $csvOutput=0;
my $forwardDriftThreshold=1;

GetOptions (
	"h|help!" => sub { pod2usage( -verbose => 1 ) },
	"man!" => sub { pod2usage( -verbose => 2 ) },
	"csv-output!" => \$csvOutput,
	"forward-drift-threshold=i" => \$forwardDriftThreshold,
);

$outputType = 'CSV' if $csvOutput;

# by date
my %timeDrift=();
my $currDate;


while (<>) {
	chomp;
	if (/(^\*{3})\s+([0-9-]+)\s+([0-9:.]+)$/) {
		$currDate = "$2 $3";	
		next;
	} elsif ( /Time jumped forward by/ ) {
		my @a = split(/\s+/);
		my $adjTime = $a[6];
		$adjTime =~ s/[a-z()]//g;
		push @{$timeDrift{$currDate}}, $adjTime;
	}

}

#print Dumper(\%timeDrift);

foreach my $date ( sort { $a cmp $b } keys %timeDrift ) {
	my @a = @{$timeDrift{$date}};
	if ( $outputType eq 'CSV' ) {
		foreach my $driftTime ( @a ) { 
			printf "%s,%2.3f\n", $date,$driftTime / 1e6, 
		}
	} else {
		print "== $date\n";
		foreach my $driftTime ( @a ) { 
			my $tooBig = $driftTime > $forwardDriftThreshold * 1e6 ? '<==' : '';
			printf "   %2.3f %s\n", $driftTime / 1e6, $tooBig ;
		}
	}
}



