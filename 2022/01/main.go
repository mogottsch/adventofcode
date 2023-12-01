package main

import (
	"fmt"
	"os"
	"strings"
)

func main() {
	readInput()
}

func readInput() [][]int {
	getLines()
	// fmt.Println(lines[0])
	// fmt.Println(len(lines))
	return [][]int{}
}

func getLines() []string {
	data, err := os.ReadFile("input.txt")
	if err != nil {
		panic(err)
	}
	fmt.Println(string(data))
	return strings.Split(string(data), "\n")
}
