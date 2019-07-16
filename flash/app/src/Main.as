package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.*;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author level
	 */
	public class Main extends Sprite 
	{
		private var _layoutWidth:int = 0;  //场景宽
		private var _layoutHeight:int = 0; //场景高
		private var _boxSize:int = 4;      //布局盒子数量
		private var _channelCount:int = 2; //通道个数
		private var _selectedIndex:int = 0;//当前选择项
		
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			
			this.addEventListener(Event.RESIZE, layoutResize);
			var myText:TextField = new TextField();
			myText.x = 0;
			myText.y = 0;
			myText.backgroundColor = 0x333333;
			myText.textColor = 0x999999;
			myText.text = "fuck";
			this.stage.addChild(myText);
		}
		/**
		 * 重新调整布局
		 * @param	e
		 */
		private function layoutResize(e:Event):void 
		{
			
		}
		
	}
	
}