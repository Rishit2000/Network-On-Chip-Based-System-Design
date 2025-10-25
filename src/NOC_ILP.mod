/*********************************************
 * OPL 20.1.0.0 Model
 * Author: Rishit Patel
 * Creation Date: 11-Oct-2021 at 7:55:02 pm
 *********************************************/
using CP;

//Input Parameters

//number of tasks(nodes) in CG
int tasks = ...;
range r_tasks = 1..tasks;

//number of edges in CG
int edges = ...;
range r_edges = 1..edges;

//X dimension of 2D mesh TG
int xdim = ...;
range r_xdim = 1..xdim;
range r_xdim_1 = 0..xdim-1;

//Y dimension of 2D mesh TG
int ydim = ...;
range r_ydim = 1..ydim;
range r_ydim_1 = 0..ydim-1;

//define an edge between two tasks in CG
tuple edge{
  int a;
  int b;
}

//given edges between tasks in CG
edge edge_tasks[r_edges] = ...;				


//declaring decision variables

//mapping[t][i][j] = 1, if task t is mapped to the tile i,j ; = 0, otherwise
dvar boolean mapping[r_tasks][r_xdim][r_ydim];	

//x_dist[i][j][a] = 1, if distance in x dimension between tasks i and j is equal to a ; = 0, otherwise
dvar boolean x_dist[r_tasks][r_tasks][r_xdim_1];	

//y_dist[i][j][b] = 1, if distance in y dimension between tasks i and j is equal to b ; = 0, otherwise
dvar boolean y_dist[r_tasks][r_tasks][r_ydim_1]; 

//x[i] = The X coordinate of tile to which the task a of ith edge(a,b) is mapped
dvar int x[r_edges] in r_xdim;

//y[i] = The Y coordinate of tile to which the task a of ith edge(a,b) is mapped
dvar int x1[r_edges] in r_xdim;

//x1[i] = The X coordinate of tile to which the task b of ith edge(a,b) is mapped
dvar int y[r_edges] in r_ydim;

//y1[i] = The Y coordinate of tile to which the task b of ith edge(a,b) is mapped
dvar int y1[r_edges] in r_ydim;


//objective function - for each task edge, number of MRs = 2, if tasks mapped along same dimension; = 3, otherwise
dexpr float number_of_MRs = sum(k in r_edges)((3-x_dist[edge_tasks[k].a][edge_tasks[k].b][0]-y_dist[edge_tasks[k].a][edge_tasks[k].b][0])+ (1/(xdim*ydim))*(ftoi(abs(x[k]-x1[k]))+ftoi(abs(y[k]-y1[k]))));
minimize number_of_MRs;


//constraints 
subject to{
  
	//to ensure that each task is mapped to one tile
	forall(t in r_tasks) 
  		c1:
  		sum (i in r_xdim, j in r_ydim) mapping[t][i][j] == 1;
  
	//to ensure that each tile has been mapped with atmost one task
	forall(i in r_xdim, j in r_ydim) 
		c2:
		sum (t in r_tasks) mapping[t][i][j] <= 1;
		
    //to ensure that decision variables - x, y, x1, y1 are consistent with the mapping decision variable
	forall(k in r_edges)
	    c3:
		(mapping[edge_tasks[k].a][x[k]][y[k]]==1)&&(mapping[edge_tasks[k].b][x1[k]][y1[k]]==1)==1;
    
    //to ensure that x_dist shows the correct distance between all edge tasks along x dimension 
	forall(k in r_edges)
		c4:
		x_dist[edge_tasks[k].a][edge_tasks[k].b][ftoi(abs(x[k]-x1[k]))] == 1;
    
    //to ensure that x_dist shows only one distance value between all edge tasks along x dimension 
	forall(k in r_edges)
		c5:
		sum(d in r_xdim_1)x_dist[edge_tasks[k].a][edge_tasks[k].b][d] <= 1;

    //to ensure that y_dist shows the correct distance between all edge tasks along y dimension
	forall(k in r_edges)
		c6:
		y_dist[edge_tasks[k].a][edge_tasks[k].b][ftoi(abs(y[k]-y1[k]))] == 1;
		
    //to ensure that y_dist shows only one distance value between all edge tasks along y dimension  
	forall(k in r_edges)
		c7:
		sum(d in r_ydim_1)y_dist[edge_tasks[k].a][edge_tasks[k].b][d] <= 1; 
		
}