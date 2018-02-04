/*
 * This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
 * Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
 */

package console

import (
	"fmt"
	"os"
	"regexp"

	"github.com/ShogunPanda/tempera"
)

// Success shows a success message.
func Success(message string, args ...interface{}) {
	message = tempera.ColorizeTemplate(fmt.Sprintf("{green}🍻\u0020 %s\n{-}", message)) // Emoji code: 1F37B
	fmt.Fprintf(os.Stdout, message, args...)
}

// Warn shows a warning message.
func Warn(message string, args ...interface{}) {
	message = tempera.ColorizeTemplate(fmt.Sprintf("{yellow}⚠️\u0020 %s\n{-}", message)) // Emoji code: 26A0
	fmt.Fprintf(os.Stderr, message, args...)
}

// Fail shows a error message.
func Fail(message string, args ...interface{}) {
	message = tempera.ColorizeTemplate(fmt.Sprintf("{red}❌\u0020 %s\n{-}", message)) // Emoji code: 274C

	fmt.Fprintf(os.Stderr, message, args...)
}

// Debug shows a debug message.
func Debug(message string, args ...interface{}) {
	message = tempera.ColorizeTemplate(fmt.Sprintf("{blue}💬\u0020 %s\n{-}", message)) // Emoji code: 1F4AC

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

	fmt.Fprintf(os.Stdout, tempera.ColorizeTemplate(fmt.Sprintf("{%s}💬\u0020 Exited with status %d.\n{-}", color, code))) // Emoji code: 1F4AC
}

// WrapOutput indents output to align to emojis.
func WrapOutput(output string) string {
	replacer, _ := regexp.Compile("(?m)(^.)")
	return replacer.ReplaceAllString(output, "\u0020\u0020\u0020$1")
}
