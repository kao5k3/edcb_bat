@echo off

set RECPOST="%~dp0\RecPost.pl"

set FILEPATH="D:\Videos\�e���r\���j�h���}�u��̂��Ɂv�i�Ȃ��̂����Ƃ܁j ��O�V�b.ts"
set ADDKEY="��̂���"
set GENRE="�h���}"
call :SubRoutine

set FILEPATH="D:\Videos\�e���r\�Ƃ���Ȋw�̈���ʍs #07.ts"
set ADDKEY="�Ƃ���Ȋw�̈���ʍs"
set GENRE="�A�j��"
call :SubRoutine

set FILEPATH="D:\Videos\�e���r\�Ηj�h���}�u�g�����������H�`����y���X�g�����`�v��V�@��A�q�̒m��ꂴ��閧.ts"
set ADDKEY="Heaven?~����y���X�g����~"
set GENRE="�h���}"
call :SubRoutine

set FILEPATH="D:\Videos\�e���r\#17 �ċx�݂̂Â�.ts"
set ADDKEY="�Ƃ��閂�p�̋֏��ژ^�V"
set GENRE="�A�j��"
call :SubRoutine

set FILEPATH="D:\Video\�n�P���肢�t�A�^�� ���R.ts"
set ADDKEY="�n�P���肢�t�A�^��"
set GENRE="�h���}"
call :SubRoutine

set FILEPATH="D:\Video\�Ηj�h���}�u���߂ė����������ɓǂޘb�v ��R�b�y�͂��I���̃L���`�z.ts"
set ADDKEY="���߂ė����������ɓǂޘb"
set GENRE="�h���}"
call :SubRoutine

set FILEPATH="D:\Video\���ԍĐ��I�N���V�b�N�J�[�E�f�B�[���[�Y�F�V�R���r���䗠(��).ts"
set ADDKEY="���ԍĐ�"
call :SubRoutine

set FILEPATH="D:\Videos\�e���r\�R�N�`�g�@�|������F����́A�l���ł��|#04�����͊j�S�ց[�B�K���̑�4�b.ts"
set ADDKEY="3�NA�g -������F����́A�l���ł�-"
set GENRE="�h���}"
call :SubRoutine

set FILEPATH="D:\Video\�u���^�����u���P�Q�S�@����v.ts"
set ADDKEY="�u���^����"
set GENRE="���{"
call :SubRoutine

set FILEPATH="D:\Video\�s�A�m�̐X�i�P�S�j�u������z���v.ts"
set ADDKEY="�s�A�m�̐X"
set GENRE="�A�j��"
call :SubRoutine

set FILEPATH="D:\Video\�Ɣ���I���i�̋t�P#05 �U������&��b�J�b�v���ɋN���񐶂̉Ɣ�����GO!.ts"
set ADDKEY="�Ɣ���I���i�̋t�P"
set GENRE="�h���}"
call :SubRoutine

set FILEPATH="D:\Video\�Q�[���Z���^�[CX #258 ����ς艄���c�u���b�N�}��X2�v.ts"
set ADDKEY="�Q�[���Z���^�[CX"
set GENRE="�"
call :SubRoutine

set FILEPATH="D:\Video\���̋��l���� �g���F���w�V���Ǝ��摜�x���⃊�A���ȐV���c���I����`�������́H.ts"
set ADDKEY="���̋��l����"
set GENRE="���{"
call :SubRoutine

set FILEPATH="D:\Video\�R�Y�~�b�N �t�����g���m�d�w�s���_�f�a���ɔ���I��� �X�̉��̃^�C���J�v�Z��.ts"
set ADDKEY="�R�Y�~�b�N�t�����g"
set GENRE="���{"
call :SubRoutine

exit /b

rem ===============================================================================

:SubRoutine

echo ���V���[�Y
perl %RECPOST% -f %FILEPATH% -a %ADDKEY% -g %GENRE% -s --debug

echo ���V���[�Y_����
perl %RECPOST% -f %FILEPATH% -a %ADDKEY% -g %GENRE% -s -t --debug

echo ���V���[�Y_�A�ԁ{����
perl %RECPOST% -f %FILEPATH% -a %ADDKEY% -g %GENRE% -s -t -r --debug

set /p stdin="type any key to continue>"
exit /b