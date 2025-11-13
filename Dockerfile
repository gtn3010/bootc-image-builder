ARG BUILDERIMAGE="golang:1.24.10"
ARG BASEIMAGE="registry.redhat.io/rhel9/bootc-image-builder:9.7-1762217516"

FROM $BUILDERIMAGE as builder

WORKDIR /app
ENV CONTAINERS_STORAGE_THIN_TAGS="containers_image_openpgp exclude_graphdriver_btrfs exclude_graphdriver_devicemapper"

COPY . .
RUN mkdir /images && git clone https://github.com/gtn3010/osbuild-images.git --depth 1 /images && \
    mkdir /blueprint && git clone https://github.com/gtn3010/blueprint.git --depth 1 /blueprint && \
    cd bib && go mod tidy && \
    CGO_ENABLED=0 go build -tags "${CONTAINERS_STORAGE_THIN_TAGS}" -o ../bin/bootc-image-builder ./cmd/bootc-image-builder


FROM $BASEIMAGE as base
COPY custom-osbuild-stages/org.osbuild.oscap.remediation /usr/lib/osbuild/stages/org.osbuild.oscap.remediation
COPY custom-osbuild-stages/org.osbuild.oscap.remediation.meta.json /usr/lib/osbuild/stages/org.osbuild.oscap.remediation.meta.json
RUN dnf install -y libxcrypt-compat zip && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install
COPY --from=builder /app/bin/bootc-image-builder /usr/bin/bootc-image-builder
