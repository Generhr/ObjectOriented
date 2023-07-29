# ObjectOriented.ahk

Ported most of the MDN prototype as well as some custom methods for use with ahk objects and adjusted the base index of arrays to zero.

## Array methods

#### `array.Print()`

Converts the array into a string to more easily see the structure.

##### Example

```autohotkey
test := [0, 1, 2]
MsgBox(test.Print())  ; "[0, 1, 2]"
```

#### `array.Compact([recursive])`

Remove all falsy values from an array.

##### Example

```autohotkey
test := [0, , 2, ""]
MsgBox(test.Compact().Print())  ; "[0, 2]"
```

#### `array.Empty()`

Removes all elements from an array.

##### Example

```autohotkey
test := [0, 1, 2]
MsgBox(test.Empty().Print())  ; "[]"
```

#### `array.Sample(number)`

Returns a new array with `number` random elements from an array.

##### Example

```autohotkey
test := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
MsgBox(test.Sample(-5).Print())  ; Potential result: "[0, 2, 4, 1, 3]"
```

#### `array.Shuffle([callback])`

See https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle.

##### Example

```autohotkey
test := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
MsgBox(test.Shuffle().Print())  ; Potential result: "[2, 8, 5, 9, 4, 3, 6, 0, 7, 1]"
```

#### `array.Swap(index1, index2)`

Swap any two elements in an array.

##### Example

```autohotkey
test := [[0], 1, 2, 3, 4, 5, 6, 7, 8, {Nine: 9}]
MsgBox(test.Swap(0, 9).Print())  ; "[{Nine: 9}, 1, 2, 3, 4, 5, 6, 7, 8, [0]]"
```

#### `array.Concat(values*)`

See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/concat.

##### Example

```autohotkey
test := [[2, 3], [4, 5, 6], [8, 9, 10]]
MsgBox([1].Concat(test[0], test[1], 7, test[2]).Print())  ; [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
```

#### `array.Every(callback)`

See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/every.

##### Example

```autohotkey
test := [1, 30, 39, 29, 10, 13]
MsgBox(test.Every((value, *) => (value < 40)))  ; 1 (True)

(test := [1, 2, 3]).Every(Function)
MsgBox(test.Print())  ; "[1, 2, 3, "New", "New", "New"]"

Function(value, index, array) {
	array.Push("New")

	return (value is Number && value < 4)
}
```

#### `array.Fill(value[, start, end])`

See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/fill.

##### Example

```autohotkey
test := [0, 1, 2, , 4]
MsgBox(test.Fill(0).Print())  ; "[0, 0, 0, 0, 0]"
```

#### `array.Filter(callback)`

See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/filter.

##### Example

```autohotkey
test := ["Spray", "Limit", "Elite", "Exuberant", "Destruction", "Present"]
MsgBox(test.Filter((value, *) => (StrLen(value) > 5)).Print())  ; "["Exuberant", "Destruction", "Present"]"
```

#### `array.Find(callback)`

See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/find.

##### Example

```autohotkey
test := [5, 12, 8, 130, 44]
MsgBox(test.Find((value, *) => (value > 10)))  ; 12
```

#### `array.FindIndex(callback)`

See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/findIndex.

##### Example

```autohotkey
test := [5, 12, 8, 130, 44]
MsgBox(test.FindIndex((value, *) => (value > 12)))  ; 3
```

#### `array.Flat([depth])`

See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/flat.

##### Example

```autohotkey
MsgBox([1, 2, "", 3, [[4]], [5]].Flat().Print())  ; "[1, 2, 3, [4], 5]"
```

#### `array.ForEach(callback)`

See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/forEach.

##### Example

```autohotkey
(test := [1, 3, "", 7]).ForEach((value, *) => ((value is Number) ? (value - 1) : ("")))
MsgBox(test.Print())  ; "[0, 2, "", 6]"
```

#### `array.Includes(needle[, start])`

See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/includes.

##### Example

```autohotkey
MsgBox([1, 2, 3].Includes("3", 3))  ; False
MsgBox([1, 2, 3].Includes("3", -1))  ; True
MsgBox([1, 2, 3].Includes("3", 0))  ; True
```

#### `array.IndexOf(needle[, start])`

See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/indexOf.

##### Example

