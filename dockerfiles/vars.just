default_archs := 'x86_64 aarch64'

builder_repository := 'ghcr.io/a-light-win/builder'
builder_source := 'source=https://github.com/a-light-win/builder'
builder_licenses := 'licenses=MIT'

debian_version := '12'
debian_release := ''
zig_version := '0.13.0'
zig_release := ''
nfpm_version := '2.39.0'
nfpm_release := ''

debian_tag := debian_version + debian_release
debian_image := builder_repository / 'debian'
debian_image_full := debian_image + ':' + debian_tag

zig_tag := zig_version + zig_release
zig_image := builder_repository / 'zig'
zig_image_full := zig_image + ':' + zig_tag

nfpm_tag := nfpm_version + nfpm_release
nfpm_image := builder_repository / 'nfpm'
nfpm_image_full := nfpm_image + ':' + nfpm_tag
