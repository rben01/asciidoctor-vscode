#!/bin/bash

red="\033[0;31m"
bold="\033[1m"
reset="\033[0m"


# Help text
help() {
  echo -e "AsciiDoc extension build script

  ${bold}-h${reset}, ${bold}--help${reset}, ${bold}help$reset
    show this help

  ${bold}build${reset}
    1. install local node dependencies
    2. install global node dependencies
    3. package the extension

  ${bold}npm${reset}
    1. install local node dependencies
    2. install global node dependencies

  ${bold}npm_local${reset}, ${bold}npm_local_deps${reset}
    1. install local node dependencies

  ${bold}npm_global${reset}, ${bold}npm_global_deps${reset}
    1. install global node dependencie

  ${bold}package${reset}
    1. package the extension

  ${bold}install${reset}
    1. install the extension\n"
}

# Exit if any operation fails
exitdialog() {
  echo -e "==> ${red}${bold}ERROR${reset}: build aborted"
  exit ${1:-1}
}

# Install node dependencies
npm_local_deps() {
  echo "==> Installing local dependencies"
  rm -f package-lock.json
  npm install || exitdialog $?
}

# Check status of vsce and typescript dependencies
npm_global_deps() {
  unset deps
  npm list -g vsce &>/dev/null || deps+=("vsce")
  npm list -g typescript &>/dev/null || deps+=("typescript")
  if [[ -n $deps ]] ; then
    echo "==> Installing global dependencies"
    npm install -g ${deps[@]} || exitdialog $?
  fi
}

# Package extension
package() {
  echo "==> Packaging extension"
  rm -f *.vsix
  rm -rf dist/
  rm -rf out/
  vsce package || exitdialog
}

# Install extension
install() {
  echo "==> Installing extension"
  code --install-extension *.vsix || exitdialog $?
}


# Move to project root
cd "$(dirname "$(readlink -fn "$0")")"/..

# Run help() if -h or --help or help have been used as argument
[[ -z $@ || $1 =~ (-h|--help|help) ]] && help && exit

# Run operations for each argument
while [[ $# > 0 ]] ; do
  case $1 in
    build)
      npm_local_deps || exitdialog $?
      npm_global_deps || exitdialog $?
      package || exitdialog $?
      ;;

    npm|npm_local|npm_local_deps)
      npm_local_deps || exitdialog $?
      ;;

    npm|npm_global|npm_global_deps)
      npm_global_deps || exitdialog $?
      ;;

    package)
      package || exitdialog $?
      ;;

    install)
      install || exitdialog $?
      ;;

    *)
      echo -e "==> ${red}${bold}ERROR${reset}: unknown argument '$1'"
      ;;
  esac
  shift
done
