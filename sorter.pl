#!/usr/bin/perl

use 5.010;
use File::Find;
use File::Copy;
use File::Path qw(make_path);

# корневая папка FTP.
$ftp_root = "/home/yar/ftp/mnt/ftp";
# $logfile - имя файла, в который ведется логирование.
$logfile = "/var/log/sorter.log";

# Открываем лог.
open LOGFILE, ">>", $logfile;

finddepth ( \&dig, $ftp_root );

close LOGFILE;

sub dig {
	if ( /(?:20)?([0-9][0-9])[0-1][0-9][0-3][0-9]\.[0-2][0-9][0-6][0-9][0-6][0-9]\.(?:\w+\.)?([A-Z]{4}|CCC)\.(?:20)?(?:1|2)\.(?:\w+\.)?(?:(?:lccs\.xz$)|(?:lkks$)|(?:tar\.gz$))/ ) {
		my $target_dir = "$ftp_root/$2/" . 20 . "$1" . "/";
		say LOGFILE "\nFor dir $File::Find::dir and target $target_dir"
		if ( $File::Find::dir eq $ftp_root ) {
			say LOGFILE "File $Find::File::name with ICAO $2 and year $1 was send to root ftp directory" ;
		} elsif ( $File::Find::dir eq $target_dir) {
			return;
		}
		unless ( -d $target_dir ) {
			make_path ( $target_dir );
			say LOGFILE "Create dir $target_dir for data file $File::Find::name" ;
		}
		move ("$File::Find::name", "$target_dir");
		say LOGFILE "Файл $File::Find::name перемещен в $target_dir";
	} else {
		if ( -f $_ && $File::Find::dir eq <$ftp_root/([A-Z]{4}|CCC)/*> && $_ ne <*.uploading> ) {
			move ($File::Find::name, "$ftp_root/$_" . "__from_" . split (/\//, $File::Find::dir));
			say LOGFILE "Файл $File::Find::name перенесен в корень FTP" ;
		}
		if ( -d $_ && $Find::Find::dir =~ m/^$ftp_root\/([A-Z]{4}|CCC)\/.*/ ) {
			rmdir;
			say LOGFILE "Каталог $File::Find::name удален";
		}
	}
}
