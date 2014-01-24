#!/usr/bin/perl

use File::Find;
use File::Path;

$ftp_dir = "/var/log";
$home_dir = "/root/ftp_mirror/";

find ( \&copier, $ftp_dir );

sub copier {
	$inbox_dir = "$home_dir";

	# Проверить, что имя файла совпадает с шаблоном. Если да,
	if ( /[1-2]\d{3}[0-1]\d[0-3]\d\.[0-2]\d[0-6]\d[0-6]\d\.[a-z]{4})\.20(1|2)\.\w+\.(lccs.xz|lkks)/ ) {
		# Получаем список каталогов.
		@dirs = split (/\//, $File::Find::dir);
		shift @dirs;

		# Создаем переменную с каталогом-целью.
		foreach my $dir (@dirs){
			$inbox_dir = $inbox_dir . $dir . "/";
		}

		# Если каталога нет, создать его и продолжить проверять наличие каталогов на FTP
		mkpath $inbox_dir unless ( -d $inbox_dir ) ; 

		# Затем создать файл с таким же именем локально.
		open NEWF, ">>", ("$inbox_dir"."$_");
	}
}
