package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.*;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author level
	 */
	public class Main extends Sprite 
	{
		private var _layoutWidth:int = 0;  //场景宽
		private var _layoutHeight:int = 0; //场景高
		private var _boxTotal:int = 0;     //页面盒子元素总量
		private var _boxSize:int = 0;      //当前布局盒子数量
		private var _channelCount:int = 2; //通道个数
		private var _selectedIndex:int = 0;//当前选择盒子索引值
		private var _license:String = "渝A123456_1(黄色)";  //当前车辆
		
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
			this.stage.frameRate = 30;
			this.stage.showDefaultContextMenu = false;
			this.stage.quality = StageQuality.BEST;
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			this.layout(4);
			this.stage.addEventListener(Event.RESIZE, layoutResizeEvent);
		}
		/**
		 * 布局
		 * @param	boxSize
		 */
		private function layout(boxSize:int):void
		{
			this._boxSize = boxSize;
			this._layoutWidth = this.stage.stageWidth;
			this._layoutHeight = this.stage.stageHeight;
			
			this.initBox();
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
			if (this._boxTotal >= this._boxSize)
			{
				for (var j:int = 1; j <= this._boxSize; j++) 
				{
					//var box1:Sprite = this.stage.getChildByName("box_" + j) as Sprite;
					//box1.visible = true;
					this.layoutVisable(j, true);
				}
				for (var k:int = (this._boxSize+1); k <= this._boxTotal; k++) 
				{
					//var box2:Sprite = this.stage.getChildByName("box_" + k) as Sprite;
					//box2.visible = false;
					this.layoutVisable(k, false);
				}
			}
			else 
			{
				for (var i:int = (this._boxTotal+1); i <= this._boxSize; i++) 
				{
					//外框
					var boxBorder:Shape = new Shape();
					boxBorder.name = "boxBorder_" + i;
					boxBorder.graphics.lineStyle(0.5, 0x999999);
					boxBorder.graphics.drawRect(0, 0, 10, 10);
					boxBorder.graphics.endFill();
					this.stage.addChild(boxBorder);
					
					//视频遮罩图片
					var poster:Bitmap = new poster();
					poster.name = "boxPoster_" + i;
					poster.smoothing = true;
					this.stage.addChild(poster);
					
					//信息部分
					var boxIndex:TextField = new TextField();
					var boxIndexText:TextFormat = new TextFormat();
					boxIndexText.size = 12;
					boxIndex.defaultTextFormat = boxIndexText;
					boxIndex.text = i + "";
					boxIndex.name = "boxIndex_" + boxIndex.text;
					this.stage.addChild(boxIndex);
					
					var boxTitle:TextField = new TextField();
					var boxTitleText:TextFormat = new TextFormat();
					boxTitleText.size = 12;
					boxTitle.defaultTextFormat = boxTitleText;
					boxTitle.text = this._license;
					boxTitle.width = 180;
					boxTitle.name = "boxTitle_" + boxIndex.text;
					this.stage.addChild(boxTitle);
					
					var boxSpeed:TextField = new TextField();
					var boxSpeedText:TextFormat = new TextFormat();
					boxSpeedText.size = 12;
					boxSpeed.defaultTextFormat = boxSpeedText;
					boxSpeed.text = "200kb/s";
					boxSpeed.name = "boxSpeed_" + boxIndex.text;
					this.stage.addChild(boxSpeed);
					
					var boxError:TextField = new TextField();
					var boxErrorText:TextFormat = new TextFormat();
					boxErrorText.size = 12;
					boxErrorText.color = 0xFF0000;
					boxError.defaultTextFormat = boxErrorText;
					boxError.text = "NetworkError";
					boxError.name = "boxError_" + boxIndex.text;
					this.stage.addChild(boxError);
					/*按钮部分*/
					//停止按钮
					var stopIconBitmap:Bitmap = new stopIcon();
					stopIconBitmap.smoothing = true;
					var stopButton:SimpleButton = new SimpleButton(stopIconBitmap,stopIconBitmap,stopIconBitmap,stopIconBitmap);
					stopButton.width = 16;
					stopButton.height = 16;
					stopButton.useHandCursor = true;
					stopButton.visible = true;
					stopButton.name = "stopbutton_" + boxIndex.text;
					this.stage.addChild(stopButton);
					//静音按钮
					var muteIconBitmap:Bitmap = new muteIcon();
					muteIconBitmap.smoothing = true;
					var muteButton:SimpleButton = new SimpleButton(muteIconBitmap,muteIconBitmap,muteIconBitmap,muteIconBitmap);
					muteButton.width = 16;
					muteButton.height = 16;
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
					this.stage.addChild(muteButton);
					//播放声音按钮
					var soundIconBitmap:Bitmap = new soundIcon();
					soundIconBitmap.smoothing = true;
					var soundButton:SimpleButton = new SimpleButton(soundIconBitmap,soundIconBitmap,soundIconBitmap,soundIconBitmap);
					soundButton.width = 16;
					soundButton.height = 16;
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
					this.stage.addChild(soundButton);
					//播放画面按钮
					var bigplayIconBitmap:Bitmap = new bigplayIcon();
					bigplayIconBitmap.smoothing = true;
					var playButton:SimpleButton = new SimpleButton(bigplayIconBitmap,bigplayIconBitmap,bigplayIconBitmap,bigplayIconBitmap);
					playButton.width = 58;
					playButton.height = 58;
					playButton.name = "playbutton_" + boxIndex.text;
					playButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
					{
						var clickButton:SimpleButton = e.currentTarget as SimpleButton;
						var name:String = clickButton.name;
						var index:String = name.split('_')[1];
						
						//TODO
					});
					this.stage.addChild(playButton);
					
					this._boxTotal++;
				}	
			}
		}
		private function layoutVisable(i:int,flag:Boolean):void
		{
			var boxBorder:Shape = this.stage.getChildByName("boxBorder_" + i) as Shape;
			var poster:Bitmap = this.stage.getChildByName("boxPoster_" + i) as Bitmap;
			var boxIndex:TextField = this.stage.getChildByName("boxIndex_" + i) as TextField;
			var boxTitle:TextField = this.stage.getChildByName("boxTitle_" + i) as TextField;
			var boxSpeed:TextField = this.stage.getChildByName("boxSpeed_" + i) as TextField;
			var boxError:TextField = this.stage.getChildByName("boxError_" + i) as TextField;
			var stopButton:SimpleButton = this.stage.getChildByName("stopbutton_" + i) as SimpleButton;
			var muteButton:SimpleButton = this.stage.getChildByName("mutebutton_" + i) as SimpleButton;
			var soundButton:SimpleButton = this.stage.getChildByName("soundbutton_" + i) as SimpleButton;
			var playButton:SimpleButton = this.stage.getChildByName("playbutton_" + i) as SimpleButton;
			
			boxBorder.visible = flag;
			poster.visible = flag;
			boxIndex.visible = flag;
			boxTitle.visible = flag;
			boxSpeed.visible = flag;
			boxError.visible = flag;
			stopButton.visible = flag;
			muteButton.visible = flag;
			soundButton.visible = flag;
			playButton.visible = flag;
		}
		private function layoutFactory(i:int,x:int,y:int,boxWidth:int,boxHeight:int):void
		{
			var boxBorder:Shape = this.stage.getChildByName("boxBorder_" + i) as Shape;
			var poster:Bitmap = this.stage.getChildByName("boxPoster_" + i) as Bitmap;
			var boxIndex:TextField = this.stage.getChildByName("boxIndex_" + i) as TextField;
			var boxTitle:TextField = this.stage.getChildByName("boxTitle_" + i) as TextField;
			var boxSpeed:TextField = this.stage.getChildByName("boxSpeed_" + i) as TextField;
			var boxError:TextField = this.stage.getChildByName("boxError_" + i) as TextField;
			var stopButton:SimpleButton = this.stage.getChildByName("stopbutton_" + i) as SimpleButton;
			var muteButton:SimpleButton = this.stage.getChildByName("mutebutton_" + i) as SimpleButton;
			var soundButton:SimpleButton = this.stage.getChildByName("soundbutton_" + i) as SimpleButton;
			var playButton:SimpleButton = this.stage.getChildByName("playbutton_" + i) as SimpleButton;
			
			var topHeight:int = 20;
			var textSpace:int = 10;
			var buttonSpace:int = 2;
			
			boxBorder.x = x;
			boxBorder.y = y;
			boxBorder.width = boxWidth;
			boxBorder.height = boxHeight;
			poster.x = x + 1;
			poster.y = y + topHeight;
			poster.width = boxWidth - 2;
			poster.height = boxHeight - topHeight - 1;
			boxIndex.x = x;
			boxIndex.y = y;
			boxTitle.x = x + boxIndex.textWidth;
			boxTitle.y = y;
			boxSpeed.x = boxTitle.x + boxTitle.textWidth + textSpace;
			boxSpeed.y = y;
			boxError.x = boxSpeed.x + boxSpeed.textWidth + textSpace;
			boxError.y = y;
			
			stopButton.x = x + boxWidth - (stopButton.width * 2) - buttonSpace * 2;
			stopButton.y = y + 2;
			muteButton.x = x + boxWidth - muteButton.width - buttonSpace;
			muteButton.y = y + 2;
			soundButton.x = x + boxWidth - soundButton.width - buttonSpace;
			soundButton.y = y + 2;
			playButton.x = x + boxWidth / 2 - playButton.width / 2;
			playButton.y = y + boxHeight / 2 - playButton.height / 2 + topHeight;
		}
		private function layout1():void 
		{
			var boxWidth:int = this._layoutWidth - 4;
			var boxHeight:int = this._layoutHeight - 4;
			var x:int = 2;
			var y:int = 2;
			var i:int = 1;
			
			this.layoutFactory(i, x, y, boxWidth, boxHeight);
		}
		private function layout4():void 
		{
			var boxWidth:int = (this._layoutWidth - 6) / 2;
			var boxHeight:int = (this._layoutHeight - 6) / 2;
			var x:int = 0;
			var y:int = 0;
			var index:int = 0;
			
			for (var i:int = 1; i <= 4; i++) 
			{
				index = i;
				switch (i) 
				{
					case 1:
						x = 2;
						y = 2;
						break;
					case 2:
						x = boxWidth + 4;
						y = 2;
						break;
					case 3:
						x = 2;
						y = boxHeight + 4;
						break;
					case 4:
						x = boxWidth + 4;
						y = boxHeight + 4;
						break;
					default:
						break;
				}
				
				this.layoutFactory(index, x, y, boxWidth, boxHeight);
			}
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