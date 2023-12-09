FROM amazoncorretto:17-alpine

ARG RELEASE_VERSION="5.0.2"

RUN apk --no-cache add bash wget gzip

WORKDIR /app
RUN wget --progress=dot:giga "https://github.com/jeremylong/Open-Vulnerability-Project/releases/download/v${RELEASE_VERSION}/vulnz-${RELEASE_VERSION}.jar" && \
    mv "vulnz-${RELEASE_VERSION}.jar" "vulnz.jar"

COPY mirror.sh /app/mirror.sh
