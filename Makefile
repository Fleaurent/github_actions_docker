# Hint: Make sure to login to GitHub Container Registry before executing the commands below
# docker login ghcr.io -> use your GitHub username and a personal access token

.PHONY: help build_image create_config doxygen

help:
    @echo "Available commands:"
    @echo "  build_image    - Builds the Docker image named 'doxygen_image'"
    @echo "  publish_image  - Builds, tags, and pushes the Docker image to GitHub Container Registry"
    @echo "  create_config  - Generates a default Doxygen configuration file"
    @echo "  doxygen        - Runs Doxygen using the Doxyfile configuration"
    @echo "  help           - Displays this help message"

build_image:
	docker build -t doxygen_image .
	
publish_image:
	make build_image
	docker tag doxygen_image:latest ghcr.io/fleaurent/doxygen_image:latest
	docker push ghcr.io/fleaurent/doxygen_image:latest
	
create_config:
	docker run --rm -v $(pwd):/tmp doxygen_image doxygen -g
	
doxygen:
	docker run --rm -v $(pwd):/tmp doxygen_image doxygen Doxyfile

