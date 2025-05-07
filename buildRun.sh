# Build the image (in the directory with your Containerfile)
podman build -t sf3000-dev .

# Launch a shell, with your current directory mounted at /workspace
podman run --rm -it \
  --userns=keep-id  \
  -v "$(pwd)":/workspace:z \
  sf3000-dev
