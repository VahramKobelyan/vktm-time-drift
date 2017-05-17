#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;

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


# by date
my $currDate;
my $currTime;

# just print really large values along with date and time

my $threshold = 10 * 1e6;

while (<>) {
	chomp;
	if (/(^\*{3})\s+([0-9-]+)\s+([0-9-:.]+)/) {
		$currDate = $2;	
		$currTime = $3;
		next;
	} elsif ( /Time jumped forward by/ ) {
		my @a = split(/\s+/);
		my $driftTime = $a[6];
		$driftTime =~ s/[a-z()]//g;
		printf ("%s %s,%2.3f\n", $currDate, $currTime , $driftTime / 1e6) if $driftTime > $threshold;
	}

}

