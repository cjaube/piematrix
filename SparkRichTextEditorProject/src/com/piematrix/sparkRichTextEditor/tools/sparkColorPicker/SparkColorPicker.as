package com.piematrix.sparkRichTextEditor.tools.sparkColorPicker
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import mx.collections.IList;
	import mx.controls.colorPickerClasses.WebSafePalette;
	import mx.events.CollectionEvent;
	import mx.graphics.SolidColor;
	import spark.components.ComboBox;
	import spark.components.Label;
	import spark.events.DropDownEvent;

	/**
	 *  Subclass DropDownList and make it work like a ColorPicker
	 */
	public class SparkColorPicker extends ComboBox
	{

		[SkinPart(required = "false")]
		public var current:SolidColor;

		private var wsp:WebSafePalette;

		public function SparkColorPicker()
		{
			super();
			wsp = new WebSafePalette();
			super.dataProvider = wsp.getList();
			labelFunction = blank;
			labelToItemFunction = colorFunction;
			openOnInput = false;
			addEventListener(Event.CHANGE, colorChangeHandler);
			this.setStyle("skinClass", ColorPickerListSkin);
		}

		// don't allow anyone to set our custom DP
		public override function set dataProvider(value:IList):void
		{

		}

		public override function setFocus():void
		{
			stage.focus = this;
		}

		protected override function dropDownController_closeHandler(event:DropDownEvent):void
		{
			event.preventDefault();
			super.dropDownController_closeHandler(event);
		}

		protected override function isOurFocus(target:DisplayObject):Boolean
		{
			return target == this;
		}

		/**
		 *  @private
		 */
		protected override function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);

			if (instance == current)
				current.color = selectedItem;
		}

		private function blank(item:Object):String
		{
			return "";
		}

		private function colorChangeHandler(event:Event):void
		{
			if (current)
				current.color = selectedItem;
		}

		private function colorFunction(value:String):*
		{
			return uint(value);
		}
	}

}
