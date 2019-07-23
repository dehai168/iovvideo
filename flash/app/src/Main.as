package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.display.*;
	import flash.media.Video;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.external.ExternalInterface;
	import flash.net.*;
	
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
			this.jscallreg();
		}
		/**
		 * 布局
		 * @param	boxSize
		 */
		public function layout(boxSize:int):void
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
					break;
				case 6:this.layout6();
					break;
				case 9:this.layout9();
					break;
				case 10:this.layout10();
					break;
				case 16:this.layout16();
					break;
				case 36:this.layout36();
					break;
				default:break;
			}
		}
		/**
		 * 初始化盒子
		 */
		private function initBox():void 
		{
			if (this._boxTotal >= this._boxSize)
			{
				for (var j:int = 1; j <= this._boxSize; j++) 
				{
					this.layoutVisable(j, true);
				}
				for (var k:int = (this._boxSize+1); k <= this._boxTotal; k++) 
				{
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
					
					//视频
					var boxVideo:BoxVideo = new BoxVideo(i+"");
					boxVideo.name = "boxVideo_" + i;
					boxVideo.addEventListener(BoxVideoEvent.INFO,function (event:BoxVideoEvent):void 
					{
						var boxSpeed:TextField = stage.getChildByName("boxSpeed_" + event.index) as TextField;
						switch (event.key) 
						{
							case "speed":
								boxSpeed.text = event.value + "kb/s";
							break;
							default:
						}
					});
					boxVideo.addEventListener(BoxVideoEvent.ERROR,function (event:BoxVideoEvent):void 
					{
						var boxError:TextField = stage.getChildByName("boxError_" + event.index) as TextField;
						boxError.text = event.content;
					});
					
					this.stage.addChild(boxVideo);
					
					//视频遮罩图片
					var poster:Bitmap = new poster();
					poster.name = "boxPoster_" + i;
					poster.smoothing = true;
					this.stage.addChild(poster);
					poster.addEventListener(MouseEvent.CLICK,function (event:MouseEvent):void 
					{
						jsConsole('click fuck');
					});
					
					//信息部分
					var boxIndex:TextField = new TextField();
					var boxIndexText:TextFormat = new TextFormat();
					boxIndexText.size = 12;
					boxIndex.height = 20;
					boxIndex.defaultTextFormat = boxIndexText;
					boxIndex.text = i + "";
					boxIndex.name = "boxIndex_" + boxIndex.text;
					this.stage.addChild(boxIndex);
					
					var boxTitle:TextField = new TextField();
					var boxTitleText:TextFormat = new TextFormat();
					boxTitleText.size = 12;
					boxTitle.height = 20;
					boxTitle.defaultTextFormat = boxTitleText;
					boxTitle.text = this._license;
					boxTitle.width = 180;
					boxTitle.name = "boxTitle_" + boxIndex.text;
					this.stage.addChild(boxTitle);
					
					var boxSpeed:TextField = new TextField();
					var boxSpeedText:TextFormat = new TextFormat();
					boxSpeedText.size = 12;
					boxSpeed.height = 20;
					boxSpeed.defaultTextFormat = boxSpeedText;
					boxSpeed.text = "";
					boxSpeed.name = "boxSpeed_" + boxIndex.text;
					this.stage.addChild(boxSpeed);
					
					var boxError:TextField = new TextField();
					var boxErrorText:TextFormat = new TextFormat();
					boxErrorText.size = 12;
					boxError.height = 20;
					boxErrorText.color = 0xFF0000;
					boxError.defaultTextFormat = boxErrorText;
					boxError.text = "";
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
					stopButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
					{
						var clickButton:SimpleButton = e.currentTarget as SimpleButton;
						var name:String = clickButton.name;
						var index:String = name.split('_')[1];
						
						videoStop(index);
					});
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
						
						videoSound(index);
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
						
						videoMute(index);
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
						
						videoPlay(index);
					});
					this.stage.addChild(playButton);
					
					this._boxTotal++;
				}	
			}
		}
		/**
		 * 视频播放
		 * @param	i
		 */
		private function videoPlay(i:String):void
		{
			var boxVideo:BoxVideo = this.stage.getChildByName("boxVideo_" + i) as BoxVideo;
			var poster:Bitmap = this.stage.getChildByName("boxPoster_" + i) as Bitmap;
			var playButton:SimpleButton = this.stage.getChildByName("playbutton_" + i) as SimpleButton;
			
			boxVideo.setMediaUrl("rtmp://202.69.69.180:443/webcast/");
			boxVideo.play();
			
			poster.visible = false;
			playButton.visible = false;
		}
		/**
		 * 视频停止
		 * @param	i
		 */
		private function videoStop(i:String):void 
		{
			var boxVideo:BoxVideo = this.stage.getChildByName("boxVideo_" + i) as BoxVideo;
			var poster:Bitmap = this.stage.getChildByName("boxPoster_" + i) as Bitmap;
			var playButton:SimpleButton = this.stage.getChildByName("playbutton_" + i) as SimpleButton;
			var boxSpeed:TextField = this.stage.getChildByName("boxSpeed_" + i) as TextField;
			var boxError:TextField = this.stage.getChildByName("boxError_" + i) as TextField;
			
			boxVideo.stop();
			
			boxSpeed.text = "";
			boxError.text = "";
			
			poster.visible = true;
			playButton.visible = true;
		}
		/**
		 * 视频放声
		 */
		private function videoSound(i:String):void 
		{
			var boxVideo:BoxVideo = this.stage.getChildByName("boxVideo_" + i) as BoxVideo;
			
			boxVideo.sound();
		}
		/**
		 * 视频静音
		 */
		private function videoMute(i:String):void 
		{
			var boxVideo:BoxVideo = this.stage.getChildByName("boxVideo_" + i) as BoxVideo;
			
			boxVideo.mute();
		}
		/**
		 * 布局显示和隐藏
		 * @param	i
		 * @param	flag
		 */
		private function layoutVisable(i:int,flag:Boolean):void
		{
			var boxBorder:Shape = this.stage.getChildByName("boxBorder_" + i) as Shape;
			var boxVideo:BoxVideo = this.stage.getChildByName("boxVideo_" + i) as BoxVideo;
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
			boxIndex.visible = flag;
			boxTitle.visible = flag;
			boxSpeed.visible = flag;
			boxError.visible = flag;
			stopButton.visible = flag;
			muteButton.visible = flag;
			soundButton.visible = flag;
			
			if (!boxVideo.isplay) //没有播放
			{
				boxVideo.visible = flag;
				poster.visible = flag;
				playButton.visible = flag;
			}
			else //播放
			{
				if (flag){ //显示
					boxVideo.resume();
					boxVideo.visible = true;
					
				}else{ //隐藏
					boxVideo.pause();
					boxVideo.visible = false;
				}
				poster.visible = false;
				playButton.visible = false;
			}
		}
		/**
		 * 布局适配工厂
		 * @param	i
		 * @param	x
		 * @param	y
		 * @param	boxWidth
		 * @param	boxHeight
		 */
		private function layoutFactory(i:int,x:int,y:int,boxWidth:int,boxHeight:int):void
		{
			var boxBorder:Shape = this.stage.getChildByName("boxBorder_" + i) as Shape;
			var boxVideo:BoxVideo = this.stage.getChildByName("boxVideo_" + i) as BoxVideo;
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
			boxVideo.x = x + 1;
			boxVideo.y = y + topHeight;
			boxVideo.width = boxWidth - 2;
			boxVideo.height = boxHeight - topHeight - 1;
			
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
		/**
		 * 1路布局
		 */
		private function layout1():void 
		{
			var boxWidth:int = this._layoutWidth - 4;
			var boxHeight:int = this._layoutHeight - 4;
			var x:int = 2;
			var y:int = 2;
			var i:int = 1;
			
			this.layoutFactory(i, x, y, boxWidth, boxHeight);
		}
		/**
		 * 4路布局
		 */
		private function layout4():void 
		{
			var boxWidth:int = (this._layoutWidth - 6) / 2;
			var boxHeight:int = (this._layoutHeight - 6) / 2;
			var x:int = 0;
			var y:int = 0;
			var index:int = 0;
			
			for (var i:int = 1; i <= 2; i++) 
			{
				for (var j:int = 1; j <= 2; j++) 
				{
					x = boxWidth * (j - 1) + 2 * j;
					y = boxHeight * (i - 1) + 2 * i;
					index++;
					
					this.layoutFactory(index, x, y, boxWidth, boxHeight);
				}
			}
		}
		/**
		 * 6路布局
		 */
		private function layout6():void 
		{
			var boxWidth:int = (this._layoutWidth - 8) / 3;
			var boxHeight:int = (this._layoutHeight - 8) / 3;
			var x:int = 0;
			var y:int = 0;
			var index:int = 0;
			var maxWidth:int = 0;
			var maxHeight:int = 0;
			
			for (var i:int = 1; i <= 6; i++) 
			{
				index = i;
				switch (i) 
				{
					case 1:
						x = 2;
						y = 2;
						maxWidth = boxWidth * 2 + 2;
						maxHeight = boxHeight * 2 + 2;
						break;
					case 2:
						x = boxWidth * 2 + 6;
						y = 2;
						maxWidth = boxWidth;
						maxHeight = boxHeight;
						break;
					case 3:
						x = boxWidth * 2 + 6;
						y = boxHeight + 4;
						maxWidth = boxWidth;
						maxHeight = boxHeight;
						break;
					case 4:
						x = 2;
						y = boxHeight * 2 + 6;
						maxWidth = boxWidth;
						maxHeight = boxHeight;
						break;
					case 5:
						x = boxWidth + 4;
						y = boxHeight * 2 + 6;
						maxWidth = boxWidth;
						maxHeight = boxHeight;
						break;
					case 6:
						x = boxWidth * 2 + 6;
						y = boxHeight * 2 + 6;
						maxWidth = boxWidth;
						maxHeight = boxHeight;
						break;
					default:
						break;
				}
				
				this.layoutFactory(index, x, y, maxWidth, maxHeight);
			}
		}
		/**
		 * 9路布局
		 */
		private function layout9():void 
		{
			var boxWidth:int = (this._layoutWidth - 8) / 3;
			var boxHeight:int = (this._layoutHeight - 8) / 3;
			var x:int = 0;
			var y:int = 0;
			var index:int = 0;
			
			for (var i:int = 1; i <= 3; i++) 
			{
				for (var j:int = 1; j <= 3; j++) 
				{
					x = boxWidth * (j - 1) + 2 * j;
					y = boxHeight * (i - 1) + 2 * i;
					index++;
					
					this.layoutFactory(index, x, y, boxWidth, boxHeight);
				}
			}
		}
		/**
		 * 10路布局
		 */
		private function layout10():void 
		{
			var boxWidth:int = (this._layoutWidth - 10) / 4;
			var boxHeight:int = (this._layoutHeight - 10) / 4;
			var x:int = 0;
			var y:int = 0;
			var index:int = 0;
			var maxWidth:int = 0;
			var maxHeight:int = 0;
			
			for (var i:int = 1; i <= 10; i++) 
			{
				index = i;
				switch (i) 
				{
					case 1:
						x = 2;
						y = 2;
						maxWidth = boxWidth * 2+2;
						maxHeight = boxHeight * 2+1;
						break;
					case 2:
						x = boxWidth * 2 + 6;
						y = 2;
						maxWidth = boxWidth * 2+2;
						maxHeight = boxHeight * 2+1;
						break;
					case 3:
						x = 2;
						y = boxHeight * 2 + 6;
						maxWidth = boxWidth;
						maxHeight = boxHeight;
						break;
					case 4:
						x = boxWidth+4;
						y = boxHeight * 2 + 6;
						maxWidth = boxWidth;
						maxHeight = boxHeight;
						break;
					case 5:
						x = boxWidth*2 + 6;
						y = boxHeight * 2 + 6;
						maxWidth = boxWidth;
						maxHeight = boxHeight;
						break;
					case 6:
						x = boxWidth * 3 + 8;
						y = boxHeight * 2 + 6;
						maxWidth = boxWidth;
						maxHeight = boxHeight;
						break;
					case 7:
						x = 2;
						y = boxHeight * 3 + 8;
						maxWidth = boxWidth;
						maxHeight = boxHeight;
						break;
					case 8:
						x = boxWidth + 4;
						y = boxHeight * 3 + 8;
						maxWidth = boxWidth;
						maxHeight = boxHeight;
						break;
					case 9:
						x = boxWidth * 2 + 6;
						y = boxHeight * 3 + 8;
						maxWidth = boxWidth;
						maxHeight = boxHeight;
						break;
					case 10:
						x = boxWidth * 3 + 8;
						y = boxHeight * 3 + 8;
						maxWidth = boxWidth;
						maxHeight = boxHeight;
						break;
					default:
						break;
				}
				
				this.layoutFactory(index, x, y, maxWidth, maxHeight);
			}
		}
		/**
		 * 16路布局
		 */
		private function layout16():void 
		{
			var boxWidth:int = (this._layoutWidth - 10) / 4;
			var boxHeight:int = (this._layoutHeight - 10) / 4;
			var x:int = 0;
			var y:int = 0;
			var index:int = 0;
			
			for (var i:int = 1; i <= 4; i++) 
			{
				for (var j:int = 1; j <= 4; j++) 
				{
					x = boxWidth * (j - 1) + 2 * j;
					y = boxHeight * (i - 1) + 2 * i;
					index++;
					
					this.layoutFactory(index, x, y, boxWidth, boxHeight);
				}
			}
		}
		/**
		 * 36路布局
		 */
		private function layout36():void 
		{
			var boxWidth:int = (this._layoutWidth - 14) / 6;
			var boxHeight:int = (this._layoutHeight - 14) / 6;
			var x:int = 0;
			var y:int = 0;
			var index:int = 0;
			
			for (var i:int = 1; i <= 6; i++) 
			{
				for (var j:int = 1; j <= 6; j++) 
				{
					x = boxWidth * (j - 1) + 2 * j;
					y = boxHeight * (i - 1) + 2 * i;
					index++;
					
					this.layoutFactory(index, x, y, boxWidth, boxHeight);
				}
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
		
		
		/**
		 * action script 调用 JavaScript 方法
		 * @param	funname
		 * @param	param1
		 */
		private function calljs(funname:String,param1:String):void 
		{
			if (ExternalInterface.available)
			{
				ExternalInterface.call(funname, param1);
			}
		}
		/**
		 * js方法调用注册
		 */
		private function jscallreg():void
		{
			if (ExternalInterface.available)
			{
				try 
				{
					ExternalInterface.addCallback('layout', layout);
				}
				catch (err:Error)
				{
					jsConsole(err.message);
				}
				
			}
		}
		/**
		 * js打印
		 * @param	error
		 */
		private function jsConsole(error:String):void 
		{
			this.calljs('console.log', error);
		}
	}
}