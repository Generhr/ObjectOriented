#Requires AutoHotkey v2.0-beta.12

;============ Auto-Execute ====================================================;
;--------------  Include  ------------------------------------------------------;

#Include ..\..\Core.ahk

#Include ..\..\Assert\Assert.ahk
#Include ..\..\Console\Console.ahk

;--------------  Setting  ------------------------------------------------------;

#SingleInstance
#Warn All, MsgBox
#Warn LocalSameAsGlobal, Off

ListLines(False)
ProcessSetPriority("Normal")

;---------------- Test --------------------------------------------------------;
;-------------------------------------------------------  Range  ---------------;
Assert.SetLabel("Range")

for test in [[10, "", "", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]], [1, 20, "", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]], [5, 20, "", [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]], [0, 30, 3, [0, 3, 6, 9, 12, 15, 18, 21, 24, 27]], [0, 50, 5, [0, 5, 10, 15, 20, 25, 30, 35, 40, 45]], [2, 25, 2, [2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24]], [0, 30, 4, [0, 4, 8, 12, 16, 20, 24, 28]], [15, 25, 3, [15, 18, 21, 24]], [25, 2, -2, [25, 23, 21, 19, 17, 15, 13, 11, 9, 7, 5, 3]], [30, 1, -4, [30, 26, 22, 18, 14, 10, 6, 2]], [25, -6, -3, [25, 22, 19, 16, 13, 10, 7, 4, 1, -2, -5]]] {
	Assert.IsEqual(Range(test[0], test[1] || Unset, test[2] || Unset), test[3])
}

;-------------------------------------------------- Negative Lookups ----------;
Assert.SetLabel("Negative Lookups")

Assert.IsEqual([0, 1, 2, 3, 4][-1], 4)
Assert.IsEqual([0, 1, 2, 3, 4][-5], 0)

;------------------------------------------------------- Length ---------------;
Assert.SetLabel("Length")

test := [1, , 3]
Assert.IsEqual(test.Length, 3)
test.Length := 5
Assert.IsEqual(test, [1, "", 3, "", ""])
Assert.IsEqual(test.Length, 5)
;(test := [])[9] := 10  ;~ This now throws an error and I think that's fine. Arrays need to explicitly have their `.Length` increased.
;Assert.IsEqual(test.Length, 10)

;------------------------------------------------------  Compact  --------------;
Assert.SetLabel("Compact")

Assert.IsEqual([0, [0, 0], 0, 0].Compact(1), [[]])
Assert.IsEqual([0, [0, 0], 0, 0].Compact(0), [[0, 0]])
Assert.IsEqual([0, 0, 0, 0, 0].Compact(), [])
Assert.IsEqual([0, "", 1, 0, 0].Compact(), [1])

;-------------------------------------------------------  Empty  ---------------;
Assert.SetLabel("Empty")

test1 := test2 := [1, 2]
test1.Empty()
Assert.IsEqual(test1, test2)

;------------------------------------------------------- Remove ---------------;
Assert.SetLabel("Remove")

test := [0, 1, 2, "", "", 3]
Assert.IsEqual(test.Remove(""), [0, 1, 2, 3])

nested := [3]
test := [0, 1, 2, nested, [3], nested, 4]
Assert.IsEqual(test.Remove(nested), [0, 1, 2, [3], 4])

;-------------------------------------------------------- Swap ----------------;
Assert.SetLabel("Swap")

temp := {1: .10}
Assert.IsEqual([{1: .10, 2: [.2]}, [2], 3, , 5].Swap(0, 4), [5, [2], 3, , {1: .1, 2: [.2]}])
try {
	e := [1, 2, 3].Swap(2, 5)
}
catch {
	e := "*Swap"
}
Assert.IsEqual(e, "*Swap")

;------------------------------------------------------- Unique ---------------;
Assert.SetLabel("Unique")

nested := [0]
test := [nested, "1", 1, 2, [3], [4], 2, 2, a := {Five: 5}, "", "", a, a]
Assert.IsEqual(test.Concat([nested, nested]).Unique(), [[0], 1, 2, [3], [4], {Five: 5}, ""])

;------------------------------------------------------- Concat ---------------;
Assert.SetLabel("Concat")

