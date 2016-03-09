
import js.Browser.document;
import js.Browser.window;
import js.html.DivElement;
import js.html.ButtonElement;
import om.StateMachine;

/*
@sm([
	//{ name: 'start', from: 'none',   to: 'green'  },
	//{ name: 'warn',  from: 'green',  to: 'yellow' },
	//{ name: 'panic', from: 'green',  to: 'red'    },
	//{ name: 'panic', from: 'yellow', to: 'red'    },
	//{ name: 'calm',  from: 'red',    to: 'yellow' },
	{ name: 'clear', from: 'red',    to: 'green'  },
	//{ name: 'clear', from: 'yellow', to: 'green'  }
])
private class AnotherStateMachine extends StateMachine {}
*/

//@sm('testscript.json')
@sm('{
	{ "name": "start", from: "none",   to: "green"  },
	{ "name": "warn",  from: "green",  to: "yellow" },
	{ "name": "panic", from: "green",  to: "red"    },
	{ "name": "panic", from: "yellow", to: "red"    },
	{ "name": "calm",  from: "red",    to: "yellow" },
	{ "name": "clear", from: "red",    to: "green"  },
	{ "name": "clear", from: "yellow", to: "green"  }
}')
private class AnotherStateMachine extends StateMachine {}

class App {

    public var dom(default,null) : DivElement;

    var demo : DivElement;
	var diagram : DivElement;
	var output : DivElement;
	var clear : ButtonElement;
	var calm : ButtonElement;
	var warn : ButtonElement;
	var panic : ButtonElement;
	var count = 0;
	var sm : StateMachine;

    function new() {

        dom = document.createDivElement();

        demo = document.createDivElement();
		demo.classList.add( 'green' );

		var controls = document.createDivElement();
		dom.appendChild( controls );

		var addControlButton = function(name:String){
			var btn = document.createButtonElement();
			btn.id = name;
			btn.textContent = name;
			btn.onclick = handleButtonClick;
			controls.appendChild( btn );
			return btn;
		}
		clear = addControlButton( 'clear' );
		calm = addControlButton( 'calm' );
		warn = addControlButton( 'warn' );
		panic = addControlButton( 'panic' );

		diagram = document.createDivElement();
		diagram.id = 'statemachine-diagram';
		dom.appendChild( diagram );

		output = document.createDivElement();
		dom.appendChild( output );

		sm = new AnotherStateMachine();
		sm.add( 'start', ['none'],   'green' );
		sm.add( 'warn',  ['green'],  'yellow' );
		sm.add( 'panic', ['green'],  'red' );
		sm.add( 'panic', ['yellow'], 'red' );
		sm.add( 'calm',  ['red'],    'yellow' );
		sm.add( 'clear', ['red'],    'green' );
		sm.add( 'clear', ['yellow'], 'green' );
		/*
		sm = StateMachine.create([
			{ name: 'start', from: 'none',   to: 'green'  },
      		{ name: 'warn',  from: 'green',  to: 'yellow' },
      		{ name: 'panic', from: 'green',  to: 'red'    },
      		{ name: 'panic', from: 'yellow', to: 'red'    },
      		{ name: 'calm',  from: 'red',    to: 'yellow' },
      		{ name: 'clear', from: 'red',    to: 'green'  },
      		{ name: 'clear', from: 'yellow', to: 'green'  },
		]);
		*/

		//sm.onBeforeEvent = function(e) trace( 'BEFORE '+e.event );
		sm.onLeave = function(e) { log( 'LEAVE '+e.from ); return true; }
		sm.onEnter = function(e) log( 'ENTER '+e.to );
		sm.onChange = function(e,?params) log( 'CHANGED from ${e.from} to ${e.to} [$params]' );
		sm.onAfter = function(e) log( 'AFTER '+e.from );
		sm.onError = function(e) log( 'ERROR '+e.type+' from '+e.from+' to '+e.to );
		//sm.onAfterEvent = function(e) log( 'AFTER '+e.event );
		sm.onCancel = function(e) log( 'CANCELLED '+e.event );
    }

    function start() {
        sm.start();
    }

    function log( msg : String, separate = false ) {

		count = count + (separate ? 1 : 0);
		output.innerHTML = '<br>'+count+": "+msg+"\n"+(separate?"\n":"")+output.innerHTML;

		demo.className = sm.current;
		diagram.className = sm.current;
		//diagram.style.background = 'url(image/alerts.${sm.current}.png);';

		panic.disabled = sm.cannot( 'panic' );
	    warn.disabled  = sm.cannot( 'warn' );
		calm.disabled  = sm.cannot( 'calm' );
    	clear.disabled = sm.cannot( 'clear' );
	}

	function handleButtonClick(e) {
		sm.change( e.target.id );
	}

    static function main() {
        window.onload = function(_){
            var app = new App();
            document.body.appendChild( app.dom );
            app.start();
        }
    }
}
