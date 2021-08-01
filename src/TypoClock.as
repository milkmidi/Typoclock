package {
	import flash.display.*;	
	import flash.events.AccelerometerEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.media.Sound;
	import flash.utils.Timer;
	[SWF(width = "1024", height = "800", frameRate = "120", backgroundColor = "#222222")]
	public class TypoClock extends Sprite {
		private static const FOCUS_SCALE:Number = 1.5;
		private var symbolsS:Vector.<Number_mc> = new Vector.<Number_mc>();
		private var symbolsM:Vector.<Number_mc> = new Vector.<Number_mc>();
		private var symbolsH:Vector.<Number_mc> = new Vector.<Number_mc>();
		private var wrap	:Sprite = new Sprite();
		private var timer	:Timer = new Timer( 1000 );
		private var focusLength: Number = 350;
		public function TypoClock() {
			this.generate();		
			this.stage.addEventListener(MouseEvent.MOUSE_WHEEL, this.atStageMouseWheel);
			this.stage.frameRate = 180;
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
			this.symbolsH = this.createItems("h", 24);
			timer.addEventListener( TimerEvent.TIMER, _timerHandler );
			timer.start();
			addEventListener( Event.ENTER_FRAME, _tickHandler );
			_timerHandler(null);
		}
		private function createItems(pName:String , pLength:uint):Vector.<Number_mc> {
			var resultArr:Vector.<Number_mc> = new Vector.<Number_mc>();
			var item:Number_mc;
			for (var i:int = 0; i < pLength; i++) {
				item = wrap.addChild(new Number_mc()) as Number_mc;
				//_mc.cacheAsBitmap = true;				
				// _mc.cacheAsBitmapMatrix = new Matrix;
				item.sec_txt.text = i + "";
				item.name = pName + i;
				resultArr.push(item);
			}
			return resultArr;
		}
		private function _timerHandler( e:TimerEvent ):void {
			var now		:Date = new Date()
			var sec		:int = now.getSeconds() + 14;
			var min		:int = now.getMinutes() + 14;
			var hour	:int = now.getHours() + 5;
			var i		:uint = symbolsS.length;
			var mc		:Number_mc;			
			var _radian	:Number = 360 * Math.PI / 180;			
			while ( i-- ){
				mc = symbolsS[ i ];
				mc.tx = 4000 * Math.cos((( i - sec ) % 60 ) / 60 * _radian );
				mc.ty = 200;
				mc.tz = 4000 * Math.sin((( i - sec ) % 60 ) / 60 * _radian ) + 6000;
				if ( i == sec-15 ) {
					mc.ta = 1;
					mc.ts = FOCUS_SCALE;
				} else {
					mc.ta = .35;
					mc.ts = 1;
				}
			}
			i = symbolsM.length;
			while ( i-- ){
				mc = symbolsM[ i ];
				mc.tx = 4500 * Math.cos((( i - min ) % 60 ) / 60 * _radian );
				mc.ty = 200;
				mc.tz = 4500 * Math.sin((( i - min ) % 60 ) / 60 * _radian) + 5250;
				if ( i == min-15 ){
					mc.ta = 1;
					mc.ts = FOCUS_SCALE;
				} else {
					mc.ta = .35;
					mc.ts = 1;
				}
			}
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
			wrap.alpha = 0.8;
		}
		private function _tickHandler( e:Event ):void {
			var _targetR:Number = 180 * stage.mouseX / stage.stageWidth;
			wrap.rotation += ( _targetR - wrap.rotation ) * .05;			
			wrap.alpha += ( 1 - wrap.alpha ) * .25;			
			this.updateSymbol(symbolsS, -90);
			this.updateSymbol(symbolsM, -50);
			this.updateSymbol(symbolsH, 20);
			sortChildren(wrap, "tz", Array.DESCENDING);						
		}
		private function updateSymbol(sympobs:Vector.<Number_mc>, y:Number): void{
			var n 		:Number = sympobs.length;
			var mc		:Number_mc;
			var pers	:Number;
			var focus	:Number = this.focusLength;
			while ( n-- ){
				mc = sympobs[ n ];
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
			if( _numChildren < 2 ) return ;
			
			
			var _childrenArray:Array = new Array( _numChildren );
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
/*
//import flash.display.BlendMode;
import flash.display.*;
import flash.text.TextField;
import flash.text.TextFormat;

class CircleMC extends Sprite {
	public var tx:int;
	public var ty:int;
	public var tz:int;
	public var ta:Number = 1;
	
	public var sec_txt:TextField;
	public function CircleMC() {
		
		
		
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0xffff00);
		shape.graphics.drawCircle(0, 0, 40);
	
		this.addChild( shape );
		
		
		sec_txt = new TextField();
		
		var tf:TextFormat = new TextFormat( "Arial", 30 );
		sec_txt.setTextFormat( tf );
		sec_txt.embedFonts = true;
		this.addChild( sec_txt );
		//shape.graphics.
	}
	
}
*/