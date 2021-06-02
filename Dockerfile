FROM blcdsdockerregistry/bl-base:1.0.0 AS builder

# This dockerfile is written in this way, that I use a environment.yaml to manage dependencies, and
# download the tarball from github releases. The reason that it's not directly installing from conda
# is that the bioconda recipe for version 1.33 isn't configured correctly. In the future versions,
# or if the bioconda recipe is fixed, we may consider just directly install from it.

COPY environment.yaml /opt
COPY build.sh /opt
COPY download-human-db.sh /opt

ENV FUSIONCATCHER_VERSION=1.33
ENV FUSIONCATCHER_SHA512=1d39aa154d6018ecb3f4cb1296e404a36edd2464e86b24e5c0fe70ac3f5d5c84cb1be50ac027f3b627b2d7972689527e06a3483be1873a4d43ed14a651a54ba8
ENV FASTQTK_VERSION=0.27
ENV FASTQTK_SHA512=cf4eb4f057b427cd09c28fa7890bee34db5c475039adaaca53c408a857b3d0640f7a245ff388cee6d8c98f8ddf6bd624a4621c96ef3fcfe1a4b48ae069a882e6
ENV CONDA_PREFIX=/usr/local

RUN conda update -n base -c defaults conda && \
    conda env create -f /opt/environment.yaml --prefix ${CONDA_PREFIX}

RUN apt-get update && \
    apt-get install --no-install-recommends -y build-essential && \
    rm -rf /var/lib/apt/lists/*

RUN cd /opt && \
    wget https://github.com/ndaniel/fusioncatcher/archive/${FUSIONCATCHER_VERSION}.tar.gz && \
    echo "${FUSIONCATCHER_SHA512} ${FUSIONCATCHER_VERSION}.tar.gz" | sha512sum --strict -c - && \
    tar -zxf ${FUSIONCATCHER_VERSION}.tar.gz && \
    cd fusioncatcher-${FUSIONCATCHER_VERSION} && \
    mv ../build.sh ./ && mv ../download-human-db.sh ./ && \
    bash build.sh

# fastqtk was added in v1.33. The package is not available on bioconda yet.
RUN cd /opt && \
    wget https://github.com/ndaniel/fastqtk/archive/refs/tags/v${FASTQTK_VERSION}.tar.gz && \
    echo "${FASTQTK_SHA512} v${FASTQTK_VERSION}.tar.gz" | sha512sum --strict -c - && \
    tar -zxf v${FASTQTK_VERSION}.tar.gz && \
    cd fastqtk-${FASTQTK_VERSION} && \
    make && \
    mv fastqtk /usr/local/bin/

# fix error: faToTwoBit: error while loading shared libraries: libssl.so.1.0.0: cannot open shared
# object file
# https://github.com/ndaniel/fusioncatcher/issues/110
RUN ln -s ${CONDA_PREFIX}/lib/libssl.so.1.1 ${CONDA_PREFIX}/lib/libssl.so.1.0.0 && \
    ln -s ${CONDA_PREFIX}/lib/libcrypto.so.1.1 ${CONDA_PREFIX}/lib/libcrypto.so.1.0.0


# Deploy the target tools into a base image
FROM ubuntu:20.04
COPY --from=builder /usr/local /usr/local

# ps and command for reporting mertics 
RUN apt-get update && \
    apt-get install --no-install-recommends -y procps && \
    rm -rf /var/lib/apt/lists/*

LABEL maintainer="Chenghao Zhu <ChenghaoZhu@mednet.ucla.edu>"
