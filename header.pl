#!/usr/bin/perl
#------------------------------------------------------------------------------#
# vi: set sw=4 ts=4 ai:                            ("set modeline" in ~/.exrc) #
#------------------------------------------------------------------------------#
# Program      : header.pl                                                     #
#                                                                              #
# Author       : Ton Kersten                                   The Netherlands #
#                                                                              #
# Start date   : 10 December 2004                           Start time : 08:33 #
#                                                                              #
# Description : Create a standard program header, like this one.               #
#               The file ~/.name.info is used for name and                     #
#               address info.                                                  #
#               It should contain in this order:                               #
#                    name <coder name>                                         #
#                    firm <firm name>                                          #
#                    adr1 <address line>                                       #
#                    adr2 <address line>                                       #
#                    adr3 <address line>                                       #
#                    zipc <zipcode>                                            #
#                    cntr <country>                                            #
#                    tele Tel: <telephone number>                              #
#                    tfax Fax: <fax number>                                    #
#                    mail <email address>                                      #
#                    cpri <copyright owner>                                    #
#               If the file ~/.name.info cannot be found the values from the   #
#               %MYOWN hash are used. If this file does not contain all the    #
#               required lines, the defaults from the %MYOWN hash are used.    #
#               All fields should be there!!                                   #
#                                                                              #
#               If no language is given, a default of "bash" is used.          #
#                                                                              #
# Remarks     : Adjust the                                                     #
#                  %author,                                                    #
#                  %hbs,                                                       #
#                  %ends,                                                      #
#                  %delims                                                     #
#               to your own wishes                                             #
#                                                                              #
# Updates     : A lot.                                                         #
#------------------------------------------------------------------------------#
use strict;
use warnings;
use diagnostics;
use Env;
use Getopt::Long;
use POSIX qw(locale_h strftime);		# Needed for locale support            #

#------------------------------------------------------------------------------#
#                    V e r s i o n   i n f o r m a t i o n                     #
#------------------------------------------------------------------------------#
# $Id:: header.pl 146 2010-10-04 14:16:38 tonk                              $: #
# $Revision:: 146                                                           $: #
# $Author:: Ton Kersten <tonk@tonkersten.com>                               $: #
# $Date:: 2010-10-04 14:16:43 +0200 (Mon, 04 Oct 2010)                      $: #
# $Hash:: 5eee1ac24debc3dbd4c2a04ef284bdd00957c1b5 (tonk)                   $: #
#------------------------------------------------------------------------------#
#             E n d   o f   v e r s i o n   i n f o r m a t i o n              #
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
# Define the header version information                                        #
#------------------------------------------------------------------------------#
my $HeaderVersion = "4.12";

#------------------------------------------------------------------------------#
# Make sure we have a correct locale                                           #
#------------------------------------------------------------------------------#
$ENV{LC_ALL} = 'C';						# use the "C" locale                   #
setlocale(LC_ALL, "C");

#------------------------------------------------------------------------------#
# Find out if we do have a real operating system                               #
#------------------------------------------------------------------------------#
my $UNIX = ( ($^O !~ /win/i) && ($^O !~ /cygwin/i) );

#------------------------------------------------------------------------------#
# Get the current time and date                                                #
#------------------------------------------------------------------------------#
my (undef, $min, $hour, $mday, $mon, $year, $wday, undef) = localtime();
$year += 1900;

#------------------------------------------------------------------------------#
# Set the default author and the other structures                              #
#------------------------------------------------------------------------------#
my %MYOWN =
(	name => 'Ton Kersten',
	firm => 'Ton Kersten',
	adr1 => 'My street address',
	adr2 => 'My home town',
	adr3 => '',
	zipc => 'My zip code',
	cntr => 'My country',
	tele => 'Tel: +31xxxxxxxxxx',
	tfax => 'Fax: +31xxxxxxxxx',
	mail => 'Ton.Kersten@xxxxxxxx.nl',
	cpri => 'Ton Kersten',
);
my %author =
(	name => '',
	firm => '',
	adr1 => '',
	adr2 => '',
	adr3 => '',
	cntr => '',
	zipc => '',
	tele => '',
	tfax => '',
	mail => '',
	cpri => '',
);
my @fields =
(	"name",								# Author name                          #
	"firm",								# Company name                         #
	"adr1",								# Company address                      #
	"adr2",								# Company address                      #
	"adr3",								# Company address                      #
	"cntr",								# Country                              #
	"zipc",								# Zip code                             #
	"tele",								# Telephone number                     #
	"tfax",								# Telefax number                       #
	"mail",								# E-mail address                       #
	"cpri",								# The copyright owner                  #
);
my %default =
(	hlang	=> "en",
	lang	=> "bash",
	copy	=> "none",
	short	=> "no",
	vcs		=> "git",					# svn, git or none                     #
	tab		=> 4,
	width	=> 80,
);

#------------------------------------------------------------------------------#
# According to GNU, you should leave this alone                                #
#------------------------------------------------------------------------------#
my $me = "(c) 2001-$year by $MYOWN{name} ";

#------------------------------------------------------------------------------#
# Language definitions                                                         #
#------------------------------------------------------------------------------#
my %hbs =								# Start the header with this           #
(	bash	=>	"#!/bin/bash" ,

	ksh		=>	"#!/bin/ksh",

	perl	=>	"#!/usr/bin/perl" ,

	rexx    =>	"#!/usr/bin/rexx\n" .
				"/* Comment needed for Rexx */",

	php		=>	"<?php",

	html	=>	"<html lang=\"nl\" xmlns=\"http://www.w3.org/1999/xhtml\">\n" .
				"<body>\n" .
				"<head>\n" ,

	init	=>	"#!/bin/bash\n" .
				"# chkconfig: 2345 85 15\n" .
				"# description:",
);

