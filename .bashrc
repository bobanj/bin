# My Custom bash settings, alias definitions, functions.
#
# This works on a Mac. YMMV.
#
# Author: Stefan Saasen (most of it) and various other people (sorry if I haven't given you proper credits)...
#

# Import:
#
# if [ -f ~/bin/.bashrc ]; then
#    . ~/bin/.bashrc
# fi

CUSTOM_BIN_DIR=${HOME}/bin


if [ -f resty ]; then
  . resty
fi


# Include everything in .bashrc.d
# Thanks to Tim Moore
if [ -d $CUSTOM_BIN_DIR/bashrc.d ]; then
    for bashrc in $CUSTOM_BIN_DIR/bashrc.d/*; do
        [ -f $bashrc ] || continue
        . $bashrc
    done
fi

# Include host-specific .bashrc file
[ -f $CUSTOM_BIN_DIR/bashrc.d/`hostname -s` ] && . $CUSTOM_BIN_DIR/bashrc.d/`hostname -s`

# custom bindings
bind -f ${CUSTOM_BIN_DIR}/.bash_key_bindings

# show bindings:
# bind -P

# Custom prompt
declare -f __git_ps1 >/dev/null
if [ "$?" -eq "0" ]; then
  green=$(tput setaf 2)
  blue=$(tput setaf 4)
  branch_name=$(tput bold; tput setaf 4)
  bold=$(tput bold)
  reset=$(tput sgr0)
  export PS1='\u@\h:\w $(__git_ps1 "(\[$green$bold\]$(prompt_char)\[$reset\] \[$branch_name\]%s\[$reset\]$(parse_scm_dirty)) ")[\j]\n[\!] λ > '
fi

## ============================================================================
## Bash settings
## ============================================================================
#Bash History
# http://www.faqs.org/docs/bashman/bashref_106.html
export HISTCONTROL=erasedups
export HISTSIZE=5000
# Append to the history file instead of overwriting it from multiple shells
shopt -s histappend

# Use vanilla vim for the "fc" command
export FCEDIT="vim"

# Set xterm title
export PROMPT_COMMAND='echo -ne "\033]0;$(basename `pwd`)\007"'

# Use vim for viewing manpages
export MANPAGER="col -b | view -c 'set ft=man nomod nolist' -"

# Rake autocomplete
complete -C rake_autocomplete.rb -o default rake

# ~~~~~ cdargs ~~~~~~~~~~~~
CDARGS_BASH=`brew --prefix cdargs`"/contrib/cdargs-bash.sh"
if [ -f $CDARGS_BASH ]; then
  source $CDARGS_BASH
fi

# search path for cd
#export CDPATH=$HOME/dev

# ~~~~~ Load git completion
#. ${CUSTOM_BIN_DIR}/.git-completion.bash

## ============================================================================
## Alias definitions
## ============================================================================

alias m="mvim"

# Old habits...
alias rehash="hash -r"
alias vmstat="vm_stat"

# Tomcat
alias tom="ps aux | grep \"catalina.startup.Bootstrap\" | grep -v grep"

# Pushd/Popd
alias pu="pushd"
alias po="popd"

# To disable an alias temporarily: "\ALIASNAME" -> "\nl" will not use the alias nl
# Default arguments for well known programs
# Modify existing commands
alias stat="stat -x"
# grep -n -> line numbers
alias grep="grep --color=auto"
alias nl="nl -b a"

# ~~~~~ shortcuts
alias lc="ls -lah"
#alias mate=gedit
alias ".."="cd .."
alias h="history"
alias cd..='cd ..'
alias d='dict'
alias p="ps aux | grep ^$USER"


# Maven
alias madness='mvn org.apache.maven.plugins:maven-dependency-plugin:RELEASE:tree'

# OSGi bundles
#  -verify - Verify the JAR for consistency with the specification. The print will exit with an error if the verify fails
#  -manifest - Show the manifest
#  -list - List the entries in the JAR file
#  -all - Do all (this is the default)
alias osgi="java -jar ~/bin/biz.aQute.bnd.jar print -manifest"

# Ruby/Rails
alias ss="./script/server"
alias sd="./script/server --debugger"

alias svnnew='svn status | grep "^?"'
alias svn-dir-remove="ruby -rfileutils -e 'include FileUtils; Dir[\"**/.svn\"].each do |f|; rm_r f; end'"

