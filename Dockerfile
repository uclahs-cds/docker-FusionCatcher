FROM blcdsdockerregistry/bl-base:1.0.0 AS builder

# Use conda to install tools and dependencies into /usr/local
ARG TOOL_VERSION=X.X.X
RUN conda create -qy -p /usr/local \
    -c bioconda \
    -c conda-forge \
    tool_name==${TOOL_VERSION}

# Deploy the target tools into a base image
FROM ubuntu:20.04
COPY --from=builder /usr/local /usr/local

LABEL maintainer="Your Name <YourName@mednet.ucla.edu>"