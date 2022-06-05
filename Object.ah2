#Requires AutoHotkey v2.0-beta

;============ Auto-Execute ====================================================;

PatchObjectPrototype()

;============== Function ======================================================;

PatchObjectPrototype() {

	;* object.Print()
	;* Description:
		;* Converts an object into a string to more easily see the structure.
	Object.Prototype.DefineProp("Print", {Call: Print})

	Print(this) {
		if (c := ObjOwnPropCount(this)) {
			for k, v in (r := "{", this.OwnProps()) {
				r .= k . ": " . ((IsObject(v)) ? ((v.HasProp("Print")) ? (v.Print()) : (Type(v))) : ((IsNumber(v)) ? (RegExReplace(v, "S)^0+(?=\d\.?)|(?=\.).*?\K\.?0*$")) : (Format("`"{}`"", v)))) . ((A_Index < c) ? (", ") : ("}"))
			}
		}
		else {
			r := "{}"
		}

		return (r)
	}
}
