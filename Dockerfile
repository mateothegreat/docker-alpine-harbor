#
#
#
FROM alpine:3.6

ARG IMAGE_BUILD_DATE
ARG IMAGE_VERSION
LABEL build="Image-Version:- ${IMAGE_VERSION} Image-Build-Date: ${IMAGE_BUILD_DATE}"

RUN apk --update --no-cache \
        --virtual build-dependencies add \
        curl wget sudo util-linux 

COPY src /

#WORKDIR /home/alpine
#USER alpine
# ENTRYPOINT ["docker-entrypoint.sh"]
# CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]