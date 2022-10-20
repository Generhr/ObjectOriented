#Requires AutoHotkey v2.0-beta.12

/*
* MIT License
*
* Copyright (c) 2022 Onimuru
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

;============ Auto-Execute ====================================================;

PatchArray()

;============== Function ======================================================;
;---------------  Patch  -------------------------------------------------------;

PatchArray() {

	;------------------------------------------------------- __Item ---------------;

	__Default__Item_Get := Array.Prototype.GetOwnPropDesc("__Item").Get, Default__Item_Set := Array.Prototype.GetOwnPropDesc("__Item").Set  ;* Store the defualt implementation in a variable. This is done so that a reference can be retained even if the defualt implementation is deleted/overritten.

	Array.Prototype.DefineProp("__Item", {Get: __Custom__Item_Get, Set: __Custom__Item_Set})  ;* Override the default implementation with a custom version.

	__Custom__Item_Get(this, zeroIndex) {
		try {
			return (__Default__Item_Get(this, zeroIndex + (zeroIndex >= 0)))  ;* Delegate to the default implementation.
		}
		catch (IndexError as e) {
			throw (IndexError(e.Message, -2, zeroIndex))  ;* This is here to report a zero-based index in `e.Extra`.
		}
		catch (TypeError as e) {  ;* This error is triggered when you try to index with strings for example array["string"].
			throw (TypeError(e.Message, -2, e.Extra))  ;* This is here to point `e.What` to the actual origin of the error.
		}
	}

	__Custom__Item_Set(this, value, zeroIndex) {
		try {
			return (Default__Item_Set(this, value, zeroIndex + (zeroIndex >= 0)))
		}
		catch (IndexError as e) {
			throw (IndexError(e.Message, -2, zeroIndex))  ;~ When assigning or retrieving an array element, the absolute value of the index must be between 0 and the Length of the array, otherwise an exception is thrown. An array can be resized by inserting or removing elements with the appropriate method, or by assigning Length.
		}
		catch (TypeError as e) {
			throw (TypeError(e.Message, -2, e.Extra))
		}
	}

	;------------------------------------------------------- __Enum ---------------;

	__Default__Enum_Call := Array.Prototype.GetOwnPropDesc("__Enum").Call

	Array.Prototype.DefineProp("__Enum", {Call: __Custom__Enum_Call})  ;* Override the default dispatcher with a custom version.

	__Custom__Enum_Call(this, numberOfVars) {
		__DefaultEnum := __Default__Enum_Call(this, numberOfVars)  ;* Have the default dispatcher provide the original one based enumerator implementation.

		switch (numberOfVars) {
			case 1:
				return (__DefaultEnum)  ;* `for v in array`, no special handling needed since it enumerates the values only.
			case 2:
				return (__CustomEnum) ;* `for i, v in array`.

				__CustomEnum(&zeroIndex, &value) {
					if (__DefaultEnum(&oneIndex, &value)) {  ;* While the array has Items, retrieve one with `oneIndex` and assign Item to the for-loop's second value.
						zeroIndex := oneIndex - 1

						return (true)  ;* Continue enumerating since an Item had been returned.
					}
				}
			default:
				throw (ValueError("No matching Enumerator found for this many for-loop variables.", -2, numberOfVars))
		}
	}

	;--------------------------------------------------------  Has  ----------------;

	__DefaultHas_Call := Array.Prototype.GetOwnPropDesc("Has").Call

	Array.Prototype.DefineProp("Has", {Call: (this, index) => (__DefaultHas_Call(this, index + (index >= 0)))})

	;------------------------------------------------------ InsertAt --------------;

	__DefaultInsertAt_Call := Array.Prototype.GetOwnPropDesc("InsertAt").Call

	Array.Prototype.DefineProp("InsertAt", {Call: (this, index, values*) => (__DefaultInsertAt_Call(this, index + (index >= 0), values*))})

	;------------------------------------------------------ RemoveAt --------------;

	__DefaultRemoveAt_Call := Array.Prototype.GetOwnPropDesc("RemoveAt").Call

	Array.Prototype.DefineProp("RemoveAt", {Call: (this, index, length := 1) => ((length == 1) ? (__DefaultRemoveAt_Call(this, index + (index >= 0))) : (__DefaultRemoveAt_Call(this, index + (index >= 0), length)))})

	;------------------------------------------------------- Delete ---------------;

	__DefaultDelete_Call := Array.Prototype.GetOwnPropDesc("Delete").Call

	Array.Prototype.DefineProp("Delete", {Call: (this, index) => (__DefaultDelete_Call(this, index + (index >= 0)))})

	;-------------------------------------------------------  Print  ---------------;

	Array.Prototype.DefineProp("Print", {Call: __Print})

	/**
	 * Converts the array into a string.
	 * @returns {String}
	 */
	__Print(this) {
		if (length := this.Length) {
			out := "["

			for value in this {
				if (!IsSet(value)) {
					value := ""
				}

				out .= ((IsObject(value)) ? ((value.HasProp("Print")) ? (value.Print()) : (Type(value))) : ((IsNumber(value)) ? (RegExReplace(value, "S)^0+(?=\d\.?)|(?=\.).*?\K\.?0*$")) : (Format('"{}"', value)))) . ((A_Index < length) ? (", ") : ("]"))
			}
		}
		else {
			out := "[]"
		}

		return (out)
	}

	;------------------------------------------------------  Compact  --------------;

	Array.Prototype.DefineProp("Compact", {Call: __Compact})

	/**
	 * Removes all falsy values from the array.
	 * @returns {Array}
	 */
	__Compact(this, recursive := 0) {
		for element in (out := [], this) {
			if (element) {
				out.Push((recursive && element is Array) ? (element.Compact(recursive)) : (element))
			}
		}

		return (this := out)
	}

	;-------------------------------------------------------  Empty  ---------------;

	Array.Prototype.DefineProp("Empty", {Call: __Empty})

	/**
	 * Removes all elements from the array.
	 * @returns {Array}
	 */
	__Empty(this) {
		this.RemoveAt(0, this.Length)

		return (this)
	}

	;------------------------------------------------------- Remove ---------------;

	Array.Prototype.DefineProp("Remove", {Call: __Remove})

	/**
	 * Removes all occurences of `value` from the array.
	 * @returns {Array}
	 */
	__Remove(this, value) {
		length := this.Length, index := -1

		while (++index != length) {
			if (this[index] == value) {  ;* No need to get and compare object pointers since that's done automatically in v2.
				this.RemoveAt(index--), length--
			}
		}

		return (this)
	}

	;------------------------------------------------------- Sample ---------------;

	Array.Prototype.DefineProp("Sample", {Call: __Sample})

	/**
	 * Returns a new array with `number` random elements from the array.
	 * @returns {Array}
	 */
	__Sample(this, number) {
		if (!this.Length) {
			throw (IndexError("The array is empty.", -1))
		}

		return (this.Clone().Slice(0, number).Shuffle())
	}

	;------------------------------------------------------  Shuffle  --------------;

	Array.Prototype.DefineProp("Shuffle", {Call: __Shuffle})

	/**
	 * Shuffles all elements in the array.
	 * @see {@link https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle}
	 * @returns {Array}
	 */
	__Shuffle(this, callback?) {
		if (IsSet(callback) && !(callback is Func || callback is Closure)) {
			throw (TypeError("``callback`` must be a function.", -1, callback))
		}
		else {
			callback := Random
		}

		for index, value in (maxIndex := this.Length - 1, this) {
			newIndex := callback.Call(index, maxIndex)
				, temp := this[index], this[index] := this[newIndex], this[newIndex] := temp
		}

		return (this)
	}

	;-------------------------------------------------------- Swap ----------------;

	Array.Prototype.DefineProp("Swap", {Call: __Swap})

	/**
	 * Swap any two elements in the array.
	 * @returns {Array}
	 */
	__Swap(this, index1, index2) {
		if (this.Length < 2) {
			throw (IndexError("The array has less than 2 elements.", -1, this.Length))
		}

		temp := this[index1], this[index1] := this[index2], this[index2] := temp

		return (this)
	}

	;------------------------------------------------------- Unique ---------------;

	Array.Prototype.DefineProp("Unique", {Call: __Unique})

	/**
	 * Removes all duplicate values from the array such that all remaining values are unique.
	 * @returns {Array}
	 */
	__Unique(this) {
		index := this.Length

		while (--index != -1) {  ;* This is basically a `array.LastIndexOf()` method with a `array.IndexOf()` method inside of it but more efficient than using those methods as is.
			loop (element := this[index], index) {
				if (this[A_Index - 1] == element) {
					this.RemoveAt(index)

					break
				}
			}
		}

		return (this)
	}

