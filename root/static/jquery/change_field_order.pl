#!/usr/local/bin/perl -w
use strict;
#------
my $infile_name = 'local_city_state_zip.txt';
my $outfile_name = 'local_city-state-zip.txt';
my ($in_h,$out_h,@sorted,@all);

#------ Convert This "06022"-"CT"-"COLLINSVILLE",
#------ To this "COLLINSVILLE"-"CT"-"06022"

open $in_h,  '<',  $infile_name      or die "Can't read $infile_name : $!";
open $out_h, '>', $outfile_name      or die "Can't write $outfile_name: $!";
 
 
 #------ Sort so that NY is top of pile, then order by city and zip
 my $i = 0;
 
  while (<$in_h>) {
 	chomp;
	chop;
   my @line = split ('-');
   
   push (@all, [$line[2],$line[1],$line[0]] );
   #print $all[0][0];
   #die;
  
   };
   
  
 
   @sorted = sort {
					$b->[1] cmp $a->[1] ||
				    $a->[0] cmp $b->[0] ||
					$a->[2] cmp $b->[2] 
					} @all;
 
	
 #------ Create new file with fields shifted 
 for (@sorted){
 	print $out_h "$_->[0]-$_->[1]-$_->[2]\n";    #   "$_[2]-$_[1]-$_[0]\n";
		
 };
 close ($in_h)or die "Can't close $infile_name : $!";
 close ($out_h)or die "Can't close $outfile_name : $!"; 