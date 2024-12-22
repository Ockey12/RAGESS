//
//  Character+systemSize50Width.swift
//
//
//  Created by Ockey12 on 2024/05/22
//
//

import Foundation

extension Character {
    var systemSize50Width: CGFloat {
        let width: CGFloat
        switch self {
        // lower case letters
        case "a":
            width = 26
        case "b":
            width = 29
        case "c":
            width = 26
        case "d":
            width = 29
        case "e":
            width = 26
        case "f":
            width = 16
        case "g":
            width = 28
        case "h":
            width = 28
        case "i":
            width = 11
        case "j":
            width = 11
        case "k":
            width = 25
        case "l":
            width = 11
        case "m":
            width = 41
        case "n":
            width = 27
        case "o":
            width = 27
        case "p":
            width = 28
        case "q":
            width = 28
        case "r":
            width = 16
        case "s":
            width = 24
        case "t":
            width = 16
        case "u":
            width = 27
        case "v":
            width = 25
        case "w":
            width = 37
        case "x":
            width = 24
        case "y":
            width = 25
        case "z":
            width = 24

        // upper case letters
        case "A":
            width = 33
        case "B":
            width = 31
        case "C":
            width = 35
        case "D":
            width = 35
        case "E":
            width = 28
        case "F":
            width = 27
        case "G":
            width = 36
        case "H":
            width = 36
        case "I":
            width = 12
        case "J":
            width = 26
        case "K":
            width = 31
        case "L":
            width = 27
        case "M":
            width = 42
        case "N":
            width = 36
        case "O":
            width = 37
        case "P":
            width = 30
        case "Q":
            width = 37
        case "R":
            width = 31
        case "S":
            width = 31
        case "T":
            width = 30
        case "U":
            width = 36
        case "V":
            width = 32
        case "W":
            width = 47
        case "X":
            width = 33
        case "Y":
            width = 31
        case "Z":
            width = 32

        // figure
        case "0":
            width = 31
        case "1":
            width = 23
        case "2":
            width = 29
        case "3":
            width = 30
        case "4":
            width = 31
        case "5":
            width = 30
        case "6":
            width = 32
        case "7":
            width = 28
        case "8":
            width = 31
        case "9":
            width = 32

        // symbol
        case "`":
            width = 26
        case "~":
            width = 31
        case "!":
            width = 14
        case "@":
            width = 45
        case "#":
            width = 31
        case "$":
            width = 31
        case "%":
            width = 41
        case "^":
            width = 31
        case "&":
            width = 34
        case "*":
            width = 21
        case "(":
            width = 17
        case ")":
            width = 17
        case "-":
            width = 22
        case "_":
            width = 27
        case "=":
            width = 31
        case "+":
            width = 31
        case "[":
            width = 16
        case "{":
            width = 17
        case "]":
            width = 16
        case "}":
            width = 17
        case "\\":
            width = 15
        case "|":
            width = 12
        case ";":
            width = 12
        case ":":
            width = 12
        case "'":
            width = 14
        case "\"":
            width = 21
        case ",":
            width = 12
        case "<":
            width = 31
        case ".":
            width = 12
        case ">":
            width = 31
        case "/":
            width = 15
        case "?":
            width = 25

        default:
            width = 47
        }

        return width / 3.5
    }
}
