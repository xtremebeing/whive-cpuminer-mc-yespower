FROM alpine:3.14 as stage1

# Dockerfile to build Whive yespower cpuminer
#
# Build:
# docker build -f Dockerfile -t cpuminer .
#
# Run:
# docker run cpuminer --url stratum+tcp://miningpool.example.com:80 --user user.worker --pass abcdef
#
# Run with imposing cpu limit and 2 threads
# docker run --cpus=".2" cpuminer --url stratum+tcp://miningpool.example.com:80 --user user.worker --pass abcdef -t2 
#

RUN apk update && \
    apk add --no-cache gcc make automake autoconf pkgconfig libcurl curl-dev libc-dev git

RUN git clone https://github.com/whiveio/cpuminer-mc-yespower.git cpuminer

RUN cd cpuminer && \
    make clean ; \
    ./autogen.sh && \
    ./nomacro.pl && \
    ./configure CFLAGS="-O3 -march=native" && \
    make

FROM alpine:3.14
LABEL author="tcarter@entrusion.com"
LABEL description="Dockerfile to build Whive yespower cpuminer"
LABEL version="1.0"
WORKDIR /cpuminer
COPY --from=stage1 /cpuminer/minerd /cpuminer
RUN apk add --no-cache libcurl
ENTRYPOINT ["./minerd"]
