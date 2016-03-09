
class Unit {

	static function _trace( v : Dynamic, ?pos : haxe.PosInfos ) {

		var msg = pos.fileName+':'+pos.lineNumber+': '+v;
		om.Console.println( msg );

		#if web
		var e = js.Browser.document.createDivElement();
		e.textContent = StringTools.htmlEscape( msg );
        js.Browser.document.body.appendChild( e );
		#end
    }

	static function run() {
		var r = new haxe.unit.TestRunner();
		r.add( new TestStateMachine() );
		r.run();
		//trace( r.result.toString() );
	}

	static function main() {

		haxe.Log.trace = Unit._trace;

		#if web
		js.Browser.window.onload = function(_) run();
		#else
		run();
		#end
	}
}
