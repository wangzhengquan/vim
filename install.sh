#!/bin/bash
#OS=
install="apt-get"
ORIGDIR=$(pwd)

# check arguments
until [ $# -eq 0 ]
do
  case "$1" in
    --YCMFULL | --YCMFULL=1) YCMFULL=1 ;;
    update) INSTALL_TYPE=update ;;
  esac
  shift
done

echo "installing will take a long time, please wait patiently ^_^"

function systype() {

  case `uname -s` in
  "FreeBSD")
    PLATFORM="freebsd"
    ;;
  "Linux")
    PLATFORM="linux"
    ;;
  "Darwin")
    PLATFORM="macos"
    ;;
  "SunOS")
    PLATFORM="solaris"
    ;;
  *)
    echo "Unknown platform" >&2
    return 1
  esac

  if [ "$PLATFORM"=="linux" ]; then
    if [ "$(cat /proc/version | grep "Red Hat")" ]; then
      PLATFORM="redhat"
    elif [ "$(cat /proc/version | grep "Ubuntu")" ]; then
      PLATFORM="ubuntu"
    elif [ "$(cat /proc/version | grep "debian")" ]; then
      PLATFORM="debian"
    else
      echo "Unknown platform" >&2
      return 1
    fi
  fi
  echo $PLATFORM
  return 0
}


OS=`systype`

echo "The operating system is $OS"
# args: install name list
check_install() {
  while [ "$1" != "" ]; do
    if test -z `which $1`; then
      $install $1
    else
      echo "$1 has already been installed."
    fi
    shift
  done
}

# arg1: alias, arg2: install-name
check_install_by_alias() {
  while [ "$1" != "" ]; do
    if test -z `which $1`; then
      $install $2 
    else
      echo "$1 has already been installed."
    fi
    shift 2
  done
}

echo ">>> Install required programe"

case $OS in
  "ubuntu")
    install="sudo apt-get install -y"
    sudo apt-get update -y
    sudo apt-get upgrade -y
    # sudo apt install -y build-essential cmake gdb
    # cscope : https://cscope.sourceforge.net/
    $install ctags cscope xclip astyle \
      xdg-utils  silversearcher-ag 

   # sudo apt install -y  vim vim-gnome 
   # sudo apt-get install -y qemu libvirt-bin
   # sudo apt install -y  openssl libssl-dev 
   # sudo apt install -y openssh-server openssh-client
   # sudo apt install -y python-setuptools python-dev python3-dev
   # sudo apt install -y git curl
    #nodejs
    #sudo npm -g install instant-markdown-d
    ;;
  "debian")
   install="sudo apt install -y"
   sudo apt install -y  build-essential gcc linux-headers-$(uname -r) aptitude
   ;;
  "mac")
    install="brew install"
    check_install cmake git \
      ctags astyle the_silver_searcher
    ;;
  "redhat")
    install="yum install -y"
    # yum  -y update
    yum install kernel-headers kernel-devel gcc gcc-c++ make autoconf automake -y
    
    ;;
  *)
    echo "can't recognize the system flavor"
    ;;
esac


# sudo ln -s /usr/bin/ctags /usr/local/bin/ctags

# https://pypi.org/project/autopep8/0.5.2/
if test -z `which autopep8`; then
  sudo easy_install -ZU autopep8 
fi



if test "X$INSTALL_TYPE" != "Xupdate" ; then
  echo ">>> Download vim plugin"
  # install
  [ -d ~/.vim ] && mv -f ~/.vim ~/.vim_`date +%F_%T`
  [ -f ~/.vimrc ] && mv -f ~/.vimrc ~/.vimrc_`date +%F_%T`
  git clone --depth=1 https://github.com/wangzhengquan/vim.git ~/.vim
  mv -f ~/.vim/vimrc ~/.vimrc
  mv -f ~/.vim/vimrc.bundle ~/.vimrc.bundle
  # git clone --depth=1  ~/.vim/bundle/
  git clone --depth=1 https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  git clone --depth=1 https://github.com/scrooloOSe/nerdtree.git ~/.vim/bundle/nerdtree
  git clone --depth=1 https://github.com/powerline/powerline.git ~/.vim/bundle/powerline
  git clone --depth=1 https://github.com/ctrlpvim/ctrlp.vim.git ~/.vim/bundle/ctrlp.vim
  git clone --depth=1 https://github.com/tomasr/molokai.git ~/.vim/bundle/molokai
  git clone --depth=1 https://github.com/mileszs/ack.vim.git ~/.vim/bundle/ack.vim
  git clone --depth=1 https://github.com/godlygeek/tabular.git ~/.vim/godlygeek/tabular
else
  # update
  echo "update..."
fi

cat > tmpinfo << EOF
Installing......
Please wait patiently!
EOF

# vim tmpinfo -c "BundleInstall" -c "qa"
vim tmpinfo +PluginInstall +qall

echo $? End

# if [ $? = 0 ]; then
#   echo "Success!"
# else
#   echo "Failture!"
# fi

rm -f tmpinfo

if [ "$YCMFULL" = "1" ]; then
  echo ">>> Install libclang-based completer that provides semantic completion for C-family languages"
  mkdir ~/vim_tmp && cd ~/vim_tmp
  LLVM_ROOT="clang_llvm"
  case "$OS" in
    "ubuntu")
      wget -O clang_llvm.tar.xz  http://releases.llvm.org/6.0.0/clang+llvm-6.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz   
      ;;
    "redhat")
      ;;
    "mac")
      wget -O clang_llvm.tar.xz  http://releases.llvm.org/6.0.0/clang+llvm-6.0.0-x86_64-apple-darwin.tar.xz.sig
      ;;
    *)
      echo "Don't support YCMFULL install"
      ;;
  esac
  tar -zxvf clang_llvm.tar.xz

  mkdir ycm_build && cd ycm_build
  cmake -G "Unix Makefiles" -DPATH_TO_LLVM_ROOT=$LLVM_ROOT . ~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp
  cmake --build . --target ycm_core --config Release

  cd $ORIGDIR
  rm -rf ~/vim_tmp
#else
#  ~/.vim/bundle/YouCompleteMe/install.py --clang-completer
fi


