//a-star testing program
//optimization Theory final project
//Written by Yukio Nozawa - 71646673


//settings
//Alt texts for screen reader users
var txtPath="Path";
var txtWall="Wall";
var txtYourPos="you";//your position

//Image size in percentage, but smaller images seem to create unnecessary blanks between the paths
var imgPercentage=100;

//constants
var WALL=0;
var PATH=1;
var LEFT=0;
var RIGHT=1;
var UP=2;
var DOWN=3;
var NONE=0;
var CLOSED=1;
var OPENED=2;

//global memory alocations
var maze;//the main field
var sound=new Audio("step.mp3");
var route;//the result of a-star is stored here
var navigationX,navigationY;//the current coordinate while auto-navigating
var navigating=false;//whether the navigation is in progress
var circleX=0,circleY=0;//your position(circle)
var lastCircleX=-1,lastCircleY=-1;//the position of the circle at the last frame
var navigationCount;//how many steps we took while navigating

window.onload=function(){//Generate a maze when loaded
	maze_generate();
}

function changeTile(x, y){//change the clicked tile
	if(navigating) return;//If the maze were altered while navigating, the circle would penetrate walls! no!
	if(x==0 && y==0){
		alert("this is not allowed!");
		return
}
	if(x==9 && y==9){
		alert("this is not allowed!");
		return
}

	var b=document.getElementById(""+x+"-"+y);
	var btxt=b.alt;
	switch(btxt){
		case txtWall:
			b.alt=txtPath;
			b.src="white.jpg";
			maze[x][y]=PATH;
		break;
		case txtPath:
			b.alt=txtWall;
			b.src="black.png";
			maze[x][y]=WALL;
		break;
	}
}
function maze_generate(){//generate a random maze
	//check the factor
	var a=document.getElementById("factor");
	var factor=parseInt(a.value);
	if(factor<5) factor=5;
	if(factor>40) factor=40;
	a.value=factor;
	//initialize with walls first
	maze=new Array(10);
	for(var i=0;i<10;i++){
		maze[i]=new Array(10);
	}
	for(i=0;i<10;i++){
		for(var j=0;j<10;j++){
			maze[i][j]=WALL;
		}
	}
	maze[0][0]=PATH;//the top left corner should be the starting position
	maze[9][9]=PATH;//we want the bottom right corner to be our destination
	randomly_dig(0,0,factor);//dig from the upper left
	randomly_dig(9,9,factor);//dig from the bottom right
	//write down the maze
	a=document.getElementById("map");
	var tmp='<table frame="box" border="1" rules="none" cellspacing="0" cellpadding="0">';
	for(var i=0;i<10;i++){
		tmp+="<tr>";
		for(var j=0;j<10;j++){
			if(maze[i][j]==WALL){
				tmp+='<td><img src="black.png" alt="'+txtWall+'" onclick="changeTile('+i+','+j+');" id="'+i+'-'+j+'" width="'+imgPercentage+'%" height="'+imgPercentage+'%"></td>'
			}else{
				tmp+='<td><img src="white.jpg" alt="'+txtPath+'" onclick="changeTile('+i+','+j+');" id="'+i+'-'+j+'" width="'+imgPercentage+'%" height="'+imgPercentage+'%"></td>'
			}
		}
		tmp+="</tr>";
	}
	tmp+="</table>";
	a.innerHTML=tmp;
	setCircle(0,0);//you are at the starting position
}
function randomly_dig(_x,_y,num){//makes some paths from the specified position
	var x=_x;
	var y=_y;
	var count=0;
	var opposite=-1;
	while(true){//until we reach the factor number
		while(true){//until we find the non-opposite way
			var r=Math.floor(Math.random()*4);
			if(r!=opposite) break;
		}
		switch(r){//which do we go?
			case LEFT:
				opposite=RIGHT;
				x--;
			break;
			case RIGHT:
				opposite=LEFT;
				x++;
			break;
			case UP:
				opposite=DOWN;
				y--;
			break;
			case DOWN:
				opposite=UP;
				y++;
			break;
		}
		//not to get out of the maze
		if(x==-1) x=0;
		if(x==10) x=9;
		if(y==-1) y=0;
		if(y==10) y=9;
		if(maze[x][y]==WALL){//dig
			maze[x][y]=PATH;
			count++;
		}
		if(count==num) break;
	}
}