my %ends =									 # End the header with this        #
(	latex	=>	"%\n" .
			    "\\documentclass[a4paper,11pt,twoside,mctitle,dutch]{boek}\n" .
				"\\usepackage[dutch,english]{babel}\n" .
	 		    "\\selectlanguage{dutch}\n" .
	 		    "\\parindent 0pt\n" .
	 		    "\\parskip \\baselineskip\n%\n%\n" .
	 		    "\\title{Document Skelet}\n\n" .
	 		    "\\author{\\small Author name \\\\\n" .
				"        \\small Company \\\\\n" .
				"        \\small Address line 1 \\\\\n" .
				"        \\small Address line 2 \\\\\n" .
		 	    "        \\small Country \\\\\n" .
		 	    "        \\small email: {\\small \\tt $MYOWN{mail}}}\n\n" .
		 	    "\\date{CONCEPT --- \\today\\ --- CONCEPT}\n\n" .
		 	    "\\begin{document}\n" .
		 	    "\\selectlanguage{dutch}\n" .
		 	    "\\maketitle\n\n\n\n\n" .
		 	    "\\end{document}" ,

	ksh		=>	"IAM=\"\$\{0##*/}\"\n" .
				"CRD=\"\$( [[ \"\$(printf \"\${0}\" | cut -c 1 )\" = \".\" ]] &&\n" .
				"	{	printf \"\${PWD}/\${0}\"\n" .
				"	} || {\n" .
				"		printf \"\${0}\"\n".
				"	})\"\n" .
				"CRD=\"\$\{CRD%/*}\"\n" .
				"CUR=\"\$\{PWD}\"\n" ,

	bash	=>	"IAM=\"\$\{0##*/}\"\n" .
				"CRD=\"\$( [[ \"\$(printf \"\${0}\" | cut -c 1 )\" = \".\" ]] &&\n" .
				"	{	printf \"\${PWD}/\${0}\"\n" .
				"	} || {\n" .
				"		printf \"\${0}\"\n".
				"	})\"\n" .
				"CRD=\"\$\{CRD%/*}\"\n" .
				"CUR=\"\$\{PWD}\"\n" ,

	perl	=>	"require 5;\n" .
				"use strict;\n" .
				"use warnings;\n" .
				"use Carp;\n" .
				"use Getopt::Std;\n",

	atroff	=>	".LAN ned\n" .
				".TYP dictaat\n" .
				".TIT\n" .
				".TIT\n" .
				".TIT\n" .
				".TIT \$Date\$\n" .
				".FIR AT Computing\n" .
				".VER \$Revision\$\n" .
				".CPR $year\n" ,

	html	=>	"<title>" .
				"</title>\n\n\n\n" .
				"</head>\n" .
				"</body>\n" .
				"</html>\n" ,

	c		=>	"#include <stdio.h>\n" .
				"#include <stdlib.h>\n" .
				"#include <strings.h>\n" ,

	spec	=>	"Name:			RPM Name\n" .
				"Version:		%(echo \${VERSION})\n" .
				"Release:		%(echo \${RELEASE})\n" .
				"License:		Distributable\n" .
				"Group:			Applications/Tools\n" .
				"Packager:		%{_packager}\n" .
				"Vendor:			%{_vendor}\n" .
				"Source:			%{name}-%{version}.tar.gz\n" .
				"Summary:		Short description\n" .
				"Buildroot:		%{_buildroot}\n" .
				"Distribution:	AT Computing RPM Manager\n" .
				"BuildArch:		i386\n" .
				"\#AutoReqProv:	no\n",
);


my %delims =
(	#--------------------------------------------------------------------------#
	# Comment delimiter hash                                                   #
	# Key:  Language                                                           #
	# List: comment start                                                      #
	#       comment dash                                                       #
	#       comment end                                                        #
	#       comment left for GIT/SVN comment                                   #
	#       prelim comments (like #!/bin/bash for the bourne again shell)      #
	#                                                                          #
	#       Newlines are allowed                                               #
	#--------------------------------------------------------------------------#
	atroff => [".COM #", "-", "#"   , $hbs{atroff} ],
	bash   => ["#"     , "-", "#"   , $hbs{bash}   ],
	c      => ["/*"    , "-", "*/"  , $hbs{c}      ],
	config => ["#"     , "-", "#"   , $hbs{config} ],
	go     => ["/*"    , "-", "*/"  , $hbs{go}     ],
	html   => ["<!-- " , "=", " -->", $hbs{html}   ],
	init   => ["#"     , "-", "#"   , $hbs{init}   ],
	js     => ["/*"    , "-", "*/"  , $hbs{js}     ],
	ksh    => ["#"     , "-", "#"   , $hbs{ksh}    ],
	latex  => ["%"     , "-", "%"   , $hbs{latex}  ],
	nagios => ["#"     , "-", "#"   , $hbs{bash}   ],
	pascal => ["(*"    , "-", "*)"  , $hbs{pascal} ],
	perl   => ["#"     , "-", "#"   , $hbs{perl}   ],
	php    => ["/*"    , "-", "*/"  , $hbs{php}    ],
	rexx   => ["/*"    , "-", "*/"  , $hbs{rexx}   ],
	spec   => ["#"     , "-", "#"   , $hbs{spec}   ],
	tic    => ["#"     , "-", "#"   , $hbs{tic}    ],
	vim    => ["\""    , "-", "\""  , $hbs{vim}    ],
);

#------------------------------------------------------------------------------#
# Copyright message definition.                                                #
#------------------------------------------------------------------------------#

my @gnu   = (
	'This program is free software; you can redistribute it and/or modify it',
	'under the terms of the GNU General Public License as published by the',
	'Free Software Foundation; either version 2 of the License, or (at your',
	'option) any later version.',
	'',
	'This program is distributed in the hope that it will be useful, but',
	'WITHOUT ANY WARRANTY; without even the implied warranty of',
	'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.',
	'',
	'You should have received a copy of the GNU General Public License',
	'along with this program; if not, write to the',
	'Free Software Foundation, Inc.,',
	'    59 Temple Place - Suite 330,',
	'    Boston,  MA 02111-1307,',
	'    USA',
	'',
	'See the GNU General Public License for more details.',
	'URL: http://www.gnu.org/copyleft/gpl.html.'
);

#------------------------------------------------------------------------------#
# Define global variables                                                      #
#------------------------------------------------------------------------------#
my $wd = $default{width};			# The comment width                        #
my $cs;					 			# The comment start                        #
my $ce;		 						# The comment end                          #
my $da;					 			# The comment 'dashes'                     #
my $hashbang;						# Possible prelim #!....                   #
my $cl;		 						# Comment like /*---- .... ----*/          #
my $el;		 						# Comment like /*     ....     */          #
my $ts;								# Tab stop setting                         #
my $nameinfo   = $ENV{"HOME"} . "/.name.info";
my $vimcomment = "(\"set modeline\" in ~/.exrc)";
if ($UNIX != 1 )
{	my $nameinfo   = "C:\\name.info";
	my $vimcomment = "(\"set modeline\" in c:\\vimrc)";
}

my ($cop1, $cop2, $cop3, $progtext, $authtext, $startdate, $starttime, $desctext);
my ($cvsbegin, $cvseinde, $shellset, $shellexmp, $perlexmp, $default, $headline, $parmtext);
my ($updates, $prereqs, $exitcs, $functext, $setshell, $returns);
my ($rundir, $clobcom, $unsetcom, $errexitcom, $vcs);

