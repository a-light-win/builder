
_exec_base := just_executable() + ' -f ' + source_directory() / '../mods'

github := _exec_base / 'github/justfile'

builtin_bash_functions := source_directory() / 'bash/functions' 
