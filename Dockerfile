FROM golang:1.21-alpine AS builder

ARG VERSION
WORKDIR /app

COPY <<EOF main.go
package main
import (
	"fmt"
	"os"
	"net"
)
func main() {
	hostname, _ := os.Hostname()
	addrs, _ := net.InterfaceAddrs()
	var ip string
	for _, a := range addrs {
		if ipnet, ok := a.(*net.IPNet); ok && !ipnet.IP.IsLoopback() {
			if ipnet.IP.To4() != nil {
				ip = ipnet.IP.String()
			}
		}
	}
	fmt.Printf("<html><body><h1>Laboratorium 5 - Go + Nginx</h1>")
	fmt.Printf("<p><b>Wersja:</b> %%s</p>", os.Getenv("APP_VERSION"))
	fmt.Printf("<p><b>Hostname:</b> %%s</p>", hostname)
	fmt.Printf("<p><b>IP:</b> %%s</p>", ip)
	fmt.Printf("</body></html>")
}
EOF

ENV APP_VERSION=$VERSION
RUN CGO_ENABLED=0 GOOS=linux go build -o html-gen main.go


FROM nginx:alpine

COPY --from=builder /app/html-gen /usr/local/bin/html-gen
ARG VERSION
ENV APP_VERSION=$VERSION


RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo '/usr/local/bin/html-gen > /usr/share/nginx/html/index.html' >> /entrypoint.sh && \
    echo 'nginx -g "daemon off;"' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -f http://localhost/ || exit 1

CMD ["/entrypoint.sh"]