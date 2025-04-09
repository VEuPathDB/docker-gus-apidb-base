package main

import (
	"fmt"
	"os"
	"path"
	"slices"
)

// collectSortedWorkspaces gathers and sorts all the workspace directories that
// were created by the Nextflow execution.
//
// Nextflow creates workspaces for steps in a two level deep nested directory
// structure based on segments of a generated hash.  There is no particular
// organization of the created workspaces, so this method sorts on the creation
// timestamp of each directory.
func collectSortedWorkspaces() []string {
	workspaceRootDir := path.Join(mustReturn(os.Getwd()), taskWorkspaceRoot)

	if !fileExists(workspaceRootDir) {
		return []string{}
	}

	buckets := mustReturn(os.ReadDir(workspaceRootDir))
	slices.SortFunc(buckets, dirSort)

	workspaces := make([]string, 0, len(buckets))

	for _, bucket := range buckets {
		if !bucket.IsDir() {
			continue
		}

		bucketDir := path.Join(workspaceRootDir, bucket.Name())

		workspaceDirs := mustReturn(os.ReadDir(bucketDir))
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

// dirSort implements the slices.SortFunc input function signature and applies
// sorting based on creation timestamp in ascending order.
func dirSort(a, b os.DirEntry) int {
	at := mustReturn(a.Info()).ModTime()
	bt := mustReturn(b.Info()).ModTime()

	if at.Before(bt) {
		return -1
	}

	if bt.Before(at) {
		return 1
	}

	return 0
}

func requireRelativeFile(file string) *os.File {
	fullPath := path.Join(mustReturn(os.Getwd()), mainLogFileName)

	if !fileExists(fullPath) {
		printLog(fmt.Sprintf("Target file '%s' not found.", file))
		os.Exit(0)
	}

	return mustReturn(os.Open(fullPath))
}

func fileExists(path string) bool {
	if _, err := os.Stat(path); err != nil {
		if os.IsNotExist(err) {
			return false
		}

		panic(err)
	}

	return true
}
