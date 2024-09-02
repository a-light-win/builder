
# Package the application using nfpm
[private, no-cd, script('bash')]
nfpm-pack arch: && \
  (nfpm-pack-one 'deb' arch) \
  (nfpm-pack-one 'rpm' arch) \
  (nfpm-pack-one 'archlinux' arch) \
  (nfpm-pack-one 'apk' arch)
  source "{{ builtin_bash_functions }}"
  nfpm-pre-pack

# Clean the nfpm artifacts
[private, no-cd, script('bash')]
nfpm-clean:
  source "{{ builtin_bash_functions }}"
  nfpm-clean

[private, no-cd, script('bash')]
nfpm-pack-one packager arch:
  source "{{ builtin_bash_functions }}"
  nfpm-pack "{{ packager }}" "{{ arch }}"
