ARG BUILDERIMAGE="golang:1.24.1"
ARG BASEIMAGE="registry.redhat.io/rhel9/bootc-image-builder:9.6-1759893307"

FROM $BUILDERIMAGE as builder

WORKDIR /app
ENV CONTAINERS_STORAGE_THIN_TAGS="containers_image_openpgp exclude_graphdriver_btrfs exclude_graphdriver_devicemapper"

COPY . .
RUN mkdir /images && git clone https://github.com/gtn3010/osbuild-images.git --depth 1 /images && \
    cd bib && go mod tidy && \
    go build -tags "${CONTAINERS_STORAGE_THIN_TAGS}" -o ../bin/bootc-image-builder ./cmd/bootc-image-builder


FROM $BASEIMAGE as base
RUN dnf install -y libxcrypt-compat
COPY --from=builder /app/bin/bootc-image-builder /usr/bin/bootc-image-builder