test := [[2, 3], [4, 5, 6], [8, 9, 10]]
Assert.IsEqual([1].Concat(test[0], test[1], 7, test[2]), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
Assert.IsEqual([1].Concat([2], [], {3: "Three"}, [[4]], "", 6), [1, 2, {3: "Three"}, [4], "", 6])
test1 := ["a", "b", "c"]
test2 := ["d", "e", "f"]
array3 := test1.concat(test2)
Assert.IsEqual(test1, ["a", "b", "c"])

;-------------------------------------------------------  Every  ---------------;
Assert.SetLabel("Every")

test := [1, 30, 39, 29, 10, 13]
Assert.IsTrue(test.Every((value, *) => (value < 40)))
test.Push(40)
Assert.IsFalse(test.Every((value, *) => (value < 40)))
test := [1, "", 39, "", 10, 13]
Assert.IsTrue(test.Every((value, *) => (value < 40)))
Assert.IsEqual(test, [1, "", 39, "", 10, 13])

(test := [1, 2, 3, 4]).Every(Every1)
Assert.IsEqual(test, [1, 1, 2, 3])

Every1(value, index, array) {
	array[index + 1] -= 1

	return (value < 2)
}

(test := [1, 2, 3]).Every(Every2)
Assert.IsEqual(test, [1, 2, 3, "New", "New", "New"])

Every2(value, index, array) {
	array.Push("New")

	return (value is Number && value < 4)
}

(test := [1, 2, 3, 4]).Every(Every3)
Assert.IsEqual(test, [1, 2])

Every3(value, index, array) {
	array.Pop()

	return (value < 4)
}

;-------------------------------------------------------- Fill ----------------;
Assert.SetLabel("Fill")

test := [1, 2, 3, 4]
Assert.IsEqual(test.Fill(0), [0, 0, 0, 0])
Assert.IsEqual(test.Fill(1, -3, -1), [0, 1, 1, 0])
Assert.IsEqual(test.Fill(0, 2, 4).Fill(5, 1).Fill(6), [6, 6, 6, 6])
test.Fill({})[0].key := "value"
Assert.IsEqual(test, [{key: "value"}, {key: "value"}, {key: "value"}, {key: "value"}])

;------------------------------------------------------- Filter ---------------;
Assert.SetLabel("Filter")

Assert.IsEqual(["Spray", "Limit", "Elite", "Exuberant", "Destruction", "Present"].Filter((value, *) => (StrLen(value) > 5)), ["Exuberant", "Destruction", "Present"])
Assert.IsEqual([4, 6, 8, 9, 12, 53, -17, 2, 5, 7, 31, 97, -1, 17].Filter(IsPrime), [53, 2, 5, 7, 31, 97, 17])

IsPrime(value, *) {
	if (value < 2 || value is Float) {
		return (False)
	}

	loop (Floor(Sqrt(value))) {
		if (A_Index > 1 && Mod(value, A_Index) == 0) {
			return (False)
		}
	}

	return (True)
}

test := ["Spray", "Limit", "Exuberant", "Destruction", "Elite", "Present"].Filter(Filter1)
Assert.IsEqual(test, ["Spray"])

Filter1(word, index, array) {
	array[index + 1] .= " extra"

	return (word.Length < 6)
}

test := ["Spray", "Limit", "Exuberant", "Destruction", "Elite", "Present"].Filter(Filter2)
Assert.IsEqual(test, ["Spray", "Limit" , "Elite"])

Filter2(word, index, array) {
	array.Push("New")

	return (word.Length < 6)
}

test := ["Spray", "Limit", "Exuberant", "Destruction", "Elite", "Present"].Filter(Filter3)
Assert.IsEqual(test, ["Spray", "Limit"])

Filter3(word, index, array) {
	array.Pop()

	return (word.Length < 6)
}

;-------------------------------------------------------- Find ----------------;
Assert.SetLabel("Find")

test := [5, 12, 8, 130, 44]
Assert.IsEqual(test.Find((value, *) => (value > 10)), 12)

;-----------------------------------------------------  FindIndex  -------------;
Assert.SetLabel("FindIndex")

Assert.IsEqual([5, 12, 8, 130, 44].FindIndex((value, *) => (value > 12)), 3)

;-------------------------------------------------------- Flat ----------------;
Assert.SetLabel("Flat")

Assert.IsEqual([1, 2, "", 3, [[4]], [5]].Flat(), [1, 2, 3, [4], 5])
Assert.IsEqual([1, 2, [3, 4]].Flat(), [1, 2, 3, 4])
Assert.IsEqual([1, 2, [3, 4, [5, 6]]].Flat(), [1, 2, 3, 4, [5, 6]])
Assert.IsEqual([1, 2, [3, 4, [5, 6]]].Flat(2), [1, 2, 3, 4, 5, 6])
Assert.IsEqual([1, 2, [{3: "Three"}, "", [4, 5, [6, 7, [8, [[[[9]]]]]]]]].Flat(5000), [1, 2, {3: "Three"}, 4, 5, 6, 7, 8, 9])

;------------------------------------------------------  ForEach  --------------;
Assert.SetLabel("ForEach")

(obj := Counter()).Add([2, 5, 9])
Assert.IsEqual(obj.Sum, 16)
Assert.IsEqual(obj.Count, 3)

class Counter {

	__New() {
	  this.Sum := 0, this.Count := 0
	}

	Add(obj) {
		obj.ForEach((entry, *) => (this.Sum += entry, ++this.Count))
	}
 }

(words := ["one", "two", "three", "four"]).ForEach((word, *) => ((word == "two") ? (words.shift()) : ("")))
Assert.IsEqual(words, ["two", "three", "four"])

;------------------------------------------------------ Includes --------------;
Assert.SetLabel("Includes")

test := [1, 2, 3]
Assert.IsFalse(test.Includes("3", 3))
Assert.IsFalse(test.Includes("3", 100))
Assert.IsTrue(test.Includes("1", -10))
Assert.IsFalse(test.Includes("1", -2))
test[1] := ""
Assert.IsTrue(test.Includes(""))
Assert.IsFalse(["Red", "Green", "bLUe"].Includes("Blue"))

;------------------------------------------------------  IndexOf  --------------;
Assert.SetLabel("IndexOf")

test := ["ant", "bison", "camel", "", "bison"]
Assert.IsEqual(test.IndexOf("bison"), 1)
Assert.IsEqual(test.IndexOf("bison", 2), 4)
Assert.IsEqual(test.IndexOf("Marco"), -1)

;-------------------------------------------------------- Join ----------------;
Assert.SetLabel("Join")

test := [1, "", "3", "", "Five"]
Assert.IsEqual(test.Join(" + "), "1 +  + 3 +  + Five")
Assert.IsEqual(test.Join(""), "13Five")

;----------------------------------------------------  LastIndexOf  ------------;
Assert.SetLabel("LastIndexOf")

test := [2, 5, 9, 2, "", 1]
Assert.IsEqual(test.LastIndexOf(2), 3)
Assert.IsEqual(test.LastIndexOf(7), -1)
Assert.IsEqual(test.LastIndexOf(2, 3), 3)
Assert.IsEqual(test.LastIndexOf(2, 2), 0)
Assert.IsEqual(test.LastIndexOf(2, -4), 0)
Assert.IsEqual(test.LastIndexOf(2, -1), 3)

;--------------------------------------------------------  Map  ----------------;
Assert.SetLabel("Map")

test := [1, 4, 9, 16]
Assert.IsEqual(test.Map((value, *) => (value*2)), [2, 8, 18, 32])
Assert.IsEqual(test, [1, 4, 9, 16])

;--------------------------------------------------------  Pop  ----------------;
Assert.SetLabel("Pop")

test := ["broccoli", "cauliflower"]
Assert.IsEqual(test.Pop(), "cauliflower")
Assert.IsEqual(test, ["broccoli"])
test.Pop()
Assert.IsEqual(test, [])

;-------------------------------------------------------- Push ----------------;
Assert.SetLabel("Push")

test := ["pigs", "goats", "sheep"]
Assert.IsEqual(test.Push("", ["cows", "", "horses"]), 5)
Assert.IsEqual(test, ["pigs", "goats", "sheep", "", ["cows", "", "horses"]])

;------------------------------------------------------- Reduce ---------------;
Assert.SetLabel("Reduce")

Assert.IsEqual([1].Reduce(Reduce1), 1)
test := [1, 2, 3, 4]
Assert.IsEqual(test.Reduce(Reduce1), 10)
Assert.IsEqual(test.Reduce(Reduce1, 5), 15)
Assert.IsEqual([1].Reduce(Reduce1), 1)
Assert.IsEqual([1, 0, 3].Reduce(Reduce1), 4)
try {
	e := [].Reduce(Reduce1)
}
catch {
	e := "*Reduce"
}
Assert.IsEqual(e, "*Reduce")

Reduce1(accumulator, currentValue, *) {
	return (accumulator + currentValue)
}

test := ["a", "b", "a", "b", "c", "e", "e", "c", "d", "d", "d", "d"]
Assert.IsEqual(test.Reduce(Reduce2, []), ["a", "b", "c", "e", "d"])

Reduce2(accumulator, currentValue, *) {
	if (accumulator.IndexOf(currentValue) == -1) {
		accumulator.Push(currentValue)
	}

	return (accumulator)
}

;----------------------------------------------------  ReduceRight  ------------;
Assert.SetLabel("ReduceRight")

Assert.IsEqual([[0, 1], [2, 3], [4, 5]].ReduceRight((value1, value2, *) => (value1.Concat(value2))), [4, 5, 2, 3, 0, 1])
Assert.IsEqual([[0, 1]].ReduceRight((value1, value2, *) => (value1.Concat(value2))), [0, 1])

;------------------------------------------------------  Reverse  --------------;
Assert.SetLabel("Reverse")

test := ["One", "Two", "Three", "", 5]
Assert.IsEqual(test.Reverse(), [5, "", "Three", "Two", "One"])
Assert.IsEqual(test, [5, "", "Three", "Two", "One"])

;-------------------------------------------------------  Shift  ---------------;
Assert.SetLabel("Shift")

test := ["1", 2, "Three", , 5]
Assert.IsEqual(test.Shift(), 1)
Assert.IsEqual(test, [2, "Three", , 5])
(test := [5]).Shift()
Assert.IsEqual(test, [])

;-------------------------------------------------------  Slice  ---------------;
Assert.SetLabel("Slice")

test := ["Ant", "Bison", "Camel", "Duck", "Elephant"]
Assert.IsEqual(test.slice(2), ["Camel", "Duck", "Elephant"])
Assert.IsEqual(test.slice(2, 4), ["Camel", "Duck"])
Assert.IsEqual(test.slice(1, 5), ["Bison", "Camel", "Duck", "Elephant"])
Assert.IsEqual(test.slice(-1), ["Elephant"])

;-------------------------------------------------------- Some ----------------;
Assert.SetLabel("Some")

Assert.IsTrue([1, 2, 3, 4, 5].Some((value, *) => (Mod(value, 2) == 0)))
Assert.IsFalse([1, 3, 5, 7, 9].Some((value, *) => (Mod(value, 2) == 0)))

;-------------------------------------------------------- Sort ----------------;  ;~ It is no longer possible to compare strings with greater than/less than and so `callback` is now a required parameter.
Assert.SetLabel("Sort")

Assert.IsEqual(["March", "Jan", "Feb", "Dec"].Sort((value1, value2) => (StrCompare(value1, value2, True))), ["Dec", "Feb", "Jan", "March"])
Assert.IsEqual([1, 30, 4, 21, 100000].Sort((value1, value2) => ((value1 < value2) ? (-1) : ((value1 > value2) ? (1) : (0)))), [1, 4, 21, 30, 100000])

;------------------------------------------------------- Splice ---------------;
Assert.SetLabel("Splice")

Assert.IsEqual((test := ["angel", "clown", "mandarin", "sturgeon"]).Splice(2, 0, "drum"), [])
Assert.IsEqual(test, ["angel", "clown", "drum", "mandarin", "sturgeon"])

Assert.IsEqual((test := ["angel", "clown", "mandarin", "sturgeon"]).Splice(2, 0, "drum", "guitar"), [])
Assert.IsEqual(test, ["angel", "clown", "drum", "guitar", "mandarin", "sturgeon"])

Assert.IsEqual((test := ["angel", "clown", "drum", "mandarin", "sturgeon"]).Splice(3, 1), ["mandarin"])
Assert.IsEqual(test, ["angel", "clown", "drum", "sturgeon"])

Assert.IsEqual(test.Splice(2, 1, "trumpet"), ["drum"])
Assert.IsEqual(test, ["angel", "clown", "trumpet", "sturgeon"])

Assert.IsEqual(test.Splice(0, 2, "parrot", "anemone", "blue"), ["angel", "clown"])
Assert.IsEqual(test, ["parrot", "anemone", "blue", "trumpet", "sturgeon"])

Assert.IsEqual(test.Splice(2, 2), ["blue", "trumpet"])
Assert.IsEqual(test, ["parrot", "anemone", "sturgeon"])

Assert.IsEqual((test := ["angel", "clown", "mandarin", "sturgeon"]).Splice(-2, 1), ["mandarin"])
Assert.IsEqual(test, ["angel", "clown", "sturgeon"])

Assert.IsEqual((test := ["angel", "clown", "mandarin", "sturgeon"]).Splice(2), ["mandarin", "sturgeon"])
Assert.IsEqual(test, ["angel", "clown"])

;------------------------------------------------------  UnShift  --------------;
Assert.SetLabel("UnShift")

test := [4, 5, 6]
Assert.IsEqual(test.UnShift(1, "", 3), 6)
Assert.IsEqual(test, [1, "", 3, 4, 5, 6])

;--------------------------------------------------------  Log  ----------------;

Console.KeyBoardHook := False, Console.MouseHook := False

Console.Log(Assert.CreateReport())

;---------------  Other  -------------------------------------------------------;

Exit()

;--------------- Hotkey -------------------------------------------------------;

#HotIf (WinActive(A_ScriptName))

	$F10:: {
		ListVars()

		KeyWait("F10")
	}

	~$^s:: {
		Critical(True)

		Sleep(200)
		Reload()
	}

#HotIf

~$Escape:: {
	ExitApp()
}