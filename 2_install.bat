@echo off
set drive=i:
if NOT EXIST %Drive%\ (
	echo Please mount the disk image at %Drive%
	pause
	EXIT
)
IF NOT EXIST %Drive%\boot mkdir %Drive%\boot
IF NOT EXIST %Drive%\bin mkdir %Drive%\bin
IF NOT EXIST %Drive%\sys mkdir %Drive%\sys
IF NOT EXIST %Drive%\apps mkdir %Drive%\Apps

IF NOT EXIST %Drive%\keys mkdir %Drive%\keys
IF NOT EXIST %Drive%\fonts mkdir %Drive%\fonts
IF NOT EXIST %Drive%\res mkdir %Drive%\res
IF NOT EXIST %Drive%\icons mkdir %Drive%\icons
IF NOT EXIST %Drive%\etc mkdir %Drive%\etc
echo Install kernel ...
del %Drive%\boot\kernel.elf /F /Q

copy bin\kernel.elf %Drive%\boot\kernel.elf
copy bin\res\realmode.bin %Drive%\boot\realmode.bin


for /r %%i in (bin\userland\*.bin) do (
	echo    %%~ni
	IF NOT EXIST %Drive%\apps\%%~ni.APP mkdir %Drive%\apps\%%~ni.APP
	copy bin\userland\%%~ni.bin %Drive%\apps\%%~ni.APP\main.bin
	if exist icons\%%~ni.bmp copy icons\%%~ni.bmp %Drive%\apps\%%~ni.APP\app.bmp
)

echo install keymaps
copy bin\keymaps\*.* %Drive%\keys

echo Install fonts
copy fonts\*.* %Drive%\fonts

echo install skins
copy skins\*.bmp %Drive%\res\*.bmp

echo install icons
copy icons\*.bmp %Drive%\icons\*.bmp


copy bin\res\mousecur.bin %Drive%\res

echo Instal System bin
copy bin\sys\*.* %Drive%\sys

echo Install config
copy etc\*.* %Drive%\etc
pause