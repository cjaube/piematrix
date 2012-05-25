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
	import flash.utils.getTimer;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.managers.ISystemManager;
	import spark.components.Application;

	/**
	 *
	 * @author Curtis Aube
	 *
	 */
	public class PseudoThreadManager extends EventDispatcher
	{
		private static var pseudoThreadManager:PseudoThreadManager;

		/**
		 *
		 * @return an instance of the PseudoThreadManager
		 *
		 */
		public static function getInstance():PseudoThreadManager
		{
			if (pseudoThreadManager == null)
			{
				pseudoThreadManager = new PseudoThreadManager();
			}
			return pseudoThreadManager;
		}

		// number of milliseconds we think it takes to render the screen
		private const RENDER_DEDUCTION:int = 10;
		private var _frame:Number = 0;
		private var due:Number;
		private var maxTime:Number = 60;
		private var preferredDue:Number;
		private var preferredMaxTime:Number;
		private var preferredMinThreadPerFrame:Number = 3;
		private var renderDispatcher:UIComponent;
		private var start:Number;

		/**
		 * Constructor
		 *
		 */
		public function PseudoThreadManager()
		{
			super();
			if (pseudoThreadManager != null)
			{
				throw new Error("Only one PseudoThreadManager can be instatiated at a time");
			}
			var sm:ISystemManager = (FlexGlobals.topLevelApplication as Application).systemManager;
			renderDispatcher = new UIComponent();
			sm.addChild(renderDispatcher);

		}

		/**
		 * Add a thread
		 * @param thread the thread to be added
		 *
		 */
		public function addThread(thread:PseudoThread):void
		{
			var stp:PseudoThreadPriority;
			if (thread != null)
			{
				stp = PseudoThreadPriority.getInstanceFromPriority(thread.priority);
				if (stp.addThread(thread))
				{
					startThreading();
				}
			}
		}

		/**
		 *
		 * @return the current frame number
		 *
		 */
		public function get frame():Number
		{
			return _frame;
		}

		/**
		 * Remove a thread
		 * @param thread the thread to be removed
		 *
		 */
		public function removeThread(thread:PseudoThread):void
		{
			if (thread != null)
			{
				var stp:PseudoThreadPriority = PseudoThreadPriority.getInstanceFromPriority(thread.priority);
				if (stp.removeThread(thread))
				{
					if (PseudoThreadPriority.currentPriority == null)
					{
						stopThreading();
					}
				}
			}
		}

		/**
		 * Handle an enter frame event
		 * @param event
		 *
		 */
		private function enterFrameHandler(event:Event):void
		{
			start = getTimer();
			preferredMaxTime = Math.floor(1000 / renderDispatcher.systemManager.stage.frameRate) - RENDER_DEDUCTION;
			preferredDue = start + preferredMaxTime;
			due = start + maxTime;

			renderDispatcher.systemManager.stage.invalidate();
		}

		private function executeThreads():void
		{
			var threadsRunning:int = PseudoThreadPriority.totalThreads;
			var count:int = 0;
			while ((count < preferredMinThreadPerFrame && getTimer() < due) || getTimer() < preferredDue)
			{
				var currentPriority:PseudoThreadPriority = PseudoThreadPriority.currentPriority;
				if (currentPriority == null)
				{
					logFrameData(threadsRunning, count);
					return;
				}
				var thread:PseudoThread = currentPriority.nextThread;
				var threadFinished:Boolean = thread.threadObject != null ? thread.threadFunction(thread.threadObject) : thread.threadFunction();
				if (threadFinished)
				{
					removeThread(thread);
				}
				thread.cycles++;
				if (thread.cycles == 500000)
				{
					trace("WARNING: A thread has been run more than 500,000 times.");
				}
				count++;
			}
			logFrameData(threadsRunning, count);
		}

		/**
		 * Log data collected during this frame
		 *
		 */
		private function logFrameData(threadsRunning:int, cycles:int):void
		{
			trace("Frame Data: (runningTime:" + (getTimer() - start) + "ms, threadsRunning:" + threadsRunning + ", cyclesCompleted:" + cycles + ")");
		}

		/**
		 * Handle a render event
		 * @param event
		 *
		 */
		private function renderHandler(event:Event):void
		{
			PseudoThreadPriority.updateCurrentPriority();
			executeThreads();
			_frame++;
		}

		/**
		 * Start threading
		 *
		 */
		private function startThreading():void
		{
			renderDispatcher.systemManager.stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 100);
			renderDispatcher.addEventListener(Event.RENDER, renderHandler);
		}

		/**
		 * Stop threading
		 *
		 */
		private function stopThreading():void
		{
			renderDispatcher.systemManager.stage.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			renderDispatcher.removeEventListener(Event.RENDER, renderHandler);
		}
	}
}
