--
-- DoNothing.lua
-- Sample Script.
--

--
-- Copyright (C) 2011 Yamaha Corporation
--

--
-- プラグインマニフェスト関数.
--
function manifest()
    myManifest = {
        name          = "Test",
        comment       = "Test",
        author        = "Had2Apps",
        pluginID      = "{D6E12F23-3123-4D10-B10C-561F94D78933}",
        pluginVersion = "1.0.0.0",
        apiVersion    = "3.0.0.1"
    }
    
    return myManifest
end


--
-- 何もしないJobプラグインスクリプト.
--

-- Jobプラグインスクリプトのエントリポイント関数.
function main(processParam, envParam)
    -- 実行時に渡されたパラメータの取得.
    beginPosTick = processParam.beginPosTick  -- 選択範囲の始点時刻.
    endPosTick   = processParam.endPosTick    -- 選択範囲の終点時刻.
    songPosTick  = processParam.songPosTick   -- カレントソングポジション時刻.

    -- 実行時に渡された実行環境パラメータを取得する.
    scriptDir  = envParam.scriptDir   -- スクリプトが配置されているディレクトリパス.
    scriptName = envParam.scriptName  -- スクリプトのファイル名.
    tempDir    = envParam.tempDir     -- Jobプラグインが利用可能な一時ディレクトリパス.

    -- Jobプラグインの処理をここ以下で行います.

    local noteEx     = {}
	local noteExList = {}
	local noteCount

	local control = {}
	local controlList = {}
	local controlNum
	local controlDef
	local setControl = {}

	local i

	local stat

	mes("time: "..tick2Spos(beginPosTick,-1).."～"..tick2Spos(endPosTick,-1).."->"..tick2Spos(songPosTick,-1))
	
	-- パラメータ入力ダイアログのウィンドウタイトルを設定します.
	initDialog("自動調教プラグイン")

	-- ダイアログにフィールドを追加します.
	local field = {}

	addDialogElement("Mode","モード選択","test,ノート一括調整",4)

	-- パラメータ入力ダイアログを表示します.
	if  (getDialogResponse() ~= 1) then
		-- OKボタンが押されなかったら終了します.
		return 1
	end
	
	-- パラメータ入力ダイアログから入力値を取得します.
	local mode
	stat, mode = VSDlgGetStringValue("Mode")
	
	-- 取得したノートイベントを更新します.
	if (mode=="test") then
		--test
	elseif (mode=="ノート一括調整") then
		-- ノートを取得してノートイベント配列へ格納します.
		VSSeekToBeginNote()
		i = 1
		stat, noteEx = VSGetNextNoteEx()
		while (stat == 1) do
			if(beginPosTick<=noteEx.posTick and noteEx.posTick<=endPosTick) then
				noteExList[i] = noteEx
				i = i + 1
			end
			stat, noteEx = VSGetNextNoteEx()
		end

		-- 読み込んだノートの総数.
		noteCount = table.getn(noteExList)
		if (noteCount == 0) then
			mes("ERROR: 読み込んだノートがありません.")
			return 0
		end

		for i = 1, noteCount do
			local updNoteEx = {}
			updNoteEx = noteExList[i]
			
			--updNoteEx.lyric    = "ら"
			--updNoteEx.phonemes = "4 a"
			updNoteEx.bendDepth = 0
			updNoteEx.bendLength = 0
			updNoteEx.risePort = 1
			updNoteEx.fallPort = 0
			--updNoteEx.opening = 127
			--updNoteEx.vibratoLength = 50
			--updNoteEx.vibratoType = 15
			updNoteEx.vibratoType = 0
			if (compareLyrics(updNoteEx.lyric,
				"あ,い,う,え,お")==1) then
				updNoteEx.decay = 85
			end
			if (compareLyrics(updNoteEx.lyric,
				"か,き,く,け,こ,た,ち,つ,て,と,"..
				"きゃ,きゅ,きょ,ちゃ,つぃ,ちゅ,ちぇ,ちょ")==1) then
				updNoteEx.accent = 90
			end
			if (compareLyrics(updNoteEx.lyric,
				"か,き,く,け,こ,さ,し,す,せ,そ,つ,が,ぎ,ぐ,げ,ご,ざ,じ,ず,ぜ,ぞ,"..
				"きゃ,きゅ,きょ,しゃ,すぃ,しゅ,しぇ,しょ,"..
				"ぎゃ,ぎゅ,ぎぇ,ぎょ,じゃ,ずぃ,じゅ,じぇ,じょ")==1) then
				updNoteEx.velocity = updNoteEx.velocity + (128/8)
			end
			if (compareLyrics(updNoteEx.lyric,
				"な,に,ぬ,ね,の,は,ひ,ふ,へ,ほ,ま,み,む,め,も,ら,り,る,れ,ろ,"..
				"ば,び,ぶ,べ,ぼ,ぱ,ぴ,ぷ,ぺ,ぽ,にゃ,にゅ,にぇ,にょ,"..
				"ひゃ,ひゅ,ひぇ,ひょ,ふぁ,ふぃ,ふゅ,ふぇ,ふぉ,みゃ,みゅ,みぇ,みょ,"..
				"りゃ,りゅ,りょ,びゃ,びゅ,びぇ,びょ,ぴゃ,ぴゅ,ぴぇ,ぴょ")==1) then
				updNoteEx.velocity = updNoteEx.velocity - (128/8)
			end
			
			
			stat = VSUpdateNoteEx(updNoteEx);
			if (stat ~= 1) then
				mes("ERROR: 更新エラー発生!!")
				return 1
			end
		end
	end

    -- MusicalパートのplayTimeを更新します.
	local musicalPart = {}
	stat, musicalPart = VSGetMusicalPart()
	stat = VSUpdateMusicalPart(musicalPart)
	if (stat ~= 1) then
		mes("ERROR: MusicalパートのplayTimeを更新できません")
		return 1
	end

    -- 正常終了.
    return 0
