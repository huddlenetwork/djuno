# To build the DJuno image, just run:
# > docker build -t djuno .
#
# In order to work properly, this Docker container needs to have a volume that:
# - as source points to a directory which contains a config.toml and firebase-config.toml files
# - as destination it points to the /home folder
#
# Simple usage with a mounted data directory (considering ~/.djuno/config as the configuration folder):
# > docker run -it -v ~/.djuno/config:/home djuno djuno parse config.toml firebase-config.json
#
# If you want to run this container as a daemon, you can do so by executing
# > docker run -td -v ~/.djuno/config:/home --name djuno djuno
#
# Once you have done so, you can enter the container shell by executing
# > docker exec -it djuno bash
#
# To exit the bash, just execute
# > exit
FROM golang:1.18-alpine
ARG arch=x86_64

# Set up dependencies
ENV PACKAGES curl make git libc-dev bash gcc linux-headers eudev-dev python3 ca-certificates build-base
RUN set -eux; apk add --no-cache $PACKAGES;

# Set working directory for the build
WORKDIR /code

# Add source files
COPY . /code/

# See https://github.com/CosmWasm/wasmvm/releases
ADD https://github.com/CosmWasm/wasmvm/releases/download/v1.1.1/libwasmvm_muslc.aarch64.a /lib/libwasmvm_muslc.aarch64.a
RUN sha256sum /lib/libwasmvm_muslc.aarch64.a | grep 9ecb037336bd56076573dc18c26631a9d2099a7f2b40dc04b6cae31ffb4c8f9a

ADD https://github.com/CosmWasm/wasmvm/releases/download/v1.1.1/libwasmvm_muslc.x86_64.a /lib/libwasmvm_muslc.x86_64.a
RUN sha256sum /lib/libwasmvm_muslc.x86_64.a | grep 6e4de7ba9bad4ae9679c7f9ecf7e283dd0160e71567c6a7be6ae47c81ebe7f32

# Copy the library you want to the final location that will be found by the linker flag `-lwasmvm_muslc`
RUN cp /lib/libwasmvm_muslc.${arch}.a /usr/local/lib/libwasmvm_muslc.a

# force it to use static lib (from above) not standard libgo_cosmwasm.so file
RUN BUILD_TAGS=muslc GOOS=linux GOARCH=amd64 LEDGER_ENABLED=true LINK_STATICALLY=true make build
RUN cp /code/build/djuno /usr/bin/djuno
RUN echo "Ensuring binary is statically linked ..." && (file /usr/bin/djuno | grep "statically linked")

ENTRYPOINT ["djuno"]