package 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author level
	 */
	public class BoxVideoEvent extends Event 
	{
		public static const STATE:String = "state";
		public static const ERROR:String = "error";
		public static const INFO:String = "info";
		
		public var content:String;
		public var key:String;
		public var value:String;
		public var index:String;
		
		public function BoxVideoEvent(type:String,parameter : *=null, parameter2 : *=null,parameter3 : *=null) 
		{
			this.index = parameter as String;
			switch (type) 
			{
				case INFO:
					this.key = parameter2 as String;
					this.value = parameter3 as String;
					break;
				case ERROR:
					content = parameter2 as String;
					break;
				case STATE:
					this.key = parameter2 as String;
					break;
				default:break;
			}
			super(type, false, false);
		}
	}
	
}