# ======= dtrace =========
alias dtfiles="sudo dtrace -n 'syscall::open*:entry { printf(\"%s %s\", execname, copyinstr(arg0)); }'"
alias dtfiles-hist="echo 'Hit CTRL-C to see a list of files accessed.' && sudo dtrace -n 'syscall::open*:entry{@[copyinstr(arg0)] = count();}'"

# Remove ~ files
alias cl="find . -name "*~" | xargs rm"
# Remove IntelliJ IDEA project files
alias idea-clean='find . -name "*.ipr" -o -name "*.iml" -o -name "*.iws" | xargs rm'

alias sha1sum="openssl dgst -sha1 "

# List servers
alias servers="sudo lsof -i -Pn"

# IP (en0)
alias myip="ruby -e 'print `ifconfig`.map{|line| $1.dup if line !~ /127\./ and line =~ /inet ([0-9.]+)/}.compact.first'"

# tcpdump
# use the loopback interface for local traffic
alias sniff="sudo tcpdump -s0 -i en0 -A"
alias couchgrep="sudo ngrep -W byline -d lo0 port 5984"
alias httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""
alias httpdump_local="sudo tcpdump -i lo0 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""

# ~~~~~ ditz
alias dt="ditz todo"
alias ds="ditz status"


function searchreplace {
	# sed -i .bak 's/BLUE_COLOR/kBlueColor/g' *.h
  if [ $# -lt 3 ]; then
    echo "Usage:   searchreplace SEARCHSTRING REPLACEMENT FILEGLOB"
    echo ""
    echo "    example: searchreplace BLUE_COLOR kBlueColor ./path/to/file"
    echo ""
    return
  fi
  if [ $# -eq 3 ]; then
	echo "Replacing '$1' with '$2' in '$3'"
    sed "s/${1}/${2}/g" -i -- $3
  fi	
}

# ~~~~~ Misc ~~~~~~~~
# show file header. Usage: fh test.db
alias fh="od -c -N 16 "



# ~~~~~ darcs
alias dw="darcs whatsnew -l"
alias dp="darcs pull --dry-run"

# ~~~~ Apache ~~~~~~~
# (show compiled in modules)
# apache2 -l
# (show all loaded modules)
alias apsm="apache2 -t -D DUMP_MODULES" 


# ~~~~~ Server Info ~~~~~
alias srvinf="netstat --tcp -l"

# ~~~~~ Java lib structure
alias mkv="mkdir -p vendor/{lib-dist,lib-dev,lib-test}"

## ============================================================================
# ~~~~~ Ruby
alias rbgv="ruby -e 'global_variables.each{ |var| puts var + \": \" + eval(var).inspect }'"
alias irb='irb --readline -r irb/completion -rubygems'

## ============================================================================

# Filenumbering -> nl
# Usage: rnl < file.txt
function rnl {
    ruby -ne 'printf("%-6s%s", $., $_)' < $1
}

# quickly inspect source files in style (from @defunkt I think...)
function pless {
  pygmentize $1 | less -r
}

function cdgem {
  cd `gem env gemdir`/gems/; cd `ls|grep $1|sort|tail -1`
}

function cpu_usage {
  if [ ! $# == 1 ]; then
    echo "Usage:       cpu_usage PID"
    echo ""
    return
  fi
  ps -p$1 -opid -opcpu -ocomm -c
}

function rm_trailing_whitespace {
    ruby -pe 'gsub(/\s+$/, $/)' < $1 > tt.tmp;
    mv tt.tmp $1
}

function jdumpclass {
  # We need exactly 2 arguments
  if [ ! $# == 2 ]; then
    echo "Usage: jdumpclass classpath class"
    return
  fi
  javap -verbose -private -classpath $1 $2
}

# Print 9k worth of 'x'
function create_file {
  data=`ruby -e "(['x' * 1024] * 9).each {|line| puts line}"`
  echo -n $data
# dd if=/dev/random of=out.txt bs=1000000 count=100
}

function fd {
  find . -iname "*$1*" -type d
}

function f {
    set -e
    result=$TMPDIR/_find_result.txt
    # Search and store the first match in the clipboard
    find . -iname "*$1*" | tee $result | awk -F ":| " '{print $0} NR>0{exit};0' | tr -d '\n' | pbcopy
    # Show the searchresult
    cat $result
    rm -f $result
}

function netdump {
    sudo ngrep -d en1 -W byline host $1
}

function netdump_local {
    # lo loopback 127.0.0.1
	# sudo ngrep -W byline -d lo port 8080
    sudo ngrep -W byline -d lo0 port 5984
}

# (C)opy (c)hanges to
function ccto {
  echo "Copying changes from $1 to $2"
  diff -u $2 $1 | patch
}

function mem_mon {
	mem=`ps -o rss= -p $1`
    mb=$(echo "scale=2; $mem/1024.0" | bc -l)
    echo "${mb} MB"
}

function mem_mon3 {
    mem=`pmap $1 | grep total | awk '{print $2}' | sed 's/K//'`
    mb=$(echo "scale=2; $mem/1024.0" | bc -l)
    echo "${mb} MB"
}

# http://tinyurl.com/5fd6mj
# http://en.wikipedia.org/wiki/Virtual_memory
function mem_mon2 {
  echo "Memory usage for PID ${1}"
  mem=`grep Private_Dirty /proc/${1}/smaps | awk '{print $2}' | xargs ruby -e 'puts ARGV.inject { |i, j| i.to_i + j.to_i }'`
  mb=$(echo "scale=2; $mem/1024.0" | bc -l)
  echo "${mb} MB"  
}

function check_c_code {
  # simple regex to look for bad things:
  egrep '[^_.>a-zA-Z0-9](str(n?cpy|n?cat|xfrm|n?dup|str|pbrk|tok|_)|stpn?cpy|r?index[^.]|a?sn?printf|byte_)' *.c
}

# This function looks for malformed a href tags in java src files.
function find_malformed_ahref {
    find src -name "*.java" | xargs grep -i ".*[*].*<[aA][^[:space:]]"
}

function mysqlschemadump {
  # We need exactly 4 arguments
  if [ ! $# == 4 ]; then
    echo "Usage: mysqlschemadump USER PASSWORD HOST DATABASE"
    return
  fi
  mysqldump --single-transaction -u $1 -h $3 --triggers --routines --password=$2 -X --no-data $4 | xsltproc ~/bin/xml-ascii-treeview.xsl -
}

# extract files eg: ex tarball.tar
function ex () {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1        ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1       ;;
            *.rar)       rar x $1     ;;
            *.gz)        gunzip $1     ;;
            *.tar)       tar xf $1        ;;
            *.tbz2)      tar xjf $1      ;;
            *.tgz)       tar xzf $1       ;;
            *.zip)       unzip $1     ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1    ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}


