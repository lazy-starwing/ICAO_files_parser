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

say LOGFILE "Work done!";

close LOGFILE;

sub dig {
	# Если файл с данными из региона
	if ( /(?:20)?([0-9][0-9])([0-1][0-9])([0-3][0-9])\.[0-2][0-9][0-6][0-9][0-6][0-9]\.(?:\w+\.)?([A-Z]{4}|CCC)\.(?:20)?(?:1|2)\.(?:\w+\.)?(?:(?:lccs\.xz$)|(?:lkks$)|(?:tar\.xz$))/ ) {
		my $target_dir = "$ftp_root/$3/" . 20 . "$1" . "/" . "$2" . "/" "$3" . "/";
		# Если файл с данными лежит в корне ftp
		if ( $File::Find::dir eq $ftp_root ) {
			say LOGFILE "File $Find::File::name with ICAO $4, year $1, month $2 and day $3 was send to root ftp directory" ;
		# Проверка, что файл уже в нужном каталоге
		} elsif ( $File::Find::dir . "/" eq $target_dir) {
			return;
		}
		# Если нет нужного каталога
		unless ( -d $target_dir ) {
			# Создаем его
			make_path ( $target_dir );
			say LOGFILE "Create dir $target_dir for data file $File::Find::name" ;
		}
		# Переместить в нужный каталог.
		move ("$File::Find::name", "$target_dir");
		say LOGFILE "Файл $File::Find::name перемещен в $target_dir";
	# Заливающиеся файлы не трогать!
	} elsif ( $_ eq <*.uploading> ) {
		# Извлечь время модификации файла
		# Проверить текущую дату
		# Сравнить даты, если разница больше месяца
		# Проверить lsof, не открыт ли файл proftpd
		# Если нет, переносим файл в папку UPL_TRASH на хранение
		return;
	} else {
		# Несовпадающие файлы из папок ИКАО/год в корень перекинуть
		if ( -f $_ && $File::Find::dir eq <$ftp_root/([A-Z]{4}|CCC)/*> ) {
			move ($File::Find::name, "$ftp_root/$_" . "__from_" . split (/\//, $File::Find::dir));
			say LOGFILE "Файл $File::Find::name перенесен в корень FTP" ;
		}
		# Удаляем пустые папки
		if ( -d $_ && $Find::Find::dir eq <$ftp_root\([A-Z]{4}|CCC)/*> ) {
			rmdir;
			say LOGFILE "Каталог $File::Find::name удален";
		}
	}
}
