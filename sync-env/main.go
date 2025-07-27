package main

import (
	"log"
	"os"
	"path"

	"github.com/joho/godotenv"
)

const envFile = ".env"
const logPrefix = "==>"

func main() {
	cwd, err := os.Getwd()

	if err != nil {
		log.Fatalf("failed to get current dir path: %v", err)
	}

	var env map[string]string
	env, err = godotenv.Read()

	dirs, err := os.ReadDir(cwd)

	for _, d := range dirs {
		if d.IsDir() && d.Name() != ".git" {
			err := processDir(path.Join(cwd, d.Name()), env)
			if err != nil {
				log.Fatal(err)
			}
		}
	}
}

func processDir(d string, env map[string]string) (err error) {
	log.Println(logPrefix, "processing dir: ", d)

	p := path.Join(d, envFile)
	log.Println(logPrefix, "checking for file: ", p)

	_, err = os.Stat(p)

	if os.IsNotExist(err) {
		err = processNewEnvFile(p, env)
		return
	}

	err = processExistingEnvFile(p, env)

	return
}
