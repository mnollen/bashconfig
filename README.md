# Bash config files

The intent of this scripts are for personal use.

## Bash profile
  This script has functions created by internet contributions, friends and myself. 
  The purpose is to complement other work scripts

## Macro_script
  The purpose of this script is to record the comands that contain 0 in their return code.
  
```
  Bash script to record a sequence of commands
  mstart            - Start recording
  mstop             - Stop  recording and name record
  mcheck            - Show the current status (Recording or empty string)
  mls               - List macros
  mrun [macro_name] - Execute record in cache or a saved one
  mrm <macro_name>  - Delete macro
  mmod <macro_name> - Modify recorded script 
```

  The recorded scripts are saved in $HOME/macro file path
  
  mstart, mcheck, returns 1 to avoid recording itself.
  A script created during recording may call another script previously created by this command.
  
