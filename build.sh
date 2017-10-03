#!/bin/sh

################################################################################
# External tools
################################################################################

MARKDOWN=/usr/bin/markdown
WINE=/usr/bin/wine
PERL=/usr/bin/perl

################################################################################
# Directories
################################################################################

SDK_DIR=sdk
DIST_DIR=dist

################################################################################
# LOVE configuration
################################################################################

LOVE_VERSION=0.10.2

################################################################################
# Game configuration
################################################################################

GAME_CODE=tower-quest
GAME_TITLE="Tower Quest: The Unfinished Journey"
GAME_VERSION=0.11.1
GAME_SOURCES="*.lua engine game graphics levels libraries music sounds"
GAME_README=README.md
GAME_LICENSE=LICENSE.txt
GAME_ICO=graphics/icon.ico
GAME_LOVE=$DIST_DIR/$GAME_CODE.love
GAME_WIN64_EXE=$DIST_DIR/$GAME_CODE.exe
GAME_MACOSX_ID=com.evilnote4d.towerquest
GAME_MACOSX_APP=$DIST_DIR/$GAME_CODE.app
GAME_MACOSX_INFO=$GAME_MACOSX_APP/Contents/Info.plist

################################################################################
# Release configuration
################################################################################

RELEASE_DIR_NAME=$GAME_CODE
RELEASE_DIR=$DIST_DIR/$RELEASE_DIR_NAME
RELEASE_LICENSE=$RELEASE_DIR/$GAME_LICENSE
RELEASE_README=$RELEASE_DIR/$GAME_README
RELEASE_README_HTML_ENABLED=true
RELEASE_README_HTML=$RELEASE_DIR/README.html
RELEASE_LOVE_ENABLED=true
RELEASE_LOVE_ZIP=$GAME_CODE-$GAME_VERSION.zip
RELEASE_WIN64_ENABLED=true
RELEASE_WIN64_ZIP=$GAME_CODE-$GAME_VERSION-win64.zip
RELEASE_MACOSX_ENABLED=true
RELEASE_MACOSX_ZIP=$GAME_CODE-$GAME_VERSION-macosx.zip

################################################################################
# Win64 SDK configuration
################################################################################

WIN64_SDK_NAME=love-$LOVE_VERSION-win64
WIN64_SDK_ZIP_NAME=$WIN64_SDK_NAME.zip
WIN64_SDK_ZIP=$SDK_DIR/$WIN64_SDK_ZIP_NAME
WIN64_SDK_DIR=$SDK_DIR/$WIN64_SDK_NAME
WIN64_SDK_URL=https://bitbucket.org/rude/love/downloads/$WIN64_SDK_ZIP_NAME
WIN64_SDK_LICENSE=$WIN64_SDK_DIR/license.txt
WIN64_SDK_SOURCES="$WIN64_SDK_DIR/*.dll"

################################################################################
# Max OS X SDK configuration
################################################################################

MACOSX_SDK_NAME=love-$LOVE_VERSION-macosx-x64
MACOSX_SDK_ZIP_NAME=$MACOSX_SDK_NAME.zip
MACOSX_SDK_ZIP=$SDK_DIR/$MACOSX_SDK_ZIP_NAME
MACOSX_SDK_DIR=$SDK_DIR/$MACOSX_SDK_NAME
MACOSX_SDK_URL=https://bitbucket.org/rude/love/downloads/$MACOSX_SDK_ZIP_NAME

################################################################################
# Resource Hacker configuration
################################################################################

RESHACKER_ENABLED=true
RESHACKER_ZIP_NAME=resource_hacker.zip
RESHACKER_ZIP=$SDK_DIR/$RESHACKER_ZIP_NAME
RESHACKER_DIR=$SDK_DIR/resource_hacker
RESHACKER_URL=http://www.angusj.com/resourcehacker/$RESHACKER_ZIP_NAME
RESHACKER_EXE=$RESHACKER_DIR/ResourceHacker.exe

################################################################################
# Generic helpers
################################################################################

print_section() {
  echo
  echo "===[ $1 ]==="
  echo
}

################################################################################
# SDK helpers
################################################################################

