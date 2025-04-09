package main

import (
	"bufio"
	"fmt"
	"os"
	"path"
	"strconv"
	"strings"
)

const (
	mainLogFileName   = ".nextflow.log"
	taskWorkspaceRoot = "work"
	exitCodeFileName  = ".exitcode"
	stdoutLogFileName = ".command.out"
	stderrLogFileName = ".command.err"

	validationErrorCode = 99
)

func main() {
	verbose := false
	for _, v := range os.Args {
		if v == "--verbose" {
			verbose = true
		}
	}

	nfLog := requireRelativeFile(mainLogFileName)
	defer silence(nfLog.Close)

	if failedTaskWS, found := findFailedStepWorkspaceDir(nfLog); found {
		handleFailure(failedTaskWS)
	} else if verbose {
		handleSuccess()
	}
}

func handleFailure(failedWorkspaceDir string) {
	if !fileExists(failedWorkspaceDir) {
		printLog("\n\nNextflow log indicates a task failed, but the workspace for the failed task no longer exists.")
		os.Exit(1)
	}

	exitCode := getExitCode(failedWorkspaceDir)

	for i, workspace := range collectSortedWorkspaces() {
		if workspace == failedWorkspaceDir {
			break
		} else {
			printLog(fmt.Sprintf("\nTASK %d LOGS\n", i+1))
			printTaskStdout(path.Join(workspace, stdoutLogFileName))
			printTaskStderr(path.Join(workspace, stderrLogFileName))
		}
	}

	if exitCode == validationErrorCode {
		printTaskValidationErrors(failedWorkspaceDir)
	} else {
		printLog("\nFAILED TASK STDOUT\n")
		printTaskStdout(path.Join(failedWorkspaceDir, stdoutLogFileName))
	}
	printLog("\nFAILED TASK STDERR\n")
	printTaskStderr(path.Join(failedWorkspaceDir, stderrLogFileName))

	os.Exit(int(exitCode))
}

func handleSuccess() {
	for i, workspace := range collectSortedWorkspaces() {
		printLog(fmt.Sprintf("\nTASK %d LOGS\n", i+1))
		printTaskStdout(path.Join(workspace, stdoutLogFileName))
		printTaskStderr(path.Join(workspace, stderrLogFileName))
	}
}

// getExitCode reads the Nextflow exitcode output file and parses its content
// into an integral value.
func getExitCode(dir string) uint8 {
	file := path.Join(dir, exitCodeFileName)

	if !fileExists(file) {
		printLog("Nextflow script exit code file could not be found in workspace " + dir)
		printLog("It is possible the task execution failed on initialization")
		return 1
	}

	return uint8(mustReturn(strconv.ParseUint(strings.TrimSpace(string(mustReturn(os.ReadFile(file)))), 10, 8)))
}

// findFailedStepWorkspaceDir parses the overall Nextflow log output file to
// try and locate the log line that indicates the workspace for the failed step.
//
// This function returns the path to the failed workspace, if found, and a
// boolean flag indicating whether the path could be found.
func findFailedStepWorkspaceDir(nfLog *os.File) (string, bool) {
	scanner := bufio.NewScanner(nfLog)

	for scanner.Scan() {
		if strings.Index(scanner.Text(), "Work dir:") > -1 {
			if scanner.Scan() {
				return strings.TrimSpace(scanner.Text()), true
			}

			break
		}
	}

	if err := scanner.Err(); err != nil {
		panic(err)
	}

	return "", false
}

// silence executes the given function and ignores the output error.
//
// This method is intended to be used with `defer` statements which eagerly
// evaluate everything but the outermost function call, which means that the
// target function cannot be called inline with its return value passed as the
// argument to silence.
func silence(fn func() error) {
	_ = fn()
}

// mustReturn is a convenience method to avoid having dozens of if err != nil
// blocks throughout the code.
func mustReturn[V any](r V, err error) V {
	if err != nil {
		panic(err)
	}

	return r
}
