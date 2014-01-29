#!/usr/bin/perl

use 5.010;
use File::Find;
use File::Copy;
use File::Path qw(make_path);

# корневая папка FTP.
$ftp_root = "/var/ftp";
# $logfile - имя файла, в который ведется логирование.
$logfile = "/var/log/sorter.log";
# права на каталоги на FTP-сервере.
$permissions = "0755";

# Открываем лог.
open LOGFILE, ">>", $logfile;

finddepth ( \&dig, $ftp_root );

sub dig {
	if ( /(?:20)?([0-9][0-9][0-1][0-9][0-3][0-9]\.[0-2][0-9][0-6][0-9][0-6][0-9]\.(?:([A-Z]{4}|CCC)\.(20)?(1|2)\.\w+\.|\w+\.\2.(20)?(1|2))\.(?:lccs\.xz|lkks|tar\.gz$)/ ) {
		my $target_dir = "$ftp_root/$2/" . 20 . "$1" . "/";
		if ( $File::Find::dir -eq $ftp_root ) {
			say LOGFILE "File $_ with ICAO $2 was send to root ftp directory" ;
		} elsif ( $File::Find::dir -eq $target_dir) {
			return;
		}
		unless ( -d $target_dir ) {
			make_path ( $target_dir );
			say LOGFILE "Create dir $target_dir for data file $_" ;
		}
		move ("$File::Find::name", "$target_dir");
	} else {
		if ( -f $_ && $File::Find:dir -eq "$ftp_root/m\([A-Z]{4}|CCC)\/.*" && $_ -neq ".*iploading$" ) {
			move ($File::Find::name, "$ftp_root/$_" . "__from_" . split (/\//, $File::Find::dir));
			say LOGFILE "Файл $File::Find::name перенесен в корень FTP" ;
		}
		if ( -d $_ && $Find::Find::dir =~ m/$ftp_root\/([A-Z]{4}|CCC)\/.*/ ) {
			# Проверить, что папка пуста
				# Удалить папку
		}
	}

close LOGFILE;
