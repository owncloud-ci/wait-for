package main

import (
	"os/exec"
	"testing"
)

func TestHelpExitsZero(t *testing.T) {
	cmd := exec.Command("go", "run", ".", "-help")
	if err := cmd.Run(); err != nil {
		t.Fatalf("expected exit 0, got: %v", err)
	}
}
