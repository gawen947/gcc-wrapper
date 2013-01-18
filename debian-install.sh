#!/bin/sh
# What more than a stupid sh-script could install a stupid sh-script ?

if [ -f "/usr/bin/gcc.real" -o -f "/usr/bin/g++.real" ]
then
  echo "Already installed, update..."
  cp gcc-wrapper.sh /usr/local/bin/gcc-wrapper
  chmod a+rx /usr/local/bin/gcc-wrapper
else
  echo "Installing..."
  dpkg-divert --add --rename --divert "/usr/bin/gcc.real" "/usr/bin/gcc"
  dpkg-divert --add --rename --divert "/usr/bin/g++.real" "/usr/bin/g++"
  cp gcc-wrapper.sh /usr/local/bin/gcc-wrapper
  chmod a+rx /usr/local/bin/gcc-wrapper
  ln -s /usr/local/bin/gcc-wrapper /usr/bin/gcc
  ln -s /usr/local/bin/gcc-wrapper /usr/bin/g++
  mkdir /etc/gcc-wrapper
  cp default /etc/gcc-wrapper
fi
