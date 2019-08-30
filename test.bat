@echo off

set RECPOST="%~dp0\RecPost.pl"

set FILEPATH="D:\Videos\テレビ\金曜ドラマ「凪のお暇」（なぎのおいとま） 第０７話.ts"
set ADDKEY="凪のお暇"
set GENRE="ドラマ"
call :SubRoutine

set FILEPATH="D:\Videos\テレビ\とある科学の一方通行 #07.ts"
set ADDKEY="とある科学の一方通行"
set GENRE="アニメ"
call :SubRoutine

set FILEPATH="D:\Videos\テレビ\火曜ドラマ「Ｈｅａｖｅｎ？～ご苦楽レストラン～」♯７　常連客の知られざる秘密.ts"
set ADDKEY="Heaven?~ご苦楽レストラン~"
set GENRE="ドラマ"
call :SubRoutine

set FILEPATH="D:\Videos\テレビ\#17 夏休みのつづり.ts"
set ADDKEY="とある魔術の禁書目録Ⅲ"
set GENRE="アニメ"
call :SubRoutine

set FILEPATH="D:\Video\ハケン占い師アタル ＃３.ts"
set ADDKEY="ハケン占い師アタル"
set GENRE="ドラマ"
call :SubRoutine

set FILEPATH="D:\Video\火曜ドラマ「初めて恋をした日に読む話」 第３話【届け！俺のキモチ】.ts"
set ADDKEY="初めて恋をした日に読む話"
set GENRE="ドラマ"
call :SubRoutine

set FILEPATH="D:\Video\名車再生！クラシックカー・ディーラーズ：新コンビ舞台裏(二).ts"
set ADDKEY="名車再生"
call :SubRoutine

set FILEPATH="D:\Videos\テレビ\３年Ａ組　－今から皆さんは、人質です－#04事件は核心へー。必見の第4話.ts"
set ADDKEY="3年A組 -今から皆さんは、人質です-"
set GENRE="ドラマ"
call :SubRoutine

set FILEPATH="D:\Video\ブラタモリ「＃１２４　福井」.ts"
set ADDKEY="ブラタモリ"
set GENRE="教養"
call :SubRoutine

set FILEPATH="D:\Video\ピアノの森（１４）「懸ける想い」.ts"
set ADDKEY="ピアノの森"
set GENRE="アニメ"
call :SubRoutine

set FILEPATH="D:\Video\家売るオンナの逆襲#05 偽装美女&野獣カップルに起死回生の家爆売りGO!.ts"
set ADDKEY="家売るオンナの逆襲"
set GENRE="ドラマ"
call :SubRoutine

set FILEPATH="D:\Video\ゲームセンターCX #258 やっぱり延長…「ロックマンX2」.ts"
set ADDKEY="ゲームセンターCX"
set GENRE="趣味"
call :SubRoutine

set FILEPATH="D:\Video\美の巨人たち 吉村芳生『新聞と自画像』超絶リアルな新聞…え！これ描いたもの？.ts"
set ADDKEY="美の巨人たち"
set GENRE="教養"
call :SubRoutine

set FILEPATH="D:\Video\コズミック フロント☆ＮＥＸＴ▽酸素誕生に迫れ！南極 氷の下のタイムカプセル.ts"
set ADDKEY="コズミックフロント"
set GENRE="教養"
call :SubRoutine

exit /b

rem ===============================================================================

:SubRoutine

echo ●シリーズ
perl %RECPOST% -f %FILEPATH% -a %ADDKEY% -g %GENRE% -s --debug

echo ●シリーズ_副題
perl %RECPOST% -f %FILEPATH% -a %ADDKEY% -g %GENRE% -s -t --debug

echo ●シリーズ_連番＋副題
perl %RECPOST% -f %FILEPATH% -a %ADDKEY% -g %GENRE% -s -t -r --debug

set /p stdin="type any key to continue>"
exit /b