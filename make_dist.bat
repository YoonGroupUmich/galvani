copy libgalvani\Release\libgalvani-ni.dll
python galvani_cffi_build.py

python -m PyInstaller galgui.py --add-data "config.ini;."

pause
