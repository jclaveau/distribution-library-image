FROM alpine:3.23

RUN apk add --no-cache ca-certificates

RUN set -eux; \
# https://github.com/distribution/distribution/releases
	version='3.1.0'; \
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		x86_64)  arch='amd64';   sha256='c69f2b8778c5357a77f6b41730d94d5f0b2b7cf54534040a06af5f0a70a731b2' ;; \
		aarch64) arch='arm64';   sha256='f5527b7ed356767afb8a616e7b9423ef161b470e3674893e395e2a4e656deb1c' ;; \
		armhf)   arch='armv6';   sha256='2c9a44ea1c289bade76770de459c437dde0bea3b44a3e7555264a63707e71470' ;; \
		armv7)   arch='armv7';   sha256='0217d5704cd0be893320e686ca6bb7341991d9ed23251ac1265301994a890b6f' ;; \
		ppc64le) arch='ppc64le'; sha256='1dc0fc28f368dd2d3b485f1bc7f9e5a6cb2421cf8fa94aade30fc334a362ae47' ;; \
		s390x)   arch='s390x';   sha256='cbe535d6d70e5d9b6c160a6c52445eb9c90af57e12e2b5d377d1263077ae741e' ;; \
		riscv64) arch='riscv64'; sha256='77cd50cd517758a5de09391d4cbda47e64caf1b67ba07413fbfbfeffed6de444' ;; \
		*) echo >&2 "error: unsupported architecture: $apkArch"; exit 1 ;; \
	esac; \
	wget -O registry.tar.gz "https://github.com/distribution/distribution/releases/download/v${version}/registry_${version}_linux_${arch}.tar.gz"; \
	echo "$sha256 *registry.tar.gz" | sha256sum -c -; \
	tar --extract --verbose --file registry.tar.gz --directory /bin/ registry; \
	rm registry.tar.gz; \
	registry --version

COPY ./config-example.yml /etc/distribution/config.yml

ENV OTEL_TRACES_EXPORTER=none

VOLUME ["/var/lib/registry"]
EXPOSE 5000

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/etc/distribution/config.yml"]
