.PHONY: hello build_image create_config doxygen

hello:
	echo "hello"

build_image:
	docker build -t doxygen_image .

create_config:
	docker run --rm -v $(pwd):/tmp doxygen_image doxygen -g
	
doxygen:
	docker run --rm -v $(pwd):/tmp doxygen_image doxygen Doxyfile
