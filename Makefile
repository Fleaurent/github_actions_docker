.PHONY: hello build_image create_config doxygen

hello:
	@echo "hello"

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

