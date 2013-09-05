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
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.ElementRange;
	import flashx.textLayout.edit.IEditManager;
	import flashx.textLayout.edit.SelectionState;
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextDecoration;
	import flashx.textLayout.formats.TextLayoutFormat;
	import mx.controls.Alert;
	import mx.events.FlexEvent;
	import spark.components.TextArea;
	import spark.components.TextInput;

	[Event(name = "linkSelectedChange", type = "flash.events.Event")]
	public class LinkInput extends TextInput
	{
		public var textArea:TextArea;
		private var _linkSelected:Boolean = false;
		private const defaultLinkText:String = "http://";
		private var lastRange:ElementRange;

		public function LinkInput()
		{
			super();
			this.addEventListener(FlexEvent.ENTER, apply);
			this.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, apply);
		}

		[Bindable("linkSelectedChange")]
		public function get linkSelected():Boolean
		{
			return _linkSelected;
		}

		public function update(range:ElementRange):void
		{
			if (!range)
			{
				lastRange = null;
				return;
			}
			var linkString:String = defaultLinkText;
			var linkEl:LinkElement = range.firstLeaf.getParentByType(LinkElement) as LinkElement;
			if (linkEl != null)
			{
				var linkElStart:int = linkEl.getAbsoluteStart();
				var linkElEnd:int = linkElStart + linkEl.textLength;
				if (linkElEnd < linkElStart)
				{
					var temp:int = linkElStart;
					linkElStart = linkElEnd;
					linkElEnd = temp;
				}

				var beginRange:int = range.absoluteStart;
				var endRange:int = range.absoluteEnd;

				var beginPara:ParagraphElement = range.firstParagraph;
				if (endRange == (beginPara.getAbsoluteStart() + beginPara.textLength))
				{
					endRange--;
				}

				if ((beginRange == endRange) || (endRange <= linkElEnd))
				{
					linkString = LinkElement(linkEl).href;
				}
			}
			var newLinkSelected:Boolean = linkEl != null;
			if (_linkSelected != newLinkSelected)
			{
				_linkSelected = newLinkSelected;
				this.dispatchEvent(new Event("linkSelectedChange"));
			}

			this.text = linkString;

			lastRange = range;
		}

		private function apply(e:Event = null):void
		{
			var newText:String = this.text == defaultLinkText ? '' : this.text;
			changeLink(newText);
		}

		private function changeLink(urlText:String):void
		{
			if (textArea && textArea.textFlow && textArea.textFlow.interactionManager is IEditManager)
			{
				//Get the current format
				var txtLayFmt:TextLayoutFormat = textArea.textFlow.interactionManager.getCommonCharacterFormat();
				//Set the link
				var linkElement:LinkElement = IEditManager(textArea.textFlow.interactionManager).applyLink(urlText, "_blank", true);
				//Fix the formatting
				IEditManager(textArea.textFlow.interactionManager).clearFormatOnElement(linkElement.getChildAt(0), txtLayFmt);
				var selectionEnd:int = Math.max(textArea.selectionActivePosition, textArea.selectionAnchorPosition);
				textArea.selectRange(selectionEnd, selectionEnd);
				IEditManager(textArea.textFlow.interactionManager).applyLeafFormat(txtLayFmt);
				//Set focus to textFlow
				textArea.textFlow.interactionManager.setFocus();
			}
		}
	}
}
