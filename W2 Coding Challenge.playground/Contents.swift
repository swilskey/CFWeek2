//: Playground - noun: a place where people can play

import UIKit

/*
* Monday
* Function that counts how many words in a string
*
*/

func wordCount(string: String) -> Int {
  var words = string.componentsSeparatedByCharactersInSet((NSCharacterSet.whitespaceCharacterSet()))
  
  return words.count
}

let testString = "Hello this is a sentence with 8 words"
wordCount(testString)
