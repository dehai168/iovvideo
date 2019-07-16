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
		
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			var myText:TextField = new TextField();
			myText.text = "fuck";
			this.stage.addChild(myText);
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
		}
		
	}
	
}