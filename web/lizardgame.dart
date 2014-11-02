import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:stagexl/stagexl.dart';
import 'package:frappe/frappe.dart';

CanvasElement canvas;
Stage stage;
RenderLoop renderLoop;
ResourceManager resourceManager;
int mouseX = 0;
int mouseY = 0;
int MAX_BALLS = 5;
int MAX_SQUARES = 5;
int MAX_BUGS = 5;
Sprite makerBall;
Sprite makerSquare;
Sprite makerBug;
Sprite saveButton;
Sprite loadButton;
Sprite newButton;
Sprite holder;
List<Sprite> balls = new List<Sprite>();
List<Sprite> squares = new List<Sprite>();
List<Shape> bugs = new List<Shape>();

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
		
		makerSquare = new Sprite();
		makerSquare.graphics.rect(0, 0, 40, 40);
		makerSquare.graphics.fillColor(Color.Blue);
		makerSquare.graphics.strokeColor(Color.Black, 1);
		makerSquare.alpha = 0.9;
		makerSquare.x = 560;
		makerSquare.y = 20;
		stage.addChild(makerSquare);
		makerSquare.onMouseClick.listen((_)
		{
			makeNewSquare();
		});
		
		makerBug = new Sprite();
		makerBug.graphics.rect(0, 0, 40, 40);
		makerBug.graphics.fillColor(Color.Blue);
		makerBug.graphics.strokeColor(Color.Black, 1);
		makerBug.alpha = 0.9;
		makerBug.x = 600;
		makerBug.y = 20;
		stage.addChild(makerBug);
		makerBug.onMouseClick.listen((_)
		{
			makeBugSquare();
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
		
		holder = new Sprite();
        stage.addChild(holder);
	});
}

void makeNewBall()
{
	if(balls.length < MAX_BALLS)
	{
		holder.addChild(makeBall());
	}
}

void makeNewSquare()
{
	if(squares.length < MAX_SQUARES)
	{
		holder.addChild(makeSquare());
	}
}

void makeBugSquare()
{
	if(bugs.length < MAX_BUGS)
	{
		holder.addChild(makeBug());
	}
}

DraggableBall makeBall()
{
	DraggableBall ball = getDraggableBall();
	ball.x = makerBall.x;
	ball.y = makerBall.y + 50;
	balls.add(ball);
	return ball;
}

DraggableBall makeSquare()
{
	DraggableBall square = getDraggableSquare();
	square.x = makerSquare.x;
	square.y = makerSquare.y + 50;
	squares.add(square);
	return square;
}