#------------------------------------------------------------------------------#
# Define the language dependent strings                                        #
#------------------------------------------------------------------------------#
sub setlang($)
{
	my $lng = shift;

	if ( $lng eq "nl" )
	{
		$cop1       = '(c) Copyright %4d van ';
		$cop2       = 'Alle rechten voorbehouden. Gehele of gedeeltelijke reproductie is,';
		$cop3       = 'zonder schiftelijke toestemming van de copyrighthouder, verboden.';
		$default    = "standaard";
		$cvsbegin   = "Versie informatie";
		$cvseinde   = "Einde versie informatie";
		$progtext   = "Programma    :";
		$authtext   = "Auteur       :";
		$startdate  = "Datum        :";
		$starttime  = "Tijd :";
		$desctext   = "Omschrijving :";
		$parmtext   = "Parameters   :";
		$functext   = "Functie      :";
		$returns    = "Resultaat    :";
		$prereqs    = "Voorwaarden  :";
		$exitcs     = "Stop codes   :";
		$updates    = "Aanpassingen : (Nog) geen";
		$shellset   = "Bewaar de shell settings";
		$setshell   = "Set en unset de benodigde shell settings";
		$perlexmp   = "Perl functie voorbeeld";
		$shellexmp  = "Shell functie voorbeeld";
		$headline   = "Header gegenereerd door \"header " . $HeaderVersion . "\"";
		$clobcom    = "Overschrijf bestaande files, indien nodig";
		$unsetcom   = "Sta geen uninitialized variabelen toe";
		$errexitcom = "Returncode checking uit";
		$rundir     = "Bepaal de programmanaam en de 'running directory'";
	}
	else
	{
		$cop1       = '(c) Copyright %4d by ';
		$cop2       = 'All rights are reserved. Reproduction in whole or in part is';
		$cop3       = 'prohibited without the written consent of the copyrightowner';
		$default    = "default";
		$cvsbegin   = "Version information";
		$cvseinde   = "End of version information";
		$progtext   = "Program      :";
		$authtext   = "Author       :";
		$startdate  = "Date         :";
		$starttime  = "Time :";
		$desctext   = "Description  :";
		$parmtext   = "Parameters   :";
		$functext   = "Function     :";
		$returns    = "Returns      :";
		$prereqs    = "Pre reqs     :";
		$exitcs     = "Exit codes   :";
		$updates    = "Updates      : None (yet)";
		$shellset   = "Save the shell settings";
		$setshell   = "Set and unset the needed shell settings";
		$perlexmp   = "Perl function example";
		$shellexmp  = "Shell function example";
		$headline   = "Header generated by \"header " . $HeaderVersion . "\"";
		$clobcom    = "Overwrite existing files, if needed";
		$unsetcom   = "Don't allow uninitialized variables";
		$errexitcom = "No returncode checking";
		$rundir     = "Determine the program name and the 'running directory'";
	}
}


#------------------------------------------------------------------------------#
# Here come the subroutines                                                    #
#------------------------------------------------------------------------------#

sub unknownlang($)
{	#--------------------------------------------------------------------------#
	# Display an error message and stop                                        #
	#                                                                          #
	# Returns   : nothing                                                      #
	#--------------------------------------------------------------------------#
	my $lang = shift;

	#--------------------------------------------------------------------------#
	# Undefined language requested. Show the known ones                        #
	# and EXIT!! the program                                                   #
	#--------------------------------------------------------------------------#
	local $" = "\n\t";
	my @known = sort keys %delims;

	my $warnstring;
	($warnstring = <<WARN) =~ s/^\s+//gm;
		Unsupported language or illegal option: $lang

	 	Supported languages:
	 	@known

WARN
	warn $warnstring;
	exit(10);
}


sub right($$)
{	#--------------------------------------------------------------------------#
	# Right align a string with spaces to the left                             #
	#                                                                          #
	# Returns   : right aligned text padded with blanks to length width        #
	#                                                                          #
	# Parameters: 1) width to align the text in                                #
	#             2) the text to align                                         #
	#--------------------------------------------------------------------------#
	my $width = shift;
	my $line  = shift;

	#--------------------------------------------------------------------------#
	# Determine the front spaces.                                              #
	#--------------------------------------------------------------------------#
	my $front = $width - length($line);

	return " " x $front . $line;
}


sub left($$)
{	#--------------------------------------------------------------------------#
	# Pad a line with white space                                              #
	#                                                                          #
	# Returns   : left aligned text padded with blanks to length width         #
	#                                                                          #
	# Parameters: 1) width to align the text in                                #
	#             2) the text to align                                         #
	#--------------------------------------------------------------------------#
	my $width = shift;
	my $line  = shift;

	#--------------------------------------------------------------------------#
	# Determine the front spaces.                                              #
	#--------------------------------------------------------------------------#
	my $trail = $width - length($line);

	return $line . " " x $trail;
}


sub centerchar($$$)
{	#--------------------------------------------------------------------------#
	# Centre a string in the available space                                   #
	#                                                                          #
	# Returns   : centered text padded with $chars to length width             #
	#                                                                          #
	# Parameters: 1) width to center the text in                               #
	#             2) the text to align                                         #
	#--------------------------------------------------------------------------#
	my $width = shift;
	my $pad   = shift;
	my $line  = shift;

	#--------------------------------------------------------------------------#
	# Solve problems with odd and even length strings                          #
	#--------------------------------------------------------------------------#
	use integer;

	#--------------------------------------------------------------------------#
	# Determine the front and end spaces.                                      #
	#--------------------------------------------------------------------------#
	my $front = ($width - length($line)) / 2;
	my $trail  = $width - length($line) - $front;

	return $pad x $front . $line . $pad x $trail;
}


sub center($$)
{	#--------------------------------------------------------------------------#
	# Centre a string in the available space                                   #
	#                                                                          #
	# Returns   : centered text padded with blanks to                          #
	#             length width                                                 #
	#                                                                          #
	# Parameters: 1) width to center the text in                               #
	#             2) the text to align                                         #
	#--------------------------------------------------------------------------#
	my $width = shift;
	my $line  = shift;

	return centerchar($wd, " ", $line);
}


sub spaceline($)
{	#--------------------------------------------------------------------------#
	# Space a line, meaning that every character is surrounded                 #
	# with spaces.                                                             #
	#                                                                          #
	# Returns   : The spaced line                                              #
	#                                                                          #
	# Parameters: 1) the line to space                                         #
	#--------------------------------------------------------------------------#
	my $line = shift;

	my $out = "";
	while ( $line ne "" )
	{
		my $char = substr($line, 0, 1);
		$line = substr($line, 1);

		if ( $out eq "" )
		{	$out = $char;
		}
		else
		{	$out = $out . " " . $char;
		}
	}
	return $out;
}


sub comment($)
{	#--------------------------------------------------------------------------#
	# Determine the comment and prelim strings                                 #
	# Parameters: 1) language for comment strings                              #
	#                                                                          #
	# Returns   : list of comment info                                         #
	#                comment_start,                                            #
	#                comment_dash,                                             #
	#                comment_end,                                              #
	#                hashbang                                                  #
	#                                                                          #
	# Parameters: 1) language for which the comment strings are wanted         #
	#--------------------------------------------------------------------------#
	my $lang = shift;

	if($delims{$lang})
	{	return @{$delims{$lang}};
	}
	else
	{	unknownlang($lang);
	}
}


