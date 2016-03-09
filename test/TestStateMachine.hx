
import om.StateMachine;
import om.StateMachine.STATE_NONE;
//import om.state.StrictStateMachine;

class TestStateMachine extends haxe.unit.TestCase {

	public function test_1() {

		var sm = new StateMachine();
		assertEquals( StateMachine.STATE_NONE, sm.current );

		var sm = new StateMachine( 'custom' );
		assertEquals( 'custom', sm.current );

		var sm = new StateMachine();
		sm.add( 'start', ['none'], 'idle' );
		assertEquals( StateMachine.STATE_NONE, sm.current );

		var sm = new StateMachine();
		sm.add( 'start', ['none'],   'green' );
		sm.add( 'warn',  ['green'],  'yellow' );
		sm.add( 'panic', ['green'],  'red' );
		sm.add( 'panic', ['yellow'], 'red' );
		sm.add( 'calm',  ['red'],    'yellow' );
		sm.add( 'clear', ['red'],    'green' );
		sm.add( 'clear', ['yellow'], 'green' );

		assertEquals( StateMachine.STATE_NONE, sm.current );
		assertEquals( 1, sm.transitions().length );
		assertEquals( 'start', sm.transitions()[0] );
		assertTrue( sm.can( 'start' ) );

		sm.change( 'start' );
		assertTrue( sm.is( 'green' ) );
		assertEquals( 'green', sm.current );
		assertEquals( 2, sm.transitions().length );
		assertEquals( 'warn', sm.transitions()[0] );
		assertEquals( 'panic', sm.transitions()[1] );
		assertTrue( sm.cannot( 'start' ) );
		assertTrue( sm.can( 'warn' ) );
		assertTrue( sm.can( 'panic' ) );
		assertTrue( sm.cannot( 'calm' ) );
		assertTrue( sm.cannot( 'clear' ) );

		sm.change( 'warn' );
		assertTrue( sm.is( 'yellow' ) );
		assertEquals( 'yellow', sm.current );
		assertEquals( 2, sm.transitions().length );
		assertEquals( 'panic', sm.transitions()[0] );
		assertEquals( 'clear', sm.transitions()[1] );
		assertTrue( sm.cannot( 'start' ) );
		assertTrue( sm.cannot( 'warn' ) );
		assertTrue( sm.can( 'panic' ) );
		assertTrue( sm.cannot( 'calm' ) );
		assertTrue( sm.can( 'clear' ) );

		sm.change( 'panic' );
		assertTrue( sm.is( 'red' ) );
		assertEquals( 'red', sm.current );
		assertEquals( 2, sm.transitions().length );
		assertEquals( 'calm', sm.transitions()[0] );
		assertEquals( 'clear', sm.transitions()[1] );
		assertTrue( sm.cannot( 'start' ) );
		assertTrue( sm.cannot( 'warn' ) );
		assertTrue( sm.cannot( 'panic' ) );
		assertTrue( sm.can( 'calm' ) );
		assertTrue( sm.can( 'clear' ) );
	}

	public function test_2() {

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

		assertEquals( STATE_NONE, sm.current );
		assertTrue( sm.can( 'start' ) );
		assertTrue( sm.cannot( 'eat' ) );
		assertTrue( sm.cannot( 'rest' ) );

		sm.change( 'start', 'getting warm' );

		assertEquals( 'hungry', sm.current );
		assertTrue( sm.cannot( 'start' ) );
		assertTrue( sm.can( 'eat' ) );
		assertTrue( sm.can( 'rest' ) );

		sm.change( 'eat' );
		assertEquals( 'satisfied', sm.current );
		assertTrue( sm.cannot( 'start' ) );
		assertTrue( sm.can( 'eat' ) );
		assertTrue( sm.can( 'rest' ) );

		sm.change( 'eat' );
		assertEquals( 'full', sm.current );
		assertTrue( sm.cannot( 'start' ) );
		assertTrue( sm.can( 'eat' ) );
		assertTrue( sm.can( 'rest' ) );

		sm.change( 'eat' );
		assertEquals( 'sick', sm.current );
		assertTrue( sm.cannot( 'start' ) );
		assertTrue( sm.cannot( 'eat' ) );
		assertTrue( sm.can( 'rest' ) );

		sm.change( 'rest' );


		// ASYNC

		#if js

		sm.onLeave = function(e) {

			haxe.Timer.delay(function(){

				sm.cancel();
				assertEquals( 'hungry', sm.current );

				sm.onLeave = function(e) {
					haxe.Timer.delay(function(){

						sm.transition();
						assertEquals( 'satisfied', sm.current );

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
