package {
	import flash.display.*;	
	import flash.events.AccelerometerEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.media.Sound;
	import flash.utils.Timer;
	[SWF(width = "1024", height = "800", frameRate = "120", backgroundColor = "#222222")]
	public class CountDownTypoClock extends Sprite {
		private static const FOCUS_SCALE:Number = 2;
		private static const UNFOCUS_OPACITY:Number = 0.15;
		private var symbolsS:Vector.<Number_mc>;
		private var symbolsM:Vector.<Number_mc>;
		private var symbolsH:Vector.<Number_mc>;
		private var wrap	:Sprite = new Sprite();
		private var timer	:Timer = new Timer(1000);
		private var focusLength: Number = 450;
		private var countDownValue: Number = 60 * 10; // 10 min;
		private static const radian	:Number = 360 * Math.PI / 180;
		public function CountDownTypoClock() {
			this.generate();
			this.stage.frameRate = 180;
			this.timer.addEventListener(TimerEvent.TIMER, atTimerHandler);
			this.timer.start();
			this.addEventListener(Event.ENTER_FRAME, atTickHandler);
			this.atTimerHandler(null);
			this.stage.addEventListener(MouseEvent.MOUSE_WHEEL, this.atStageMouseWheel);
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent) {
				trace(e.keyCode);
				switch(e.keyCode){
					case 13: {
						countDownValue = 60 * 10;
						break;
					}
					case 38: { // up
						countDownValue += 60 * 10;
						break;
					}
					case 39: {
						focusLength += 50;
						break;
					}
					case 37: {
						focusLength -= 50;
						break;
					}
				}
			});
		}	
		
		private function atStageMouseWheel(e:MouseEvent):void {
			if (e.delta > 0 ){
				focusLength += 50;
			} else {
				focusLength -= 50;
			}
		}
		private function generate():void {
			this.addChild(this.wrap);
			this.wrap.x = stage.stageWidth >> 1;
			this.wrap.y = stage.stageHeight >> 1;
			this.symbolsS = this.createItems("s", 60);
			this.symbolsM = this.createItems("m", 60);
			//this.symbolsH = this.createItems("h", 24);
		}
		private function createItems(pName:String , pLength:uint, pIncrement:Number = 0):Vector.<Number_mc> {
			var resultArr:Vector.<Number_mc> = new Vector.<Number_mc>();
			var item:Number_mc;
			for (var i:int = 0; i < pLength; i++) {
				item = wrap.addChild(new Number_mc()) as Number_mc;
				item.cacheAsBitmap = true;				
				//item.cacheAsBitmapMatrix = new Matrix;
				item.sec_txt.text = (i + pIncrement) + "";
				//item.name = pName + i;
				resultArr.push(item);
			}
			return resultArr;
		}
		private function atTimerHandler( e:TimerEvent ):void {
			this.countDownValue -= 1;
			if (this.countDownValue <= 0) {
				this.timer.stop();
			}
			var sec		:int = (this.countDownValue % 60 ) + 15;
			var min		:int = Math.floor(this.countDownValue / 60) + 15;
			//var hour	:int = 0;
			var i		:uint = symbolsS.length;
			var mc		:Number_mc;
			while ( i-- ){
				mc = symbolsS[i];
				mc.tx = 4000 * Math.cos((( i - sec ) % 60 ) / 60 * radian );
				mc.ty = 200;
				mc.tz = 4000 * Math.sin((( i - sec ) % 60 ) / 60 * radian ) + 6000;
				if ( i == sec - 15) {
					mc.ta = 1;
					mc.ts = FOCUS_SCALE;
				} else {
					mc.ta = UNFOCUS_OPACITY;
					mc.ts = 1;
				}
			}
			i = symbolsM.length;
			while ( i-- ){
				mc = symbolsM[i];
				mc.tx = 4500 * Math.cos((( i - min ) % 60 ) / 60 * radian );
				mc.ty = 200;
				mc.tz = 4500 * Math.sin((( i - min ) % 60 ) / 60 * radian) + 5250;
				if ( i == min - 15 ){
					mc.ta = 1;
					mc.ts = FOCUS_SCALE;
				} else {
					mc.ta = UNFOCUS_OPACITY;
					mc.ts = 1;
				}
			}
			/*
			i = symbolsH.length
			while ( i-- ){
				mc = symbolsH[ i ];
				mc.tx = 5000 * Math.cos((( i - hour ) % 24 ) / 24 * _radian );
				mc.ty = 200;
				mc.tz = 5000 * Math.sin((( i - hour ) % 24 ) / 24 * _radian) + 5500;
				if ( i == hour-6 ){
					mc.ta = 1;
					mc.ts = FOCUS_SCALE;
				} else {
					mc.ta = .35;
					mc.ts = 1;
				}
			}
			*/
			wrap.alpha = 0.8;
		}
		private static function clamp(max:Number, min:Number, value:Number):Number{
			return Math.max(min, Math.min(max, value));
		}
		private function atTickHandler( e:Event ):void {
			var targetRotation:Number = 180 * (stage.mouseX / stage.stageWidth);
			targetRotation = clamp(170, 10, targetRotation);
			//trace(targetRotation);
			wrap.rotation += ( targetRotation - wrap.rotation ) * .05;			
			wrap.alpha += ( 1 - wrap.alpha ) * .25;			
			this.updateSymbol(symbolsS, -90);
			this.updateSymbol(symbolsM, 0);
			//this.updateSymbol(symbolsH, 20);
			sortChildren(wrap, "tz", Array.DESCENDING);						
		}
		private function updateSymbol(sympobs:Vector.<Number_mc>, y:Number): void{
			var n 		:Number = sympobs.length;
			var mc		:Number_mc;
			var pers	:Number;
			var focus	:Number = this.focusLength;
			while (n--){
				mc = sympobs[n];
				pers = focus / (focus + mc.tz);	
				pers = pers > 0 ? pers : 0;
				mc.x += ( mc.tx * pers - mc.x ) * 0.3;
				mc.y += ( mc.ty * pers - mc.y ) * 0.3 + y;
				mc.scaleX = mc.scaleY = pers * mc.ts;
				mc.rotation = -wrap.rotation;
				mc.alpha += (mc.ta - mc.alpha) * 0.3;
			}
		}
		public static function sortChildren(pContainer:Sprite, pCriteria:String , pDescending:int = 0):void {
			var _numChildren:int = pContainer.numChildren;
			if( _numChildren < 2 ) return;			
			
			var _childrenArray:Array = new Array(_numChildren);
			var i:int = -1;
			while( ++i < _numChildren )	{
				_childrenArray[i] = pContainer.getChildAt(i);
			}
			_childrenArray.sortOn(pCriteria, Array.NUMERIC | pDescending);
			
			var _child:DisplayObject;
			i = -1;
			while( ++i < _numChildren )	{
				_child = _childrenArray[i] as DisplayObject;
				if( i != pContainer.getChildIndex(_child)) {
					pContainer.setChildIndex( _child, i );
				}
			}
		}
	}
}