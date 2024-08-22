set unstable := true

# build a multi-arch image for zig
[script('bash')]
build version: (build-all version)
  podman manifest exists builder/zig:{{ version }}
  if [ $? -ne 0 ]; then
    podman manifest create builder/zig:{{ version }}
  fi

# clean up docker image of zig by version
[script('bash')]
clean version:
  podman manifest exists builder/zig:{{ version }}
  if [ $? -eq 0 ]; then
    podman manifest rm builder/zig:{{ version }}
  fi

[private]
build-all version: (build-zig version 'x86_64' 'linux') \
  (build-zig version 'aarch64' 'linux')

[private, script('bash')]
build-zig version arch platform: (download-zig version arch platform)
  podman build --platform {{ platform }}/{{ arch }} \
    --manifest=builder/zig:{{ version }} \
    --build-arg PLATFORM={{ platform }} \
    --build-arg ARCH={{ arch }} \
    --build-arg VERSION={{ version }} . 

[private, script('bash')]
download-zig version arch platform:
  name=zig-{{ platform }}-{{ arch }}-{{ version }}

  if [ -e "${name}" ] ; then
    echo "Already downloaded ${name}"
    exit 0
  fi

  curl -L -o ${name}.tar.xz https://ziglang.org/download/{{ version }}/${name}.tar.xz || exit 1
  tar xf ${name}.tar.xz
