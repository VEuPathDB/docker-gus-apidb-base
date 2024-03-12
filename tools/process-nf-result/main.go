package main

import (
	"bufio"
	"fmt"
	"os"
	"path"
	"slices"
	"strconv"
	"strings"
)

const (
	mainLogFileName   = ".nextflow.log"
	taskWorkspaceRoot = "work"
	exitCodeFileName  = ".exitcode"
	stdoutLogFileName = ".command.out"
	stderrLogFileName = ".command.err"
)

func main() {
	nfLog := requireNextflowLogFile()
	defer nfLog.Close()

	if failedTaskWS, found := findFailedTaskWorkspaceDir(nfLog); found {
		mustI(nfLog.Seek(0, 0))
		handleFailedTask(failedTaskWS, nfLog)
	} else {
		handleNFSuccess()
	}
}

func handleFailedTask(ws string, nfLog *os.File) {
	if !fileExists(ws) {
		printLog("\n\nNextflow log indicates a task failed, but the workspace for the failed task no longer exists.")
		os.Exit(1)
	}

	exitCode := getExitCode(ws)

	// exit code 99 == validation error
	if exitCode == 99 {
		printTaskValidationErrors(ws)
	} else {
		printLog("\nTASK STDOUT\n")
		printTaskStdout(ws)
	}
	printLog("\nTASK STDERR\n")
	printTaskStderr(ws)

	os.Exit(int(exitCode))
}

func handleNFSuccess() {
	workspaces := collectSortedWorkspaces()

	for _, workspace := range workspaces {
		printTaskStdout(workspace)
		printTaskStderr(workspace)
	}
}

func collectSortedWorkspaces() []string {
	workspaceRootDir := path.Join(mustR(os.Getwd()), taskWorkspaceRoot)

	if !fileExists(workspaceRootDir) {
		return []string{}
	}

	buckets := mustR(os.ReadDir(workspaceRootDir))
	slices.SortFunc(buckets, dirSort)

	workspaces := make([]string, 0, len(buckets))

	for _, bucket := range buckets {
		if !bucket.IsDir() {
			continue
		}

		bucketDir := path.Join(workspaceRootDir, bucket.Name())

		workspaceDirs := mustR(os.ReadDir(bucketDir))
		slices.SortFunc(workspaceDirs, dirSort)

		for _, workspace := range workspaceDirs {
			if !workspace.IsDir() {
				continue
			}

			workspaces = append(workspaces, path.Join(bucketDir, workspace.Name()))
		}
	}

	return workspaces
}

func dirSort(a, b os.DirEntry) int {
	at := mustR(a.Info()).ModTime()
	bt := mustR(b.Info()).ModTime()

	if at.Before(bt) {
		return -1
	}

	if bt.Before(at) {
		return 1
	}

	return 0
}

func getExitCode(dir string) uint8 {
	file := path.Join(dir, exitCodeFileName)

	if !fileExists(file) {
		printLog("Nextflow script exit code file could not be found in workspace " + dir)
		printLog("It is possible the task execution failed on initialization")
		return 1
	}

	return uint8(mustR(strconv.ParseUint(strings.TrimSpace(string(mustR(os.ReadFile(file)))), 10, 8)))
}

func printTaskStderr(dir string) {
	filePath := path.Join(dir, stderrLogFileName)

	if !fileExists(filePath) {
		printLog("Nextflow script stderr log file could not be found in workspace " + dir)
		printLog("It is possible the task execution failed on initialization")
		return
	}

	file := mustR(os.Open(filePath))
	defer file.Close()

	printFileTo(file, "", printLog)
}

func printTaskStdout(dir string) {
	printTaskStdoutTo(dir, "[stdout]", printLog)
}

func printTaskValidationErrors(dir string) {
	printTaskStdoutTo(dir, "", printErr)
}

func printTaskStdoutTo(dir, prefix string, printer func(string)) {
	filePath := path.Join(dir, stdoutLogFileName)

	if !fileExists(filePath) {
		printLog("Nextflow script stdout log file could not be found in workspace " + dir)
		printLog("It is possible the task execution failed on initialization")
		return
	}

	file := mustR(os.Open(filePath))
	defer file.Close()

	printFileTo(file, prefix, printer)
}

func printFileTo(file *os.File, prefix string, printer func(string)) {
	scanner := bufio.NewScanner(file)

	for scanner.Scan() {
		printer(prefix + scanner.Text())
	}

	must(scanner.Err())
}

func findFailedTaskWorkspaceDir(nfLog *os.File) (string, bool) {
	scanner := bufio.NewScanner(nfLog)

	for scanner.Scan() {
		if strings.Index(scanner.Text(), "Work dir:") > -1 {
			if scanner.Scan() {
				return strings.TrimSpace(scanner.Text()), true
			}

			break
		}
	}

	must(scanner.Err())

	return "", false
}

func requireNextflowLogFile() *os.File {
	nfLogFilePath := path.Join(mustR(os.Getwd()), mainLogFileName)

	if !fileExists(nfLogFilePath) {
		printLog("No nextflow log file found.")
		os.Exit(0)
	}

	return mustR(os.Open(nfLogFilePath))
}

func fileExists(path string) bool {
	if _, err := os.Stat(path); err != nil {
		if os.IsNotExist(err) {
			return false
		}

		must(err)
	}

	return true
}

func printErr(line string) {
	fmt.Println(line)
}

func printLog(line string) {
	mustI(fmt.Fprintln(os.Stderr, line))
}

func must(err error) {
	if err != nil {
		panic(err)
	}
}

func mustI[V any](_ V, err error) {
	if err != nil {
		panic(err)
	}
}

func mustR[V any](r V, err error) V {
	if err != nil {
		panic(err)
	}

	return r
}
