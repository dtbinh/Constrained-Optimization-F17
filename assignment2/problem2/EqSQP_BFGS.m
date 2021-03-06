function [ x_k, fval, lambda_k, k, X ] = EqSQP_BFGS( x_0, lambda_0, maxiter, epsilon )
% Equality constrained non-linear programming solver using
% sequential quadratic programming approach with damped BFGS approximation
% to the hessian of the lagrangian
x_k = x_0;
X = [ x_k ];

lambda_k = lambda_0;
k = 0;
B_k = eye(5);
%B_k = hessian_f(x_k) - (lambda_k(1) * hessian_ci(x_k,1) + ...
%                        lambda_k(2) * hessian_ci(x_k,2) + ...
%                        lambda_k(3) * hessian_ci(x_k,3));
%B_k = B_k' * B_k;
grad_fk = gradient_f(x_k);
A_k = jacobian_c(x_k);
while (k < maxiter) 
    c_k = c(x_k);
    
    % 8 element vector (n+m)
    F_k = [ grad_fk - A_k' * lambda_k ; c_k ];
    % first order KKT conditions 
    if max(abs(F_k)) < epsilon
        break
    end
    %[p, ~, ~, ~, lambda] = quadprog(B_k, grad_fk, A_k, -c_k);
    [p, lambda] = EqualityQPSolverLU(B_k, grad_fk, A_k', -c_k);
    x_kplus1 = x_k + p;
    lambda_kplus1 = lambda;
    
    % p536 18.13
    s_k = x_kplus1 - x_k;
    grad_fkplus1 = gradient_f(x_kplus1);
    A_kplus1 = jacobian_c(x_kplus1);
    grad_Lkplus1 = grad_fkplus1 - A_kplus1' * lambda_kplus1;
    grad_Lk = grad_fk - A_k'*lambda_kplus1;
    y_k = grad_Lkplus1 - grad_Lk;
    % p537 
    theta_k = get_theta_k(B_k, s_k, y_k);
    r_k = theta_k * y_k + (1-theta_k) * B_k * s_k;
    % standard BFGS update with y_k replaced by r_k
    add1 = (B_k * s_k * s_k' * B_k) / (s_k' * B_k * s_k);
    add2 = (r_k * r_k') / (s_k' * r_k);
    B_kplus1 = B_k - add1 + add2;
    
    % update everything for next iteration
    B_k = B_kplus1;
    grad_fk = grad_fkplus1;
    A_k = A_kplus1;
    x_k = x_kplus1;
    X = [X x_k];
    lambda_k = lambda_kplus1;
    k = k + 1;  
end
fval = f(x_k);
end

