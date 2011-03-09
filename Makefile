#------------------------------------------------------------------------------#
# vi: set sw=4 ts=4 ai:                            ("set modeline" in ~/.exrc) #
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
#                    V e r s i o n   i n f o r m a t i o n                     #
#------------------------------------------------------------------------------#
# $Id: ba399e1 2010-10-04 14:37:02 +0200 (Ton Kersten)$: #
# $Revision:: 5                                                             $: #
# $Author:: Ton Kersten <tonk@tonkersten.com>                               $: #
# $Date:: 2011-03-09 13:00:03 +0100 (Wed, 09 Mar 2011)                      $: #
# $Hash::                                                                   $: #
#------------------------------------------------------------------------------#
#             E n d   o f   v e r s i o n   i n f o r m a t i o n              #
#------------------------------------------------------------------------------#

install:
	install -p -m 755 header.pl		/home/tonk/bin
	#
	install -p -m 644 header.pl		/data/vhosts/blog/html/files/header
	install -p -m 644 name.info		/data/vhosts/blog/html/files/header
	install -p -m 644 README		/data/vhosts/blog/html/files/header
