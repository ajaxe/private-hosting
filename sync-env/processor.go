package main

import (
	"fmt"
	"log"
	"os"

	"github.com/joho/godotenv"
)

const managedComment = "# << sync-managed"

func formatEntry(k, v string, managed bool) string {
	if managed {
		return fmt.Sprintf("%s=%s %s\n", k, v, managedComment)
	}

	return fmt.Sprintf("%s=%s\n", k, v)
}

func processNewEnvFile(p string, env map[string]string) error {
	f, err := os.OpenFile(p, os.O_CREATE, 0600)

	if err != nil {
		return fmt.Errorf("failed to create env file, at path=%s: %v", p, err)
	}

	defer f.Close()

	err = writeAllAsManaged(f, env)

	if err != nil {
		return fmt.Errorf("failed to create env file, at path=%s: %v", p, err)
	}

	log.Println(logPrefix, " end writing to env file: ", f.Name())

	return nil
}

func writeAllAsManaged(f *os.File, env map[string]string) error {
	log.Println(logPrefix, " begin writing to env file: ", f.Name())
	for k, v := range env {
		entry := formatEntry(k, v, true)
		_, err := f.WriteString(entry)
		if err != nil {
			log.Println(logPrefix, " end writing due to error, env file: ", f.Name())
			return fmt.Errorf("failed to write to env file: %v", err)
		}
	}
	return nil
}

func processExistingEnvFile(p string, env map[string]string) error {
	log.Println(logPrefix, " processing existing env file: ", p)
	envExisting, err := godotenv.Read(p)

	if err != nil {
		return fmt.Errorf("failed to read env file, at path=%s: %v", p, err)
	}

	f, err := os.OpenFile(p, os.O_WRONLY|os.O_TRUNC, 0644)
	if err != nil {
		return fmt.Errorf("failed to open env file, at path=%s: %v", p, err)
	}

	defer f.Close()

	if len(envExisting) == 0 {
		log.Println(logPrefix, " env file is empty: ", f.Name())
		return writeAllAsManaged(f, env)
	}

	log.Println(logPrefix, " file has entries, count=", len(envExisting), " updating env file: ", f.Name())

	for k, v := range envExisting {
		entry := ""
		if _, ok := env[k]; !ok {
			entry = formatEntry(k, v, false)
		} else {
			entry = formatEntry(k, env[k], true)
		}
		_, err := f.WriteString(entry)
		if err != nil {
			return fmt.Errorf("failed to write to env file, at path=%s: %v", p, err)
		}
	}

	log.Println(logPrefix, " end writing to env file: ", f.Name())

	return nil
}
