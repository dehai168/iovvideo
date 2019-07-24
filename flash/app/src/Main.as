package
{
	import flash.events.*;
	import flash.display.*;
	import flash.media.Video;
	import flash.text.*;
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
		private var _boxMaxIndex:int = 0;  //当前最大化盒子索引值
		private var _lastBoxSize:int = 0;  //最近一次盒子数量,主要是放大以后恢复用
		private var _license:String = "渝A123456_1(黄色)";  //当前车辆
		private var _selectedColor:int = 0xDC143C;  //选中框颜色
		
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
			
			try 
			{
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
				this.videoSelected();
			}
			catch (err:Error)
			{
				jsConsole('layout:' + err.message);
			}
		}
		/**
		 * 初始化盒子
		 */
		private function initBox():void 
		{
			if (this._boxTotal >= this._boxSize)
			{
				if (this._boxMaxIndex != 0&& this._boxSize == 1)//双击最大化
				{ 
					for (var k1:int = 1; k1 <= this._boxTotal; k1++) 
					{
						if (k1 == this._boxMaxIndex){
							this.layoutVisable(k1, true);
						}else{
							this.layoutVisable(k1, false);
						}
					}
				}else if (this._selectedIndex != 0 && this._boxSize == 1){
					for (var k2:int = 1; k2<= this._boxTotal; k2++) 
					{
						if (k2 == this._selectedIndex){
							this.layoutVisable(k2, true);
						}else{
							this.layoutVisable(k2, false);
						}
					}
				}
				else//正常窗口切换
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
			}
			else 
			{
				for (var j1:int = 1; j1 <= this._boxTotal; j1++) 
				{
					this.layoutVisable(j1, true);
				}
				for (var i:int = (this._boxTotal+1); i <= this._boxSize; i++) 
				{
					//外框
					var boxContainer:Sprite = new Sprite();  // Sprite有MouseEvent事件,而Shape没有,切记！！！
					boxContainer.name = "boxContainer_" + i;
					boxContainer.graphics.lineStyle(0.5, 0x999999);
					boxContainer.graphics.beginFill(0xe9e8e8, 1);
					boxContainer.graphics.drawRect(0, 0, 10, 10);
					boxContainer.graphics.endFill();
					boxContainer.addEventListener(MouseEvent.CLICK,function (event:MouseEvent):void 
					{
						var boxContainer:Sprite = event.target as Sprite;
						var name:String = boxContainer.name;
						var index:String = name.split('_')[1];
						
						_selectedIndex = parseInt(index);
						videoSelected();
						
					});
					boxContainer.doubleClickEnabled = true;
					boxContainer.addEventListener(MouseEvent.DOUBLE_CLICK,function (event:MouseEvent):void 
					{
						var boxContainer:Sprite = event.target as Sprite;
						var name:String = boxContainer.name;
						var index:String = name.split('_')[1];
						
						layoutMax(index);
					});
					this.stage.addChild(boxContainer);
					
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
		 * 视频选中
		 * @param	i
		 */
		private function videoSelected():void
		{
			if (this._selectedIndex == 0){
				return; //初始化的时候1个都没有选择
			}
			var boxContainer:Sprite = this.stage.getChildByName("boxContainer_" + this._selectedIndex) as Sprite;
			var border:Shape = this.stage.getChildByName("selectedBorder") as Shape;
			if (border != null){
				this.stage.removeChild(border);
			}
			border = new Shape();
			border.name = "selectedBorder";
			border.graphics.lineStyle(0.5, _selectedColor);
			border.graphics.drawRect(boxContainer.x, boxContainer.y, boxContainer.width, boxContainer.height);
			border.graphics.endFill();
			this.stage.addChild(border);
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
		 * 单窗口最大化
		 * @param	i
		 */
		private function layoutMax(i:String):void 
		{
			var index:int = parseInt(i);
			if (this._boxMaxIndex != 0){ //已经最大化,需要最小化
				this._boxMaxIndex = 0;
				this.layout(this._lastBoxSize);
			}else{ //正常模式,需要最大化
				this._boxMaxIndex = index;
				this._lastBoxSize = this._boxSize;
				this.layout(1);
			}
		}
		/**
		 * 布局显示和隐藏
		 * @param	i
		 * @param	flag
		 */
		private function layoutVisable(i:int,flag:Boolean):void
		{
			var boxContainer:Sprite = this.stage.getChildByName("boxContainer_" + i) as Sprite;
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
			
			boxContainer.visible = flag;
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
			var boxContainer:Sprite = this.stage.getChildByName("boxContainer_" + i) as Sprite;
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
			
			boxContainer.x = x;
			boxContainer.y = y;
			boxContainer.width = boxWidth;
			boxContainer.height = boxHeight;
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
			var i:int = 1;  //默认窗口
			
			if (this._selectedIndex != 0){ //选择窗口
				i = this._selectedIndex;
			}
			
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
			var index:int = 3;
			
			this.layoutFactory(1, 2, 2, boxWidth * 2 + 2, boxHeight * 2 + 2);
			this.layoutFactory(2, boxWidth * 2 + 6, 2, boxWidth, boxHeight);
			this.layoutFactory(3, boxWidth * 2 + 6,  boxHeight + 4, boxWidth, boxHeight);
			for (var i:int = 3; i <= 3; i++) 
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
			var index:int = 2;
			
			this.layoutFactory(1, 2, 2, boxWidth * 2 + 2, boxHeight * 2 + 1);
			this.layoutFactory(2, boxWidth * 2 + 6, 2, boxWidth * 2 + 2, boxHeight * 2 + 1);
			
			for (var i:int = 3; i <= 4; i++) 
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
		private function jsConsole(log:String):void 
		{
			this.calljs('console.log', log);
		}
	}
}