function astar(sx, sy, dx, dy){//search for the shortest path from sx-sy to dx-dy
	//alocate some memory
	var nodeX=new Array(10);
	var nodeY=new Array(10);
	var nodeState=new Array(10);
	var nodeCostA=new Array(10);
	var nodeCostH=new Array(10);
	var nodeScore=new Array(10);
	var nodeParentX=new Array(10);
	var nodeParentY=new Array(10);

	for(var i=0;i<10;i++){
		nodeX[i]=new Array(10);
		nodeY[i]=new Array(10);
		nodeState[i]=new Array(10);
		nodeCostA[i]=new Array(10);
		nodeCostH[i]=new Array(10);
		nodeScore[i]=new Array(10);
		nodeParentX[i]=new Array(10);
		nodeParentY[i]=new Array(10);
	}

	var openListX=new Array();
	var openListY=new Array();

	var cpx=sx;
	var cpy=sy;
	var cCost=0;
	var cScore=0;
	var cScoreX=-1;
	var cScoreY=-1;

//initialize the node status
	for(var i=0;i<10;i++){
		for(var j=0;j<10;j++){
			nodeState[i][j]=NONE;
		}
	}
	var cpx=sx;
	var cpy=sy;
	var cCost=0;
	var cScore=0;
	var cScoreX=-1;
	var cScoreY=-1;

//open the first location
	var parent=open(cpx,cpy,-1,-1);//the starting position doesn't have a parent node, so specify -1,-1

	var counter=0;
	var nopath=0;//true if no path was found
	while(true){//start searching
		counter++;
		if(cpx==dx && cpy==dy) break;//reached our destination
		if(openListX.length==0){//no more to look for
			nopath=1;
			break;
		}
		if(cpx!=0) open(cpx-1,cpy,cpx,cpy);//left
		if(cpx!=9) open(cpx+1,cpy,cpx,cpy);//right
		if(cpy!=0) open(cpx,cpy-1,cpx,cpy);//down
		if(cpy!=9) open(cpx,cpy+1,cpx,cpy);//up
		close(parent);//close the parent node
//search for a node that has the smallest cost from the opened nodes list
		cScore=-1;//still undefined
		for(var i=0;i<openListX.length;i++){
			var x=openListX[i];
			var y=openListY[i];
			if(cScore==-1 || nodeScore[x][y]<cScore){//update the value
				cScore=nodeScore[x][y];
				cScoreX=x;
				cScoreY=y;
			}
		}//found the next node to check
		cpx=cScoreX;
		cpy=cScoreY;
		parent=getOpenList(cpx,cpy);
	}//searching loop
	if(nopath){
		return false;
	}
	//found a path
	var tmp=""+dx+"-"+dy+",";//start
	while(true){
		var prx=nodeParentX[cpx][cpy];//ask the parent its position
		var pry=nodeParentY[cpx][cpy];
		cpx=prx;//move our position
		cpy=pry;
		tmp+=""+prx+"-"+pry+","//log where we are now
		if(prx==sx && pry==sy) break;
	}//traced parents
	var ret=tmp.split(",");//make it an array
	return ret.reverse();//reverse it and return

//related functions
	function open(x, y, px, py){//try to open the specified node
		if(nodeState[x][y]!=NONE) return 0;//A node that is still untouched can only be opened
		if(maze[x][y]==WALL) return 0;//the location of wall can't be opened
		nodeState[x][y]=OPENED;
		nodeCostA[x][y]=Math.abs(sx-x)+Math.abs(sy-y);//the cost so far
		nodeCostH[x][y]=Math.abs(x-dx)+Math.abs(y-dy);//the heuristic cost
		nodeScore[x][y]=nodeCostA[x][y]+nodeCostH[x][y];//the heuristic score for evaluation
		if(px!=-1 && py!=-1){//has a parent
			nodeParentX[x][y]=px;
			nodeParentY[x][y]=py;
		}
		openListX.push(x);//add to the opened nodes list
		openListY.push(y);
		return openListX.length-1;
	}
	function close(closeNum){//close the specified node
		var x=openListX[closeNum];//retrieve the coordinate
		var y=openListY[closeNum];
		nodeState[x][y]=CLOSED;
		openListX.splice(closeNum,1);//delete from the list as well
		openListY.splice(closeNum,1);
		return;
	}
	function getOpenList(x,y){//convert a coordinate to the slot number of the opened nodes list
		var found=-1;
		for(var i=0;i<openListX.length;i++){
			if(openListX[i]==x && openListY[i]==y){
				found=i;
				break;
			}
		}
		return found;
	}
}

function btn_regenerate(){//regenerate maze button
	maze_generate();
}

function btn_search(){//search for the shortest path button
	route=astar(0,0,9,9);
	if(route===false){
		alert("No path was found for this maze.");
		return;
	}
	navigation_init();
	navigate();
	return;
}

function navigation_init(){//initialize the auto-navigation
	navigating=true;
	document.getElementById("btn_regenerate").disabled="true";
	document.getElementById("btn_search").disabled="true";

	navigationCount=2;//this should be always 2
	navigationX=0;//starting position
	navigationY=0;
	document.getElementById("trace").innerHTML="Turn 1 : Navigation started<br>";
}

function navigate(){//one step per call
	if(navigationCount==route.length){//we are done
		navigation_end();
		return;
	}
	var tmp=route[navigationCount].split("-");//separate the x and y
	tmp[0]=parseInt(tmp[0]);
	tmp[1]=parseInt(tmp[1]);
	var direction;
	if(tmp[0]<navigationX) direction="west";
	if(tmp[0]>navigationX) direction="east";
	if(tmp[1]>navigationY) direction="south";
	if(tmp[1]<navigationY) direction="north";
	navigationX=tmp[0];
	navigationY=tmp[1];
	setCircle(navigationX,navigationY);//move the circle
	sound.play();
	document.getElementById("trace").innerHTML+="Turn "+navigationCount+" : moving to "+direction+" ("+navigationX+"-"+navigationY+")<br>";
	navigationCount++;
	setTimeout("navigate();",500);//0.5 seconds later
}
function navigation_end(){//ends the navigation
	navigating=false;
	document.getElementById("trace").innerHTML+="Reached the destination";
	setTimeout("setCircle(0,0);",5000);//reset the position of the circle 5 seconds later
	document.getElementById("btn_regenerate").disabled="";
	document.getElementById("btn_search").disabled="";
}
function setCircle(x,y){//place the circle at the specified position, irasing the previous one of course
	var a;
	if(lastCircleX!=-1 || lastCircleY!=-1){//there was a circle somewhere before this frame
		a=document.getElementById(""+lastCircleX+"-"+lastCircleY);
		//turn it back to the tile image
		if(maze[lastCircleX][lastCircleY]==WALL){
			a.alt=txtWall;
			a.src="black.png";
		}else{
			a.alt=txtPath;
			a.src="white.jpg";
		}
	}
	a=document.getElementById(""+x+"-"+y);
	a.alt=txtYourPos;
	a.src="circle.bmp";
	lastCircleX=x;
	lastCircleY=y;
}
