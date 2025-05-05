#!/bin/bash

# Update packages database
apk update

# Installing git package
apk add git

# Installing openssh package
if [[ -n "${SSH_PRIVATE_KEY}" ]]; then
  apk add openssh
fi

# Install asdf-vm for tools' version management
ASDF_HOME=${WORKING_DIR}/.asdf

if [[ ! -f "${ASDF_HOME}/asdf.sh" ]]; then
  git clone https://github.com/asdf-vm/asdf.git \
      ${ASDF_HOME} --branch v0.14.0
fi

source ${ASDF_HOME}/asdf.sh

# Fix invalid cache to asdf tools' installation
ln -s ${ASDF_HOME} ${HOME}/.asdf

# Install ruby environment
apk add yaml-dev

# Manually specify the language version for C compilation for ruby-build
# to avoid error when building ruby and building ruby extensions.
# C23 by default in GCC15: https://gcc.gnu.org/gcc-15/changes.html#c
export RUBY_CFLAGS="-std=gnu17"

if ! asdf list ruby ${RUBY_VER} &>/dev/null; then
  # Clean up ruby environments avoiding unnecessary cache
  rm -rf ${ASDF_HOME}/installs/ruby
  asdf plugin add ruby
  asdf install ruby ${RUBY_VER}
fi

asdf global ruby ${RUBY_VER}

# debug
ruby -v && bundle version

# This is a temporary workaround
# See https://github.com/actions/checkout/issues/766
git config --global --add safe.directory "*"
