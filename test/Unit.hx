
import utest.Runner;
import utest.ui.Report;

class Unit {

	/*
	static function _trace( v : Dynamic, ?pos : haxe.PosInfos ) {

		var msg = pos.fileName+':'+pos.lineNumber+': '+v;
		om.Console.println( msg );

		#if web
		var e = js.Browser.document.createDivElement();
		e.textContent = StringTools.htmlEscape( msg );
        js.Browser.document.body.appendChild( e );
		#end
    }
	*/

	static function main() {

		//haxe.Log.trace = Unit._trace;

		var runner = new Runner();

		runner.addCase( new TestStateMachine() );

		var report = Report.create( runner );

		runner.run();
	}

}
