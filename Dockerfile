FROM alpine:3.19 as build-stage

ENV \
  IDE_USER=ide \
  IDE_HOME=/jasonben/ide

ENV \
  HOME=$IDE_HOME \
  TERM=tmux-256color \
  LANG=C.UTF-8 \
  SHELL=/bin/zsh \
  EDITOR=vim \
  GOPATH=$IDE_HOME/go

ENV \
  GOPATH_BIN="$GOPATH/bin"

ENV \
  PATH="$GOPATH_BIN:$PATH"

# hadolint ignore=DL4006,DL3018
RUN \
  echo "%%%%%%%%%%%%%%===> System: Installing build deps" && \
  apk add --no-cache \
  autoconf \
  automake \
  binutils-gold \
  build-base \
  ca-certificates \
  doas \
  ffmpeg \
  file \
  g++ \
  gcc \
  gcompat \
  glib-dev \
  gnupg \
  jpeg \
  libffi-dev \
  libgcc \
  libgit2 \
  libjpeg-turbo-dev \
  libpq \
  libstdc++ \
  libtool \
  libxml2-dev \
  libxslt-dev \
  linux-headers \
  make \
  mariadb-dev \
  musl-dev \
  nasm \
  ncurses \
  pacman \
  pkgconf \
  poppler \
  postgresql-client \
  postgresql-dev \
  py3-pip \
  py3-pygit2 \
  py3-setuptools \
  py3-wheel \
  python3-dev \
  ruby-dev \
  shadow \
  sqlite-dev \
  tiff \
  tzdata \
  unixodbc-dev=2.3.12-r0 \
  vips-dev \
  yaml-dev \
  zlib \
  zlib-dev \
  && \
  apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/community \
  go \
  && \
  echo "%%%%%%%%%%%%%%===> System: Done installing apps" && \
  echo "%%%%%%%%%%%%%%===> System: Configuring settings" && \
  echo "%%%%%%%%%%%%%%===> System: Changing timezone to US/Central" && \
  cp /usr/share/zoneinfo/US/Central /etc/localtime && \
  echo "US/Central" > /etc/timezone \
  && \
  echo "%%%%%%%%%%%%%%===> System: Creating new user: '$IDE_USER'" && \
  addgroup -g 1000 -S $IDE_USER && \
  mkdir -p $IDE_HOME && \
  adduser -D -u 1000 -G $IDE_USER -S $IDE_USER -h $IDE_HOME && \
  usermod -s /bin/zsh $IDE_USER && \
  echo "$IDE_USER:password" | chpasswd && \
  chown -R "$IDE_USER:$IDE_USER" $IDE_HOME && \
  mkdir -p /etc/doas.d && \
  echo "permit nopass $IDE_USER as root" > /etc/doas.d/doas.conf && \
  chown -c root:root /etc/doas.d/doas.conf && \
  chmod -c 0400 /etc/doas.d/doas.conf && \
  echo "%%%%%%%%%%%%%%===> Ruby: Ignore ri and rdoc" && \
  touch "$IDE_HOME/.gemrc" && \
  echo 'gem: --no-document' >> "$IDE_HOME/.gemrc" && \
  echo "%%%%%%%%%%%%%%===> Tmux: Generate tmux-256color TERM" && \
  infocmp -x tmux-256color > tmux-256color.src && \
  /usr/bin/tic -x tmux-256color.src

USER $IDE_USER
WORKDIR $IDE_HOME

RUN \
  echo "%%%%%%%%%%%%%%===> Go: Configuring folders" && \
    mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH" \
          && \
  echo "%%%%%%%%%%%%%%===> Go: Installing packages" && \
  echo "%%%%%%%%%%%%%%===> Go: jqp" && \
    go install github.com/noahgorstein/jqp@latest \
          && \
  echo "%%%%%%%%%%%%%%===> Go: sqls" && \
    go install github.com/sqls-server/sqls@latest \
          && \
  echo "%%%%%%%%%%%%%%===> Go: gron" && \
    go install github.com/tomnomnom/gron@latest \
          && \
  echo "%%%%%%%%%%%%%%===> Go: glow" && \
    go install github.com/charmbracelet/glow@latest \
          && \
  echo "%%%%%%%%%%%%%%===> Go: usql" && \
    go install -tags 'most no_duckdb sqlite_app_armor sqlite_fts5 sqlite_introspect sqlite_json1 sqlite_math_functions sqlite_stat4 sqlite_userauth sqlite_vtable odbc adodb godror csvq sqlserver mysql postgres clickhouse' github.com/xo/usql@v0.19.1 \
          && \
  echo "%%%%%%%%%%%%%%===> Go: ultimate plumber" && \
    go install github.com/akavel/up@master \
          && \
  echo "%%%%%%%%%%%%%%===> Go: lazygit" && \
    go install github.com/jesseduffield/lazygit@latest \
    && \
    go clean -cache && \
    doas rm -rf "$GOPATH/src" && \
    doas rm -rf "$GOPATH/pkg" && \
    doas rm -rf "$IDE_HOME/.cache" \
          && \
  echo "%%%%%%%%%%%%%%===> Go: gitmux" && \
    go install github.com/arl/gitmux@latest \
          && \
  echo "%%%%%%%%%%%%%%===> Done"

FROM alpine:3.19

COPY --from=build-stage /jasonben/ide/go /jasonben/ide/go
