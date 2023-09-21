package;

import Nvd.HXX;
 using StringTools;

class Main {

	static inline function one(s) return document.querySelector(s);

	static function mkitems( body : Element, side : Element ) {
		var stack = [];
		var last : Element = null;
		var frags = document.createDocumentFragment();
		var headers = body.querySelectorAll("h2, h3, h4");
		for (head in headers) {
			var head : Element = cast head;
			var desc = text(head);
			if (desc.fastCodeAt(0) == "!".code) { // skiped if text prefix with "!"
				text(head) = desc.substring(1);
				continue;
			}
			var rank = head.nodeName.fastCodeAt(1) - "0".code;
			var item = HXX( <li><a href="{{ '#' + head.id  }}">{{ desc }}</a></li> );
			while (item != last) {
				var len = stack.length;
				if (len == 0 || last == null) {
					frags.appendChild(item);
					stack.push(rank);
					last = item;
					continue;
				}
				var prev = stack[len - 1];
				if (rank == prev) {
					var parent = last.parentElement == null ? frags : last.parentElement;
					parent.appendChild(item);
				} else if (rank > prev) { // h3 > h2
					var ul = HXX( <ul/> );
					ul.appendChild(item);
					last.appendChild(ul);
					stack.push(rank);
				} else {
					stack.pop();
					last = last.parentElement;     // ul
					if (last != null)
						last = last.parentElement; // li
					continue;
				}
				last = item;
			}
		}
		side.appendChild(frags);
		return headers;
	}

	static function scrollspy( hfixed : Int, side : Element, nodes : js.html.NodeList ) {
		if (side.children.length == 0) {
			one("#content").style.marginLeft = "0";
			return;
		}
		if (nvd.Dt.getCss(side, "position") != "fixed")
			return;
		var offsets = [];
		var prev = 0;
		for (elem in nodes) {
			var elem : Element = cast elem;
			var curr = elem.offsetTop - hfixed;   // 100%
			var midd = curr + prev >> 1;          // 50%
			var goal = midd + (curr - midd >> 1); // 75%
			offsets.push(goal);
			prev = curr;
		}
		nodes = null;
		if (offsets.length == 0)
			return;
		var onscroll = function() {
			// cleanup
			var actives = side.querySelectorAll("." + "active");
			for (node in actives)
				(cast node : Element).className = "";
			// binary search
			var top = document.documentElement.scrollTop;
			var i = 0;
			var j = offsets.length - 1;
			while (i <= j) {
				var mid = i + j >> 1;
				if (top >= offsets[mid]) {
					if (mid + 1 <= j && top >= offsets[mid + 1]) {
						i = mid + 1;
						continue;
					}
					i = mid;
					break;
				} else {
					j = mid - 1;
				}
			}
			// if (i > j) return;
			// depth-first search
			var acc = [0];
			var link : Element = cast dsearch(side, i, acc);
			if (link == null)
				return;
			link.className = "active";
			var parent = link.parentElement;
			while (parent != null) {
				var ul = parent.parentElement;
				if (ul == null || ul.nodeName.toUpperCase() != "UL")
					break;
				parent = ul.parentElement;
				parent.querySelector("a").className = "active";
			}
		}
		window.onscroll = onscroll;
		onscroll();
	}

	static function dsearch( elem : Element, pos : Int, acc : Array<Int> ) {
		for (li in elem.children) {
			if (pos == acc[0])
				return li.firstChild;
			acc[0]++;
			if (li.children.length == 1)
				continue;
			var link = dsearch(li.children[1], pos, acc);
			if (link != null)
				return link;
		}
		return null;
	}

	static function main() {
		var body = one(".markdown-body");
		var side = one("#items");
		if (body == null || side == null)
			return;
		var nodes = mkitems(body, side);
		scrollspy(2, side, nodes);
	}
}
