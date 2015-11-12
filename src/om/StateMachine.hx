package om;

import haxe.ds.StringMap;

typedef TransitionEvent = {
	var event : String;
	var from : String;
	var to : String;
}

//enum abstract TransitionErrorType {
//@:enum abstract TransitionErrorType(Int) {
@:enum abstract TransitionErrorType(String) {
	var noEvent = 'no_event';
	var noTransition = 'no_transition';
	var notAllowed = 'not_allowed';
	var pendingTransition = 'pending_transition';
	var noPendingTransition = 'no_pending_transition';
}

typedef TransitionErrorEvent = { > TransitionEvent,
	var type : TransitionErrorType;
}

private typedef Transition = {
	var from : Array<String>;
	var to : String;
}

/**
	Finite state machine.

	TODO
		- from * wildcards
		? @:autoBuild strict sm
*/
//@:autoBuild(tron.macro.BuildStateMachine.build())
class StateMachine {

	public static inline var STATE_NONE = 'none';
	public static inline var STATE_START = 'start';
	//public static inline var ASYNC = 'async';

	public dynamic function onBeforeStart() {}
	public dynamic function onStart() {}

	public dynamic function onBeforeEvent( e : TransitionEvent ) {}
	public dynamic function onLeave( e : TransitionEvent ) : Bool { return true; }
	public dynamic function onEnter( e : TransitionEvent ) {}
	public dynamic function onChange<T>( e : TransitionEvent, ?params : T ) {}
	public dynamic function onAfter( e : TransitionEvent ) {}
	public dynamic function onAfterEvent( e : TransitionEvent ) {}

	public dynamic function onCancel( e : TransitionEvent ) {}

	/** Custom error handler */
	public var onError : TransitionErrorEvent->Void;

	/** Current state */
	public var current(default,null) : String;

	var map : StringMap<Array<Transition>>;
	var pending : TransitionEvent;

	public function new( ?initialState : String ) {
		current = (initialState != null) ? initialState : STATE_NONE;
		map = new StringMap();
	}

	/**
		Register transition for event.
	*/
	public function add( e : String, from : Array<String>, to : String ) {
		//var transition = { from: Std.is( from, String )?[from]:from, to: to };
		var transition = { from: from, to: to };
		if( map.exists( e ) ) {
			map.get( e ).push( transition );
		} else {
			map.set( e, [transition] );
		}
	}

	/**
		Return true if s is the current state
	*/
	public inline function is( s : String ) : Bool
		return s == current;

	/**
		Return true if event e can be fired in the current state
	*/
	public function can( e : String ) : Bool {
		for( e in map.get( e ) )
			for( from in e.from )
				if( from == current )
					return true;
		return false;
	}

	/**
		Return true if event e cannot be fired in the current state
	*/
	public inline function cannot( e : String ) : Bool
		return !can( e );

	/**
	*/
	public function start() {
		onBeforeStart();
		change( STATE_START );
		onStart();
	}

	/**
		Return list of events that are allowed from the current state
	*/
	public function transitions() : Array<String> {
		var allowed = new Array<String>();
		for( key in map.keys() ) {
			for( transition in map.get( key ) ) {
				for( from in transition.from ) {
					if( from == current ) {
						allowed.push( key );
					}
				}
			}
		}
		return allowed;
	}

	/**
		Change state.
	*/
	public function change<T>( e : String, ?params : T ) {

		if( pending != null ) {
			handleError( e, current, null, pendingTransition );
			return;
		}

		if( !map.exists( e ) ) {
			handleError( e, current, null, noEvent );
			return;
		}

		var transition : Transition = null;
		for( t in map.get( e ) ) {
			for( from in t.from ) {
				if( from == current ) {
					transition = t;
					break;
				}
			}
			if( transition != null )
				break;
		}
		if( transition == null ) {
			handleError( e, current, null, noTransition );
			return;
		}

		var allowed = false;
		for( from in transition.from ) {
			if( from == current ) {
				allowed = true;
				break;
			}
		}
		if( !allowed ) {
			handleError( e, current, transition.to, notAllowed );
			return;
		}

		var e : TransitionEvent = { event:e, from:current, to:transition.to };
		onBeforeEvent( e );
		onLeave( e ) ? applyEvent( e, params ) : pending = e;
	}

	/**
		Cancel pending transition
	*/
	public function cancel() {
		if( pending == null ) {
			handleError( pending.event, pending.from, pending.to, noPendingTransition );
			return;
		}
		var event : TransitionEvent = { event:pending.event, from:pending.from, to:pending.to };
		pending = null;
		onCancel( event );
	}

	/**
		Run pending transition
	*/
	public function transition<T>( ?params : T ) {
		if( pending == null ) {
			handleError( pending.event, pending.from, pending.to, noPendingTransition );
			return;
		}
		applyEvent( pending );
		pending = null;
	}

	/**
		Clear state machine
	*/
	public function reset() {
		current = null;
		map = new StringMap();
		//if( resetErrorHandler ) onError = null;
	}

	public function toString() : String {
		return 'StateMachine: current=>$current';
	}

	function applyEvent<T>( e : TransitionEvent, ?params : T ) {
		onEnter( e );
		current = e.to;
		onChange( e, params );
		onAfter( e );
		onAfterEvent( e );
	}

	function handleError( e : String, from : String, to : String, type : TransitionErrorType ) {
		var event : TransitionErrorEvent = { event:e, from:from, to:to, type:type };
		if( onError == null ) throw event else onError( event );
	}

}
