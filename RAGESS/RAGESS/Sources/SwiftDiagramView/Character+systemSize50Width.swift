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
        switch self {
        // lower case letters
        case "a":
            return 26
        case "b":
            return 29
        case "c":
            return 26
        case "d":
            return 29
        case "e":
            return 26
        case "f":
            return 16
        case "g":
            return 28
        case "h":
            return 28
        case "i":
            return 11
        case "j":
            return 11
        case "k":
            return 25
        case "l":
            return 11
        case "m":
            return 41
        case "n":
            return 27
        case "o":
            return 27
        case "p":
            return 28
        case "q":
            return 28
        case "r":
            return 16
        case "s":
            return 24
        case "t":
            return 16
        case "u":
            return 27
        case "v":
            return 25
        case "w":
            return 37
        case "x":
            return 24
        case "y":
            return 25
        case "z":
            return 24

        // upper case letters
        case "A":
            return 33
        case "B":
            return 31
        case "C":
            return 35
        case "D":
            return 35
        case "E":
            return 28
        case "F":
            return 27
        case "G":
            return 36
        case "H":
            return 36
        case "I":
            return 12
        case "J":
            return 26
        case "K":
            return 31
        case "L":
            return 27
        case "M":
            return 42
        case "N":
            return 36
        case "O":
            return 37
        case "P":
            return 30
        case "Q":
            return 37
        case "R":
            return 31
        case "S":
            return 31
        case "T":
            return 30
        case "U":
            return 36
        case "V":
            return 32
        case "W":
            return 47
        case "X":
            return 33
        case "Y":
            return 31
        case "Z":
            return 32

        // figure
        case "0":
            return 31
        case "1":
            return 23
        case "2":
            return 29
        case "3":
            return 30
        case "4":
            return 31
        case "5":
            return 30
        case "6":
            return 32
        case "7":
            return 28
        case "8":
            return 31
        case "9":
            return 32

        // symbol
        case "`":
            return 26
        case "~":
            return 31
        case "!":
            return 14
        case "@":
            return 45
        case "#":
            return 31
        case "$":
            return 31
        case "%":
            return 41
        case "^":
            return 31
        case "&":
            return 34
        case "*":
            return 21
        case "(":
            return 17
        case ")":
            return 17
        case "-":
            return 22
        case "_":
            return 27
        case "=":
            return 31
        case "+":
            return 31
        case "[":
            return 16
        case "{":
            return 17
        case "]":
            return 16
        case "}":
            return 17
        case "\\":
            return 15
        case "|":
            return 12
        case ";":
            return 12
        case ":":
            return 12
        case "'":
            return 14
        case "\"":
            return 21
        case ",":
            return 12
        case "<":
            return 31
        case ".":
            return 12
        case ">":
            return 31
        case "/":
            return 15
        case "?":
            return 25

        default:
            return 47
        }
    }
}