TestBug makeBug()
{
	TestBug bug = getBug();
//	bug.x = makerBug.x;
//	bug.y = makerBug.y + 50;
	bugs.add(bug);
	return bug;
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

Sprite getDraggableSquare()
{
	DraggableBall ball = new DraggableBall();
    ball.graphics.rect(0, 0, 40, 40);
	ball.graphics.fillColor(Color.Blue);
	ball.graphics.strokeColor(Color.Black, 2);
	ball.alpha = 0.9;
	return ball;
}

Shape getBug()
{
	TestBug bug = new TestBug(new Point(300, 300), new Point(400, 400));
	return bug;
}

int orderByDepth(Sprite a, Sprite b)
{
	int aIndex = a.parent.getChildIndex(a);
	int bIndex = b.parent.getChildIndex(b);
	if(aIndex > bIndex)
	{
		return 1;
	}
	else if(aIndex < bIndex)
	{
		return -1;
	}
	else
	{
		return 0;
	}
}

void saveGame()
{
	var memento = {};
	var ballObjects = [];
	var squareObjects = [];
	int index = 0;
	int len = balls.length;
	
	for(index = 0; index < len; index++)
	{
		Sprite ball = balls[index];
		ballObjects.add({"x": ball.x, "y": ball.y, "z": ball.parent.getChildIndex(ball)});
	};
	len = squares.length;
	for(index = 0; index < len; index++)
	{
		Sprite square = squares[index];
		squareObjects.add({"x": square.x, "y": square.y, "z": square.parent.getChildIndex(square)});
	}
	memento["balls"] = ballObjects;
	memento["squares"] = squareObjects;
	window.localStorage["saveGame"] = JSON.encode(memento);
}

void destroyAll()
{
	balls.forEach((Sprite ball)
	{
		ball.removeFromParent();
	});
	balls.clear();
	squares.forEach((Sprite square)
	{
		square.removeFromParent();
	});
	squares.clear();
}

void loadGame()
{
	if(window.localStorage.containsKey("saveGame") == true)
	{
		var memento = JSON.decode(window.localStorage["saveGame"]);
		destroyAll();
		
		List balls = memento["balls"];
		List squares = memento["squares"];
		List preSortList = new List();
		balls.forEach((ball)
		{
			ball["type"] = "ball";
			preSortList.add(ball);
		});
		squares.forEach((square)
		{
			square["type"] = "square";
			preSortList.add(square);
		});
		preSortList.sort((a, b)
		{
			int aDepth = a["z"];
			int bDepth = b["z"];
			if(aDepth > bDepth)
			{
				return 1;
			}
			else if(aDepth < bDepth)
			{
				return -1;
			}
			else
			{
				return 0;
			}
		});
				
		int index;
		int len = preSortList.length;
		for(index = 0; index < len; index++)
		{
			Object memento = preSortList[index];
			DraggableBall item;
			if(memento["type"] == 'ball')
			{
				item = makeBall();
			}
			else if(memento["type"] == 'square')
			{
				item = makeSquare();
			}
			item.x = memento["x"];
			item.y = memento["y"];
			holder.addChild(item);
		}
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
	
	var sub;
	
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



class TestBug extends Shape
{
//	steering = truncate (steering, max_force)
//    steering = steering / mass
//     
//    velocity = truncate (velocity + steering , max_speed)
//    position = position + velocity
	
	num steering;
	Point velocity;
	Point target;
	Point position;
	Point fleeTarget;
	num mass = 20;
	num MAX_FORCE = 3;
	num MAX_VELOCITY = 1;
	num SLOWING_RADIUS = 200;
	num CIRCLE_DISTANCE = 4;
	num CIRCLE_RADIUS = 20;
	num wanderAngle = 0;
	num ANGLE_CHANGE = 1;
	
	TestBug(Point start, Point target)
	{
		x = start.x;
		y = start.y;
		position = new Point(x, y);
		this.target = target;
		graphics.rect(0, 0, 30, 10);
        graphics.fillColor(Color.Red);
    	graphics.strokeColor(Color.Black, 2);
    	alpha = 0.9;
    	velocity = new Point(MAX_VELOCITY, MAX_VELOCITY);
    	truncate(velocity, MAX_VELOCITY);
    	fleeTarget = new Point(500, 500);
    	
		onEnterFrame.listen((_)
		{
			
//			Point steering = seek(position, target);
			Point steering = wander();
			truncate(steering, MAX_FORCE);
			scaleBy(steering, 1 / mass);
			velocity = velocity.add(steering);
			truncate(velocity, MAX_VELOCITY);
			position = position.add(velocity);
			
			if(fleeTarget != null)
			{
				fleeTarget.x = mouseX;
				fleeTarget.y = mouseY;
				Point fleeVelocity = flee(fleeTarget);
				truncate(fleeVelocity, MAX_FORCE);
                scaleBy(fleeVelocity, 1 / mass);
                velocity = velocity.add(fleeVelocity);
                truncate(velocity, MAX_VELOCITY);
                position = position.add(velocity);
			}
			
			x = position.x;
           	y = position.y;
//           	if(x < 0 || x > stage.stageWidth || y < 0 || y > stage.stageHeight)
//           	{
//           		resetPosition(position, velocity, stage, steering, force);
//           	}
		});
		
		stage.onMouseClick.listen((MouseEvent event)
		{
			target.setTo(event.stageX, event.stageY);
		});
	}
	
	Point wander()
	{
		Point circle = velocity.clone();
		scaleBy(circle, CIRCLE_DISTANCE);
		Point displacement = new Point(0, -1);
		scaleBy(displacement, CIRCLE_RADIUS);
		setAngle(displacement, wanderAngle);
		wanderAngle += (new Random().nextDouble() * ANGLE_CHANGE) - (ANGLE_CHANGE * 0.5);
		Point wanderForce = circle.add(displacement);
		return wanderForce;
	}
	
	void setAngle(Point angle, num value)
	{
		num len = angle.magnitude;
		angle.x = cos(value) * len;
		angle.y = sin(value) * len;
	}
	
	Point seek(Point position, Point target)
	{
		Point desired = new Point(target.x - position.x, target.y - position.y);
		normalize(desired);
		num distance = position.distanceTo(target);
		if(distance <= SLOWING_RADIUS)
		{
			scaleBy(desired, MAX_VELOCITY * distance / SLOWING_RADIUS);
		}
		else
		{
			scaleBy(desired, MAX_VELOCITY);
		}
		Point force = desired.subtract(velocity);
		return force;
	}
	
	Point flee(Point fleeTarget)
	{
		Point desired = position.subtract(fleeTarget);
		scaleBy(desired, MAX_VELOCITY);
		Point force = desired.subtract(velocity);
		return force;
	}
	
	void normalize(Point point)
	{
		double l = sqrt(point.x * point.x + point.y * point.y);
		point.x /= l;
		point.y /= l;
	}
	
	void scaleBy(Point point, num value)
	{
		point.x *= value;
		point.y *= value;
	}
	
	void truncate(Point point, num max)
	{
		num i;
		if(point.magnitude != 0)
		{
			i = max / point.magnitude;
		}
		else
		{
			i = 0;
		}
		i = i < 1.0 ? i : 1.0;
		scaleBy(point, i);
	}
	
	void resetPosition(Point position, Point velocity, Stage stage, Point desired, Point steering)
	{
		position.x = stage.stageWidth / 2;
		position.y = stage.stageHeight / 2;
		
		velocity.x = -1 * (new Random().nextDouble() < 0.5 ? -2 : 1);
		velocity.y = -1 * (new Random().nextDouble() < 0.5 ? -2 : 1);
		
		truncate(velocity, MAX_VELOCITY * 0.5);
		desired.setTo(0, 0);
		steering.setTo(0, 0);
		
		x = position.x;
        y = position.y;
	}
}










