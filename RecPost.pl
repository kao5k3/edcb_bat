
use Encode 'encode', 'decode';
use File::Copy 'move';
use File::Path;
use File::Basename 'basename', 'dirname';
use Getopt::Long;

use utf8;
use strict;
use warnings;

# このスクリプトを配置する場所
my $self_path = 'C:\PT2\EDCB\Bat\RecPost.pl';

# 引数
#
#	-a | --addkey
#				予約録画時のキーワード (ex. "相棒")
#
#	-d | --debug
#				デバッグモード
#
#	-f | --filepath
#				入力ファイルパス (ex. "E:\Temp\Video\サンプル.ts")
#
#	-g | --genre
#				番組のジャンル (ex. "ドラマ")
#				入力ファイルがあるディレクトリの下に {ジャンル} フォルダを
#				作成し、その下にファイルを移動する。
#
#	-r | --renban
#				ファイル名を連番にする
#				-t と併用可（連番＋タイトルになる）
#
#	-s | --series
#				genre フォルダの下に、更に addkey フォルダを作成する
#				有効であった場合は "ドラマ\相棒\" や "アニメ\サザエさん\"
#				といったフォルダを作成し、その下にファイルを移動する
#
#	-t | --title
#				ファイル名をいい感じのタイトル名に変更する
#
my %opts = ();
GetOptions(\%opts, 'addkey=s', 'debug', 'filepath=s', 'genre=s', 'renban', 'series', 'title');
	
# 必須パラメータがない ＝ バッチファイル生成
unless ($opts{filepath}) {
	&generate_batch_files($self_path);
	exit;
}

# 入力パラメータの文字コードを Shift-JIS から内部コードに変換
$opts{filepath} = decode('CP932', $opts{filepath});
$opts{addkey} = decode('CP932', $opts{addkey});
$opts{genre} = decode('CP932', $opts{genre});

# 録画ファイル名
my $infile_name = basename($opts{filepath});
#&debug("infile_name\n " . $infile_name);
exit unless ($infile_name);

# addkey はフォルダやファイル名に使用する場合があるので安全な全角にしておく
$opts{addkey} = &safe_string($opts{addkey});
#&debug("addkey\n " . $opts{addkey});

# 録画ファイルの親ディレクトリパス
my $parent_dir = dirname($opts{filepath});
#&debug("parent_dir\n " . $parent_dir);
exit unless ($parent_dir);

# 保存先ディレクトリパス 
my $outdir_path = &get_outdir_path($parent_dir, $opts{genre}, $opts{addkey}, $opts{series});
#&debug("outdir_path\n " . $outdir_path);
exit unless ($outdir_path);

# 保存ファイル名
my $outfile_name = &get_outfile_name($infile_name, $opts{addkey}, $outdir_path, $opts{title}, $opts{renban});
#&debug("outfile_name\n " . $outfile_name);
exit unless ($outfile_name);

# 保存先へ移動
&debug(" " . $outdir_path . "\\" . $outfile_name);
&move_file($opts{filepath}, $outdir_path, $outfile_name);

# ジャンルフォルダの最終更新時刻を更新
&update_folder_utime($parent_dir, $opts{genre}, $opts{series});

exit 0;
#####################################################################

# 保存先ディレクトリパスを決定する
sub get_outdir_path {
	my $path_to_store = shift;
	my $genre = shift;
	my $addkey = shift;
	my $series = shift;
	
	# ディレクトリパスにジャンル名を追加
	$path_to_store .= "\\" . $genre if ($genre);
	# シリーズフラグがあれば更に addkey を追加
	$path_to_store .= "\\" . $addkey if ($series && $addkey);
	
	return $path_to_store;
}

# 保存ファイル名を決定する
sub get_outfile_name {
	my $infile_name = shift;
	my $addkey = shift;
	my $outdir_path = shift;
	my $title_mode = shift;
	my $renban_mode = shift;
	
	# ディスカバリーによくある "(二)" が邪魔なので消去
	$infile_name =~ s/\(二\).ts$/.ts/;
	
	# ディスカバリーで稀にある "(日)" も邪魔なので消去
	$infile_name =~ s/\(日\).ts$/.ts/;
	
	# ファイル名からタイトルを抽出
	my $title = "";
	if ($title_mode) {
		$title = &extract_title($infile_name, $addkey);
	}
	
	# ファイル名から連番を抽出
	my $renban = 0;
	if ($renban_mode) {
		$renban = &extract_episode_number($infile_name, $outdir_path);
	}
	
	# タイトルと連番が揃っている時
	if ($title && $renban) {
		$title = &delete_episode_number($title);
		$title = " " . $title if ($title);
		return sprintf("#%02d%s.ts", $renban, $title);
	}
	# タイトルだけの時
	if ($title) {
		my $tmp = &delete_episode_number($title);
		$title = $tmp if ($tmp);
		return $title . '.ts';
	}
	# 連番だけの時
	if ($renban) {
		return sprintf("#%02d.ts", $renban);
	}
	# その他: 変更しない
	return $infile_name;
}
	
