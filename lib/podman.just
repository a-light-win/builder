podman_run := ('podman run --rm' +
               ' --env-host' +
               ' -v "' + invocation_directory() + ':' + invocation_directory() + '"' +
               ' -w "' + invocation_directory() + '"'
              )

[private, no-cd, script('bash'), positional-arguments]
podman_manifest tag *labels:
  podman manifest exists "{{ tag }}"
  if [ $? -eq 0 ]; then
    echo "Manifest {{ tag }} already exists, skipping"
    exit 0
  fi

  labels=("${@:2}")
  annotations=()
  for label in "${labels[@]}" ; do
    IFS='=' read -r key value <<< "$label"
    if [ -z "$key" ] || [ -z "$value" ]; then
      echo >&2 "Invalid label: $label"
      exit 1
    fi

    grep -q "[.]" <<< "$key"
    if [ $? -ne 0 ]; then
      key="org.opencontainers.image.$key"
    fi
    annotations+=("--annotation" "$key=$value")
  done

  echo "Creating manifest {{ tag }}"
  podman manifest create "${annotations[@]}" "{{ tag }}"

[private, no-cd, script('bash')]
podman_manifest_clean tag:
  podman manifest exists "{{ tag }}"
  if [ $? -ne 0 ]; then
    echo "Manifest {{ tag }} does not exist, skipping"
    exit 0
  fi
  podman manifest rm "{{ tag }}"
