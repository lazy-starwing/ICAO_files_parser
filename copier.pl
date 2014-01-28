#!/usr/bin/perl

use 5.010;
use File::Find;
use File::Path qw(make_path);

$ftp_dir = "/mnt/ftp/";
$home_dir = "/root/ftp_mirror/";

find ( \&copier, $ftp_dir );

sub copier {
	$inbox_dir = "$home_dir";

	# Проверить, что имя файла совпадает с шаблоном. Если да,
	if ( /.*+/ ) {
		# Получаем список каталогов.
		@dirs = split (/\//, $File::Find::dir);
		# Количество сдвигов можно увеличить, чтобы не копировать лишние папки.
		# Плюс 1 сдвиг нужен всегда для первого пустого значения в списке.
		shift @dirs;

		# Создаем переменную с каталогом-целью.
		foreach my $dir (@dirs){
			$inbox_dir = $inbox_dir . $dir . "/";
		}

		# Если каталога нет, создать его и продолжить проверять наличие каталогов на FTP
		if ( -d $File::Find::name ) {
			$inbox_dir = $home_dir . $File::Find::name;
			unless ( -d $inbox_dir ) {
				make_path $inbox_dir || die "Scum $inbox_dir: $!\n" ;
			}
		} else {
		# Затем создать файл с таким же именем локально.
		say $_;
		open NEWF, ">>", ($inbox_dir . $_);
		}
	}
}
