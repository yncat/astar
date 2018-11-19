A-STAR TEST PROGRAM
Yukio Nozawa
Keio SFC(71646673)

This is a small program that visualizes a shortest path searching algorithm called A*. This program was written for the final project of the optimization theory class. It has following features:
Automatic maze generation 
Manual editing for the generated maze 
An adjustable maze generation factor 
Shortest path searching using A* algorithm 
Automatic navigation for the searched route  using visuals
Tracing logs in text

About A*
Here is a quick description about how to implement the algorithm.
In this example, the field is a two dimensional array of integers (it can also be applied for 3D). Where you can go is represented as the constant PATH. Where you cannot go is represented as the constant WALL.
The A* function is called with two sets of coordinates, starting and destination points.
When the algorithm starts, we need the following variables for each node:

State -- This is all initialized as NONE  at first. The state can be changed to OPENED or CLOSED.
Actual cost -- The cost we have to take from the starting point. 
Heuristic cost -- The approximate cost we may need to take to the destination point.
Score -- The sum of actual and heuristic cost.
Parent node -- From which the node was opened.
Opened nodes list -- the name explains itself.

First, we change the status of the starting point node to OPENED and add the coordinate of the node to the opened nodes list (I'll use "open somewhere" expression for this). Since this is the first open, there is no parent node here. Then, we start to loop. The loop continues until we reach the destination or the opened nodes list is empty.
Next, we try to open the adjacent nodes. If we want to go to only 4 directions, we just apply this for one unit left / right / up / down nodes. If we are to allow 8 directions, 4 more adjacent nodes must be processed. A node can be opened when all of the following conditions are met:
1 The state of the node is NONE (in other words, the already closed node can't be reopened)
2 The field array for the coordinate is PATH (the position that cannot be passed should not be opened)
When a node is opened, the actual and heuristic cost, and the score must be calculated and stored to the node's array. Also, the location of the node must be added to the opened nodes list. The location we were when a node was opened is called parent node and it's stored to the node's array.
After opening the adjacent nodes, we close the node we are currently at and forget it. We check the opened nodes list and find a node that has the least score and move our location to that coordinate.
When this loop ends, two results are expected. The opened nodes list is empty, or we reached the destination node. When the list is empty, it means that there was no path for the goal. If not, we can go further.
We are now focusing on the destination node. We check the parent node of where we are and move to the parent. Repeat this until we reach the starting node, and we can obtain the full backtrace of the optimal path. Finally, we reverce the data and done!

Application functions
Run index.html to start the program.
In this application, the starting point is fixed to the upper left and the destination is fixed to the bottom right.
The main screen displays the maze using a table with images. You can click anywhere on the maze to wall / unwall there. This enables you to create your own maze.
 There are some controls at the top of the screen. Regenerate maze button regenerates the maze. Search for the shortest path button runs the A* function and starts the auto navigation. When this button is pressed, the two buttons above is disabled until the navigation ends.
In the navigation mode, the green circle moves to the destination using the optimal path.

The map generation factor changes the total amount of tiles the automatic generation function unwalls the maze. the value of the factor is actually multiplied by 2 because the algorithm tries to unwall the tiles from two directions (the left upper corner and the right bottom corner).
At the bottom of the screen, tracing logs are displayed. These are mainly for me. 
The program was tested with Firefox and my iPhone with Safari on IOS10.

