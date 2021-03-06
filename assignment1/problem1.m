clc; clear all; close all;
% problem 1

% Q 1
g = [ -8 -3 -3 ]';
b = [ 3 0 ]';
A = [ 1 0 1 ; 0 1 1 ]';
H = [ 6 2 1 ; 2 5 2 ; 1 2 4 ];
%%
% Q 2
% Q 3
% Q 4
[ x, lambda ] = EqualityQPSolver(H,g,A,b)
%%
% Q 5
% q5
% nr of unknowns
unks = 3;
% nr of constraints
constr = 2;
R = rand(unks, unks);
% make symmetric
R = 1/2 * (R + R');
% make positive definite
H = R + unks*eye(unks);

x_true = [ 0.5; 0.25; 4 ]
lambda_true = [ 0.7; 0.5 ]
A = rand(unks, constr);
b = A' * x_true;
g = A * lambda_true - H * x_true;
[x, lambda] = EqualityQPSolver(H,g,A,b)


%%
% Q 6
%The sensitivities add to the EqualityQPSolver 
[x,lambda,dx,dlambda] = EqualityQPSolver(H,g,A,b);
dx
dlambda
% Q 7
% Added to solver
% Q 8
% In report
% Q 9 
% In report
% Q 10
