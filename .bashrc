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


# custom bindings
bind -f ${CUSTOM_BIN_DIR}/.bash_key_bindings

## ============================================================================
## Bash settings
## ============================================================================
#Bash History
export HISTCONTROL=erasedups
export HISTSIZE=10000
shopt -s histappend


# Bash prompt (with git branch)
function prompt_char {
    git branch >/dev/null 2>/dev/null && echo '±' && return
    hg root >/dev/null 2>/dev/null && echo '☿' && return
    echo ''
}
export PS1='\u@\h:\w $(__git_ps1 "(\[\033[1;32m\]$(prompt_char)\[\033[0m\] \[\033[0;36m\] %s\[\033[0m\]) ")[\j]$ '

# Rake autocomplete
complete -C rake_autocomplete.rb -o default rake

# ~~~~~ cdargs ~~~~~~~~~~~~
if [ -f /opt/local/etc/profile.d/cdargs-bash.sh ]; then
  source /opt/local/etc/profile.d/cdargs-bash.sh
fi

# search path for cd
#export CDPATH=$HOME/dev

# ~~~~~ Load git completion
#. ~/bin/.git-completion.bash
if [ -f $GITHOME/contrib/completion/git-completion.bash ]; then
	. $GITHOME/contrib/completion/git-completion.bash
else
	echo "warning: GITHOME is not defined."
fi

# Temporary (I guess somehow my git installation is borked)
alias fixgitrepos="chmod 755 .git/hooks/{prepare-commit-msg,commit-msg,pre-commit}"

## ============================================================================
## Alias definitions
## ============================================================================

# Tomcat
alias tom="ps aux | grep \"catalina.startup.Bootstrap\" | grep -v grep"

# Pushd/Popd
alias pu="pushd"
alias po="popd"

# To disable an alias temporarily: "\ALIASNAME" -> "\nl" will not use the alias nl
# Default arguments for well known programs
# Modify existing commands
alias stat="stat -x"
alias grep="grep -n"
alias nl="nl -b a"

# ~~~~~ shortcuts
alias lc="ls -lah"
#alias mate=gedit
alias ".."="cd .."
alias h="history"
alias cd..='cd ..'
alias d='dict'
alias h='history'
alias p="ps aux | grep ^$USER"


# Maven
alias madness='mvn org.apache.maven.plugins:maven-dependency-plugin:RELEASE:tree'

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

alias sha1sum="openssl dgst -sha1 "

# List servers
alias servers="sudo lsof -i -Pn"

# IP (en0)
alias myip="ruby -e 'print `ifconfig`.map{|line| $1.dup if line !~ /127\./ and line =~ /inet ([0-9.]+)/}.compact.first'"

# tcpdump
alias sniff="sudo tcpdump -s0 -i eth0 -A"
alias couchgrep="sudo ngrep -W byline -d lo0 port 5984"
alias httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""

# ~~~~~ ditz
alias dt="ditz todo"
alias ds="ditz status"

# ~~~~~ git
alias gt="git status"
alias gb='git branch --color -v'
alias gd='git diff --color --ignore-space-at-eol'
alias gdi='git diff --color --ignore-space-at-eol --cached'
alias gds='git diff --stat'
alias gl="git log --graph --pretty=format:'%Cred%h%Creset - %Cblue[%an]%Creset%C(yellow)%d%Creset: %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
alias gls="git log --stat"
alias glm='git log --author="ssaasen" --pretty=format:"%Cblue%h%Creset %Cgreen%an%Creset %ad %s %n"'
alias gw="git whatchanged"
# Changelog style
alias glc="git log --abbrev-commit --pretty=medium "

# Show a short commit stat
alias gsa="git shortlog -n -s"
# For more stat info have a look at: git clone git://repo.or.cz/gitstats.git

# Show the commit that introduced a particular file
# Usage:
#  git-file-added ./path/to/file
alias git-file-added="git log --diff-filter=A --pretty=short -- "


# show current sha1 hash (abbreviated)
alias gh="git rev-parse --short HEAD"

alias gv="git describe --long"

