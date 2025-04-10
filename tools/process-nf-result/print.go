package main

import (
	"bufio"
	"fmt"
	"os"
	"path"
)

func printTaskStderr(filePath string, withPrefix bool) {
	if !fileExists(filePath) {
		printLog("Nextflow script stderr log file could not be found in workspace " + path.Dir(filePath))
		printLog("It is possible the task execution failed on initialization")
		return
	}

	file := mustReturn(os.Open(filePath))
	defer silence(file.Close)

	prefix := ""
	if withPrefix {
		prefix = "[stderr] "
	}

	printFileTo(file, prefix, printLog)
}

func printTaskStdout(path string, withPrefix bool) {
	if withPrefix {
		printTaskStdoutTo(path, "[stdout] ", printLog)
	} else {
		printTaskStdoutTo(path, "", printLog)
	}
}

func printTaskValidationErrors(path string) {
	printTaskStdoutTo(path, "", printErr)
}

func printTaskStdoutTo(filePath, prefix string, printer func(string)) {
	if !fileExists(filePath) {
		printLog("Nextflow script stdout log file could not be found in workspace " + path.Dir(filePath))
		printLog("It is possible the task execution failed on initialization")
		return
	}

	file := mustReturn(os.Open(filePath))
	defer silence(file.Close)

	printFileTo(file, prefix, printer)
}

func printFileTo(file *os.File, prefix string, printer func(string)) {
	scanner := bufio.NewScanner(file)

	for scanner.Scan() {
		printer(prefix + scanner.Text())
	}

	if err := scanner.Err(); err != nil {
		panic(err)
	}
}

func printErr(line string) {
	fmt.Println(line)
}

func printLog(line string) {
	mustReturn(fmt.Fprintln(os.Stderr, line))
}
