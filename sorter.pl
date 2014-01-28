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
	if ( /(?:20)?([0-9][0-9][0-1][0-9][0-3][0-9]\.[0-2][0-9][0-6][0-9][0-6][0-9]\.(?:([A-Z]{4}|CCC)\.(20)?(1|2)\.\w+\.|\w+\.\2.(20)?(1|2))\.(?:lccs\.xz|lkks|tar\.gz)/ ) {
		
}

close LOGFILE;