download_win64_sdk() {
  if [ ! -d $WIN64_SDK_DIR ]; then
    mkdir -p $SDK_DIR
    if [ ! -f $WIN64_SDK_ZIP ]; then
      echo "Downloading LOVE Win64 SDK"
      wget -q -P $SDK_DIR $WIN64_SDK_URL
    fi
    echo "Extracting LOVE Win64 SDK"
    unzip -q -d $SDK_DIR $WIN64_SDK_ZIP
  fi
  echo "LOVE Win64 SDK location: $WIN64_SDK_DIR"
}

download_macosx_sdk() {
  if [ ! -d $MACOSX_SDK_DIR ]; then
    mkdir -p $SDK_DIR
    if [ ! -f $MACOSX_SDK_ZIP ]; then
      echo "Downloading LOVE Mac OS X SDK"
      wget -q -P $SDK_DIR $MACOSX_SDK_URL
    fi
    echo "Extracting LOVE Mac OS X SDK"
    unzip -q -d $MACOSX_SDK_DIR $MACOSX_SDK_ZIP
  fi
  echo "LOVE Mac OS X SDK location: $MACOSX_SDK_DIR"
}

################################################################################
# Resource Hacker helpers
################################################################################

download_reshacker() {
  if [ ! -d $RESHACKER_DIR ]; then
    mkdir -p $SDK_DIR
    if [ ! -f $RESHACKER_ZIP ]; then
    echo "Downloading Resource Hacker"
      wget -q -P $SDK_DIR $RESHACKER_URL
    fi
    echo "Extracting Resource Hacker"
    unzip -q -d $RESHACKER_DIR $RESHACKER_ZIP
  fi
  echo "Resource Hacker location: $RESHACKER_DIR"
}

reshacker() {
  WINEDEBUG=fixme-all $WINE $RESHACKER_EXE "$@"
}

################################################################################
# Release helpers
################################################################################

clean_release_dir() {
  echo "Cleaning $RELEASE_DIR directory"
  rm -rf $RELEASE_DIR
  mkdir $RELEASE_DIR
}

copy_release_text_file() {
  if [ -x $PERL ]; then
    # Convert LF newlines to CRLF newlines
    $PERL -p -e 's/\n/\r\n/' < "$1" > "$RELEASE_DIR/$1"
  else
    cp "$1" "$RELEASE_DIR/$1"
  fi
}

copy_release_sources() {
  echo "Copying sources to $RELEASE_DIR directory"
  copy_release_text_file $GAME_LICENSE
  copy_release_text_file "CREDITS.txt"
  copy_release_text_file "CHANGES.txt"
}

write_release_readme_html() {
  echo "$1" >> $RELEASE_README_HTML
}

build_release_readme_html() {
  echo "Building HTML readme $RELEASE_README_HTML"
  rm -rf $RELEASE_README_HTML
  write_release_readme_html "<!DOCTYPE html>"
  write_release_readme_html "<html>"
  write_release_readme_html "<head>"
  write_release_readme_html "<meta charset=\"UTF-8\">"
  write_release_readme_html "<title>$GAME_TITLE</title>"
  write_release_readme_html "<style>"
  write_release_readme_html "html { font-family: sans-serif; }"
  write_release_readme_html "body { max-width: 768px; margin: 0 auto; }"
  write_release_readme_html "code { padding: 0 0.2em; border-radius: 0.2em; background: #eee; }"
  write_release_readme_html "</style>"
  write_release_readme_html "</head>"
  write_release_readme_html "<body>"
  $MARKDOWN --html4tags $GAME_README >> $RELEASE_README_HTML
  write_release_readme_html "</body>"
  write_release_readme_html "</html>"
}

copy_release_readme() {
  echo "Creating $RELEASE_README"
  cp $GAME_README $RELEASE_README
}

build_release_readme() {
  if [ "$(basename "$GAME_README" .md)" != "$GAME_README" ]; then
    if [ $RELEASE_README_HTML_ENABLED = "true" ]; then
      if [ -x $MARKDOWN ]; then
        build_release_readme_html
      else
        echo "Cannot build HTML readme: No $MARKDOWN executable found"
        copy_release_readme
      fi
    else
      echo "HTML readme build disabled"
    fi
  else
    copy_release_readme
  fi
}

build_release_dir() {
  clean_release_dir
  copy_release_sources
  build_release_readme
}

