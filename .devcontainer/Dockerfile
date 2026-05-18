FROM mcr.microsoft.com/devcontainers/cpp:2-ubuntu24.04

ARG REINSTALL_CMAKE_VERSION_FROM_SOURCE="3.29.0"

# Optionally install the cmake for vcpkg
COPY ./reinstall-cmake.sh /tmp/

RUN if [ "${REINSTALL_CMAKE_VERSION_FROM_SOURCE}" != "none" ]; then \
        chmod +x /tmp/reinstall-cmake.sh && /tmp/reinstall-cmake.sh ${REINSTALL_CMAKE_VERSION_FROM_SOURCE}; \
    fi \
    && rm -f /tmp/reinstall-cmake.sh

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        ninja-build \
        clang \
        clang-tidy \
        clang-format \
        lld \
        lldb \
        libc++-18-dev \
        libc++abi-18-dev \
        libclang-rt-18-dev \
        clangd-18 \
        llvm-18 \
        binutils-dev \
        libdw-dev \
        libdwarf-dev \
        libelf-dev \
        curl \
        ca-certificates \
    && update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 \
    && update-alternatives --set cc /usr/bin/clang \
    && update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++ 100 \
    && update-alternatives --set c++ /usr/bin/clang++ \
    && update-alternatives --install /usr/bin/ld ld /usr/bin/ld.lld 100 \
    && update-alternatives --set ld /usr/bin/ld.lld \
    && update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-18 100 \
    && update-alternatives --set clangd /usr/bin/clangd-18 \
    && update-alternatives --install /usr/bin/llvm-symbolizer llvm-symbolizer /usr/bin/llvm-symbolizer-18 100 \
    && update-alternatives --set llvm-symbolizer /usr/bin/llvm-symbolizer-18 \
    && update-alternatives --install /usr/bin/llvm-cov llvm-cov /usr/bin/llvm-cov-18 100 \
    && update-alternatives --set llvm-cov /usr/bin/llvm-cov-18 \
    && update-alternatives --install /usr/bin/llvm-profdata llvm-profdata /usr/bin/llvm-profdata-18 100 \
    && update-alternatives --set llvm-profdata /usr/bin/llvm-profdata-18 \
    && rm -rf /var/lib/apt/lists/*

ENV CC=clang
ENV CXX=clang++

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

RUN uv pip install --system --break-system-packages cmake-format

USER vscode
ENV NVM_DIR=/home/vscode/.nvm

RUN mkdir -p $NVM_DIR \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install --lts \
    && nvm alias default 'lts/*' \
    && nvm use default

RUN echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc \
    && echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc

USER root
