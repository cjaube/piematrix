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
	import flash.utils.Dictionary;
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;

	/**
	 *
	 * @author Curtis Aube
	 *
	 */
	public class PseudoThreadPriority
	{
		private static var _currentPriority:PseudoThreadPriority;
		private static var _priorities:Dictionary = new Dictionary;
		private static var _totalThreads:int = 0;

		/**
		 *
		 * @return the current PseudoThreadPriority
		 *
		 */
		public static function get currentPriority():PseudoThreadPriority
		{
			return _currentPriority;
		}

		/**
		 * Get a PseudoThreadPriority instance using a priority int
		 * @param p the priority to get
		 * @return the matching PseudoThreadPriority
		 *
		 */
		public static function getInstanceFromPriority(p:int):PseudoThreadPriority
		{
			if (_priorities[p] == null)
			{
				var stp:PseudoThreadPriority = new PseudoThreadPriority(p);
				_priorities[p] = stp;
			}
			return _priorities[p];
		}

		/**
		 *
		 * @return the total number of running threads
		 *
		 */
		public static function get totalThreads():int
		{
			return _totalThreads;
		}

		/**
		 * Update the current priority
		 *
		 */
		public static function updateCurrentPriority():void
		{
			var stp:PseudoThreadPriority;
			var highestWeightedPriority:PseudoThreadPriority = null;
			var highestWeightedPriorityValue:Number = 0;
			var currentWeightedPriorityValue:Number = 0;
			for each (stp in _priorities)
			{
				currentWeightedPriorityValue = stp.weightedPriority;
				if (stp.hasThreads && (highestWeightedPriority == null || highestWeightedPriorityValue < currentWeightedPriorityValue))
				{
					highestWeightedPriority = stp;
					highestWeightedPriorityValue = currentWeightedPriorityValue;
				}
			}
			_currentPriority = highestWeightedPriority;
			if (_currentPriority != null)
			{
				_currentPriority.lastExecutedFrame = PseudoThreadManager.getInstance().frame;
			}
		}

		public var lastExecutedFrame:Number = 0;

		private var _index:int = 0;
		private var _priority:int;
		private var _threads:Vector.<PseudoThread> = new Vector.<PseudoThread>;

		/**
		 * Constructor
		 * @param priority the priority number value. (0 is the highest priority)
		 *
		 */
		public function PseudoThreadPriority(priority:int)
		{
			_priority = priority;
		}

		/**
		 * Add a thread
		 * @param thread the thread to be added
		 * @return true if the thread was added
		 *
		 */
		public function addThread(thread:PseudoThread):Boolean
		{
			if (thread != null)
			{
				var i:int = _threads.indexOf(thread);
				if (i <= -1)
				{
					_threads.push(thread);
					_totalThreads++;
					return true;
				}
			}
			return false;
		}

		/**
		 *
		 * @return true if there are theads
		 *
		 */
		public function get hasThreads():Boolean
		{
			return _threads.length != 0;
		}

		/**
		 * Get the next thread in this priority
		 * @return the thread
		 *
		 */
		public function get nextThread():PseudoThread
		{
			if (hasThreads)
			{
				_index++;
				if (_index >= _threads.length)
				{
					_index = 0;
				}
				return _threads[_index];
			}
			return null;
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
		 * Remove a thread
		 * @param thread the thread to be removed
		 * @return
		 *
		 */
		public function removeThread(thread:PseudoThread):Boolean
		{
			if (thread != null)
			{
				var i:int = _threads.indexOf(thread);
				if (i != -1)
				{
					_threads.splice(i, 1); //Remove the thread
					_totalThreads--;
					thread.dispatchEvent(new Event(PseudoThread.THREAD_COMPLETE));
					if (_currentPriority == this && !hasThreads)
					{ //This is the current priority and it ran out of threads.
						updateCurrentPriority();
					}
					return true;
				}
			}
			return false;
		}

		/**
		 *
		 * @return the weighted priority
		 *
		 */
		public function get weightedPriority():Number
		{
			return (PseudoThreadManager.getInstance().frame - lastExecutedFrame) / Math.pow(2, _priority);
		}
	}
}
