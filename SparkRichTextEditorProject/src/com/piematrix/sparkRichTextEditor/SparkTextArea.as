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
package com.piematrix.sparkRichTextEditor
{
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.FlowElementMouseEvent;
	import spark.components.TextArea;

	public class SparkTextArea extends TextArea
	{
		private var _htmlText:String;
		private var _linkClickHandler:Function;

		public function SparkTextArea()
		{
			super();
		}

		[Bindable("change")]
		public function get htmlText():String
		{
			if (textFlow)
			{
				return TextConverter.export(textFlow, TextConverter.TEXT_FIELD_HTML_FORMAT, ConversionType.STRING_TYPE) as String;
			}
			else
			{
				return _htmlText;
			}
		}

		public function set htmlText(value:String):void
		{
			if (htmlText != value)
			{
				_htmlText = value;
				updateTextFlow();
			}
		}

		public function get linkClickHandler():Function
		{
			return _linkClickHandler;
		}

		public function set linkClickHandler(value:Function):void
		{
			_linkClickHandler = value;
		}

		protected override function createChildren():void
		{
			super.createChildren();
			updateTextFlow();
		}

		private function handleLinkClick(e:FlowElementMouseEvent):void
		{
			if (_linkClickHandler != null)
			{
				e.stopPropagation();
				e.preventDefault();
				var link:LinkElement = e.flowElement as LinkElement;
				_linkClickHandler(link.href);
			}
		}

		private function updateTextFlow():void
		{
			if (textFlow && _htmlText)
			{
				var tf:TextFlow = TextConverter.importToFlow(_htmlText, TextConverter.TEXT_FIELD_HTML_FORMAT);
				tf.addEventListener(FlowElementMouseEvent.CLICK, handleLinkClick);
				textFlow = tf;
			}
		}
	}
}
