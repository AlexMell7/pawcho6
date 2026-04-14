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