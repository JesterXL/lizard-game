import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'package:stagexl/stagexl.dart';
import 'package:frappe/frappe.dart';

CanvasElement canvas;
Stage stage;
RenderLoop renderLoop;
ResourceManager resourceManager;
int mouseX = 0;
int mouseY = 0;
int MAX_BALLS = 5;
int totalBalls = 0;
Sprite makerBall;
Sprite saveButton;
Sprite loadButton;
Sprite newButton;
List<Sprite> balls = new List<Sprite>();

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
	
	resourceManager = new ResourceManager();
	resourceManager.addBitmapData('tank', 'assets/images/tank.png');
	resourceManager.addBitmapData('saveButton', 'assets/images/save-button.png');
	resourceManager.addBitmapData('loadButton', 'assets/images/load-button.png');
	resourceManager.addBitmapData('newButton', 'assets/images/new-button.png');
	resourceManager.load().then((_)
	{
		BitmapData tankData = resourceManager.getBitmapData('tank');
		Bitmap tank = new Bitmap(tankData);
		stage.addChild(tank);
		tank.x = 32;
		tank.y = 32;
		
		makerBall = new Sprite();
		makerBall.graphics.ellipse(0, 0, 40, 40);
		makerBall.graphics.fillColor(Color.Blue);
		makerBall.graphics.strokeColor(Color.Black, 1);
		makerBall.alpha = 0.9;
		makerBall.x = 500;
		makerBall.y = 20;
		stage.addChild(makerBall);
		makerBall.onMouseClick.listen((_)
		{
			makeNewBall();
		});
		
		saveButton = new Sprite();
		saveButton.addChild(new Bitmap(resourceManager.getBitmapData('saveButton')));
		saveButton.x = makerBall.x - (saveButton.width + 20);
		saveButton.y = 20;
		stage.addChild(saveButton);
		saveButton.onMouseClick.listen((_)
		{
			saveGame();
		});
		
		loadButton = new Sprite();
		loadButton.addChild(new Bitmap(resourceManager.getBitmapData('loadButton')));
		loadButton.x = saveButton.x - (loadButton.width + 20);
		loadButton.y = saveButton.y;
		stage.addChild(loadButton);
		loadButton.onMouseClick.listen((_)
		{
			loadGame();
		});
		
		newButton = new Sprite();
		newButton.addChild(new Bitmap(resourceManager.getBitmapData('newButton')));
		newButton.x = loadButton.x - (newButton.width + 20);
		newButton.y = loadButton.y;
		stage.addChild(newButton);
		newButton.onMouseClick.listen((_)
		{
			newGame();
		});
	});
}

void makeNewBall()
{
	if(totalBalls < MAX_BALLS)
	{
		totalBalls++;
		makeBall();
	}
}

DraggableBall makeBall()
{
	DraggableBall ball = getDraggableBall();
	stage.addChild(ball);
	ball.x = makerBall.x;
	ball.y = makerBall.y + 50;
	balls.add(ball);
	return ball;
}

Sprite getDraggableBall({num x: 0, num y: 0})
{
	DraggableBall ball = new DraggableBall();
	ball.graphics.ellipse(0, 0, 40, 40);
	ball.graphics.fillColor(Color.Blue);
	ball.graphics.strokeColor(Color.Black, 2);
	ball.alpha = 0.9;
	ball.x = x;
	ball.y = y;
	return ball;
}

void saveGame()
{
	var memento = {};
	var ballObjects = [];
	int index = 0;
	balls.forEach((Sprite ball)
	{
		ballObjects.add({"x": ball.x, "y": ball.y});
	});
	memento["balls"] = ballObjects;
	window.localStorage["saveGame"] = JSON.encode(memento);
}

void destroyAll()
{
	balls.forEach((Sprite ball)
	{
		ball.removeFromParent();
	});
	balls.clear();
}

void loadGame()
{
	if(window.localStorage.containsKey("saveGame") == true)
	{
		var memento = JSON.decode(window.localStorage["saveGame"]);
		destroyAll();
		memento["balls"].forEach((obj)
		{
			DraggableBall ball = makeBall();
			ball.x = obj["x"];
			ball.y = obj["y"];
		});
	}
}

void newGame()
{
	destroyAll();
}

class DraggableBall extends Sprite
{
	bool dragging = false;
	StreamSubscription dragSub;
	StreamController _controller;
	Stream changes;
	
	DraggableBall()
	{
		init();
	}
	
	void init()
	{
		_controller = new StreamController();
		changes = _controller.stream.asBroadcastStream();
		onMouseDown.listen((mouseDownEvent)
    	{
    		dragging = true;
    		var index = parent.getChildIndex(this);
    		if(index < parent.numChildren - 1)
    		{
    			parent.setChildIndex(this, parent.numChildren - 1);
    		}
    		startDrag();
    		_controller.add(new Event("onStartDrag"));
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
    		_controller.add(new Event("onStopDrag"));
    	};
    	onMouseUp.listen(done);
	}
}
