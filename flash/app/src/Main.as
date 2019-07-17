package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
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
		private var _selectedIndex:int = 0;//当前选择盒子索引值
		private var _license:String = "";  //当前车辆
		
		[Embed(source="../asset/stop.png")]
		private var stopIcon:Class;
		[Embed(source="../asset/mute.png")]
		private var muteIcon:Class;
		[Embed(source="../asset/sound.png")]
		private var soundIcon:Class;
		[Embed(source="../asset/bigplay.png")]
		private var bigplayIcon:Class;
		[Embed(source="../asset/poster.jpg")]
		private var poster:Class;
		
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
			
			this.layout(4);
			this.addEventListener(Event.RESIZE, layoutResizeEvent);
		}
		/**
		 * 布局
		 * @param	boxSize
		 */
		private function layout(boxSize:int):void
		{
			this._boxSize = boxSize;
			this._layoutWidth = this.stage.width;
			this._layoutHeight = this.stage.height;
			
			
			switch(boxSize)
			{
				case 1:this.layout1();
					break;
				case 4:this.layout4();
					break
				default:break;
			}
		}
		private function initBox():void 
		{
			var existBoxCount:int = this.stage.numChildren;
			if (existBoxCount >= this._boxSize)
			{
				for (var j:int = 1; j <= this._boxSize; j++) 
				{
					var box:Sprite = this.stage.getChildByName("box_" + j) as Sprite;
					box.visible = true;
				}
				for (var k:int = (this._boxSize+1); k <= existBoxCount; k++) 
				{
					var box:Sprite = this.stage.getChildByName("box_" + k) as Sprite;
					box.visible = false;
				}
			}
			else 
			{
				for (var i:int = (existBoxCount+1); i <= this._boxSize; i++) 
				{
					var box:Sprite = new Sprite();
					box.name = "box_" + i;
					//外框
					var boxBorder:Shape = new Shape();
					boxBorder.name = "boxBorder_" + i;
					//TODO
					
					
					//信息部分
					var boxIndex:TextField = new TextField();
					boxIndex.text = i;
					boxIndex.name = "boxIndex_" + boxIndex.text;
					box.addChild(boxIndex);
					var boxTitle:TextField = new TextField();
					boxTitle.text = this._license;
					boxTitle.name = "boxTitle_" + boxIndex.text;
					box.addChild(boxTitle);
					var boxSpeed:TextField = new TextField();
					boxSpeed.text = "";
					boxSpeed.name = "boxSpeed_" + boxIndex.text;
					box.addChild(boxSpeed);
					var boxError:TextField = new TextField();
					boxError.text = "";
					boxError.textColor = 0xFF0000;
					boxError.name = "boxError_" + boxIndex.text;
					box.addChild(boxError);
					/*按钮部分*/
					//停止按钮
					var stopButton:SimpleButton = new SimpleButton();
					var stopIconBitmap:Bitmap = new stopIcon();
					stopButton.width = 16;
					stopButton.height = 16;
					stopButton.upState = stopIconBitmap;
					stopButton.downState = stopIconBitmap;
					box.addChild(stopButton);
					//静音按钮
					var muteButton:SimpleButton = new SimpleButton();
					var muteIconBitmap:Bitmap = new muteIcon();
					muteButton.width = 16;
					muteButton.height = 16;
					muteButton.upState = muteIconBitmap;
					muteButton.downState = muteIconBitmap;
					muteButton.visible = true;
					muteButton.name = "mutebutton_" + boxIndex.text;
					muteButton.addEventListener(MouseEvent.CLICK,function (e:MouseEvent):void 
					{
						var clickButton:SimpleButton = e.currentTarget as SimpleButton;
						var name:String = clickButton.name;
						var index:String = name.split('_')[1];
						clickButton.visible = false;
						var temp:SimpleButton = stage.getChildByName('soundbutton_' + index) as SimpleButton;
						temp.visible = true;
						
						//TODO
					});
					box.addChild(muteButton);
					//播放声音按钮
					var soundButton:SimpleButton = new SimpleButton();
					var soundIconBitmap:Bitmap = new soundIcon();
					soundButton.width = 16;
					soundButton.height = 16;
					soundButton.upState = soundIconBitmap;
					soundButton.downState = soundIconBitmap;
					soundButton.visible = false;
					soundButton.name = "soundbutton_" + boxIndex.text;
					soundButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
					{
						var clickButton:SimpleButton = e.currentTarget as SimpleButton;
						var name:String = clickButton.name;
						var index:String = name.split('_')[1];
						clickButton.visible = false;
						var temp:SimpleButton = stage.getChildByName('mutebutton_' + index) as SimpleButton;
						temp.visible = true;
						
						//TODO
					});
					box.addChild(soundButton);
					
					this.stage.addChild(box);
				}	
			}
		}
		private function layout1():void 
		{
			
		}
		private function layout4():void 
		{
			
		}
		/**
		 * 重新调整布局事件
		 * @param	e
		 */
		private function layoutResizeEvent(e:Event):void 
		{
			this.layout(this._boxSize);
		}
		
	}
	
}