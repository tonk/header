#------------------------------------------------------------------------------#
# vi: set sw=4 ts=4 ai:                            ("set modeline" in ~/.exrc) #
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
#                    V e r s i o n   i n f o r m a t i o n                     #
#------------------------------------------------------------------------------#
# $Id: Makefile 6 2011-07-08 13:00:36 tonk $: #
# $Revision:: 6                                                             $: #
# $Author:: Ton Kersten <github@tonkersten.com>                             $: #
# $Date:: 2011-07-08 13:01:54 +0200 (Fri, 08 Jul 2011)                      $: #
# $Hash::                                                                   $: #
#------------------------------------------------------------------------------#
#             E n d   o f   v e r s i o n   i n f o r m a t i o n              #
#------------------------------------------------------------------------------#

install:
	install -p -m 755 header.pl		/home/tonk/bin
	#
	install -p -m 644 header.pl		/home/tonk/tonkersten/files/header
	install -p -m 644 name.info		/home/tonk/tonkersten/files/header
	install -p -m 644 README		/home/tonk/tonkersten/files/header
