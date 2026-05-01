#!/usr/bin/env bash

set -oue pipefail

#################################
# Kernel module
#################################
dnf install -y --setopt=install_weak_deps=False "kernel-devel-matched"

dnf install -y --setopt=install_weak_deps=False akmods gcc-c++
cp /usr/sbin/akmodsbuild /usr/sbin/akmodsbuild.backup
# TODO remove this when fixed upstream
sed -i '/if \[\[ -w \/var \]\] ; then/,/fi/d' /usr/sbin/akmodsbuild
dnf copr -y enable hikariknight/looking-glass-kvmfr
dnf install -y --setopt=install_weak_deps=False kvmfr-kmod
mv /usr/sbin/akmodsbuild.backup /usr/sbin/akmodsbuild

echo "Installing kmod..."
akmods --force --kmod "kvmfr"

