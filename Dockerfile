ARG image

FROM ${image}

ARG setup
ARG configurations

ARG datadir=/usr/local/share
ARG prefix=/opt/vim

RUN eval "${setup}"

WORKDIR /root

RUN git config --global user.name sasaplus1 && \
  git config --global user.email '<>'

RUN git clone --depth 1 https://github.com/koron/guilt.git && \
  git clone --depth 1 https://github.com/koron/vim-kaoriya.git

RUN cd ./vim-kaoriya && \
  git submodule update --depth 1 --init --recommend-shallow --recursive -- ./contrib/vimdoc-ja ./patches ./vim

RUN cd ./guilt && \
  make -j $(nproc) PREFIX=/opt/guilt install

ENV PATH /opt/guilt/bin:${PATH}

RUN cd ./vim-kaoriya/vim && \
  git checkout -b v$(printf -- '%b' 'all:\n\t@printf -- $(VIM_VER)' | make -f ../VERSION -f -) && \
  git config --local guilt.patchesdir ../patches && \
  guilt init
RUN cd ./vim-kaoriya && \
  cp ./patches/master/* ./patches/v$(printf -- '%b' 'all:\n\t@printf -- $(VIM_VER)' | make -f ./VERSION -f -)
RUN cd ./vim-kaoriya/vim/src && \
  guilt push --all && \
  make -j $(nproc) autoconf

RUN cd ./vim-kaoriya/vim && \
  eval "./configure --prefix=${prefix} ${configurations}" && \
  make -j $(nproc) DATADIR=${datadir} && \
  make install

RUN make -C ./vim-kaoriya/build/xubuntu VIM_DIR="${prefix}/share/vim" install

RUN cp -rf ./vim-kaoriya/contrib/vimdoc-ja "${prefix}/share/vim/plugins"

RUN printf -- '\n\n%s\n' "PATH=${prefix}/bin:\$PATH" >> ${HOME}/.bashrc

ENV PATH ${prefix}/bin:${PATH}

RUN cd /opt && \
  tar cfz vim.tar.gz vim && \
  mv vim.tar.gz /tmp