## ============================================================================
# ~~~~~ platform specific commands ~~~~~~~~~~~~~
# TODO: extract and create platform specific files that get sourced here
# http://osxdaily.com/2007/03/23/create-a-ram-disk-in-mac-os-x/
function create_ramdisk {
    hdid -nomount ram://52428800
    newfs_hfs /dev/disk1
    mkdir /tmp/ramdisk1
    mount -t hfs /dev/disk1 /tmp/ramdisk1
}

function remove_ramdisk {
    hdiutil detach /dev/disk1
}

# See as well: http://www.macosxhints.com/article.php?story=20020530084607311

# On Linux just use /dev/shm


alias battery="ioreg -w0 -l | grep Capacity"

# On Mac OS X
alias flushcache="dscacheutil -flushcache"

# ~~~~~ Bash customization shortcut
alias bashrc="mate -w ~/bin/.bashrc && source ~/.bash_profile && cp ~/bin/.irbrc ~/"
alias bashstats="cut -f1 -d\" \" ~/.bash_history | sort | uniq -c | sort -nr | head -n 50"

alias clearhistory="history -c && rm -f ~/.bash_history"

# copy/paste
alias pc=pbcopy
alias pp=pbpaste
alias cpwd="pwd | tr -d '\n' | pbcopy"

## ============================================================================
## comments/stuff
## ============================================================================
# dig
# dig @ns1.google.com www.google.com
# dig example.com

# xattr FILE

# =====================================================
# Redirect:
# 
# 1: stdout
# 2: stderr
# 
# 1. Capture stdout & stderr in a single file.
# ./script >> thelog.log 2>&1
# "2>&1" redirects standard error to standard out
#
# 2. Write stderr to a file
# grep da * 2> grep-errors.txt
# =====================================================

# Split binary files into chuncks (here 200MB)
# split -b 200M filename.iso