# ファイルを保存先に移動する
sub move_file {
	my $infile_path = shift; return unless ($infile_path);
	my $outdir_path = shift; return unless ($outdir_path);
	my $outfile_name = shift; return unless ($outfile_name);
	my $outfile_path = $outdir_path . "\\" . $outfile_name;
	
	my $bakdir_path = $outdir_path . "\\前回";
	my $bakfile_path = $bakdir_path . "\\" . $outfile_name;
	my $bakbakdir_path = $outdir_path . "\\前々回";
	my $bakbakfile_path = $bakbakdir_path . "\\" . $outfile_name;
	
	$infile_path = encode('CP932', $infile_path);
	$outdir_path = encode('CP932', $outdir_path);
	$outfile_path = encode('CP932', $outfile_path);
	
	$bakdir_path = encode('CP932', $bakdir_path);
	$bakfile_path = encode('CP932', $bakfile_path);
	$bakbakdir_path = encode('CP932', $bakbakdir_path);
	$bakbakfile_path = encode('CP932', $bakbakfile_path);
	
	# 入力ファイルが存在するか確認
	return unless (-f $infile_path);
	
	# 入力と出力が同じなら何もしない
	return if ($infile_path eq $outfile_path);
	
	# 出力先ディレクトリを作成
	mkpath($outdir_path) unless (-e $outdir_path);
	
	# 上書きになる場合はバックアップを取っておく
	if (-f $outfile_path) {
		# バックアップディレクトリを作成
		mkpath($bakdir_path) unless (-e $bakdir_path);
		# バックアップ
		if (-f $bakfile_path) {
			mkpath($bakbakdir_path) unless (-e $bakbakdir_path);
			move($bakfile_path, $bakbakfile_path);
		}
		move($outfile_path, $bakfile_path);
	}
	
	# 移動
	move($infile_path, $outfile_path);
}

# ジャンルフォルダの最終更新時刻を更新
sub update_folder_utime {
	my $parent_dir = shift; return unless ($parent_dir);
	my $genre = shift; return unless ($genre);
	my $series = shift; return unless ($series);
	
	# ダミーファイルを作成→削除してフォルダの utime を更新する
	my $dummyfile_path = $parent_dir . "\\" . $genre . "\\" . '.dummy';
	$dummyfile_path = encode('CP932', $dummyfile_path);
	unlink $dummyfile_path if (-e $dummyfile_path);
	if (open(my $DUMMY, "> $dummyfile_path")) {
		close($DUMMY);
		unlink($dummyfile_path);
	}
}

# 半角の記号をファイルやフォルダ名に使える全角に変更
sub safe_string {
	my %replacechars = (
		'('  => '（',
		')'  => '）',
		':'  => '：',
		';'  => '；',
		'/'  => '／',
		'\\' => '￥', 
		'|'  => '｜',
		','  => '，',
		'*'  => '＊',
		'-'  => '－',
		'~'  => '～',
		'?'  => '？',
		'!'  => '！',
		'&'  => '＆',
		'"'  => '”',
		'<'  => '＜',
		'>'  => '＞'
	);
	my $arg = shift;
	while(my ($b, $a) = each(%replacechars)) {
		$arg =~ s/\Q$b\E/$a/g;
	}
	return $arg;
}

