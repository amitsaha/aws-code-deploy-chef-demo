package main

import (
	"io"
	"log"
	"net/http"
)

func main() {

	indexHandler := func(w http.ResponseWriter, req *http.Request) {
		io.WriteString(w, "Hello, world! I am a web application\n")
	}

	http.HandleFunc("/", indexHandler)
	log.Fatal(http.ListenAndServe(":8080", nil))
}
