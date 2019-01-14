#!/bin/bash
#
# Copyright 2015-2018 M Nollen
#
# The MIT License
#
#Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to
# do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# 
# NAME
#  macro script - Bash script to record a sequence of commands
#                 Does not record commands that return a code different than 0
#   
# AUTHOR
#  Nollen
#
# Notes: This script requires to set the following to your .bashrc
# export PROMPT_COMMAND='EXIT="$?"; bmacro'
# for sourcing other scripts source them in your $HOME/.bash_profile

#Check if there is a static home set
if [ -z ${PHOME+1} ]; then
  PHOME=$HOME;
fi

MSTART=""
MPATH="${PHOME}/macro" 
MFILE="${MPATH}/cachedmacro"

alias pu='      pushd > /dev/null 2>&1'
alias po='      popd  > /dev/null 2>&1'

cReset="$(tput sgr0     )"
cRed="$(tput setaf 1    )"
n="${cReset}"
R="${bld}${cRed}"

if [ "$1" == "-h" ]; then
  echo "Bash script to record a sequence of commands"
  echo "mstart            - Start recording"
  echo "mstop             - Stop  recording and name record"
  echo "mcheck            - Show the current status (Recording || \"\")"
  echo "mls               - List macros"  
  echo "mrun [macro_name] - Execute record in cache or a saved one"  
  echo "mrm <macro_name>  - Delete macro "  
  echo "mmod <macro_name> - Modify recorded script " 
fi

function bmacro ()     { case $MSTART in
                          record)  
			    if [ "$EXIT" -eq 0 ]; then 
                              fc -ln -1 >> $MFILE;
                            fi;;
                          create)
  		 	    MSTART="";
                            promptUser "Do you want to save this macro? "
                            if [[ $? -eq 1 ]]; then
  			      printf "${R}Please add name: ${n}";
                              local input;
                              read input;
                              cp $MFILE ${MPATH}/${input};
                              chmod 755 ${MPATH}/${input};
                            fi;;
                         esac
                       }
function mstart        { MSTART="record";
                         if [[ ! -f $MFILE ]]; then 
                           mkdir -p $MPATH; chmod -R 755 $MPATH;
                           echo "created filepath"
                           touch $MFILE;
                           chmod 755 $MFILE;
                         fi
		         truncate -s 0 $MFILE;
                         echo "#!/bin/bash" > $MFILE;
                         echo "source ${PHOME}/bin/macroscript.sh;" >> $MFILE;
                         echo "source ${PHOME}/.bash_profile;" >> $MFILE;
                         echo "shopt -s expand_aliases;" >> $MFILE;
			 return 1; #To avoid recording this cmd
                       }
function mstop         { MSTART="create"; }
function mrun()        { if [[ -z $1 ]]; then
                           # Run last cached macro
                           $MFILE               
			   return 1; # Avoid re-running cached file
                         else
			   local file=${MPATH}/$1
                           if [[ -f $file ]]; then
			     $file
                           else
                             printf "${R}Include a valid macro name${n}\n";
                           fi 
                         fi
                       }
function mls           { pu $MPATH; ls; po; }
function mcheck        { echo "$MSTART"; return 1; }
function mrm()         { pu $MPATH; if [[ -f $1 ]]; then rm -f $1;
                         else printf "${R}Include a valid macro name${n}\n"; fi; po; 
                       }
function mmod()        { pu $MPATH; if [[ -f $1 ]]; then $EDITOR $1;
                         else printf "${R}Include a valid macro name${n}\n"; fi; po; 
                       }
# The following function is not my creation
#Ask user yes or no question: Returns 1=yes, 0=no
function promptUser()
{
  local prompt=$1;
  [ ${#prompt} -eq 0 ] && printf "promptUser <prompt>\n" && return;
  while true; do
    read -p "${R}${prompt}${n}" yn
    case $yn in
      [Yy]*) return 1;;
      [Nn]*) return 0;;
        *  ) printf "Please answer yes or no.\n";;
    esac
  done
}