# 全角（英数＋＃＋スペース）を半角に変更(ＡＢＣ　＃１２３ → ABC #123)
sub ztoh {
	my %replacechars = (
		'Ａ'  => 'A',
		'Ｂ'  => 'B',
		'Ｃ'  => 'C',
		'Ｄ'  => 'D',
		'Ｅ'  => 'E',
		'Ｆ'  => 'F',
		'Ｇ'  => 'G',
		'Ｈ'  => 'H',
		'Ｉ'  => 'I',
		'Ｊ'  => 'J',
		'Ｋ'  => 'K',
		'Ｌ'  => 'L',
		'Ｍ'  => 'M',
		'Ｎ'  => 'N',
		'Ｏ'  => 'O',
		'Ｐ'  => 'P',
		'Ｑ'  => 'Q',
		'Ｒ'  => 'R',
		'Ｓ'  => 'S',
		'Ｔ'  => 'T',
		'Ｕ'  => 'U',
		'Ｖ'  => 'V',
		'Ｗ'  => 'W',
		'Ｘ'  => 'X',
		'Ｙ'  => 'Y',
		'Ｚ'  => 'Z',
		'ａ'  => 'a',
		'ｂ'  => 'b',
		'ｃ'  => 'c',
		'ｄ'  => 'd',
		'ｅ'  => 'e',
		'ｆ'  => 'f',
		'ｇ'  => 'g',
		'ｈ'  => 'h',
		'ｉ'  => 'i',
		'ｊ'  => 'j',
		'ｋ'  => 'k',
		'ｌ'  => 'l',
		'ｍ'  => 'm',
		'ｎ'  => 'n',
		'ｏ'  => 'o',
		'ｐ'  => 'p',
		'ｑ'  => 'q',
		'ｒ'  => 'r',
		'ｓ'  => 's',
		'ｔ'  => 't',
		'ｕ'  => 'u',
		'ｖ'  => 'v',
		'ｗ'  => 'w',
		'ｘ'  => 'x',
		'ｙ'  => 'y',
		'ｚ'  => 'z',
		'＃'  => '#',
		'♯'  => '#',
		'０'  => '0',
		'１'  => '1',
		'２'  => '2',
		'３'  => '3',
		'４'  => '4',
		'５'  => '5',
		'６'  => '6',
		'７'  => '7',
		'８'  => '8',
		'９'  => '9',
		'　'  => ' '
	);
	my $arg = shift;
	while(my ($b, $a) = each(%replacechars)) {
		$arg =~ s/\Q$b\E/$a/g;
	}
	$arg =~ s/\s+/ /g;
	return $arg;
}

