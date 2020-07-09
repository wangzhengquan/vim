#!/bin/bash
OS=
install_prefix=
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
# check system
if which apt-get; then
  OS="ubuntu"
  install_prefix="sudo apt-get install -y"
  ##Add HomeBrew support on  Mac OS
elif which brew; then
  OS="mac"
  install_prefix="brew install"
fi

# $* install name list
check_install() {
  while [ "$1" != "" ]; do
    if test -z `which $1`; then
      $install_prefix $1
    else
      echo "$1 has already been exist"
    fi
    shift
  done
}

# $1 alias $2 install-name
check_install_by_alias() {
  while [ "$1" != "" ]; do
    if test -z `which $1`; then
      $install_prefix $2 
    fi
    shift 2
  done
}

echo "the system is $OS"
case "$OS" in
  ubuntu)
    sudo apt-get update
    sudo apt-get upgrade
    check_install build-essential cmake \
      git vim vim-gnome \
      python-setuptools python-dev python3-dev \
      ctags  xclip astyle \
      xdg-utils curl silversearcher-ag \
      openssl libssl-dev \
      openssh-server openssh-client

      #nodejs npm
    #sudo npm -g install instant-markdown-d
    ;;
  mac)
    if test -z `which brew`; then
      /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi 
    check_install cmake git vim \
      ctags astyle the_silver_searcher \
      
      #nodejs npm
    #npm -g install instant-markdown-d
    ;;
  *)
    echo "can't recognize the system flavor"
    exit 1
    ;;
esac


# sudo ln -s /usr/bin/ctags /usr/local/bin/ctags

# https://pypi.org/project/autopep8/0.5.2/
if test -z `which autopep8`; then
  sudo easy_install -ZU autopep8 
fi

if test "X$INSTALL_TYPE" != "Xupdate" ; then
  # install
  mv -f ~/.vim ~/.vim_old
  mv -f ~/.vimrc ~/.vimrc_old
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

cat >tmpinfo <<EOF
Installing......
Please wait patiently!
EOF
# vim tmpinfo -c "BundleInstall" -c "qa"
vim tmpinfo +PluginInstall +qall
rm tmpinfo

if [ "$YCMFULL" = "1" ]; then
  mkdir ~/vim_tmp && cd ~/vim_tmp
  LLVM_ROOT="clang_llvm"
  # istall libclang-based completer that provides semantic completion for C-family languages
  case "$OS" in
    ubuntu)
      wget -O clang_llvm.tar.xz  http://releases.llvm.org/6.0.0/clang+llvm-6.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz   
      ;;
    mac)
      wget -O clang_llvm.tar.xz  http://releases.llvm.org/6.0.0/clang+llvm-6.0.0-x86_64-apple-darwin.tar.xz.sig
      ;;
    *)
      echo "Don't support YCMFULL install"
      exit 1
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



echo "Finished!"
