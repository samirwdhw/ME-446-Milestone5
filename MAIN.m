% Acrobot
clc
clear all
close all

addpath gen
addpath fcns
addpath optim_fcns

fprintf('------ ME446 Milestone 5 -------\n')
fprintf('Initializing ..............\n')

% --- parameters ---
p = get_params;     % Getting physical parameters of the robot

% Variables to study

% Initial condition
q0 = [-pi/2; 0]; %Joint angles
dq0 = [0; 0];       %Joint velocities
ic = [q0; dq0];

% Loading results of the optimization routine
load('optim_vars.mat');

% Recording
tstart = 0;
%tfinal = 2*Nstep;   %Maximum simulation time
tfinal = t_des(end)+10;
% Simualtion step size 
% ode45 still uses a variable time solver but this ensures it returns the 
% values at the required times
dt = 0.05;
tout = tstart;
Xout = ic';

[tout,Xout] = ode45(@(t,X)dyn_manip(t,X,p,t_des,u_des, x_des),...
    [tstart:dt:tfinal], Xout(end,:));

fprintf('Simulation Complete!\n')

% Back calculating u
u = backCalculate(tout, Xout, p, t_des, u_des, x_des);

%% Simulation for the mass at end

disp('Ball Simulation Started ..............');

xf = Xout(floor(t_des(end)/dt)+1,:)';
qf = xf(1:2);
dqf = xf(3:4);
J = fcn_J_foot(qf,p.params); J = J(1:2,1:2);

ball_pos0 = fcn_p2(qf,p.params); ball_pos0 = ball_pos0(1:2);
ball_v0 = J*dqf;

ball_x0 = [ball_pos0;ball_v0];

[ball_t, ball_X] = ode45(@(t,X)dyn_ball(t,X),[t_des(end):dt:t_des(end)+10], ball_x0);

disp('Ball Simulation Complete!');

%% Visualing the motion
animateRobot(tout,Xout,ball_t, ball_X, xb, yb, p, t_des);

%% Comparing Calculated and Actual Parameters

index_throw = find(tout == t_des(end));

figure 
plot(t_des, u_des); hold on;
plot(tout(1:index_throw), u(1:index_throw));
title('Control Comparison');

figure 
plot(t_des, x_des(:,1)); hold on;
plot(tout(1:index_throw), Xout(1:index_throw,1));
title('\theta_1 Comparison');

figure
plot(t_des, x_des(:,2)); hold on;
plot(tout(1:index_throw), Xout(1:index_throw,2));
title('\theta_2 Comparison');


