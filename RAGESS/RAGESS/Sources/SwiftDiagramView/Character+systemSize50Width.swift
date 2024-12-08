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
            return 26/4
        case "b":
            return 29/4
        case "c":
            return 26/4
        case "d":
            return 29/4
        case "e":
            return 26/4
        case "f":
            return 16/4
        case "g":
            return 28/4
        case "h":
            return 28/4
        case "i":
            return 11/4
        case "j":
            return 11/4
        case "k":
            return 25/4
        case "l":
            return 11/4
        case "m":
            return 41/4
        case "n":
            return 27/4
        case "o":
            return 27/4
        case "p":
            return 28/4
        case "q":
            return 28/4
        case "r":
            return 16/4
        case "s":
            return 24/4
        case "t":
            return 16/4
        case "u":
            return 27/4
        case "v":
            return 25/4
        case "w":
            return 37/4
        case "x":
            return 24/4
        case "y":
            return 25/4
        case "z":
            return 24/4

        // upper case letters
        case "A":
            return 33/4
        case "B":
            return 31/4
        case "C":
            return 35/4
        case "D":
            return 35/4
        case "E":
            return 28/4
        case "F":
            return 27/4
        case "G":
            return 36/4
        case "H":
            return 36/4
        case "I":
            return 12/4
        case "J":
            return 26/4
        case "K":
            return 31/4
        case "L":
            return 27/4
        case "M":
            return 42/4
        case "N":
            return 36/4
        case "O":
            return 37/4
        case "P":
            return 30/4
        case "Q":
            return 37/4
        case "R":
            return 31/4
        case "S":
            return 31/4
        case "T":
            return 30/4
        case "U":
            return 36/4
        case "V":
            return 32/4
        case "W":
            return 47/4
        case "X":
            return 33/4
        case "Y":
            return 31/4
        case "Z":
            return 32/4

        // figure
        case "0":
            return 31/4
        case "1":
            return 23/4
        case "2":
            return 29/4
        case "3":
            return 30/4
        case "4":
            return 31/4
        case "5":
            return 30/4
        case "6":
            return 32/4
        case "7":
            return 28/4
        case "8":
            return 31/4
        case "9":
            return 32/4

        // symbol
        case "`":
            return 26/4
        case "~":
            return 31/4
        case "!":
            return 14/4
        case "@":
            return 45/4
        case "#":
            return 31/4
        case "$":
            return 31/4
        case "%":
            return 41/4
        case "^":
            return 31/4
        case "&":
            return 34/4
        case "*":
            return 21/4
        case "(":
            return 17/4
        case ")":
            return 17/4
        case "-":
            return 22/4
        case "_":
            return 27/4
        case "=":
            return 31/4
        case "+":
            return 31/4
        case "[":
            return 16/4
        case "{":
            return 17/4
        case "]":
            return 16/4
        case "}":
            return 17/4
        case "\\":
            return 15/4
        case "|":
            return 12/4
        case ";":
            return 12/4
        case ":":
            return 12/4
        case "'":
            return 14/4
        case "\"":
            return 21/4
        case ",":
            return 12/4
        case "<":
            return 31/4
        case ".":
            return 12/4
        case ">":
            return 31/4
        case "/":
            return 15/4
        case "?":
            return 25/4

        default:
            return 47/4
        }
    }
}
