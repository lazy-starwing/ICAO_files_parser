#!/usr/bin/perl -w

use File::Find;

%files = (
	$home_dir => "~/ftp_mirror";
	$ftp_dir => "/mnt/ftp";
)

find \&copier, $files{$ftp_dir};
#find ({wanted => \&copier, no_chdir => 1}, $ftp_dir);

sub copier {
	# ѕроверить, что им€ файла совпадает с шаблоном. ≈сли да,
	if $_ =~ /(?:[1-2]\d{3}[0-1]\d[0-3]\d\.[0-2]\d[0-6]\d[0-6]\d\.)([a-z]{4})\.20(1|2)\.\w+\.(lccs.xz|lkks)/ {
		# ѕолучаем список каталогов.
		my @dirs = shift split "/", $File::Find:dir;
		my $inbox_dir = "$files{$home_dir}/";
		# проверить, что локально есть каталог верхнего уровн€, затем второго и т.д.
		foreach my $dir (@dirs){
			$inbox_dir = $inbox_dir . $dir . "/";
			# ≈сли каталога нет, создать его и продолжить провер€ть наличие каталогов на FTP
			opendir my LOCAL_DIR, $inbox_dir || mkdir $inbox_dir 0777;
		}
		# «атем создать файл с таким же именем локально.
		`touch $inbox_dir$_`;
	}
}