```autohotkey
MsgBox(["ant", "bison", "camel", "", "bison"].IndexOf("bison"))  ; 1
MsgBox(["ant", "bison", "camel", "", "bison"].IndexOf("bison", 2))  ; 4
```

#### `array.Join([delimiter])`

See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/join.

##### Example

```autohotkey
MsgBox([0, 1, 2, 3, 4].Join("xXx"))  ; 0xXx1xXx2xXx3xXx4
MsgBox([0, 1, 2, 3, 4].Join())  ; 0, 1, 2, 3, 4
```

#### `array.LastIndexOf(needle[, start])`

Returns the last index at which a given element can be found in the array, or -1 if it is not present. The array is searched backwards, starting at fromIndex.

##### Example

```autohotkey
test := [2, 5, 9, 2, "", 1]
MsgBox(test.LastIndexOf(2))  ; 3
MsgBox(test.LastIndexOf(7))  ; -1 (Not found)
```

#### `array.Map(callback)`

See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map.

##### Example

```autohotkey
test := [1, 4, 9, 16]
MsgBox(test.Map((value, *) => (value*2)).Print())  ; "[2, 8, 18, 32]"
MsgBox(test.Print())  ; "[1, 4, 9, 16]"
```

#### `array.Push(elements*)`

See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/push.

#### `array.Reduce(callback[, initialValue])`

See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/Reduce.

##### Example

```autohotkey
test := ["a", "b", "a", "b", "c", "e", "e", "c", "d", "d", "d", "d"]
MsgBox(test.Reduce(Reduce, []).Print())  ; "["a", "b", "c", "e", "d"]"

Reduce(accumulator, currentValue, *) {
	if (accumulator.IndexOf(currentValue) == -1) {
		accumulator.Push(currentValue)
	}

	return (accumulator)
}
```

#### `array.ReduceRight(callback[, initialValue])`

See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/ReduceRight.

##### Example

```autohotkey
test := [[0, 1], [2, 3], [4, 5]]
MsgBox(test.ReduceRight((value1, value2, *) => (value1.Concat(value2))).Print())  ; "[4, 5, 2, 3, 0, 1]"
```

#### `array.Reverse()`

See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/reverse.

##### Example

```autohotkey
MsgBox([0, 1, 2, 3, "", 5].Reverse().Print())  ; "[5, "", 3, 2, 1, 0]"
```

#### `array.Shift()`

See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/shift.

#### `array.Slice([start, end])`

See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/slice.

##### Example

```autohotkey
test := ["Ant", "Bison", "Camel", "Duck", "Elephant"]
MsgBox(test.slice(2).Print())  ; "["Camel", "Duck", "Elephant"]"
```

#### `array.Some(callback)`

See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/some.

##### Example

```autohotkey
test := [1, 2, 3, 4, 5]
MsgBox(test.Some((value, *) => (Mod(value, 2) == 0)))  ; 1 (False)
```

#### `array.Sort(callback)`

See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/sort.

Due to changes in v2, it is no longer possible to compare strings with greater than/less than and so instead of imposing checks for value types to facilitate a default sort `callback`, `callback` is now a required parameter.

##### Example

```autohotkey
test := ["March", "Jan", "Feb", "Dec"]
MsgBox(test.Sort((value1, value2) => (StrCompare(value1, value2, True))).Print())  ; "["Dec", "Feb", "Jan", "March"]"

test := [1, 30, 4, 21, 100000]
MsgBox(test.Sort((value1, value2) => ((value1 < value2) ? (-1) : ((value1 > value2) ? (1) : (0)))).Print())  ; "[1, 4, 21, 30, 100000]"
```

#### `array.Splice(start[, deleteCount, elements*])`

See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/splice.

##### Example

```autohotkey
test := ["angel", "clown", "mandarin", "sturgeon"]
MsgBox(test.Splice(2, 0, "drum").Print())  ; "[]"
MsgBox(test.Print())  ; "["angel", "clown", "drum", "mandarin", "sturgeon"]"
```

#### `array.UnShift(elements*)`

See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/unshift.

## Object methods

#### `array.Print()`

Converts an object into a string to more easily see the structure.

##### Example

```autohotkey
MsgBox({One: 1, Two: 2, Three: 3, Four: 4, Five: 5}.Print())  ; "{Five: 5, Four: 4, One: 1, Three: 3, Two: 2}"
```