sub printline($$$;$)
{	#--------------------------------------------------------------------------#
	# Print the lines nice.                                                    #
	#                                                                          #
	# Returns   : nothing                                                      #
	#                                                                          #
	# Parameters: 1) width to print the text in                                #
	#             2) boolean: print an empty line after the printed line       #
	#             3) first part of the text to print (left hand side)          #
	#             4) second part of the text to print (right hand) optional    #
	#--------------------------------------------------------------------------#
	my ($wd, $empty, $lhs, $rhs) = @_;
	my $l = $wd - 30;
	my $r = $wd - $l;

	if($rhs)
	{	print OUT $cs . left($l, $lhs);
		print OUT right($r, $rhs) . $ce . "\n";
	}
	else
	{	print OUT $cs . left($wd, $lhs) . $ce . "\n";
	}

	print OUT $el if $empty;
}


sub printwithcomment($$$)
{	#--------------------------------------------------------------------------#
	# Print the lines nice and place a comment at the right                    #
	#                                                                          #
	# Returns   : nothing                                                      #
	#                                                                          #
	# Parameters: 1) width to print the text in                                #
	#             2) first part of the text to print (left hand side)          #
	#             3) second part of the text to print (right hand side)        #
	#--------------------------------------------------------------------------#
	my ($wd, $lhs, $rhs) = @_;
	my $l = $wd - 50;
	my $r = $wd - $l;

	print OUT left($l, $lhs);
	print OUT $cs . " " . left($r-2, $rhs) . " " . $ce . "\n";
}


sub help()
{
	#--------------------------------------------------------------------------#
	# Display the help and exit                                                #
	#--------------------------------------------------------------------------#
	print "\theader $HeaderVersion by $MYOWN{name}\n";
	print "\tSyntax: header [options]\n\n";
	print "\tOptions:\n";
	print "\t\t--nameinfo=filename\tUse an alternative name.info file <~/.name.info>\n";
	print "\t\t--language=language\tProgramming language \<$default{lang}>\n";
	print "\t\t--file=filename\t\tOutput filename\n";
	print "\t\t--copyright=cpy\t\tCopyright message (<short>|yes|gnu|none)\n";
	print "\t\t--short\t\t\tUse a short header\n";
	print "\t\t--stdout\t\tPrint the output to stdout\n";
	print "\t\t--headlang=nl|en\tWhich header language to use <$default{hlang}>\n";
	print "\t\t--tabstop=n|--ts=n\tWhat tabstop size to use <$default{tab}>\n";
	print "\t\t--width=n\t\tWhat headerwidth to use <$default{width}>\n";
	print "\t\t--vcs=git|svn|none\tWhat version control system to use <$default{vcs}>\n";
	print "\t\t--help\t\t\tPrint this help\n\n";
	print "\tOptions can be abbriviated, as long as they can be uniquely identified\n\n";

	local $" = "\n\t";
	my @known = join(" ", sort keys %delims);

	print "Supported program languages:\n\t@known\n";

	exit 0;
}


#------------------------------------------------------------------------------#
# Here the main program starts. Read the options                               #
#------------------------------------------------------------------------------#
my ($namefile, $lang, $name, $copy, $short, $stdo, $hlang, $tab, $width, $help);
GetOptions(	"nameinfo=s",	=> \$namefile,
			"language=s"	=> \$lang,
			"file=s"		=> \$name,
			"copyright=s"	=> \$copy,
			"short"			=> \$short,
			"stdout"		=> \$stdo,
			"headlang=s"	=> \$hlang,
			"tabstop=n"		=> \$tab,
			"ts=n"			=> \$tab,
			"width=n"		=> \$width,
			"vcs=s"			=> \$vcs,
			"help"			=> \$help);

$hlang = $hlang || $default{hlang};	 # The default header language             #
setlang($hlang);					 # Reset the language                      #
help if ($help);					 # Help requested                          #

$lang  = $lang  || $default{lang};	 # Define the (default) language           #
$name  = $name  || $default;		 # Define the program name                 #
$copy  = $copy  || $default{copy};	 # Print 'copyright'                       #
$short = $short || $default{short};	 # Print the short header                  #
$ts    = $tab   || $default{tab};	 # Which tab stop to use                   #
$wd    = $width || $default{width};	 # Which width to use                      #
$vcs   = $vcs   || $default{vcs};	 # Which version control system to use     #
setlang($hlang);
$nameinfo = $namefile || $nameinfo;	 # Define the (default) nameinfo file      #
my $vimsettings = "vi: set sw=$ts ts=$ts ai:";

#------------------------------------------------------------------------------#
# If a name is supplied place it in that file                                  #
#------------------------------------------------------------------------------#
my $fileopen = 0;
if ($name eq $default)
{	open OUT, ">-";
}
else
{	if ($stdo)
	{	open OUT, ">-";
	}
	else
	{	open OUT, "> $name" or die "Cannot open $name";
		$fileopen = 1;
	}
}

#------------------------------------------------------------------------------#
# Open and read the nameinfo file                                              #
#------------------------------------------------------------------------------#
my $ni = 1;
open NAME, $nameinfo or $ni = 0;
if ( $ni == 1 )
{
	foreach my $field (@fields)
	{	my $line = <NAME> || '  ';
		chomp($line);
		my ($fld, @val) = split(/ /, $line) ;
		$fld = $field if (! $fld);
		my $vl = join(" ", @val);
		$author{$fld} = $vl || $MYOWN{$field};
	}
	close NAME;
}
else
{
	printf STDERR "\n\nThe nameinfo file $nameinfo could not be found.";
	printf STDERR "Using defaults.\n\n\n";
	foreach my $field (@fields)
	{	$author{$field} = $MYOWN{$field};
	}
}

#------------------------------------------------------------------------------#
# Define the comment strings                                                   #
#------------------------------------------------------------------------------#
($cs, $da, $ce, $hashbang) = comment(lc($lang));
$wd = $wd - length($cs) - length($ce);
$wd += 4 if length($cs) >= 3;
$cl = $cs . $da x $wd . $ce . "\n"; # The standard comment line                #
$el = $cs . " " x $wd . $ce . "\n";	# The standard empty comment line          #

#------------------------------------------------------------------------------#
# Create the current date and time in nice formats                             #
#------------------------------------------------------------------------------#
(undef, $min, $hour, $mday, $mon, $year, $wday, undef) = localtime();
$year += 1900;
my $now = sprintf "%02d-%02d-$year", $mday, $mon+1;
my $tim = sprintf "%02d:%02d", $hour, $min;

$cvsbegin = " " . spaceline($cvsbegin) . " ";
$cvseinde = " " . spaceline($cvseinde) . " ";

#------------------------------------------------------------------------------#
# Translate the yyyy into the year and form the copyright string               #
#------------------------------------------------------------------------------#
my $copyright = (sprintf $cop1, $year) . $author{cpri};

#------------------------------------------------------------------------------#
# Print it all out                                                             #
#------------------------------------------------------------------------------#
print OUT "$hashbang\n" if $hashbang;

