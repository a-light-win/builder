podman_run := 'podman run --rm --env-host -v "' + invocation_directory() + ':' + invocation_directory() + '" -w "' + invocation_directory() + '"'

[private, no-cd, script('bash')]
podman_manifest tag source='' licenses='' description='':
  podman manifest exists "{{ tag }}"
  if [ $? -eq 0 ]; then
    echo "Manifest {{ tag }} already exists, skipping"
    exit 0
  fi

  annotations=()
  if [ -n "{{ source }}" ]; then
    annotations+=("--annotation" "org.opencontainers.image.source={{ source }}")
  fi
  if [ -n "{{ licenses }}" ]; then
    annotations+=("--annotation" "org.opencontainers.image.licenses={{ licenses }}")
  fi
  if [ -n "{{ description }}" ]; then
    annotations+=("--annotation" "org.opencontainers.image.description={{ description }}")
  fi

  podman manifest create "${annotations[@]}" "{{ tag }}"

[private, no-cd, script('bash')]
podman_manifest_clean tag:
  podman manifest exists "{{ tag }}"
  if [ $? -ne 0 ]; then
    echo "Manifest {{ tag }} does not exist, skipping"
    exit 0
  fi
  podman manifest rm "{{ tag }}"