/*
	** MDN: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array, https://javascript.info/array-methods **
*/

	;------------------------------------------------------- Concat ---------------;

	Array.Prototype.DefineProp("Concat", {Call: __Concat})

	/**
	 * Merges two or more arrays. This method does not change the existing arrays, but instead returns a new array.
	 * @example
	 * array1 := ["a", "b", "c"]
	 * array2 := ["d", "e", "f"]
	 *
	 * Console.Log(array1.Concat(array2))  ; ["a", "b", "c", "d", "e", "f"]
	 * @see {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/concat}
	 * @returns {Array}
	 */
	__Concat(this, values*) {
		for value in (out := this.Clone(), values) {  ;~ Original array is untouched.
			if (value is Array) {
				if (value.Length) {  ;* Ignore if empty.
					out.Push(value*)
				}
			}
			else {
				out.Push(value)
			}
		}

		return (out)
	}

	;-------------------------------------------------------  Every  ---------------;

	Array.Prototype.DefineProp("Every", {Call: __Every})

	/**
	 * Tests whether all elements in the array pass the test implemented by the provided function. It returns a Boolean value.
	 *
	 * Note: Calling this method on an empty array will return true for any condition.
	 * @see {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/every}
	 * @returns {Boolean}
	 */
	__Every(this, callback) {
		if (!(callback is Func || callback is Closure)) {
			throw (TypeError("``callback`` must be a function.", -1, Type(callback)))
		}

		index := -1, length := this.Length

		while (++index != length) {  ;~ The range of elements processed is set before the first invocation of `callback`. Therefore, `callback` will not run on elements that are appended to the array after the loop begins.
			try  {
				if ((element := this[index]) != "") {  ;~ `callback` is invoked only for indexes of the array which have assigned values; it is not invoked for indexes which have been deleted or which have never been assigned values.
					if (!callback.Call(element, index, this)) {
						return (false)
					}
				}
			}
			catch (IndexError) {
				break
			}
		}

		return (true)
	}

	;-------------------------------------------------------- Fill ----------------;

	Array.Prototype.DefineProp("Fill", {Call: __Fill})

	/**
	 * Changes all elements in an array to a static value, from a start index (default 0) to an end index (default array.Length). It returns the modified array.
	 * @see {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/fill}
	 * @returns {Array}
	 */
	__Fill(this, value, start := 0, end := "") {
		loop (start := (start >= 0) ? (Min(length := this.Length, start)) : (Max((length := this.Length) + start, 0)), ((end != "") ? ((end >= 0) ? (Min(length, end)) : (Max(length + end, 0))) : length) - start) {
			this[start++] := value
		}

		return (this)
	}

	;------------------------------------------------------- Filter ---------------;

	Array.Prototype.DefineProp("Filter", {Call: __Filter})

	/**
	 * Creates a shallow copy of a portion of a given array, filtered down to just the elements from the given array that pass the test implemented by the provided function.
	 * @see {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/filter}
	 * @returns {Array}
	 */
	__Filter(this, callback) {
		if (!(callback is Func || callback is Closure)) {
			throw (TypeError("``callback`` must be a function.", -1, Type(callback)))
		}

		out := []
			, index := -1, length := this.Length

		while (++index != length) {  ;~ The range of elements processed is set before the first invocation of `callback`. Therefore, `callback` will not run on elements that are appended to the array after the loop begins.
			try  {
				if ((element := this[index]) != "") {  ;~ `callback` is invoked only for indexes of the array which have assigned values; it is not invoked for indexes which have been deleted or which have never been assigned values.
					if (callback.Call(element, index, this)) {  ;~ Array elements which do not pass the callbackFn test are skipped, and are not included in the new array.
						out.Push(element)
					}
				}
			}
			catch (IndexError) {
				break
			}
		}

		return (out)
	}

	;-------------------------------------------------------- Find ----------------;

	Array.Prototype.DefineProp("Find", {Call: __Find})

	/**
	 * Returns the first element in the provided array that satisfies the provided testing function. If no values satisfy the testing function, undefined is returned.
	 * @see {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/find}
	 * @returns {Integer|Undefined}
	 */
	__Find(this, callback) {
		if (!(callback is Func || callback is Closure)) {
			throw (TypeError("``callback`` must be a function.", -1, Type(callback)))
		}

		index := -1, length := this.Length

		while (++index != length) {  ;~ The range of elements processed is set before the first invocation of `callback`. Therefore, `callback` will not run on elements that are appended to the array after the loop begins.
			try  {
				if (callback.Call(element := this[index], index, this)) {  ;~ `callback` is invoked for every index of the array, not just those with assigned values. This means it may be less efficient for sparse arrays, compared to methods that only visit assigned values.
					return (element)
				}
			}
			catch (IndexError) {
				break
			}
		}
	}

	;-----------------------------------------------------  FindIndex  -------------;

	Array.Prototype.DefineProp("FindIndex", {Call: __FindIndex})

	/**
	 * Returns the index of the first element in an array that satisfies the provided testing function. If no elements satisfy the testing function, -1 is returned.
	 *
	 * Note: If the index of the first element in the array that passes the test is 0, the return value will be interpreted as Falsy in conditional statements.
	 * @see {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/findIndex}
	 * @returns {Integer}
	 */
	__FindIndex(this, callback) {
		if (!(callback is Func || callback is Closure)) {
			throw (TypeError("``callback`` must be a function.", -1, Type(callback)))
		}

		index := -1, length := this.Length

		while (++index != length) {  ;~ The range of elements processed is set before the first invocation of `callback`. Therefore, `callback` will not run on elements that are appended to the array after the loop begins.
			try  {
				if (callback.Call(this[index], index, this)) {  ;~ `callback` is invoked for every index of the array, not just those with assigned values. This means it may be less efficient for sparse arrays, compared to methods that only visit assigned values.
					return (index)
				}
			}
			catch (IndexError) {
				break
			}
		}

		return (-1)
	}

	;-------------------------------------------------------- Flat ----------------;

	Array.Prototype.DefineProp("Flat", {Call: __Flat})

	/**
	 * Creates a new array with all sub-array elements concatenated into it recursively up to the specified depth.
	 * @see {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/flat}
	 * @returns {Array}
	 */
	__Flat(this, depth := 1) {
		for element in (out := [], this) {
			if (element is Array && depth > 0) {
				out := out.Concat(element.Flat(depth - 1))
			}
			else if (element != "") {  ;~ Ignore empty elements.
				out.Push(element)
			}
		}

		return (out)
	}

	;------------------------------------------------------  ForEach  --------------;

	Array.Prototype.DefineProp("ForEach", {Call: __ForEach})

	/**
	 * Executes a provided function once for each array element.
	 * @see {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/forEach}
	 */
	__ForEach(this, callback) {
		if (!(callback is Func || callback is Closure)) {
			throw (TypeError("``callback`` must be a function.", -1, Type(callback)))
		}

		index := -1, length := this.Length

		while (++index != length) {  ;~ The range of elements processed is set before the first invocation of `callback`. Therefore, `callback` will not run on elements that are appended to the array after the loop begins.
			try  {
				if ((element := this[index]) != "") {  ;~ `callback` is invoked only for indexes of the array which have assigned values; it is not invoked for indexes which have been deleted or which have never been assigned values.
					callback.Call(element, index, this)
				}
			}
			catch (IndexError) {
				break
			}
		}
	}

	;------------------------------------------------------ Includes --------------;

	/**
	 * Determines whether an array includes a certain value among its entries, returning true or false as appropriate.
	 *
	 * Note: String comparisons are case-sensitive.
	 * @see {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/includes}
	 * @returns {Boolean}
	 */
	Array.Prototype.DefineProp("Includes", {Call: (this, needle, start := 0) => (start < this.Length && this.IndexOf(needle, start) != -1)})  ;~ If `start` is greater than or equal to the length of the array, the array will not be searched.

	;------------------------------------------------------  IndexOf  --------------;

	Array.Prototype.DefineProp("IndexOf", {Call: __IndexOf})

	/**
	 * Returns the first index at which a given element can be found in the array, or -1 if it is not present.
	 *
	 * Note: String comparisons are case-sensitive.
	 * @see {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/indexOf}
	 * @returns {Integer}
	 */
	__IndexOf(this, needle, start := 0) {
		loop (length := this.Length, start := (start >= 0) ? (Min(length, start)) : (Max(length + start, 0)), length - start) {
			if (this[start] == needle) {
				return (start)
			}

			start++
		}

		return (-1)
	}

	;-------------------------------------------------------- Join ----------------;

	Array.Prototype.DefineProp("Join", {Call: __Join})

	/**
	 * Creates and returns a new string by concatenating all of the elements in an array (or an array-like object), separated by commas or a specified separator string. If the array has only one item, then that item will be returned without using the separator.
	 * @see {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/join}
	 * @returns {String}
	 */
	__Join(this, delimiter := ", ") {
		for index, element in (maxIndex := this.length - 1, this) {
			out .= (IsObject(element)) ? ((element is Array) ? (element.Join(delimiter)) : (Type(element))) : (element)

			if (index < maxIndex) {
				out .= delimiter
			}
		}

		return (out)
	}

	;----------------------------------------------------  LastIndexOf  ------------;

	Array.Prototype.DefineProp("LastIndexOf", {Call: __LastIndexOf})

	/**
	 * Returns the last index at which a given element can be found in the array, or -1 if it is not present. The array is searched backwards, starting at `start`.
	 *
	 * Note: String comparisons are case-sensitive.
	 * @see {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/lastIndexOf}
	 * @returns {Integer}
	 */
	__LastIndexOf(this, needle, start := -1) {
		start := (start >= 0) ? (Min(this.Length - 1, start + 1)) : (Max(this.Length + start + 1, -1))

		while (--start != -1) {
			if (this[start] == needle) {
				return (start)
			}
		}

		return (-1)
	}

	;--------------------------------------------------------  Map  ----------------;

	Array.Prototype.DefineProp("Map", {Call: __Map})

	/**
	 * Creates a new array populated with the results of calling a provided function on every element in the calling array.
	 * @see {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map}
	 * @returns {Array}
	 */
	__Map(this, callback) {
		if (!(callback is Func || callback is Closure)) {
			throw (TypeError("``callback`` must be a function.", -1, Type(callback)))
		}

		out := []
			, index := -1, length := this.Length

		while (++index != length) {  ;~ The range of elements processed is set before the first invocation of `callback`. Therefore, `callback` will not run on elements that are appended to the array after the loop begins.
			try  {
				out.Push(callback.Call(this[index], index, this))
			}
			catch (IndexError) {
				break
			}
		}

		return (out)
	}

	;-------------------------------------------------------- Push ----------------;

	Array.Prototype.DefineProp("Push", {Call: __Push})

	/**
	 * Adds one or more elements to the end of an array and returns the new length of the array.
	 * @see {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/push}
	 * @returns {Integer}
	 */
	__Push(this, values*) {
		this.InsertAt(this.Length, values*)

		return (this.Length)
	}

	;------------------------------------------------------- Reduce ---------------;

	Array.Prototype.DefineProp("Reduce", {Call: __Reduce})

	/**
	 * Executes a user-supplied "reducer" callback function on each element of the array, in order, passing in the return value from the calculation on the preceding element. The final result of running the reducer across all elements of the array is a single value.
	 *
	 * The first time that the callback is run there is no "return value of the previous calculation". If supplied, an initial value may be used in its place. Otherwise the array element at index 0 is used as the initial value and iteration starts from the next element (index 1 instead of index 0).
	 *
	 * Note: If `initialValue` is not provided, `callback` will be executed starting at index 1, skipping the first index. If `initialValue` is provided, it will start at index 0.
	 * @see {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/Reduce}
	 * @returns {Any}
	 */
	__Reduce(this, callback, initialValue := "") {
		if (!(callback is Func || callback is Closure)) {
			throw (TypeError("``callback`` must be a function.", -1, Type(callback)))
		}

		index := -1, length := this.Length

		if ((accumulator := initialValue) == "") {
			while (++index < length && (accumulator := this[index]) == "") {  ;~ If no `initialValue` is supplied, the first element in the array will be used as the initial `accumulator` value and not passed to `callback`.
				continue
			}

			if (index >= length) {
				throw (ValueError("The array is empty and no intital value was set in ``initialValue``.", -1, initialValue))  ;~ Calling `.Reduce()` on an empty array without an initial value creates a TypeError.
			}
		}

		while (++index != length) {
			if ((element := this[index]) != "") {
				accumulator := callback.Call(accumulator, element, index, this)  ;~ The return value of `callback` is assigned to `accumulator`, whose value is remembered across each iteration throughout the array, and ultimately becomes the final, single resulting value.
			}
		}

		return (accumulator)  ;~ If the array only has one element (regardless of position) and no `initialValue` is provided, or if `initialValue` is provided but the array is empty, the solo value will be returned without calling `callback`.
	}

	;----------------------------------------------------  ReduceRight  ------------;

	Array.Prototype.DefineProp("ReduceRight", {Call: __ReduceRight})

	/**
	 * Applies a function against an accumulator and each value of the array (from right-to-left) to reduce it to a single value.
	 * @see {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/ReduceRight}
	 * @returns {Any}
	 */
	__ReduceRight(this, callback, initialValue := "") {
		if (!(callback is Func || callback is Closure)) {
			throw (TypeError("``callback`` must be a function.", -1, Type(callback)))
		}

		index := this.Length

		if ((accumulator := initialValue) == "") {
			while (--index >= 0 && (accumulator := this[index]) == "") {  ;~ If no `initialValue` is supplied, the last element in the array will be used as the initial `accumulator` value and not passed to `callback`.
				continue
			}

			if (index < 0) {
				throw (ValueError("The array is empty and no intital value was set in ``initialValue``.", -1, initialValue))  ;~ Calling `.ReduceRight()` on an empty array without an initial value creates a TypeError.
			}
		}

		while (--index != -1) {
			if ((element := this[index]) != "") {
				accumulator := callback.Call(accumulator, element, index, this)
			}
		}

		return (accumulator)  ;~ If the array only has one element (regardless of position) and no `initialValue` is provided, or if `initialValue` is provided but the array is empty, the solo value will be returned without calling `callback`.
	}

	;------------------------------------------------------  Reverse  --------------;

	Array.Prototype.DefineProp("Reverse", {Call: __Reverse})

	/**
	 * Reverses an array in place and returns the reference to the same array, the first array element now becoming the last, and the last array element becoming the first. In other words, elements order in the array will be turned towards the direction opposite to that previously stated.
	 * @see {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/reverse}
	 * @returns {Array}
	 */
	__Reverse(this) {
		for index, element in (maxIndex := this.Length - 1, this) {
			this.InsertAt(maxIndex, this.RemoveAt(maxIndex - index))
		}

		return (this)
	}

	;-------------------------------------------------------  Shift  ---------------;

	/**
	 * Removes the first element from an array and returns that removed element. This method changes the length of the array.
	 * @see {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/shift}
	 * @returns {Any}
	 */
	Array.Prototype.DefineProp("Shift", {Call: (this) => (this.RemoveAt(0))})

	;-------------------------------------------------------  Slice  ---------------;

	Array.Prototype.DefineProp("Slice", {Call: __Slice})

	/**
	 * Returns a shallow copy of a portion of an array into a new array object selected from start to end (end not included) where start and end represent the index of items in that array. The original array will not be modified.
	 * @see {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/slice}
	 * @returns {Array}
	 */
	__Slice(this, start := 0, end := "") {
		loop (out := [], start := (start >= 0) ? (Min(length := this.Length, start)) : (Max((length := this.Length) + start, 0)), ((end != "") ? ((end >= 0) ? (Min(length, end)) : (Max(length + end, 0))) : (length)) - start) {
			out.Push(this[start++])
		}

		return (out)
	}

	;-------------------------------------------------------- Some ----------------;

	Array.Prototype.DefineProp("Some", {Call: __Some})

	/**
	 * Tests whether at least one element in the array passes the test implemented by the provided function. It returns true if, in the array, it finds an element for which the provided function returns true; otherwise it returns false. It doesn't modify the array.
	 *
	 * Note: Calling this method on an empty array returns false for any condition.
	 * @see {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/some}
	 * @returns {Boolean}
	 */
	__Some(this, callback) {
		if (!(callback is Func || callback is Closure)) {
			throw (TypeError("``callback`` must be a function.", -1, Type(callback)))
		}

		index := -1, length := this.Length

		while (++index != length) {  ;~ The range of elements processed is set before the first invocation of `callback`. Therefore, `callback` will not run on elements that are appended to the array after the loop begins.
			try  {
				if ((element := this[index]) != "" && callback.Call(element, index, this)) {  ;~ `callback` is invoked only for indexes of the array which have assigned values; it is not invoked for indexes which have been deleted or which have never been assigned values.
					return (true)
				}
			}
			catch (IndexError) {
				break
			}
		}

		return (false)
	}

	;-------------------------------------------------------- Sort ----------------;

	Array.Prototype.DefineProp("Sort", {Call: __Sort})

	/**
	 * Sorts the elements of an array in place and returns the reference to the same array, now sorted. The default sort order is ascending, built upon converting the elements into strings, then comparing their sequences of UTF-16 code units values.
	 *
	 * The time and space complexity of the sort cannot be guaranteed as it depends on the implementation.
	 * @see {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/sort}
	 * @returns {Array}
	 */
	__Sort(this, callback) {
		if (!(callback is Func || callback is Closure)) {
			throw (TypeError("``callback`` must be a function.", -1, Type(callback)))
		}

		maxIndex := this.Length - 1, bool := true

		while (bool != false) {
			bool := false

			loop (maxIndex) {
				if (callback.Call(this[index := A_Index - 1], this[A_Index]) > 0) {
					bool := true

					temp := this[index], this[index] := this[A_Index], this[A_Index] := temp
				}
			}
		}

		return (this)
	}

	;------------------------------------------------------- Splice ---------------;

	Array.Prototype.DefineProp("Splice", {Call: __Splice})

	/**
	 * Changes the contents of an array by removing or replacing existing elements and/or adding new elements in place. To access part of an array without modifying it, see `array.Slice()`.
	 * @see {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/splice}
	 * @returns {Array}
	 */
	__Splice(this, start, deleteCount := "", elements*) {
		loop (out := [], start := (start >= 0) ? (Min(length := this.Length, start)) : (Max((length := this.Length) + start, 0)), (deleteCount != "") ? (Max((length <= start + deleteCount) ? (length - start) : (deleteCount), 0)) : ((elements.Length) ? (0) : (length - start))) {
			out.Push(this.RemoveAt(start))
		}

		if (elements.Length) {
			this.InsertAt(start, elements*)
		}

		return (out)  ;~ If no elements are removed, an empty array is returned.
	}

	;------------------------------------------------------  UnShift  --------------;

	Array.Prototype.DefineProp("UnShift", {Call: __UnShift})

	/**
	 * Adds one or more elements to the beginning of an array and returns the new length of the array.
	 * @see {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/unshift}
	 * @returns {Integer}
	 */
	__UnShift(this, elements*) {
		this.InsertAt(0, elements*)

		return (this.Length)
	}
}