# git show --stat COMMIT_ID
alias gss="git show --stat"

# show a version of a file - important PATH MUST be the full path from the repository root. Local path (from sub directory) does not work! 
# git show v1.4:src/main.c

# will use HEAD to produce a tar archive in which each filename is preceded by "latest/"
# use zcat latest.tar.gz | git get-tar-commit-id to get the embeded git id 
alias gar="git archive --format=tar --prefix=latest/ HEAD | gzip >latest.tar.gz"
# rebase -> origin/master
alias gr="git fetch -v origin && git rebase origin/master"
# Merge without commit to inspect changes/merge-result.
alias gm="git merge --no-commit"
alias gfp="git format-patch -p"

# Usage
# (1) git diff -p --raw 35AC1F > c.pat
# (2) patch -f -p 1 < c.pat
alias gp="git diff -p --raw"

# git reflog
alias grl="git reflog"

# Untrack a file (If you want to keep a file, but not have it in the next revision).
alias gun="git rm --cached"

# show git aliases
alias galias="git config --global --get-regexp alias"

# shows what will be pushed to a remote repos
alias gpd="git push --dry-run"


function git_blame_single_line {
  if [ $# -lt 2 ]; then
    echo "Usage:       git_blame_single_line PATTERN [ANCESTOR] FILE"
    echo ""
    echo "    example: git_blame_single_line \"class Test\" 14jk2k13^ ./path/to/file"
    echo ""
    return
  fi
  if [ $# -eq 2 ]; then
    git blame -M -C -L "/${1}/,+1" HEAD -- $2
  fi
  if [ $# -eq 3 ]; then
    git blame -M -C -L "/${1}/,+1" ${2} -- $3
  fi
}

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

alias gbl="git_blame_single_line"

# ~~~~~ Misc ~~~~~~~~
# show file header. Usage: fh test.db
alias fh="od -c -N 16 "

# Adds a site to an existing maven project.
# ! Should be run from inside a maven project. 
alias mvn-add-site="mvn archetype:create -DarchetypeArtifactId=maven-archetype-site"

function mvn-help {
  if [ ! $# == 1 ]; then
    echo "Usage:       mvn-help PLUGINNAME"
    echo ""
    echo "    example: mvn-help install"
    echo ""
    return
  fi
	mvn help:describe -Dplugin=$1
}

function mvn-create {
  if [ ! $# == 2 ]; then
    echo "Usage:       mvn-create GROUPID ARTIFACT ID"
    echo ""
    echo "    example: mvn-create com.coravy.jwddx jwddx"
    echo ""
    return
  fi
  #mvn archetype:create -DarchetypeGroupId=org.apache.maven.archetypes -DgroupId=$1 -DartifactId=$2
mvn archetype:generate -DarchetypeGroupId=com.coravy.archetypes -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.0-SNAPSHOT -DgroupId=$1 -DartifactId=$2
}

function mvn-create-webapp {
  if [ ! $# == 2 ]; then
    echo "Usage:       mvn-create-webapp GROUPID ARTIFACT ID"
    echo ""
    echo "    example: mvn-create-webapp com.coravy.web corporate"
    echo ""
    return
  fi
  mvn archetype:create -DarchetypeGroupId=org.apache.maven.archetypes -DarchetypeArtifactId=maven-archetype-webapp \
         -DgroupId=$1 -DartifactId=$2
}


function mvn-create-custom-archetype {
  if [ ! $# == 2 ]; then
    echo "Usage:       mvn-create-webapp GROUPID ARTIFACT ID"
    echo ""
    echo "    example: mvn-create-webapp com.coravy maven-archetype-standalone"
    echo ""
    return
  fi
  mvn archetype:create -DgroupId=$1 -DartifactId=$2 -DarchetypeArtifactId=maven-archetype-archetype
}

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


function f {
    find . -iname "*$1*"
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

function git-revert-last-commit {
    git branch __broken
    git revert HEAD
    git diff --binary master __broken > __broken.pat
    git apply < __broken.pat
    rm __broken.pat
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
