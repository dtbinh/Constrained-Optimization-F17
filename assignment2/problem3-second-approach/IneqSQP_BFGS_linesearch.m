function [ x_k, fval, lambda_k, k, X, alphas ] = IneqSQP_BFGS_linesearch( x_0, lambda_0, maxiter, epsilon, tau, eta )
% Inequality constrained non-linear programming solver using
% sequential quadratic programming approach with damped BFGS approximation
% to the hessian of the lagrangian and linesearch procedure

x_k = x_0;
X = [ x_k ];
alphas = [];
lambda_k = lambda_0;
k = 0;
B_k = eye(2);
grad_fk = gradient_f(x_k);
A_k = jacobian_c(x_k);
mu_k = 0;

tau_alpha = 0.5 * tau;

while (k < maxiter) 
    c_k = c(x_k);
    
    % KKT conditions satisfied
    if max(abs(grad_fk - A_k' * lambda_k)) < epsilon && max(abs(c_k)) + epsilon >= 0 && ...
            min(lambda_k) + epsilon >= 0 && max(abs(c_k .* lambda_k)) < epsilon
        break
    end
    %H_quad = [ B_k zeros(2) ; zeros(2) zeros(2) ];
    %f_quad = [grad_fk ; 0 ; 0 ];
    %Aeq = [-A_k eye(2)];
    %beq = c_k;
    %lb = [ -Inf -Inf 0 0 ]';
    %[p_s, fval, ~, ~, lambda_hat] = quadprog(H_quad, f_quad, [], [], Aeq, beq, lb, []);
    %p_k = p_s(1:2);
    %s = p_s(3:4);
    %lambda_hat = lambda_hat.eqlin;
    %p_lambda = lambda_hat - lambda_k;
    
    [p_k, ~, ~, ~, lambda_hat] = quadprog(B_k, grad_fk, -A_k, c_k);
    lambda_hat = lambda_hat.ineqlin;
    p_lambda = lambda_hat - lambda_k;
    
    
    % Choose mu_k to satisfy (18.36) with sigma = 1, rho = 0.5
    mu_k = get_mu(mu_k, grad_fk, p_k, B_k, c_k, 1, 0.5, 0.01);
    alpha_k = 1;
    
    % if mu_k hasn't changed this iteration, phi_1(x_k, mu_k) would not 
    % need to be recomputed
    while phi_1(x_k + alpha_k * p_k, mu_k) > phi_1(x_k, mu_k) + get_decrease_term(mu_k, eta, alpha_k, grad_fk, p_k, c_k) 
        alpha_k = tau_alpha * alpha_k;
        %k
    end
    
    alphas = [alphas alpha_k];
    x_kplus1 = x_k + alpha_k * p_k;
    lambda_kplus1 = lambda_k + alpha_k * p_lambda;
    
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
    % standard BFGS update would not necessarily retain the positive
    % semidefiniteness of the B_k matrix
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