$author{firm} = "" if ($author{firm} eq $author{name});

#------------------------------------------------------------------------------#
# Print the standard VIM settings at the top                                   #
#------------------------------------------------------------------------------#
print OUT $cl;
printline($wd, 0, " $vimsettings", "$vimcomment ");

#------------------------------------------------------------------------------#
# Do we have a C header file?                                                  #
#------------------------------------------------------------------------------#
my $head  = substr $name, -1, 1;
my $hname = "";
my $headerfile = 0;
if ($head eq "h" && $lang eq "c")
{	$headerfile = 1;
	$hname = uc($name);
	$hname =~ tr/./_/;
}

#------------------------------------------------------------------------------#
# Print it                                                                     #
#------------------------------------------------------------------------------#
if ($lang eq "config")
{	$progtext = "Config file  :";
}
print OUT $cl;
printline($wd, 1, " $progtext $name");

$short = "yes" if ($author{firm} eq "");
if (lc($short) eq "no")
{	my $spc = " " x length($authtext);
	printline($wd, 0, " $authtext $author{name}", "$author{mail} ");
	printline($wd, 0, " $spc $author{firm}", "$author{adr1} ");
	printline($wd, 0, " $spc $author{zipc}  $author{adr2}", "$author{cntr} ");
	printline($wd, 0, " $spc $author{adr3}") if ( $author{adr3} );
	printline($wd, 1, " $spc $author{tele}", "$author{tfax} ");
	printline($wd, 1, " $startdate $now", "$starttime $tim ");

	#printline($wd, 0, " $spc $MYOWN{mail}", "$MYOWN{firm} ");
	#printline($wd, 1, " $spc $MYOWN{adr1}, $MYOWN{adr2}", "$MYOWN{zipc}, $MYOWN{cntr} ");
}
else
{	printline($wd, 1, " $authtext $author{name}", "$author{cntr} ");
	printline($wd, 0, " $startdate $now", "$starttime $tim ");
}
if (lc($short) eq "no")
{	printline($wd, 1, " $desctext");
	if ($lang ne "config")
	{	printline($wd, 0, " $parmtext");
		#printline($wd, 1, " $prereqs ");
		#printline($wd, 0, " $exitcs    0 -> OK");
		#printline($wd, 1, "                <> 0 -> !OK");
	}
	# printline($wd, 0, " $updates ");
}

#------------------------------------------------------------------------------#
# Print extra copyright                                                        #
#------------------------------------------------------------------------------#
if(lc($copy) eq "yes")
{	print OUT $cl;
	print OUT $cs . center($wd, $copyright) . $ce . "\n";
	print OUT $cs . center($wd, $cop2) . $ce . "\n";
	print OUT $cs . center($wd, $cop3) . $ce . "\n";
}

#------------------------------------------------------------------------------#
# Print extra copyright (Short version)                                        #
#------------------------------------------------------------------------------#
if(lc($copy) eq "short")
{	print OUT $cl;
	print OUT $cs . center($wd, $copyright) . $ce . "\n";
}