zip_release_dir() {
  echo "Building $1"
  cd $DIST_DIR || return
  rm -f "$1"
  zip -qr "$1" $RELEASE_DIR_NAME
  cd ..
}

################################################################################
# LOVE release
################################################################################

build_love() {
  echo "Building $GAME_LOVE"
  mkdir -p $DIST_DIR
  rm -f $GAME_LOVE
  zip -qr $GAME_LOVE $GAME_SOURCES
}

build_love_release() {
  build_release_dir
  cp $GAME_LOVE $RELEASE_DIR
  zip_release_dir $RELEASE_LOVE_ZIP
}

################################################################################
# Win64 release
################################################################################

override_win64_exe_icon() {
  echo "Overriding $GAME_WIN64_EXE icon with $GAME_ICO"
  reshacker -delete $GAME_WIN64_EXE, $GAME_WIN64_EXE, ICONGROUP, 1,
  reshacker -addoverwrite $GAME_WIN64_EXE, $GAME_WIN64_EXE, $GAME_ICO, ICONGROUP, MAINICON, 0
}

build_win64_exe() {
  echo "Building $GAME_WIN64_EXE"
  rm -f $GAME_WIN64_EXE
  cat $WIN64_SDK_DIR/love.exe $GAME_LOVE > $GAME_WIN64_EXE
  if [ $RESHACKER_ENABLED = "true" ]; then
    if [ -x $WINE ]; then
      download_reshacker
      override_win64_exe_icon
    else
      echo "Cannot override $GAME_WIN64_EXE icon: No $WINE executable found"
    fi
  else
    echo "Resource Hacker disabled"
  fi
}

update_win64_release_license() {
  echo "Updating $RELEASE_LICENSE with $WIN64_SDK_LICENSE"
  printf "\r\n---------\r\n\r\n" >> "$RELEASE_LICENSE"
  cat $WIN64_SDK_LICENSE >> "$RELEASE_LICENSE"
}

build_win64_release() {
  build_win64_exe
  build_release_dir
  update_win64_release_license
  cp $GAME_WIN64_EXE $RELEASE_DIR
  cp $WIN64_SDK_SOURCES $RELEASE_DIR
  zip_release_dir $RELEASE_WIN64_ZIP
}

################################################################################
# Mac OS X release
################################################################################

update_macosx_info() {
  echo "Updating $GAME_MACOSX_INFO"
  sed -i "s/<string>org\.love2d\.love<\/string>/<string>$GAME_MACOSX_ID<\/string>/; s/<string>LÖVE<\/string>/<string>$GAME_TITLE<\/string>/" $GAME_MACOSX_INFO
  grep -B 999 "<key>UTExportedTypeDeclarations</key>" $GAME_MACOSX_INFO > $GAME_MACOSX_INFO.tmp
  grep -v "<key>UTExportedTypeDeclarations</key>" $GAME_MACOSX_INFO.tmp > $GAME_MACOSX_INFO
  { echo "</dict>"; echo "</plist>"; } >> $GAME_MACOSX_INFO
  rm $GAME_MACOSX_INFO.tmp
}

build_macosx_app() {
  echo "Building $GAME_MACOSX_APP"
  rm -rf $GAME_MACOSX_APP
  cp -r $MACOSX_SDK_DIR/love.app $GAME_MACOSX_APP
  cp $GAME_LOVE $GAME_MACOSX_APP/Contents/Resources/
  update_macosx_info
}

build_macosx_release() {
  build_macosx_app
  build_release_dir
  cp -r $GAME_MACOSX_APP $RELEASE_DIR
  zip_release_dir $RELEASE_MACOSX_ZIP
}

################################################################################
# Build
################################################################################

print_section "LOVE file"
build_love

print_section "LOVE release"

if [ $RELEASE_LOVE_ENABLED = "true" ]; then
  build_love_release
else
  echo "Disabled"
fi

print_section "Win64 release"

if [ $RELEASE_WIN64_ENABLED = "true" ]; then
  download_win64_sdk
  build_win64_release
else
  echo "Disabled"
fi

print_section "Mac OS X release"

if [ $RELEASE_MACOSX_ENABLED = "true" ]; then
  download_macosx_sdk
  build_macosx_release
else
  echo "Disabled"
fi

echo
