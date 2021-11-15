FROM alpine:latest

RUN apk --update add doxygen graphviz &&\
    rm -rf /var/cache/apk/*
    
CMD ["doxygen", "-v"]

WORKDIR /tmp