#------------------------------------------------------------------------------#
# Print GNU copyright                                                          #
#------------------------------------------------------------------------------#
if(lc($copy) eq "gnu")
{	print OUT $cl;
	print OUT $cs . center($wd, $copyright) . $ce . "\n";
	print OUT $cl;
	for ( my $i = 0; $i <= $#gnu; $i++ )
	{
		printline($wd, 0, " " . $gnu[$i]);
	}
}
print OUT "$cl";

#------------------------------------------------------------------------------#
# Print the end of the preliminary (GIT/SVN information)                       #
#------------------------------------------------------------------------------#
if ( $vcs ne "none" )
{	print OUT "\n";
	print OUT "$cl";
	print OUT "$cs" . center($wd, $cvsbegin) . $ce . "\n";
	print OUT "$cl";
	printline($wd, 0, " \$Id"       . "::", "\$: ");
	printline($wd, 0, " \$Revision" . "::", "\$: ");
	printline($wd, 0, " \$Author"   . "::", "\$: ");
	printline($wd, 0, " \$Date"     . "::", "\$: ");
	if ( $vcs eq "svn" )
	{
		printline($wd, 0, " \$Url"      . "::", "\$: ");
	}
	else
	{
		printline($wd, 0, " \$Hash" . "::",     "\$: ");
	}

	print OUT "$cl";
	print OUT "$cs" . center($wd, $cvseinde) . $ce . "\n";
	print OUT "$cl\n";
}

#------------------------------------------------------------------------------#
# Extra lines for C header files                                               #
#------------------------------------------------------------------------------#
if ($headerfile == 1)
{	print OUT "#ifndef $hname\n";
	print OUT "#define $hname\n\n";
}

if ( 	(lc($lang) eq "bash")	||
		(lc($lang) eq "ksh")	||
		(lc($lang) eq "nagios") ||
		(lc($lang) eq "init")	)
{	print OUT "$cl";
	printline($wd, 0, " $rundir");
	print OUT "$cl";
}

#------------------------------------------------------------------------------#
# Print the end part of the language                                           #
#------------------------------------------------------------------------------#
if ( (lc($lang) eq "nagios") || (lc($lang) eq "init") )
{	print OUT "$ends{bash}";
}
else
{	print OUT "$ends{$lang}" if $ends{$lang};
}

#------------------------------------------------------------------------------#
# Print the settings tags                                                      #
#------------------------------------------------------------------------------#
if ( 	(lc($lang) eq "bash")	||
		(lc($lang) eq "ksh")	||
		(lc($lang) eq "nagios") ||
		(lc($lang) eq "init")	)
{	my $fl = $cs . $da x ($wd-$ts) . $ce . "\n";

	#--------------------------------------------------------------------------#
	# Print the saving of the shell settings                                   #
	#--------------------------------------------------------------------------#
	print OUT "\n" . $cl;
	print OUT $cs . left($wd, " $shellset") . $ce . "\n";
	print OUT $cl;
	print OUT "SETA=0; [[ \${-} = *a* ]] && SETA=1\n";
	print OUT "SETE=0; [[ \${-} = *e* ]] && SETE=1\n";
	print OUT "SETU=0; [[ \${-} = *u* ]] && SETU=1\n";
	print OUT "SETX=0; [[ \${-} = *x* ]] && SETX=1\n";
	print OUT "\n";

	#--------------------------------------------------------------------------#
	# Print the setting of the shell variables                                 #
	#--------------------------------------------------------------------------#
	print OUT $cl;
	print OUT $cs . left($wd, " $setshell") . $ce . "\n";
	print OUT $cl;
	printwithcomment ($wd, "set +o noclobber", $clobcom);
	printwithcomment ($wd, "set -o nounset",   $unsetcom);
	printwithcomment ($wd, "set +o errexit",   $errexitcom);

	if ( lc($lang) eq "nagios" )
	{
		#----------------------------------------------------------------------#
		# Set verbose                                                          #
		#----------------------------------------------------------------------#
		print OUT "\n" . $cl;
		print OUT $cs . left($wd, " Switch testing modus on or off") . $ce . "\n";
		print OUT $cl;
		print OUT "TESTING=\${TESTING:-0}\n";

		#----------------------------------------------------------------------#
		# Set verbose                                                          #
		#----------------------------------------------------------------------#
		print OUT "\n" . $cl;
		print OUT $cs . left($wd, " Switch debugging on or off") . $ce . "\n";
		print OUT $cl;
		print OUT "$cs VERBOSE=\"set -x\"\n";
		print OUT "\${VERBOSE:-}\n";

		#----------------------------------------------------------------------#
		# Source the Nagios library                                            #
		#----------------------------------------------------------------------#
		print OUT "\n" . $cl;
		print OUT $cs . left($wd, " Define the Nagios library") . $ce . "\n";
		print OUT $cl;
		print OUT "NAGLIB=\"/usr/local/atcons/lib/naglib\"\n";
		print OUT "[[ \${TESTING} = 1 ]] && NAGLIB=\"./lib/naglib\"\n";

		print OUT "\n" . $cl;
		print OUT $cs . left($wd, " and source it") . $ce . "\n";
		print OUT $cl;
		print OUT "[[ ! -f \${NAGLIB} ]] &&\n";
		print OUT "{\n";
		print OUT "\tprintf -- \"The Nagios library could not be found.\\n\"\n";
		print OUT "\tprintf -- \"The program will be stopped.\\n\"\n";
		print OUT "\texit 3\n";
		print OUT "}\n";
		print OUT ". \${NAGLIB} ||\n";
		print OUT "{\n";
		print OUT "\tprintf -- \"An error occured while sourcing the NagLib\\n\"\n";
		print OUT "\tprintf -- \"The program will be stopped.\\n\"\n";
		print OUT "\texit 4\n";
		print OUT "}\n";

		#----------------------------------------------------------------------#
		# Source the function library                                          #
		#----------------------------------------------------------------------#
		print OUT "\n" . $cl;
		print OUT $cs . left($wd, " Source the Nagios functions library") . $ce . "\n";
		print OUT $cl;

		print OUT "FUNCTIONS=\"\${ATCONSLIB}/functions\"\n";
		print OUT "[[ ! -f \${FUNCTIONS} ]] &&\n";
		print OUT "{\n";
		print OUT "\tprintf -- \"The Nagios function library could not be found.\\n\"\n";
		print OUT "\tprintf -- \"The program will be stopped.\\n\"\n";
		print OUT "\texit 3\n";
		print OUT "}\n";
		print OUT ". \${FUNCTIONS} ||\n";
		print OUT "{\n";
		print OUT "\tprintf -- \"An error occured while sourcing the NagLib functions\\n\"\n";
		print OUT "\tprintf -- \"The program will be stopped.\\n\"\n";
		print OUT "\texit 4\n";
		print OUT "}\n";

		#----------------------------------------------------------------------#
		# Source the MySQL password file                                       #
		#----------------------------------------------------------------------#
		print OUT "\n" . $cl;
		print OUT $cs . left($wd, " Source the MySQL password file (If I can read it)") . $ce . "\n";
		print OUT $cl;

		print OUT "[[ -r \${MYSQLPWDFILE} ]] &&\n";
		print OUT "{\t. \${MYSQLPWDFILE} ||\n";
		print OUT "\t{\n";
		print OUT "\t\tprintf -- \"An error occured while sourcing the MySQL password file\\n\"\n";
		print OUT "\t\tprintf -- \"The program will be stopped.\\n\"\n";
		print OUT "\t\texit 4\n";
		print OUT "\t}\n";
		print OUT "}\n";

		#----------------------------------------------------------------------#
		# Set logging                                                          #
		#----------------------------------------------------------------------#
		print OUT "\n" . $cl;
		print OUT $cs . left($wd, " Set the logdirectory and file") . $ce . "\n";
		print OUT $cl;
		print OUT "LOGGING=\${LOGGING:-0}\n";
		print OUT "LOGDIR=\"\${NAGIOSVAR}/log\"\n";
		print OUT "LOGFILE=\"\${IAM}.log\"\n";

		#----------------------------------------------------------------------#
		# Create logging when wanted                                           #
		#----------------------------------------------------------------------#
		print OUT "\n" . $cl;
		print OUT $cs . left($wd, " Start the logging") . $ce . "\n";
		print OUT $cl;
		print OUT "[[ \${LOGGING:-0} = 1 ]] &&\n";
		print OUT "{\n";
		print OUT "\tCreateDirectory -Q \${LOGDIR} || Stop 6 \"Creating the log directory failed\"\n";
		print OUT "\tLOGDIR=\$(AbsolutePath \${LOGDIR})\n";
		print OUT "\tLOGFILE=\${LOGDIR}/\${LOGFILE}\n";
		print OUT "\tSetLog \${LOGFILE} || Stop 7 \"Setting the logging failed\"\n";
		print OUT "}\n\n";
	}

	if ( lc($lang) eq "init" )
	{
		#----------------------------------------------------------------------#
		# The init script part                                                 #
		#----------------------------------------------------------------------#
		print OUT "\n" . $cl;
		print OUT $cs . left($wd, " Source the function library") . $ce . "\n";
		print OUT $cl;
		print OUT ". /etc/rc.d/init.d/functions\n";

		print OUT "\n" . $cl;
		print OUT $cs . left($wd, " Program settings") . $ce . "\n";
		print OUT $cl;
		print OUT "OPTIONS=\"\"\n";
		print OUT "PIDFILE=\"/var/log/xxx.pid\"\n";
		print OUT "LOCKFILE=\"/var/log/xxx.lock\"\n";

		print OUT "\n" . $cl;
		print OUT $cs . left($wd, " Default return value") . $ce . "\n";
		print OUT $cl;
		print OUT "RETVAL=0\n";

		print OUT "\n" . $cl;
		print OUT $cs . left($wd, " Start function") . $ce . "\n";
		print OUT $cl;
		print OUT "start()\n";
		print OUT "{\n";
		print OUT "\techo -n \$\"Starting \${PROG}: \"\n";
		print OUT "\n";
		print OUT "\tRETVAL=\${?}\n";
		print OUT "\techo\n";
		print OUT "\t[[ \${RETVAL} = 0 ]] && touch \${LOCKFILE}\n";
		print OUT "\treturn \${RETVAL}\n";
		print OUT "}\n";
		print OUT "\n";

		print OUT "\n" . $cl;
		print OUT $cs . left($wd, " Stop function") . $ce . "\n";
		print OUT $cl;
		print OUT "stop()\n";
		print OUT "{\n";
		print OUT "\techo -n \$\"Stopping \${PROG}: \"\n";
		print OUT "\n";
		print OUT "\tRETVAL=\${?}\n";
		print OUT "\techo\n";
		print OUT "\t[[ \${RETVAL} = 0 ]] && rm -f \${LOCKFILE} \${PIDFILE}\n";
		print OUT "}\n";
		print OUT "\n";

		print OUT "\n" . $cl;
		print OUT $cs . left($wd, " Status function") . $ce . "\n";
		print OUT $cl;
		print OUT "status()\n";
		print OUT "{\n";
		print OUT "\techo \"The status of this daemon\"\n";
		print OUT "\treturn\n";
		print OUT "}\n";
		print OUT "\n";

		print OUT "\n" . $cl;
		print OUT $cs . left($wd, " Main program") . $ce . "\n";
		print OUT $cl;

		print OUT "case \"\${1}\"\n";
		print OUT "in\n";
		print OUT "\tstart)\n";
		print OUT "\t\tstart\n";
		print OUT "\t\t;;\n\n";
		print OUT "\tstop)\n";
		print OUT "\t\tstop\n";
		print OUT "\t\t;;\n\n";
		print OUT "\tstatus)\n";
		print OUT "\t\tstatus \${PROG}\n";
		print OUT "\t\tRETVAL=\${?}\n";
		print OUT "\t\t;;\n\n";
		print OUT "\trestart)\n";
		print OUT "\t\tstop\n";
		print OUT "\t\tsleep 2\n";
		print OUT "\t\tstart\n";
		print OUT "\t\t;;\n\n";
		print OUT "\t*)\n";
		print OUT "\t\tOPT=\"start|stop|restart|status\"\n";
		print OUT "\t\techo \$\"Usage: \${IAM} \${OPT}\"\n";
		print OUT "\t\texit 1\n";
		print OUT "\t\t;;\n\n";
		print OUT "esac\n\n";
		print OUT "exit \${RETVAL}\n";
	}

	print OUT "\n" . $cl;
	print OUT $cs . left($wd, " That's all, folks!") . $ce . "\n";
	print OUT $cl;
	print OUT "exit 0";
}

#------------------------------------------------------------------------------#
# Nice stuff for Perl                                                          #
#------------------------------------------------------------------------------#
if ( lc($lang) eq "perl")
{	my $fl = $cs . $da x ($wd-$ts) . $ce . "\n";

	#--------------------------------------------------------------------------#
	# Determine the name of this program                                       #
	#--------------------------------------------------------------------------#
	print OUT "\n\n";
	print OUT $cl;
	printline($wd, 0, " Bepaal hoe dit programma heet");
	print OUT $cl;
	print OUT "my \$iam = \$0;\n";
	print OUT "\$iam =~ s/.*\\///;\n";

	#--------------------------------------------------------------------------#
	# Check if the Perl version is high enough                                 #
	#--------------------------------------------------------------------------#
	print OUT "\n\n";
	print OUT $cl;
	printline($wd, 0, " Check if the Perl version is high enough");
	print OUT $cl;
	print OUT "my \@ver = split/\\./, \$];\n";
	print OUT "my \$ver = \$ver[0] . \$ver[1]*10;\n";
	print OUT "if (\$ver < 560)\n";
	print OUT "{\t\$ver =~ s/(.)/\$1\./g;\n";
	print OUT "\tdie \"Perl is not version 5.6.0 or higher, but version \$ver\\n\";\n";
	print OUT "}\n\n\n";

	print OUT $cl;
	printline($wd, 0, " Check the commandline options");
	print OUT $cl;
	print OUT "my (\%opts);\n";
	print OUT "getopts('h?', \\%opts);\n";
	print OUT "help() if exists \$opts{'h'} or exists \$opts{'?'};\n\n";

	print OUT $cl;
	printline($wd, 0, " Read from STDIN if there are no commandline options.");
	print OUT $cl;
	print OUT "chomp(\@ARGV = <STDIN>) unless \@ARGV;\n";
	print OUT "help() unless \@ARGV;\n\n";

	print OUT "exit;\n\n";

	print OUT $cl;
	printline($wd, 0, " Define the help function");
	print OUT $cl;

	print OUT "sub help\n";
	print OUT "{\tprint <<\"HELP\";\n";
	print OUT "\tSyntax: \$0 [opts]\n";
    print OUT "\tRun perldoc(1) on this script for extra documentation\n";
	print OUT "HELP\n";
	print OUT "\texit;\n";
	print OUT "}\n\n\n";

	print OUT $cl;
	printline($wd, 0, " Define the signal handler routines");
	print OUT $cl;

	print OUT "sub int_handler\n";
	print OUT "{\n\t$fl\t";
	printline($wd-$ts, 0, " INT signal handler");
	print OUT "\t$fl";
	print OUT "\tprint \"Exit via the INT handler\\n\";\n";
	print OUT "\t\$SIG{INT} = \\&int_handler;\n";
	print OUT "\texit 0;\n";
	print OUT "}\n";

	print OUT "\n\nsub hup_handler\n";
	print OUT "{\n\t$fl\t";
	printline($wd-$ts, 0, " HUP signal handler");
	print OUT "\t$fl";
	print OUT "\tprint \"Exit via the HUP handler\\n\";\n";
	print OUT "\t\$SIG{HUP} = \\&hup_handler;\n";
	print OUT "\texit 0;\n";
	print OUT "}\n";

	print OUT "\n\nsub abrt_handler\n";
	print OUT "{\n\t$fl\t";
	printline($wd-$ts, 0, " ABRT signal handler");
	print OUT "\t$fl";
	print OUT "\tprint \"Exit via the ABRT handler\\n\";\n";
	print OUT "\t\$SIG{ABRT} = \\&abrt_handler;\n";
	print OUT "\texit 0;\n";
	print OUT "}\n";

	print OUT "\n\nsub term_handler\n";
	print OUT "{\n\t$fl\t";
	printline($wd-$ts, 0, " TERM signal handler");
	print OUT "\t$fl";
	print OUT "\tprint \"Exit via the TERM handler\\n\";\n";
	print OUT "\t\$SIG{TERM} = \\&term_handler;\n";
	print OUT "\texit 0;\n";
	print OUT "}\n";

	print OUT "\n\n\n" . $cl;
	print OUT "$cs" . center($wd, spaceline($perlexmp)) . $ce . "\n";
	print OUT $cl;
	print OUT "sub function(\$\$;\$)\n";
	print OUT "{\n";
	print OUT "\t$fl\t";
	printline($wd-$ts, 0, " $functext"); print OUT "\t";
	printline($wd-$ts, 0, " "         ); print OUT "\t";
	printline($wd-$ts, 0, " $desctext"); print OUT "\t";
	printline($wd-$ts, 0, " "         ); print OUT "\t";
	printline($wd-$ts, 0, " $parmtext"); print OUT "\t";
	printline($wd-$ts, 0, " "         ); print OUT "\t";
	printline($wd-$ts, 0, " $returns" ); print OUT "\t";
	print OUT "$fl";
	print OUT "}\n\n";

	print OUT "\n";
	print OUT $cl;
	printline($wd, 0, " Set the signal handlers");
	print OUT $cl;
	print OUT "\$SIG{INT}\t= \\\&int_handler;\n";
	print OUT "\$SIG{HUP}\t= \\\&hup_handler;\n";
	print OUT "\$SIG{ABRT}\t= \\\&abrt_handler;\n";
	print OUT "\$SIG{TERM}\t= \\\&term_handler;\n";

	print OUT "\n\n";
	print OUT $cl;
	printline($wd, 0, " Documentation");
	print OUT $cl;
	print OUT "=pod\n\n";
	print OUT "=head1 NAME\n\n";
	print OUT "$name - A short description\n\n";
	print OUT "=head1 SYNOPSIS\n\n";
	print OUT "Short description of the program.\n\n";
	print OUT "=head1 DESCRIPTION\n\n";
	print OUT "=head2 Overview\n\n";
	print OUT "Short description of the programs purpose.\n\n";
	print OUT "=head2 Normal usage\n\n";
  	print OUT "\$ $name [options]\n\n";
	print OUT "See L<\"OPTIONS\"> For commandline option details.\n\n";
	print OUT "=head1 OPTIES\n\n";
	print OUT "Dit programma ondersteunt de volgende opties:\n\n";
	print OUT "=over 4\n\n";
	print OUT "=item B<-h>, B<-?>\n\n";
	print OUT "Druk een korte omschrijving van het programma af.\n\n";
	print OUT "=back\n\n";
	print OUT "Gebruik B<-f> I<asdf> als een van de opties argumenten nodig heeft.\n\n";
	print OUT "=head1 VOORBEELDEN\n\n";
	print OUT "Extra voorbeelden.\n\n";
	print OUT "=head1 FILES\n\n";
	print OUT "Belangrijke bestanden die afhankelijk zijn van dit programma?\n\n";
	print OUT "=head1 BUGS\n\n";
	print OUT "Bekende fouten in het programma.\n";
	print OUT "=head1 ZIE OOK\n\n";
	print OUT "perl(1)\n\n";
	print OUT "=head1 AUTEUR\n\n";
	print OUT "$author{name}, $author{mail}\n\n";
	print OUT "=head1 COPYRIGHT\n\n";
	print OUT "$copyright\n\n";
	print OUT "=head1 HISTORIE\n\n";
	print OUT "Een blanco PerlDoc template om sneller programma's te kunnen schrijven\n\n";
	print OUT "=cut";
}

#------------------------------------------------------------------------------#
# Nice stuff for spec files                                                    #
#------------------------------------------------------------------------------#
if ( lc($lang) eq "spec")
{	my $fl = $cs . $da x ($wd-$ts) . $ce . "\n";
	print OUT "\n\n$cl";
	printline($wd, 0, " Description");
	print OUT "$cl";
	print OUT "%description\n";
	print OUT "Explanation of this RPM\n";
	print OUT $da . $da x $wd . $da;
	print OUT "\n\n\n";

	print OUT "$cl";
	printline($wd, 0, " Prepare");
	print OUT "$cl";
	print OUT "%prep\n";
	print OUT "%setup -q\n";
	print OUT "#%patch -p1\n";
	print OUT "#%configure\n";
	print OUT "\n\n";

	print OUT "$cl";
	printline($wd, 0, " Build");
	print OUT "$cl";
	print OUT "%build\n";
	print OUT "#%{__make}\n";
	print OUT "\n\n";

	print OUT "$cl";
	printline($wd, 0, " Install");
	print OUT "$cl";
	print OUT "%install\n";
	print OUT "[ \"%{_buildroot}\" != \"/\" ] && rm -rf %{_buildroot}/%{ProjectDir}\n";
	print OUT "#%{__make} DESTDIR=%{_buildroot} install\n";
	print OUT "\n\n";

	print OUT "$cl";
	printline($wd, 0, " Pre install script");
	print OUT "$cl";
	print OUT "%pre\n";
	print OUT "\n\n";

	print OUT "$cl";
	printline($wd, 0, " Post install script");
	print OUT "$cl";
	print OUT "%post\n";
	print OUT "\n\n";

	print OUT "$cl";
	printline($wd, 0, " Pre uninstall script");
	print OUT "$cl";
	print OUT "%preun\n";
	print OUT "\n\n";

	print OUT "$cl";
	printline($wd, 0, " Post uninstall script");
	print OUT "$cl";
	print OUT "%postun\n";
	print OUT "\n\n";

	print OUT "$cl";
	printline($wd, 0, " Clean up after the build");
	print OUT "$cl";
	print OUT "%clean\n";
	print OUT "[ \"%{_buildroot}\" != \"/\" ] && rm -rf %{_buildroot}\n";
	print OUT "\n\n";

	print OUT "$cl";
	printline($wd, 0, " File list");
	print OUT "$cl";
	print OUT "%files\n";
	print OUT "%defattr(-,root,root,-)\n";
	print OUT "%config %dir %{_sysconfdir}/%{name}\n";
	print OUT "\n\n";

	my $chl = strftime("%a %b %e %Y", localtime);
	print OUT "$cl";
	printline($wd, 0, " Changelog");
	print OUT "$cl";
	print OUT "%changelog\n";
	print OUT "* $chl $author{name} <$author{mail}>\n";
	print OUT "- Initial version for $author{firm}\n";
	print OUT "\n\n";
}

#------------------------------------------------------------------------------#
# Print some extra empty lines                                                 #
#------------------------------------------------------------------------------#
print OUT "\n\n\n\n";

#------------------------------------------------------------------------------#
# Extra lines for C header files                                               #
#------------------------------------------------------------------------------#
if ($headerfile == 1)
{	print OUT "\n\n\n#endif" . " " x ($wd - 36);
	printline(30, 0, " $hname");
}

#------------------------------------------------------------------------------#
# Print the php conclusion part                                                #
#------------------------------------------------------------------------------#
print OUT "?>" if ($lang eq 'php');

#------------------------------------------------------------------------------#
# Print the header copyright                                                   #
#------------------------------------------------------------------------------#
print OUT "\n";
print OUT $cl;
printline($wd, 0, " $headline", $me);
print OUT $cl;

#------------------------------------------------------------------------------#
# If it was an output file, set the rights                                     #
#------------------------------------------------------------------------------#
if ($fileopen)
{	close OUT;
	chmod 0755, $name if ($lang eq 'sh');
	chmod 0755, $name if ($lang eq 'bash');
	chmod 0755, $name if ($lang eq 'ksh');
	chmod 0755, $name if ($lang eq 'nagios');
	chmod 0755, $name if ($lang eq 'perl');
	chmod 0755, $name if ($lang eq 'rexx');
}

#------------------------------------------------------------------------------#
# That's all, folks                                                            #
#------------------------------------------------------------------------------#
exit (0);
