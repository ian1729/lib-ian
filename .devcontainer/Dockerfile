FROM mcr.microsoft.com/devcontainers/cpp:2-ubuntu24.04

ARG REINSTALL_CMAKE_VERSION_FROM_SOURCE="3.29.0"

# Optionally install the cmake for vcpkg
COPY ./reinstall-cmake.sh /tmp/

RUN if [ "${REINSTALL_CMAKE_VERSION_FROM_SOURCE}" != "none" ]; then \
        chmod +x /tmp/reinstall-cmake.sh && /tmp/reinstall-cmake.sh ${REINSTALL_CMAKE_VERSION_FROM_SOURCE}; \
    fi \
    && rm -f /tmp/reinstall-cmake.sh

# Install C/C++ toolchain: clang, clang-tidy, clang-format, lld, lldb, ninja
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        ninja-build \
        clang \
        clang-tidy \
        clang-format \
        lld \
        lldb \
    && update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 \
    && update-alternatives --set cc /usr/bin/clang \
    && update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++ 100 \
    && update-alternatives --set c++ /usr/bin/clang++ \
    && update-alternatives --install /usr/bin/ld ld /usr/bin/ld.lld 100 \
    && update-alternatives --set ld /usr/bin/ld.lld \
    && rm -rf /var/lib/apt/lists/*

ENV CC=clang
ENV CXX=clang++

# Install uv (Python package manager)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Install cmake-format via uv (system-wide)
RUN uv pip install --system --break-system-packages cmake-format

# Install nvm + latest LTS Node for the vscode user
USER vscode
ENV NVM_DIR=/home/vscode/.nvm
ENV NODE_VERSION=lts/*

RUN mkdir -p $NVM_DIR \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install --lts \
    && nvm alias default 'lts/*' \
    && nvm use default

# Ensure nvm is loaded in interactive shells
RUN echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc \
    && echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc

USER root
