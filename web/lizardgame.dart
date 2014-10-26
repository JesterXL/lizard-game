import 'dart:html';
import 'dart:async';
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
	
	DraggableBall ball = getDraggableBall();
	stage.addChild(ball);
}

Sprite getDraggableBall({num x: 0, num y: 0})
{
	DraggableBall ball = new DraggableBall();
	ball.graphics.ellipse(0, 0, 40, 40);
	ball.graphics.fillColor(Color.Blue);
	ball.graphics.strokeColor(Color.Black, 1);
	ball.alpha = 0.4;
	ball.x = x;
	ball.y = y;
	return ball;
}

class DraggableBall extends Sprite
{
	bool dragging = false;
	StreamSubscription dragSub;
	
	DraggableBall()
	{
		init();
	}
	
	void init()
	{
		onMouseDown.listen((mouseDownEvent)
    	{
    		dragging = true;
    		startDrag();
//    		dragSub = onEnterFrame.listen((e)
//    		{
//    			x = mouseX - mouseDownEvent.localX;
//    			y = mouseY - mouseDownEvent.localY;
//    		});
    	});
    	Function done = (_)
    	{
    		dragging = false;
    		stopDrag();
    		if(dragSub != null)
    		{
    			dragSub.cancel();
    			dragSub = null;
    		}
    	};
    	onMouseUp.listen(done);
	}
}
