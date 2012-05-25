/**
 * Copyright (c) 2012 PIEmatrix Corporation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal 
 * in the Software without restriction, including without limitation the rights 
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
 * copies of the Software, and to permit persons to whom the Software is 
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all 
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
 * SOFTWARE.
 */
package com.piematrix.pseudoThreader
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	/**
	 *
	 * @author Curtis Aube
	 *
	 */
	public class PseudoThread extends EventDispatcher
	{
		public static const THREAD_COMPLETE:String = "threadComplete";

		private var _cycles:Number = 0;
		private var _priority:int;
		private var _threadFunction:Function;
		private var _threadObject:Object;

		/**
		 * Constructor
		 * @param threadFunction a function that returns true when the thread is done processing
		 * @param threadObject an object that can be used to store state information.
		 *
		 */
		public function PseudoThread(threadFunction:Function, priority:int = 4, threadObject:Object = null)
		{
			super();

			_threadFunction = threadFunction;
			_priority = priority;
			_threadObject = threadObject;
		}

		/**
		 *
		 * @return number of times the thread has run
		 *
		 */
		public function get cycles():Number
		{
			return _cycles;
		}

		/**
		 *
		 * @param value the number of times the thread has run
		 *
		 */
		public function set cycles(value:Number):void
		{
			_cycles = value;
		}

		/**
		 *
		 * @return the priority
		 *
		 */
		public function get priority():int
		{
			return _priority;
		}

		/**
		 * Add this thread to the PseudoThreadManager
		 *
		 */
		public function start():void
		{
//			trace("Starting thread");
			PseudoThreadManager.getInstance().addThread(this);
		}

		/**
		 * Remove this thread from the  PseudoThreadManager
		 *
		 */
		public function stop():void
		{
			PseudoThreadManager.getInstance().removeThread(this);
		}

		/**
		 *
		 * @return the threadFunction
		 *
		 */
		public function get threadFunction():Function
		{
			return _threadFunction;
		}

		/**
		 *
		 * @return the threadObject
		 *
		 */
		public function get threadObject():Object
		{
			return _threadObject;
		}
	}
}
