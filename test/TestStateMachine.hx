
import om.StateMachine;
import om.StateMachine.STATE_NONE;
//import om.state.StrictStateMachine;

class TestStateMachine extends om.test.Case {

	function test_1() {

		var sm = new StateMachine();
		equals( StateMachine.STATE_NONE, sm.current );

		var sm = new StateMachine( 'custom' );
		equals( 'custom', sm.current );

		var sm = new StateMachine();
		sm.add( 'start', ['none'], 'idle' );
		equals( StateMachine.STATE_NONE, sm.current );

		var sm = new StateMachine();
		sm.add( 'start', ['none'],   'green' );
		sm.add( 'warn',  ['green'],  'yellow' );
		sm.add( 'panic', ['green'],  'red' );
		sm.add( 'panic', ['yellow'], 'red' );
		sm.add( 'calm',  ['red'],    'yellow' );
		sm.add( 'clear', ['red'],    'green' );
		sm.add( 'clear', ['yellow'], 'green' );

		equals( StateMachine.STATE_NONE, sm.current );
		equals( 1, sm.transitions().length );
		equals( 'start', sm.transitions()[0] );
		isTrue( sm.can( 'start' ) );

		sm.change( 'start' );
		isTrue( sm.is( 'green' ) );
		equals( 'green', sm.current );
		equals( 2, sm.transitions().length );
		equals( 'warn', sm.transitions()[0] );
		equals( 'panic', sm.transitions()[1] );
		isTrue( sm.cannot( 'start' ) );
		isTrue( sm.can( 'warn' ) );
		isTrue( sm.can( 'panic' ) );
		isTrue( sm.cannot( 'calm' ) );
		isTrue( sm.cannot( 'clear' ) );

		sm.change( 'warn' );
		isTrue( sm.is( 'yellow' ) );
		equals( 'yellow', sm.current );
		equals( 2, sm.transitions().length );
		equals( 'panic', sm.transitions()[0] );
		equals( 'clear', sm.transitions()[1] );
		isTrue( sm.cannot( 'start' ) );
		isTrue( sm.cannot( 'warn' ) );
		isTrue( sm.can( 'panic' ) );
		isTrue( sm.cannot( 'calm' ) );
		isTrue( sm.can( 'clear' ) );

		sm.change( 'panic' );
		isTrue( sm.is( 'red' ) );
		equals( 'red', sm.current );
		equals( 2, sm.transitions().length );
		equals( 'calm', sm.transitions()[0] );
		equals( 'clear', sm.transitions()[1] );
		isTrue( sm.cannot( 'start' ) );
		isTrue( sm.cannot( 'warn' ) );
		isTrue( sm.cannot( 'panic' ) );
		isTrue( sm.can( 'calm' ) );
		isTrue( sm.can( 'clear' ) );
	}

	function test_2() {

		var sm = new StateMachine();

		sm.add( 'start', [STATE_NONE], 'hungry' );
		sm.add( 'eat', ['hungry'], 'satisfied' );
		sm.add( 'eat', ['satisfied'], 'full' );
		sm.add( 'eat', ['full'], 'sick' );
		sm.add( 'rest', ['hungry','satisfied','full','sick'], 'hungry' );

		//sm.onBeforeEvent = function(e) trace( 'BEFORE '+e.event );
		sm.onLeave = function(e) { trace( 'LEAVE '+e.from ); return true; }
		sm.onEnter = function(e) trace( 'ENTER '+e.to );
		sm.onChange = function(e,?params) trace( 'CHANGED from ${e.from} to ${e.to} [$params]' );
		sm.onAfter = function(e) trace( 'AFTER '+e.from );
		sm.onError = function(e) trace( 'ERROR '+e.type+' from '+e.from+' to '+e.to );
		//sm.onAfterEvent = function(e) trace( 'AFTER '+e.event );
		sm.onCancel = function(e) trace( 'CANCELLED '+e.event );

		equals( STATE_NONE, sm.current );
		isTrue( sm.can( 'start' ) );
		isTrue( sm.cannot( 'eat' ) );
		isTrue( sm.cannot( 'rest' ) );

		sm.change( 'start', 'getting warm' );

		equals( 'hungry', sm.current );
		isTrue( sm.cannot( 'start' ) );
		isTrue( sm.can( 'eat' ) );
		isTrue( sm.can( 'rest' ) );

		sm.change( 'eat' );
		equals( 'satisfied', sm.current );
		isTrue( sm.cannot( 'start' ) );
		isTrue( sm.can( 'eat' ) );
		isTrue( sm.can( 'rest' ) );

		sm.change( 'eat' );
		equals( 'full', sm.current );
		isTrue( sm.cannot( 'start' ) );
		isTrue( sm.can( 'eat' ) );
		isTrue( sm.can( 'rest' ) );

		sm.change( 'eat' );
		equals( 'sick', sm.current );
		isTrue( sm.cannot( 'start' ) );
		isTrue( sm.cannot( 'eat' ) );
		isTrue( sm.can( 'rest' ) );

		sm.change( 'rest' );


		// ASYNC

		#if js

		sm.onLeave = function(e) {

			haxe.Timer.delay(function(){

				sm.cancel();
				equals( 'hungry', sm.current );

				sm.onLeave = function(e) {
					haxe.Timer.delay(function(){

						sm.transition();
						equals( 'satisfied', sm.current );

					}, 500 );
					return false;
				}
				sm.change( 'eat' );

			}, 500 );
			return false;
		}
		sm.change( 'eat' );

		#end

	}

}
