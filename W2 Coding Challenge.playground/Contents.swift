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

/*
* Tuesday
* Function that returns odd elements of an array
*
*/

func oddElements(array: [Int]) -> [Int] {
  var returnArray = [Int]()
  
  for item in array {
    if item % 2 != 0 {
      returnArray.append(item)
    }
  }
  return returnArray
}

let testArray = [2, 4, 5, 13, 12, 54, 34, 33, 31, 51]
oddElements(testArray)

/*
* Wednesday
* Compute first 100 fibinaci numbers
*
*/

// Recursive exponential Growth
func fib(number: Double) -> Double {
  if number < 2 {
    return number
  }
  println(number)
  return fib(number - 1) + fib(number - 2)
}
// Tail Recursive
func fib2(term: Double, val: Double, prev: Double) -> Double {
  if term == 0 {
    return prev
  }
  return fib2(term - 1, val+prev, val)
}

println(fib2(100, 1, 0))
println(fib(10))