;---------------  Other  -------------------------------------------------------;

/**
 * Returns an object in string form.
 * @param {Any} input - The object to turn into a string.
 * @returns {String}
 */
Print(input) {
	if (input is Array) {
		if (length := input.Length) {
			for value in (out := "[", input) {
				if (!IsSet(value)) {
					value := ""
				}

				out .= ((IsObject(value)) ? (Print(value)) : ((IsNumber(value)) ? (RegExReplace(value, "S)^0+(?=\d\.?)|(?=\.).*?\K\.?0*$")) : (Format('"{}"', value)))) . ((A_Index < length) ? (", ") : ("]"))
			}
		}
		else {
			out := "[]"
		}
	}
	else if (input is Object) {
		if (count := ObjOwnPropCount(input)) {
			for key, value in (out := "{", input.OwnProps()) {
				out .= key . ": " . ((IsObject(value)) ? (Print(value)) : ((IsNumber(value)) ? (RegExReplace(value, "S)^0+(?=\d\.?)|(?=\.).*?\K\.?0*$")) : (Format('"{}"', value)))) . ((A_Index < count) ? (", ") : ("}"))
			}
		}
		else {
			out := "{}"
		}
	}
	else {
		out := input
	}

	return (out)
}

/**
 * Returns an array that consists series of integer numbers.
 * @param {Integer} start - The starting position of the sequence. The default value is 0 if not specified.
 * @param {Integer} [stop] - An integer number specifying at which position to stop (upper limit).
 * @param {Integer} [step] - The increment value. Each next number in the sequence is generated by adding the step value to a preceding number.
 * @see {@link https://pynative.com/python-range-function/}
 * @returns {Integer[]}
 */
Range(start, stop := start, step := 1) {
	if (start == stop) {
		start := 0
	}

	if (!(IsInteger(start) && IsInteger(stop) && IsInteger(step))) {
		throw (TypeError("``start``, ``stop`` and ``step`` must be integers.", -1, Format("{}, {}, {}", start, stop, step)))
	}

	loop (out := [], Max(Ceil((stop - start)/step), 0)) {
		out.Push(start), start += step
	}

	return (out)
}