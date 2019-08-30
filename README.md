# これは何？
EDCBで録画後に実行する Perlスクリプト

# 機能
* ジャンル（アニメ,スポーツ,ドラマ,バラエティ,映画,音楽,教養,趣味）でサブフォルダ分け

    * C:\Video\アニメ\
    * C:\Video\ドラマ\

* 検索キーワードでさらにサブフォルダ分け

    * C:\Video\アニメ\サザエさん
    * C:\Video\ドラマ\相棒\

* ファイル名をいい感じに変更

    火曜ドラマ「Ｈｅａｖｅｎ？～ご苦楽レストラン～」♯７　常連客の知られざる秘密.ts  
    　↓  
    #07 常連客の知られざる秘密.ts

    火曜ドラマ「初めて恋をした日に読む話」第３話【届け！俺のキモチ】.ts  
    　↓  
    #03 届け！俺のキモチ.ts

    ３年Ａ組　－今から皆さんは、人質です－#04事件は核心へー。必見の第4話.ts  
    　↓  
    #04 事件は核心へー。必見の第4話.ts

    ブラタモリ「＃１２４　福井」.ts  
    　↓  
    #124 福井.ts

    ピアノの森（１４）「懸ける想い」.ts  
    　↓  
    #14 懸ける想い.ts

    ゲームセンターCX #258 やっぱり延長…「ロックマンX2」.ts  
    　↓  
    #258 ロックマンX2.ts

    コズミック フロント☆ＮＥＸＴ▽酸素誕生に迫れ！南極 氷の下のタイムカプセル.ts  
    　↓  
    酸素誕生に迫れ！南極 氷の下のタイムカプセル.ts

* EDCB からこのスクリプトを呼び出すためのバッチを自動生成
 
# 動作確認環境
* Windows 7 Pro, Windows 10 Pro
* ActivePerl 5.26.3, Strawberry Perl 5.30.0.1
* EpgTimer(xtne6f版)

# インストール
* Perl をインストール
* EDCB フォルダの下に Bat というサブフォルダを掘って RecPost.pl を奥く
* RecPost.pl 内の以下のパスを RecPost.pl を置いたパスに合わせて変更

    	my $batch = 'C:\PT2\EDCB\Bat\RecPost.pl';

* RecPost.pl をダブルクリックして実行（EDCBからこのスクリプトを呼び出すバッチが生成される）
* EDCB(EpgTimer)を再起動

# 使い方
録画予約時に実行したいバッチファイルを選択するだけ
