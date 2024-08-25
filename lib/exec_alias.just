
_exec_base := just_executable() + ' -f ' + source_directory() / '../mods'

utils := _exec_base / 'utils/Justfile'
github := _exec_base / 'github/Justfile'
