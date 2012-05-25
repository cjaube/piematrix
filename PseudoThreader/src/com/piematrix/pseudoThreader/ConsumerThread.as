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
	import mx.collections.ArrayCollection;

	/**
	 *
	 * @author Norman Reed
	 *
	 */
	public class ConsumerThread extends PseudoThread
	{
		public var items:ArrayCollection = new ArrayCollection();
		public var tickInterval:Number = 1;
		private var itemFunction:Function;

		/**
		 * Constructor
		 *
		 */
		public function ConsumerThread(itemFunction:Function, priority:int = 4)
		{
			super(consumerFunction, priority);
			this.itemFunction = itemFunction;
		}

		/**
		 * Add an item to the consume thread
		 * @param item the item to be added
		 *
		 */
		public function addItem(item:Object):void
		{
			if (!items.contains(item))
			{
				items.addItem(item);
			}
		}

		/**
		 * Each cycle, one item wil be removed from the items arrayCollection
		 * and passed to the itemFunction.
		 * @return true when there a no items left.
		 *
		 */
		private function consumerFunction():Boolean
		{
			if (items.length == 0)
			{
				dispatchEvent(new Event("finished"));
				tick();
				return true;
			}
			else
			{
				itemFunction(items.removeItemAt(0));
				if (items.length % tickInterval == 0)
				{
					tick();
				}
				return false;
			}
		}

		/**
		 * Dispatch an event to say that we have processed a chunck
		 * of items. Called every tickInterval items and then again
		 * after all items have been processed.
		 *
		 * This can be used in the case that you want to handle a
		 * chuck of items that have finished being process rather than
		 * handling each one individually as they are finshed being processed.
		 *
		 */
		private function tick():void
		{
			this.dispatchEvent(new Event("tick"));
		}
	}
}
