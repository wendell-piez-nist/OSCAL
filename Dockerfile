FROM golang:alpine AS build
RUN apk add --no-cache git bash
RUN git clone https://github.com/github/hub.git
RUN cd hub && \
    script/build -o ~/hub

FROM node:9-alpine
RUN apk add --no-cache git libxml2 libxml2-utils
RUN npm install -g ajv-cli
COPY --from=build /root/hub /usr/local/bin/hub
WORKDIR /oscal
COPY . .

