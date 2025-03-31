ARG BUILDERIMAGE="golang:1.23.6"
ARG BASEIMAGE="registry.redhat.io/rhel9/bootc-image-builder:9.5-1747221457"

FROM $BUILDERIMAGE AS builder

WORKDIR /app
ENV CONTAINERS_STORAGE_THIN_TAGS="containers_image_openpgp exclude_graphdriver_btrfs exclude_graphdriver_devicemapper"

RUN git clone https://github.com/gtn3010/bootc-image-builder.git --depth 1 . && \
    mkdir /images && git clone https://github.com/gtn3010/osbuild-images.git --depth 1 /images && \
    cd bib && go mod tidy && \
    go build -tags "${CONTAINERS_STORAGE_THIN_TAGS}" -o ../bin/bootc-image-builder ./cmd/bootc-image-builder


FROM $BASEIMAGE AS base
RUN dnf install -y libxcrypt-compat awscli2
COPY --from=builder /app/bin/bootc-image-builder /usr/bin/bootc-image-builder