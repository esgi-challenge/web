package main

import (
	"embed"
	"io/fs"
	"log"
	"net/http"
)

//go:embed build/web/*
var content embed.FS

func main() {
	webFs, err := fs.Sub(content, "build/web")
	if err != nil {
		log.Fatalf("Failed to create sub filesystem: %v", err)
	}

	fileSystem := http.FS(webFs)

	http.Handle("/", http.FileServer(fileSystem))

	log.Println("Launching Web Server on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
