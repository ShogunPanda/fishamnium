/*
 * This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
 * Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
 */

package console

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"regexp"
	"strconv"
	"strings"

	"github.com/ShogunPanda/tempera"
)

var emojiSpacer = "\x1b[0E\x1b[3C"

func setTerminalMode(mode string) {
	cmd := exec.Command("/bin/stty", mode)
	cmd.Stdin = os.Stdin
	_ = cmd.Run()
	cmd.Wait()
}

// GetEmojiWidth Detects handling of emoji
func GetEmojiWidth() {
	setTerminalMode("raw")

	os.Stdout.Write([]byte("💬\x1b[6n"))
	reader := bufio.NewReader(os.Stdin)
	position, _ := reader.ReadSlice('R')

	// Set the terminal back from raw mode to 'cooked'
	setTerminalMode("-raw")

	// Delete the current line
	os.Stdout.Write([]byte("\x1b[0E\x1b[0K"))

	// Parse the position
	coordinates := strings.Split(string(position[2:len(position)-1]), ";")
	width, _ := strconv.ParseInt(coordinates[1], 0, 4)
	emojiSpacer = strings.Repeat(" ", 4-int(width))
}

// Success shows a success message.
func Success(message string, args ...interface{}) {
	message = tempera.ColorizeTemplate(fmt.Sprintf("{green}🍻%s%s\n{-}", emojiSpacer, message)) // Emoji code: 1F37B
	fmt.Fprintf(os.Stdout, message, args...)
}

// Warn shows a warning message.
func Warn(message string, args ...interface{}) {
	message = tempera.ColorizeTemplate(fmt.Sprintf("{yellow}⚠️%s%s\n{-}", emojiSpacer, message)) // Emoji code: 26A0
	fmt.Fprintf(os.Stderr, message, args...)
}

// Fail shows a error message.
func Fail(message string, args ...interface{}) {
	message = tempera.ColorizeTemplate(fmt.Sprintf("{red}❌%s%s\n{-}", emojiSpacer, message)) // Emoji code: 274C

	fmt.Fprintf(os.Stderr, message, args...)
}

// Debug shows a debug message.
func Debug(message string, args ...interface{}) {
	message = tempera.ColorizeTemplate(fmt.Sprintf("{blue}💬%s%s\n{-}", emojiSpacer, message)) // Emoji code: 1F4AC

	fmt.Fprintf(os.Stderr, message, args...)
}

// Fatal aborts the executable with a error message.
func Fatal(message string, args ...interface{}) {
	Fail(message, args...)
	os.Exit(1)
}

// Complete shows a completion message.
func Complete() {
	Success("All operations completed successfully!")
}

// FinishStep shows a step completion message.
func FinishStep(code int) {
	color := "green"

	if code != 0 {
		color = "red"
	}

	fmt.Fprintf(os.Stdout, tempera.ColorizeTemplate(fmt.Sprintf("💬%s{%s}Exited with status %d.\n{-}", emojiSpacer, color, code))) // Emoji code: 1F4AC
}

// WrapOutput indents output to align to emojis.
func WrapOutput(output string) string {
	replacer, _ := regexp.Compile("(?m)(^.)")
	return replacer.ReplaceAllString(output, fmt.Sprintf("%s$1", emojiSpacer))
}
