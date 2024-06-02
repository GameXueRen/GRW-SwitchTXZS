#Requires AutoHotkey v2.0
;调试
; ListLines()
toolVersion := "v1.1"
toolName := "荒野一键退回至铁血战士版"
;配置文件
profilesName := toolName "配置.ini"
mainConfigName := "main"
txzsDirPathName := '"退回至铁血战士版"所需文件所在目录'
gameDirPathName := '"幽灵行动荒野"游戏安装目录'
isUseToolName := "是否使用过"
;游戏文件名及自定义备份后缀
worldMapFileName := "DataPC_GRN_WorldMap_patch_01.forge"
patchFileName := "DataPC_patch_01.forge"
backupExt := ".gmxrdef"
;主界面
creatMyGui()

;创建主界面控件及事件
creatMyGui()
{
    ;读取配置文件
    global isUseTool := readMainCfg(isUseToolName, "0")
    txzsDirPath := readMainCfg(txzsDirPathName, "D:\网盘下载\幽灵行动荒野(铁血战士)\需要恢复的文件")
    gameDirPath := readMainCfg(gameDirPathName, "D:\UbisoftGame\Tom Clancy's Ghost Recon Wildlands")
    ;兼容以后可能的诈尸更新导致的文件大小变化，只需在配置文件中添加以下隐性配置项即可兼容。
    ;铁血战士版文件大小(KB值向下取整)
    global txzsWorldMapFileSize := Integer(readMainCfg("txzsWorldMapFileSize", "14091488"))
    global txzsPatchFileSize := Integer(readMainCfg("txzsPatchFileSize", "4242976"))
    ;荒野最新版文件大小(KB值向下取整)
    global gameWorldMapFileSize := Integer(readMainCfg("gameWorldMapFileSize", "13372096"))
    global gamePatchFileSize := Integer(readMainCfg("gamePatchFileSize", "4247456"))

    ;创建主界面
    global myGui := Gui("-Resize -MaximizeBox", toolName toolVersion)
    myGui.SetFont("s10")
    myGuiW := 480
    marginX := 8
    marginY := 8
    myGui.MarginX := marginX
    myGui.MarginY := marginY
    ;教程贴
    myGui.AddLink("Section xm ym", '所需文件获取方式见此贴:`n<a href="https://tieba.baidu.com/p/8695541006">《幽灵行动荒野》恢复“铁血战士”(移动的丛林)任务教程</a>')
    ;铁血战士目录
    pathEditW := myGuiW - marginX * 2
    selectButtonW := 60
    selectButtonH := 30
    txzsTextCtrl := myGui.AddText("+0x200 xs r1 w" myGuiW - marginX * 2, txzsDirPathName "：")
    txzsTextCtrl.SetFont("s10 cRed w700")
    txzsDirCtrlName := "txzsDirEdit"
    global txzsDirPathCtrl := myGui.AddEdit("ReadOnly r1 w" pathEditW " v" txzsDirCtrlName, txzsDirPath)
    selectTxzsDirCtrl := myGui.AddButton("Section xp w" selectButtonW " h" selectButtonH, "选择")
    selectTxzsDirCtrl.SetFont("w700")
    openTxzsDirCtrl := myGui.AddButton("yp hp wp", "打开")
    ;荒野目录
    gameTextCtrl := myGui.AddText("+0x200 xs r1 w" myGuiW - marginX * 2, gameDirPathName "：")
    gameTextCtrl.SetFont("cRed w700")
    gameDirCtrlName := "gameDirEdit"
    global gameDirPathCtrl := myGui.AddEdit("ReadOnly r1 w" pathEditW " v" gameDirCtrlName, gameDirPath)
    selectGameDirCtrl := myGui.AddButton("Section xp hp w" selectButtonW " h" selectButtonH, "选择")
    selectGameDirCtrl.SetFont("w700")
    openGameDirCtrl := myGui.AddButton("yp hp wp", "打开")
    ;关于
    startW := 110
    startH := 60
    buttonMarginX := 20
    aboutCtrl := myGui.AddLink("xs y+4 w" myGuiW - marginX * 2 - startW * 2 - buttonMarginX " h" startH - selectButtonH-4, 'GameXueRen制作(QQ群:299177445)`n友情推广工具:<a href="https://github.com/GameXueRen/GRW-CNChat">游戏无缝输入中文</a>')
    aboutCtrl.SetFont("s9")
    ;退回/恢复
    switchDefaultCtrl := myGui.AddButton("ys x" myGuiW - marginX - startW " w" startW " h" startH, "恢复至`n荒野最新版")
    switchDefaultCtrl.SetFont("s12 w700")
    switchTxzsCtrl := myGui.AddButton("yp wp hp xp-" buttonMarginX + startW, "退回至`n铁血战士版")
    switchTxzsCtrl.SetFont("s12 w700")

    myGui.AddLink("ym w100 x" myGuiW-marginX-100, '工具开源:`n<a href="https://github.com/GameXueRen/GRW-SwitchTXZS">GRW-SwitchTXZS</a>')

    ;显示主界面
    myGui.Show("Center AutoSize w" myGuiW)

    ;添加联动控件名属性
    selectTxzsDirCtrl.syncIniKey := txzsDirPathName
    selectGameDirCtrl.syncIniKey := gameDirPathName
    selectTxzsDirCtrl.syncCtrlName := txzsDirCtrlName
    openTxzsDirCtrl.syncCtrlName := txzsDirCtrlName
    selectGameDirCtrl.syncCtrlName := gameDirCtrlName
    openGameDirCtrl.syncCtrlName := gameDirCtrlName

    ;添加控件事件
    selectTxzsDirCtrl.OnEvent("Click", selectDirCtrl_Click)
    openTxzsDirCtrl.OnEvent("Click", openDirCtrl_Click)
    selectGameDirCtrl.OnEvent("Click", selectDirCtrl_Click)
    openGameDirCtrl.OnEvent("Click", openDirCtrl_Click)
    switchTxzsCtrl.OnEvent("Click", (*) => switchTxzsAndControl(true))
    switchDefaultCtrl.OnEvent("Click", (*) => switchTxzsAndControl(false))
    myGui.OnEvent("Close", myGui_Close)

    ;托盘右键菜单定制
    A_TrayMenu.Delete()
    A_TrayMenu.Add("打开", (*) => myGui.Show())
    A_TrayMenu.Add("重新加载", (*) => Reload())
    A_TrayMenu.Add("退出", (*) => ExitApp())
    A_TrayMenu.ClickCount := 1
    A_TrayMenu.Default := "打开"
    A_IconTip := toolName toolVersion

    ;显示首次使用提示
    if !isUseTool
    {
        warningMsgBox("如果是“首次使用此工具”切换版本:`n请先确保“幽灵行动荒野”游戏安装目录`n所有游戏文件为官方原版！`n`n本工具适用自(2023年9月)更新后的游戏版本", "首次使用提示！")
    }
}
;主界面关闭事件
myGui_Close(thisGui)
{
	result := warningMsgBox("确定退出？", "退出", "OKCancel Icon! Default2")
	if result = "OK"
	{
		ExitApp()
	} else
		return true
}
;退回或恢复按钮点击事件
switchTxzsAndControl(isTxzs)
{
    for ctrl in myGui
    {
        if ctrl.Type = "Button"
            ctrl.Enabled := false
    }
    switchResult := switchTxzs(isTxzs)
    if switchResult && (!isUseTool)
    {
        writeMainCfg("1", isUseToolName)
    }
    SetTimer(reEnableCtrl, -500)
    reEnableCtrl()
    {
        for ctrl in myGui
        {
            if ctrl.Type = "Button"
                ctrl.Enabled := true
        }
    }
}
;版本切换
switchTxzs(isTxzs)
{
    if isTxzs
        tipTitle := "退回至铁血战士版"
    else
        tipTitle := "恢复至荒野最新版"
    gameDirPath := gameDirPathCtrl.Text
    if !DirExist(gameDirPath)
    {
        warningMsgBox(gameDirPathName "`n不存在！路径无效！", "目录不存在！")
        return false
    }
    gameWorldMapPath := gameDirPath "\" worldMapFileName
    gamePatchPath := gameDirPath "\" patchFileName
    if !FileExist(gameWorldMapPath)
    {
        gameWorldMapBackupPath := gameWorldMapPath backupExt
        if FileExist(gameWorldMapBackupPath)
        {
            ;备份文件存在，提示是否恢复备份
            result := warningMsgBox("“" gameDirPathName "”缺少`n" worldMapFileName "`n文件！`n`n是否恢复备份文件以继续？", "是否恢复备份！", "OKCancel Default1 Icon!")
            if result = "OK"
            {
                try
                {
                    FileMove(gameWorldMapBackupPath, gameWorldMapPath)
                }catch
                {
                    warningMsgBox("恢复备份文件“" gameWorldMapBackupPath "”操作失败！", "恢复备份失败！")
                    return false
                }
            }else
            {
                warningMsgBox(tipTitle " 失败！", tipTitle " 失败！")
                return false
            }
        }else
        {
            warningMsgBox("“" gameDirPathName "”缺少`n" worldMapFileName "`n文件！", "文件缺失！")
            return false
        }
    }
    if !FileExist(gamePatchPath)
    {
        gamePatchBackupPath := gamePatchPath backupExt
        if FileExist(gamePatchBackupPath)
        {
            ;备份文件存在，提示是否恢复备份
            result := warningMsgBox("“" gameDirPathName "”缺少`n" patchFileName "`n文件！`n`n是否恢复备份文件以继续？", "是否恢复备份！", "OKCancel Default1 Icon!")
            if result = "OK"
            {
                try
                {
                    FileMove(gamePatchBackupPath, gamePatchPath)
                } catch
                {
                    warningMsgBox("恢复备份文件“" gamePatchBackupPath "”操作失败！", "恢复备份失败！")
                    return false
                }
            } else
            {
                warningMsgBox(tipTitle " 失败！", tipTitle " 失败！")
                return false
            }
        }else
        {
            warningMsgBox("“" gameDirPathName "”缺少`n" patchFileName "`n文件！", "文件缺失！")
            return false
        }
    }
    ;游戏目录里两个文件的状态，-1为文件大小与记录的不匹配，1为铁血战士版, 2为荒野最新版
    worldMapFileState := -1
    patchFileState := -1
    ; DataPC_GRN_WorldMap_patch_01.forge
    loop files gameWorldMapPath
    {
        if InStr(A_LoopFileAttrib, "L")
        {
            if (A_LoopFileSizeKB = 0)
                worldMapFileState := 1 ;当为符号链接且大小为0，此文件为铁血战士版
            else
            {
                warningMsgBox("“" gameDirPathName "”`n" worldMapFileName "`n文件异常！`n请手动复原该源文件或验证游戏文件完整性来重置", tipTitle " 失败！")
                return false
            }
        } else
        {
            if (A_LoopFileSizeKB = gameWorldMapFileSize)
                worldMapFileState := 2 ;为荒野最新版
            else
            {
                ;荒野最新版文件大小与工具记录的不一致，提示是否强制继续。兼容以后可能的诈尸更新导致源文件大小发生变化
                result := warningMsgBox("“" gameDirPathName "”`n" worldMapFileName "`n与本工具记录的“荒野最新版”`n文件大小不一致！`n`n点击“确定”忽略并强制继续！`n`n或手动复原该源文件`n或验证游戏文件完整性来重置", tipTitle " 是否强制继续?", "OKCancel Default2 Icon!")
                if result = "OK"
                    worldMapFileState := 2
                else
                {
                    warningMsgBox(tipTitle " 失败！", tipTitle " 失败！")
                    return false
                }
            }
        }
    }
    ; DataPC_patch_01.forge
    loop files gamePatchPath
    {
        if InStr(A_LoopFileAttrib, "L")
        {
            if (A_LoopFileSizeKB = 0)
                patchFileState := 1
            else
            {
                warningMsgBox("“" gameDirPathName "”`n" patchFileName "`n文件异常！`n请手动复原该源文件或验证游戏文件完整性来重置", tipTitle " 失败！")
                return false
            }
        } else
        {
            if (A_LoopFileSizeKB = gamePatchFileSize)
                patchFileState := 2
            else
            {
                result := warningMsgBox("“" gameDirPathName "”`n" patchFileName "`n与本工具记录的“荒野最新版”`n文件大小不一致！`n`n点击“确定”忽略并强制继续！`n`n或手动复原该源文件`n或验证游戏文件完整性来重置", tipTitle " 是否强制继续?", "OKCancel Default2 Icon!")
                if result = "OK"
                    patchFileState := 2
                else
                {
                    warningMsgBox(tipTitle "失败！", tipTitle " 失败！")
                    return false
                }
            }
        }
    }
    ;两文件状态一致，进行切换
    if (worldMapFileState = patchFileState)
    {
        if isTxzs
        {
            ;退回至铁血战士版
            if (worldMapFileState = 1)
            {
                warningMsgBox("当前已经为“铁血战士版”`n无需退回！", tipTitle)
                return false
            }
            txzsDirPath := txzsDirPathCtrl.Text
            txzsWorldMapPath := txzsDirPath "\" worldMapFileName
            txzsPatchPath := txzsDirPath "\" patchFileName
            ;检查铁血战士所需文件是否存在，是否与工具记录的大小一致
            if !DirExist(txzsDirPath)
            {
                warningMsgBox(txzsDirPathName "`n不存在！路径无效!", "目录不存在！")
                return false
            }
            if FileExist(txzsWorldMapPath)
            {
                fileSize := FileGetSize(txzsWorldMapPath, "K")
                if fileSize != txzsWorldMapFileSize
                {
                    warningMsgBox("“" txzsDirPathName "”`n" worldMapFileName "`n与本工具记录的“铁血战士版”`n文件大小不一致！`n请检查该文件是否为“退回至铁血战士版所需文件”", tipTitle "失败！")
                    return false
                }
            } else
            {
                warningMsgBox("“" txzsDirPathName "”中缺少`n" worldMapFileName "`n文件！", "文件缺失！")
                return false
            }
            if FileExist(txzsPatchPath)
            {
                fileSize := FileGetSize(txzsPatchPath, "K")
                if fileSize != txzsPatchFileSize
                {
                    warningMsgBox("“" txzsDirPathName "”`n" patchFileName "`n与本工具记录的“铁血战士版”`n文件大小不一致！`n请检查该文件是否为“退回至铁血战士版所需文件”", tipTitle "失败！")
                    return false
                }
            } else
            {
                warningMsgBox("“" txzsDirPathName "”中缺少`n" patchFileName "`n文件！", "文件缺失！")
                return false
            }
            ;执行退回至铁血战士版
            try
            {
                ;荒野最新版文件重命名以作备份
                FileMove(gameWorldMapPath, gameWorldMapPath backupExt)
                FileMove(gamePatchPath, gamePatchPath backupExt)
                Sleep 200
                ;创建铁血战士版文件符号链接到游戏目录
                command := 'mklink "' gameWorldMapPath '" "' txzsWorldMapPath '" && mklink "' gamePatchPath '" "' txzsPatchPath '"'
                RunWait("*RunAs " A_ComSpec " /c " command)
            } catch Error as errInfo
            {
                ;执行错误则进行复原
                try
                {
                    FileMove(gameWorldMapPath backupExt, gameWorldMapPath, true)
                    FileMove(gamePatchPath backupExt, gamePatchPath, true)
                }
                errMessage := errInfo.Message
                if ProcessExist("GRW.exe")
                {
                    errMessage := "幽灵行动荒野(GRW.exe) 进程正在运行中`n请先退出游戏再操作！`n" errMessage
                }
                warningMsgBox("退回失败！`n" errMessage, tipTitle " 失败！")
                return false
            } else
            {
                ;执行成功
                tipMessage := "退回成功！"
                if ProcessExist("GRW.exe")
                {
                    tipMessage := tipMessage "`n幽灵行动荒野(GRW.exe) 进程正在运行中`n需要重启游戏才可生效！"
                }
                warningMsgBox(tipMessage, tipTitle " 成功！")
                return true
            }
        } else
        {
            ;恢复至荒野最新版
            if (worldMapFileState = 2)
            {
                warningMsgBox("当前已经为“荒野最新版”`n无需恢复！", tipTitle)
                return false
            }
            ;检查工具备份文件是否存在，是否与工具记录的大小一致
            gameWorldMapBackupPath := gameWorldMapPath backupExt
            gamePatchBackupPath := gamePatchPath backupExt
            if FileExist(gameWorldMapBackupPath)
            {
                fileSize := FileGetSize(gameWorldMapBackupPath, "K")
                if fileSize != gameWorldMapFileSize
                {
                    result := warningMsgBox("备份文件`n" gameWorldMapBackupPath "`n与本工具记录的“荒野最新版”`n文件大小不一致！`n点击“确定”忽略并强制继续！`n`n或手动复原该源文件`n或验证游戏文件完整性来重置", tipTitle " 是否强制继续?", "OKCancel Default2 Icon!")
                    if result = "Cancel"
                    {
                        warningMsgBox(tipTitle " 失败！", tipTitle " 失败！")
                        return false
                    }
                }
            } else
            {
                warningMsgBox("备份文件`n" gameWorldMapBackupPath "`n不存在！`n无法恢复！", tipTitle " 失败！")
                return false
            }
            if FileExist(gamePatchBackupPath)
            {
                fileSize := FileGetSize(gamePatchBackupPath, "K")
                if fileSize != gamePatchFileSize
                {
                    result := warningMsgBox("备份文件`n" gamePatchBackupPath "`n与本工具记录的“荒野最新版”`n文件大小不一致！`n点击“确定”忽略并强制继续！`n`n或手动复原该源文件`n或验证游戏文件完整性来重置", tipTitle " 是否强制继续?", "OKCancel Default2 Icon!")
                    if result = "Cancel"
                    {
                        warningMsgBox(tipTitle " 失败！", tipTitle " 失败！")
                        return false
                    }
                }
            } else
            {
                warningMsgBox("备份文件`n" gamePatchBackupPath "`n不存在！`n无法恢复！", tipTitle " 失败！")
                return false
            }
            ;执行恢复至荒野最新版
            try
            {
                ;删除铁血战士版文件符号链接
                FileDelete(gameWorldMapPath)
                FileDelete(gamePatchPath)
                Sleep 200
                ;恢复荒野最新版备份文件原名
                FileMove(gameWorldMapBackupPath, gameWorldMapPath)
                FileMove(gamePatchBackupPath, gamePatchPath)
            } catch
            {
                ;执行错误则进行强制复原
                try
                {
                    FileMove(gameWorldMapBackupPath, gameWorldMapPath, true)
                    FileMove(gamePatchBackupPath, gamePatchPath, true)
                } catch Error as errInfo
                {
                    errMessage := errInfo.Message
                    if ProcessExist("GRW.exe")
                    {
                        errMessage := "幽灵行动荒野(GRW.exe) 进程正在运行中`n请先退出游戏再操作！`n" errMessage
                    }
                    warningMsgBox("恢复失败！`n" errMessage, tipTitle " 失败！")
                    return false
                } else
                {
                    tipMessage := "恢复成功！"
                    if ProcessExist("GRW.exe")
                    {
                        tipMessage := tipMessage "`n幽灵行动荒野(GRW.exe) 进程正在运行中`n需要重启游戏才可生效！"
                    }
                    warningMsgBox(tipMessage, tipTitle " 成功！")
                    return true
                }
            } else
            {
                ;执行成功
                tipMessage := "恢复成功！"
                if ProcessExist("GRW.exe")
                {
                    tipMessage := tipMessage "`n幽灵行动荒野(GRW.exe) 进程正在运行中`n需要重启游戏才可生效！"
                }
                warningMsgBox(tipMessage, tipTitle " 成功！")
                return true
            }
        }
    } else
    {
        ;两文件状态不一致，提示是否还原重置
        result := warningMsgBox("“" gameDirPathName "”`n" worldMapFileName "`n" patchFileName "`n两个文件状态不一致！`n是否还原重置？", tipTitle, "OKCancel Default1 Icon!")
        if result = "OK"
        {
            if (worldMapFileState != 2)
            {
                ;复原WroldMap文件
                gameWorldMapBackupPath := gameWorldMapPath backupExt
                if FileExist(gameWorldMapBackupPath)
                {
                    fileSize := FileGetSize(gameWorldMapBackupPath, "K")
                    if fileSize != gameWorldMapFileSize
                    {
                        result := warningMsgBox("备份文件`n" gameWorldMapBackupPath "`n与本工具记录的“荒野最新版”`n文件大小不一致！`n点击“确定”忽略并强制继续！`n`n或手动复原该源文件`n或验证游戏文件完整性来重置", tipTitle " 是否强制继续?", "OKCancel Default2 Icon!")
                        if result = "Cancel"
                        {
                            warningMsgBox(worldMapFileName "文件还原重置失败！", "文件还原重置失败")
                            return false
                        }
                    }
                } else
                {
                    warningMsgBox("备份文件`n" gameWorldMapBackupPath "`n不存在！`n无法还原重置！", tipTitle "文件还原重置失败")
                    return false
                }
                try
                {
                    FileMove(gameWorldMapBackupPath, gameWorldMapPath, true)
                } catch Error as errInfo
                {
                    errMessage := errInfo.Message
                    if ProcessExist("GRW.exe")
                    {
                        errMessage := "幽灵行动荒野(GRW.exe) 进程正在运行中`n请先退出游戏再操作！`n" errMessage
                    }
                    warningMsgBox(worldMapFileName "文件还原重置失败！`n" errMessage, "文件还原重置失败")
                    return false
                } else
                {
                    tipMessage := worldMapFileName "`n文件还原重置成功！"
                    if ProcessExist("GRW.exe")
                    {
                        tipMessage := tipMessage "`n幽灵行动荒野(GRW.exe) 进程正在运行中`n需要重启游戏才可生效！"
                    }
                    warningMsgBox(tipMessage, "文件还原重置成功！")
                    return true
                }
            }
            if (patchFileState != 2)
            {
                ;复原Patch文件
                gamePatchBackupPath := gamePatchPath backupExt
                if FileExist(gamePatchBackupPath)
                {
                    fileSize := FileGetSize(gamePatchBackupPath, "K")
                    if fileSize != gamePatchFileSize
                    {
                        result := warningMsgBox("备份文件`n" gamePatchBackupPath "`n与本工具记录的“荒野最新版”`n文件大小不一致！`n点击“确定”忽略并强制继续！`n`n或手动复原该源文件`n或验证游戏文件完整性来重置", tipTitle " 是否强制继续?", "OKCancel Default2 Icon!")
                        if result = "Cancel"
                        {
                            warningMsgBox(patchFileName "文件还原重置失败！", "文件还原重置失败")
                            return false
                        }
                    }
                } else
                {
                    warningMsgBox("备份文件`n" gamePatchBackupPath "`n不存在！`n无法还原重置！", tipTitle "文件还原重置失败")
                    return false
                }
                try
                {
                    FileMove(gamePatchBackupPath, gamePatchPath, true)
                } catch Error as errInfo
                {
                    errMessage := errInfo.Message
                    if ProcessExist("GRW.exe")
                    {
                        errMessage := "幽灵行动荒野(GRW.exe) 进程正在运行中`n请先退出游戏再操作！`n" errMessage
                    }
                    warningMsgBox(patchFileName "文件还原重置失败！`n" errMessage, "文件还原重置失败")
                    return false
                } else
                {
                    tipMessage := patchFileName "`n文件还原重置成功！"
                    if ProcessExist("GRW.exe")
                    {
                        tipMessage := tipMessage "`n幽灵行动荒野(GRW.exe) 进程正在运行中`n需要重启游戏才可生效！"
                    }
                    warningMsgBox(tipMessage, "文件还原重置成功！")
                    return true
                }
            }
        } else
        {
            warningMsgBox(tipTitle "失败！", tipTitle " 失败！")
            return false
        }
    }
    return false
}
;选择目录
selectDirCtrl_Click(GuiCtrlObj, info)
{
    myGui.Opt("+OwnDialogs")
    iniKeyName := GuiCtrlObj.syncIniKey
    ; 允许用户选择 此电脑 目录下的文件夹
    folder := RegExReplace(DirSelect("::{20D04FE0-3AEA-1069-A2D8-08002B30309D}", 2, "选择" iniKeyName), "\\$")
    if !folder
        return
    syncCtrl := myGui[GuiCtrlObj.syncCtrlName]
    oldPath := syncCtrl.Text
    if (folder != oldPath)
    {
        syncCtrl.Text := folder
        writeMainCfg(folder, iniKeyName)
    }
}
;打开目录
openDirCtrl_Click(GuiCtrlObj, info)
{
    dirPath := myGui[GuiCtrlObj.syncCtrlName].Text
    if !dirPath
        return
    try
    {
        Run("explore " dirPath)
    } catch
    {
        warningMsgBox(dirPath "`n打开目录失败！`n请确保已选择有效目录！", "打开目录失败！")
    }
}
;读取配置文件main
readMainCfg(Key?, Default := "")
{
    return IniRead(profilesName, mainConfigName, Key ?? unset, Default)
}
;写入配置文件main
writeMainCfg(Value, Key)
{
    if !FileExist(profilesName)
    {
        FileAppend "[" mainConfigName "]", profilesName, "CP0"
    }
    IniWrite(Value, profilesName, mainConfigName, Key)
}
;普通的警告样式弹窗
warningMsgBox(text?, title?, options?)
{
    if IsSet(myGui)
    {
        myGui.Opt("+OwnDialogs")
        myGui.GetPos(&myGuiX, &myGuiY)
        msgBoxX := myGuiX + 50
        msgBoxY := myGuiY + 50
        res := MsgBoxAt(msgBoxX, msgBoxY, text ?? unset, title ?? "警告！", options ?? "Icon!")
    } else
        res := MsgBox(text ?? unset, title ?? "警告！", options ?? "Icon!")
    return res ?? ""
}
;支持自定义弹出坐标的MsgBox
MsgBoxAt(x, y, text?, title?, options?)
{
    if hHook := DllCall("SetWindowsHookExW", "int", 5, "ptr", cb := CallbackCreate(CBTProc), "ptr", 0, "uint", DllCall("GetCurrentThreadId", "uint"), "ptr") {
        res := MsgBox(text ?? unset, title ?? unset, options ?? unset)
        if hHook
            DllCall("UnhookWindowsHookEx", "ptr", hHook)
    }
    CallbackFree(cb)
    return res ?? ""
    CBTProc(nCode, wParam, lParam) {
        if nCode == 3 && WinGetClass(wParam) == "#32770" {
            DllCall("UnhookWindowsHookEx", "ptr", hHook)
            hHook := 0
            pCreateStruct := NumGet(lParam, "ptr")
            NumPut("int", x, pCreateStruct, 44)
            NumPut("int", y, pCreateStruct, 40)
        }
        return DllCall("CallNextHookEx", "ptr", 0, "int", nCode, "ptr", wParam, "ptr", lParam)
    }
}