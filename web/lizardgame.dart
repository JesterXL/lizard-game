import 'dart:html';
import 'package:stagexl/stagexl.dart';

CanvasElement canvas;
Stage stage;
RenderLoop renderLoop;
ResourceManager resourceManager;
int mouseX = 0;
int mouseY = 0;

void main()
{
	canvas = querySelector('#stage');
	canvas.context2D.imageSmoothingEnabled = true;
	
	canvas.onMouseMove.listen((event)
	{
		mouseX = event.client.x;
		mouseY = event.client.y;
	});
	
	stage = new Stage(canvas, webGL: true);
	renderLoop = new RenderLoop();
	renderLoop.addStage(stage);
	
	Shape spot1 = new Shape();
	spot1.graphics.rectRound(0, 0, 100, 100, 6, 6);
	spot1.graphics.fillColor(Color.Blue);
	spot1.graphics.strokeColor(Color.White, 4);
	spot1.alpha = 0.4;
	spot1.x = 0;
	spot1.y = 0;
	
	Shape spot2 = new Shape();
	spot2.graphics.rect(2, 2, 2, 100);
	spot2.graphics.fillColor(Color.Black);
	spot2.x = 40;
	stage.addChild(spot2);
	
	Shape spot3 = new Shape();
	spot3.graphics.rect(2, 2, 2, 100);
	spot3.graphics.fillColor(Color.Black);
	spot3.x = 60;
	stage.addChild(spot3);
	
	Sprite sprite1 = new Sprite();
	stage.addChild(sprite1);
	sprite1.addChild(spot1);
	bool dragging = false;
	var sub;
	sprite1.onMouseDown.listen((mouseDownEvent)
	{
		dragging = true;
		print("mouseDownEvent.localX: ${mouseDownEvent.localX}, mouseX: ${mouseX}");
		sub = sprite1.onEnterFrame.listen((e)
		{
//			sprite1.x = mouseX - sprite1.width / 2 + mouseDownEvent.localX;
//			sprite1.y = mouseY - sprite1.height / 2 + mouseDownEvent.localY;
			sprite1.x = mouseX - mouseDownEvent.localX;
			sprite1.y = mouseY - mouseDownEvent.localY;
		});
	});
	Function done = (_)
	{
		dragging = false;
		if(sub != null)
		{
			sub.cancel();
			sub = null;
		}
	};
	sprite1.onMouseUp.listen(done);
//	sprite1.onMouseOver.listen(done);
}