# ファイル名から副題っぽい部分を抽出する
sub extract_title {
	my $title = shift;
	my $addkey = shift;
	
	# ファイル名から拡張子を取る
	$title =~ s/\.ts$//;
	
	# ディスカバリーによくある "(二)" が邪魔なので消去
	$title =~ s/\(二\)$//;
	
	# 半角と全角が混ざっていると面倒なので半角にする
	$title = &ztoh($title);
	$addkey = &ztoh($addkey);
	
	# 記号はファイル名に使える全角にする
	$title = &safe_string($title);
	$addkey = &safe_string($addkey);
	
	# addkey 部分を誤検出しないよう予め排除
	if ($title =~ /$addkey[」】！？～＞：　 \s]*(.+)/) {
		$title = $1;
	}
	
	# 括弧があればその中身を副題として抜き出す
	if ($title =~ /[「【](.*)/) {
		my $tmp = $1;
		# 括弧の後ろにさらに括弧があるケースを考慮
		if ($tmp =~ /[「【](.*)/) {
			$tmp = $1;
		}
		# 括弧閉じの部分まで抜き出す
		if ($tmp =~ /([^」】]+)/) {
			return $1;
		}
	}
	
	#  ：（コロン）／（スラッシュ） ▽ がある場合、その後ろを副題として抜き出す
	if ($title =~ /[：／▽](.*)/) {
		return $1;
	}
	
	# 連番(#○○)以後を副題として抜き出す
	if ($title =~ /(\#\d+[　\s]*.*)/) {
		return $1;
	}
	
	# 話数(第○回 とか 第○話)以後を副題として抜き出す
	if ($title =~ /(第\d+[回話][　\s]*.*)/) {
		return $1;
	}
	
	return $title;
}

# 連番の値を決める
sub extract_episode_number {
	my $infile_name = shift;	
	my $outdir_path = shift;
	
	# 全角と半角が混ざってると面倒なので半角にする
	$infile_name = &ztoh($infile_name);

	# ファイル名に連番(#○○)がついていないか調査する
	if ($infile_name =~ /\#[0]*(\d+)/) {
		return $1 + 0;
	}
	# 第○回 とか 第○話 のパターンを考慮
	if ($infile_name =~ /第[0]*(\d+)[回話]/) {
		return $1 + 0;
	}
	# 朝ドラによくある （１２３） みたいなのを考慮
	if ($infile_name =~ /（(\d+)）/) {
		return $1 + 0;
	}
	# 出力先フォルダにある最大値を検査
	my $renban = 1;
	chdir(encode('CP932', $outdir_path));
	foreach my $file (glob "*\.ts *\.mp4") {
		$file = decode('CP932', $file);
		# 保存先にあるファイルに付いている連番値を抽出
		next unless $file =~ /\#(\d+)/;
		# 文字列から数値への変換も兼ねて抽出した値+1を算出
		my $tmp = $1 + 1; 
		# 最大値なら候補として記憶しておく
		$renban = $tmp if ($renban < $tmp);
	}
	return $renban;
}

# タイトル先頭についている連番や話数を消す
sub delete_episode_number {
	my $title = shift;
	$title =~ s/^[＃\#][０１２３４５６７８９\d]+[　\s]*//;
	$title =~ s/^第[０１２３４５６７８９\d]+[回話][　\s]*//;
	$title =~ s/^（[０１２３４５６７８９\d]+）[　\s]*//;
	return $title;
}	

# バッチファイルを生成
sub generate_batch_files {
	my $self = shift;
	my @genre = ('アニメ','スポーツ','ドラマ','バラエティ','ワイドショー','映画','音楽','教養','趣味');
	my %series = ('アニメ' => 1, 'ドラマ' => 1, 'バラエティ' => 1, '音楽' => 1, '教養' => 1, '趣味' => 1);
	my %title =('スポーツ' => 1, 'バラエティ' => 1, '音楽' => 1, '教養' => 1, '趣味' => 1);
	my %seq = ();
	my %seq_and_title = ('アニメ' => 1, 'ドラマ' => 1, '教養' => 1, '趣味' => 1);
	
	&output_batch_file('デフォルト.bat', $self, "", 0, 0, 0);
	foreach my $target (@genre) {
		my $filename = $target . '.bat';
		&output_batch_file($filename, $self, $target, 0, 0, 0);
		if ($series{$target}) {
			$filename = $target . '_シリーズ.bat';
			&output_batch_file($filename, $self, $target, 1, 0, 0);
		}
		if ($title{$target}) {
			$filename = $target . '_シリーズ_副題.bat';
			&output_batch_file($filename, $self, $target, 1, 1, 0);
		}
		if ($seq{$target}) {
			$filename = $target . '_シリーズ_連番.bat';
			&output_batch_file($filename, $self, $target, 1, 0, 1);
		}
		if ($seq_and_title{$target}) {
			$filename = $target . '_シリーズ_連番＋副題.bat';
			&output_batch_file($filename, $self, $target, 1, 1, 1);
		}
	}
}

# バッチファイルを出力
sub output_batch_file {
	my $filename = shift;
	my $self = shift;
	my $genre = shift;
	my $series = shift;
	my $title = shift;
	my $renban = shift;
	
	$filename = encode('CP932', $filename);
	$self = encode('CP932', $self);
	$genre = encode('CP932', $genre);
	
	open(OUT, "> $filename") or die "$!";
	print OUT '@echo off', "\n";
	print OUT "\n";
	print OUT encode('CP932', 'rem -f : 入力ファイルパス (ex. "D:\Video\入力ファイル.ts")'), "\n";
	print OUT encode('CP932', 'rem -g : ジャンル＝出力先フォルダ名 (ex. "ドラマ")'), "\n";
	print OUT encode('CP932', 'rem -a : 検索キーワード (ex. "相棒")'), "\n";
	print OUT encode('CP932', 'rem -s : 検索キーワードでサブフォルダ作成'), "\n";
	print OUT encode('CP932', 'rem -t : ファイル名をタイトルにする'), "\n";
	print OUT encode('CP932', 'rem -r : ファイル名を連番にする（-t と併用すると連番＋タイトルになる）'), "\n";
	print OUT "\n";
	print OUT $self, ' -f "$FilePath$" -g "', $genre, '" -a "$AddKey$"';
	print OUT ' -s' if ($series);
	print OUT ' -t' if ($title);
	print OUT ' -r' if ($renban);
	print OUT "\n";
	close(OUT);
}

# デバッグ出力
sub debug {
	return unless ($opts{debug});
	my $arg = shift;
	return unless ($arg);
	print  encode('CP932', $arg), "\n";
}

# EOF
