#!/usr/bin/perl

use 5.010;
use File::Find;

# корневая папка FTP.
$ftp_root = "/srv/ftp";
# $logfile - имя файла, в который ведется логирование.
$logfile = "/var/log/ftp-scripts/icao_diff.log";

(,,, $dd, $mm, $yy,,,) = localtime(time);
$yy += 1900;

# Открываем лог.
open LOGFILE, ">>", $logfile;

finddepth ( \&check_icao, $ftp_root );

say LOGFILE "ICAO diff done!";
close LOGFILE;

exit;

sub check_icao {
# Если файл с данными из региона
if ( /(?:20)?(?:[0-9][0-9])(?:[0-1][0-9])(?:[0-3][0-9])\.[0-2][0-9][0-6][0-9][0-6][0-9]\.(?:\w+\.)?([A-Z]{4}|CCC)\.\d+\.(?:\w+\.)?(?:(?:lccs\.xz$)|(?:lkks$)|(?:tar\.xz$))/ ) {
        my @path = split( /\//, $File::Find::dir);
        if ($File::Find::dir ne $ftp_root) {
        if ( $path[3] ne $1 ) {
               say LOGFILE "$yy$mm$dd:  File $_ lay in $File::Find::dir";
       }
       }
}
}
