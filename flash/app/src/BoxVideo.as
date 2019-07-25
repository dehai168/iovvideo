package 
{
	import flash.events.TimerEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.*;
	import BoxVideoEvent;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author level
	 */
	public class BoxVideo extends Video
	{
		private var mediaUrl:String = "";    //媒体地址
		private var nc:NetConnection;		 //
		private var ns:NetStream;
		private var nsi:NetStreamInfo;
		private var timer:Timer;
		private var index:String;
		public var isplay:Boolean = false;
		public var mediaParam:String = "";     //媒体参数
		
		public function BoxVideo(index:String,width:int=1, height:int=1) 
		{
			super(width, height);
			
			this.smoothing = true;
			this.index = index;
		}
		public function setMediaUrl(url:String):void 
		{
			this.mediaUrl = url;
			if (this.mediaUrl.length > 0){
				nc = new NetConnection();
				nc.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
				nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			}
		}
		public function play(param:String):void 
		{
			this.mediaParam = param;
			nc.connect(this.mediaUrl);
			
			isplay = true;
		}
		public function stop():void 
		{
			if (ns != null){
				ns.close();
				ns.dispose();
				
				nc.close();
				timer.stop();
				this.clear();
			}
			isplay = false;
		}
		public function pause():void
		{
			if (ns != null){
				ns.pause();
			}
			isplay = true;
		}
		public function resume():void
		{
			if (ns != null){
				ns.resume();
			}
			isplay = true;
		}
		public function mute():void 
		{
			if (ns != null){
				ns.soundTransform = new SoundTransform(0);
			}
		}
		public function sound():void 
		{
			if (ns != null){
				ns.soundTransform = new SoundTransform(1);
			}
		}
		private function netStatusHandler(event:NetStatusEvent):void {
            switch (event.info.code) {
                case "NetConnection.Connect.Success":
                    connectStream();
					dispatchEvent(new BoxVideoEvent(BoxVideoEvent.STATE, index, "connect"));
					dispatchEvent(new BoxVideoEvent(BoxVideoEvent.ERROR, index, ""));
                    break;
				case "NetConnection.Connect.Failed":
					dispatchEvent(new BoxVideoEvent(BoxVideoEvent.ERROR,index,"Net Failed"));
					break;
                case "NetConnection.Connect.Rejected":
					dispatchEvent(new BoxVideoEvent(BoxVideoEvent.ERROR,index,"Net Rejected"));
					break;
				case "NetConnection.Connect.Closed":
					dispatchEvent(new BoxVideoEvent(BoxVideoEvent.ERROR, index,"closed"));
					break;
				case "NetConnection.Connect.NetworkChange":
					dispatchEvent(new BoxVideoEvent(BoxVideoEvent.ERROR, index,"NetworkChange"));
					break;
				case "NetStream.Play.Start":
					dispatchEvent(new BoxVideoEvent(BoxVideoEvent.STATE, index,"start"));
					break;
	            case "NetStream.Play.Stop":
					dispatchEvent(new BoxVideoEvent(BoxVideoEvent.STATE, index,"stop"));
					break;
				case "NetStream.Play.Reset":
					dispatchEvent(new BoxVideoEvent(BoxVideoEvent.STATE, index,"reset"));
					break;
				case "NetStream.Pause.Notify":
					dispatchEvent(new BoxVideoEvent(BoxVideoEvent.STATE, index,"pause"));
					break;
                case "NetStream.Play.StreamNotFound":
                    dispatchEvent(new BoxVideoEvent(BoxVideoEvent.ERROR, index,"StreamNotFound"));
                    break;
            }
        }

        private function securityErrorHandler(event:SecurityErrorEvent):void {
			dispatchEvent(new BoxVideoEvent(BoxVideoEvent.ERROR,index,"Security Error"));
        }

        private function connectStream():void {
            ns = new NetStream(nc);
			ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			ns.client = new CustomClient();
			ns.soundTransform = new SoundTransform(0);
			
			this.attachNetStream(ns);
			ns.play(this.mediaParam);  //bshdlive-pc
			
			timer = new Timer(1000);
			timer.addEventListener(TimerEvent.TIMER,function (event:TimerEvent):void 
			{
				nsi = ns.info;
				dispatchEvent(new BoxVideoEvent(BoxVideoEvent.INFO, index,"speed", (nsi.currentBytesPerSecond / (8 * 1024)).toFixed(2)+""));
			});
			timer.start();
        }
	}
}
class CustomClient {
    public function onMetaData(info:Object):void {
        trace("metadata: duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);
    }
    public function onCuePoint(info:Object):void {
        trace("cuepoint: time=" + info.time + " name=" + info.name + " type=" + info.type);
    }
}