end

--ダイアログを新規作成
function initDialog(title)
	VSDlgSetDialogTitle(title)
	return 0
end

--ダイアログ項目を追加
function addDialogElement(name, caption, initialVal, type)
	local field = {}
	field.name       = name
	field.caption    = caption
	field.initialVal = initialVal
	field.type = type
	return VSDlgAddField(field)
end

--ダイアログのレスポンスを取得
function getDialogResponse()
	return VSDlgDoModal()
end

--1秒ごとに変化する通常の乱数を取得
function getRand(min,max)
	math.randomseed(os.time())
	return math.random(min,max)
end

--0～127から疑似乱数を生成。forでseedの数を変えれば1秒経たなくても別の値を得られる。
function pseudoRandom(seed)
	local r = {28,98,26,95,74,72,42,0,120,47,34,93,110,89,62,46,84,116,30,6,9,16,71,21,
	7,40,106,64,82,113,24,117,85,126,49,52,57,124,119,81,32,125,48,104,19,14,35,115,108,
	97,118,86,77,67,107,111,45,92,12,20,63,3,103,76,27,70,100,33,18,87,41,83,11,114,51,
	109,38,69,59,60,44,31,90,127,25,94,13,101,53,15,91,43,99,68,8,123,37,5,79,10,122,2,
	22,78,61,17,36,75,4,58,54,88,65,96,29,50,66,23,112,102,105,56,55,80,73,121,1,39}
	return r[(os.time()+(seed+64))%100]
end


--SingPosをTickに変換
function spos2Tick(sp1,sp2,sp3)
	local a = ((sp1-1)*1920)+((sp2-1)*480)+sp3
	if a==0 then
		return 1
	end
	return a
end

--TickをSingPosに変換 p=0:文字列生成 p=1,2,3:小節,拍,オフセット
function tick2Spos(t,p)
	local sp1 = math.floor((t/1920)+1)
	local sp2 = math.floor(((t%1920)/480)+1)
	local sp3 = math.floor((t%1920)%480)
	if p==1 then
		return sp1
	elseif p==2 then
		return sp2
	elseif p==3 then
		return sp3
	end
	return ""..sp1..":"..sp2..":"..sp3
end

--特定のパラメーターでオーバーした値を範囲内に収める
function clipParam(param,num)
	if param=="PIT" then
		return clipping(num,-8192,8191)
	elseif param=="PBS" then
		return clipping(num,0,24)
	end
	return clip127(num1)
end

--0～127をオーバーした値を範囲内に収める
function clip127(num)
	return clipping(num,0,127)
end

--オーバーした値を範囲内に収める
function clipping(num,min,max)
	local n
	if num<min then
		n = min
	elseif max<num then
		n = max
	else
		n = num
	end
	return n
end

--対象となる文字列(target)がカンマ区切りされた文字列群(lyrics)の中にあるか調べる
function compareLyrics(target,lyrics)
	local t = split(lyrics,",")
	local i
	for i = 0, table.getn(t) do
		if(target==t[i])then
			return 1
		end
	end
	return 0
end


--ダイアログ文字列出力
function mes(message)
	VSMessageBox(message,0)
	return 0
end

--特定の文字(d)で区切られた文字列(s)を分割しテーブル化する
function split(s, d)
	local l
	local r = {}
	local p = "(.-)" .. d .. "()"
    if string.find(s, d) == nil then
        return { s }
    end
    for t, o in string.gfind(s, p) do
        table.insert(r, t)
        l = o
    end
    table.insert(r, string.sub(s, l))
    return r
end
