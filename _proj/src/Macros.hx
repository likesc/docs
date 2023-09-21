package;

class Macros {

	macro static public function text(node) {
		return macro ($node: js.html.Element).innerText;
	}

}