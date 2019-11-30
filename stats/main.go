package main

import (
	"bytes"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/exec"
	"strings"
	"time"
)

func main() {
	dir := flag.String("d", "data", "path to data directory to use")
	bind := flag.String("b", ":3001", "address to bind to")
	flag.Parse()
	errc := make(chan error)

	go func(errc chan error) {
		for {
			log.Println("INFO [refresh begin]")
			if err := update(*dir); err != nil {
				errc <- err
			}
			log.Println("INFO [refresh complete]")
			time.Sleep(time.Second * 1)
		}
	}(errc)

	go func(errc chan error) {
		errc <- server(*bind, *dir)
	}(errc)

	if err := <-errc; err != nil {
		log.Fatal(err)
	}
}

func server(port, dir string) error {
	fs := http.FileServer(http.Dir(dir))
	http.Handle("/", fs)
	log.Println("Listening on", port)
	return http.ListenAndServe(port, nil)
}

func update(dir string) error {
	_ = os.Mkdir(dir, 0700)
	query := map[string]string{
		"status":       "status",
		"version":      "version",
		"providers":    "provider status",
		"fulfillments": "query fulfillment",
		"orders":       "query order",
	}

	for key, q := range query {
		args := []string{"-m", "json"}
		args = append(args, strings.Split(q, " ")...)
		cmd := exec.Command("akash", args...)
		var out bytes.Buffer
		cmd.Stdout = &out
		cmd.Stderr = &out
		if err := cmd.Run(); err != nil {
			log.Printf("ERROR run cmd: %+v\n", err)
			return err
		}
		p := fmt.Sprintf("%s/%s.json", dir, key)
		if err := ioutil.WriteFile(p, out.Bytes(), 0644); err != nil {
			log.Printf("ERROR write file: %s: %+v\n", p, err)
			return err
		}
		log.Printf("DEBUG [updated]: %s\n", p)
	}
	return nil
}
