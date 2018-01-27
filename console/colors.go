/*
 * This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
 * Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
 */

package console

import (
	"fmt"
	"regexp"
	"sort"
	"strings"
)

// ANSICode represents a ANSI code with opening and closing (resetting) code
type ANSICode struct {
	Open  uint
	Close uint
}

// ANSICodes is the list of ANSI Escape codes, taken from https://github.com/chalk/ansi-styles
var ANSICodes = map[string]ANSICode{
	"reset": ANSICode{0, 0},
	// Style
	"bold":          ANSICode{1, 22}, // 21 isn't widely supported and 22 does the same thing
	"dim":           ANSICode{2, 22},
	"italic":        ANSICode{3, 23},
	"underline":     ANSICode{4, 24},
	"inverse":       ANSICode{7, 27},
	"hidden":        ANSICode{8, 28},
	"strikethrough": ANSICode{9, 29},
	// Foreground colors
	"black":   ANSICode{30, 39},
	"red":     ANSICode{31, 39},
	"green":   ANSICode{32, 39},
	"yellow":  ANSICode{33, 39},
	"blue":    ANSICode{34, 39},
	"magenta": ANSICode{35, 39},
	"cyan":    ANSICode{36, 39},
	"white":   ANSICode{37, 39},
	"gray":    ANSICode{90, 39},
	// Background colors
	"bgBlack":   ANSICode{40, 49},
	"bgRed":     ANSICode{41, 49},
	"bgGreen":   ANSICode{42, 49},
	"bgYellow":  ANSICode{43, 49},
	"bgBlue":    ANSICode{44, 49},
	"bgMagenta": ANSICode{45, 49},
	"bgCyan":    ANSICode{46, 49},
	"bgWhite":   ANSICode{47, 49},
	// Bright foreground colors
	"redBright":     ANSICode{91, 39},
	"greenBright":   ANSICode{92, 39},
	"yellowBright":  ANSICode{93, 39},
	"blueBright":    ANSICode{94, 39},
	"magentaBright": ANSICode{95, 39},
	"cyanBright":    ANSICode{96, 39},
	"whiteBright":   ANSICode{97, 39},
	// Bright background colors
	"bgBlackBright":   ANSICode{100, 49},
	"bgRedBright":     ANSICode{101, 49},
	"bgGreenBright":   ANSICode{102, 49},
	"bgYellowBright":  ANSICode{103, 49},
	"bgBlueBright":    ANSICode{104, 49},
	"bgMagentaBright": ANSICode{105, 49},
	"bgCyanBright":    ANSICode{106, 49},
	"bgWhiteBright":   ANSICode{107, 49},
}

var parser, _ = regexp.Compile("(?i)\\{[^\\{\\}]+?\\}")
var extracter, _ = regexp.Compile("^\\{(.+)\\}$")

func escapeANSI(code uint) string {
	return fmt.Sprintf("\x1b[%dm", code)
}

// Colorize add colors to a string
func Colorize(template string) string {
	// Create a new styles stack
	styles := make([][]string, 0)

	// For each style tokens in the string
	return parser.ReplaceAllStringFunc(template, func(match string) string {
		style := make([]string, 0) // Prepare a list of all styles in this token

		var sequences string
		var codes []string

		contents := extracter.FindStringSubmatch(match)[1]
		tokens := strings.Split(contents, "|")

	Tokens:
		for _, token := range tokens {
			switch token {
			case "-": // We are unsetting a style
				if len(styles) > 0 { // See if there is any style to unset
					codes, styles = styles[len(styles)-1], styles[:len(styles)-1] // Gather all the styles we have to unset, then remove from the stack

					for _, code := range codes { // Unset all styles by applying the closing ANSI codes
						sequences += escapeANSI(ANSICodes[code].Close)
					}

					if len(styles) > 0 { // If the style stack is still non-empty, restore the previous style
						for _, code := range styles[len(styles)-1] {
							sequences += escapeANSI(ANSICodes[code].Open)
						}
					}
				}

				break Tokens // Do no process further styles in this token
			case "reset": // Reset
				styles = make([][]string, 0)
				break Tokens // Do no process further styles in this token
			default: // We are setting a new style
				if _, exists := ANSICodes[token]; exists == true { // Validate the style
					// Push to the the list of the styles of this token
					style = append(style, token)

					// Set the style by applying the opening ANSI code
					sequences += escapeANSI(ANSICodes[token].Open)
				}
			}
		}

		// If we added any style in this iteration, add to the style stack, in reverse order in order to guarantee proper closing
		if len(style) > 0 {
			sort.Sort(sort.Reverse(sort.StringSlice(style)))
			styles = append(styles, style)
		}

		return sequences
	}) + escapeANSI(ANSICodes["reset"].Close) // Always apply the global reset at the end
}
