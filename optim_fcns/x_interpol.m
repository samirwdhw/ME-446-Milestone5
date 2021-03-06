function x = x_interpol(t,t_des, x_des, u_des, p)
% Given the states at discrete times, this function gives the  
% states at any point t using a quadratic spline

% Finding the value higher and lower than the given time in t_des
closest_high = min(t_des(t_des>=t));
closest_low = max(t_des(t_des<=t));

tau = t - closest_low;

params = p.params;

% If the same value exists in t_des
if closest_high == closest_low
   x = x_des(t_des == t,:)';
else
    x_k = x_des(t_des == closest_low,:)';
    x_kp1 = x_des(t_des == closest_high,:)';
    
    u_k = u_des(t_des == closest_low);
    u_kp1 = u_des(t_des == closest_high);
    
    dt = closest_high - closest_low;
    
    q_k = x_k(1:2); 
    dq_k = x_k(3:4);
    q_kp1 = x_kp1(1:2);
    dq_kp1 = x_kp1(3:4);
    
    % Definining system dynamics at the collocation points
    De_k = fcn_De(q_k,params);
    Ce_k = fcn_Ce(q_k,dq_k,params);
    Ge_k = fcn_Ge(q_k,params);
    Be = [0;1];
    
    f_k = [dq_k; De_k\(Be*u_k - Ce_k*dq_k - Ge_k)];
    
    De_kp1 = fcn_De(q_kp1,params);
    Ce_kp1 = fcn_Ce(q_kp1,dq_kp1,params);
    Ge_kp1 = fcn_Ge(q_kp1,params);
    
    f_kp1 = [dq_kp1; De_kp1\(Be*u_kp1 - Ce_kp1*dq_kp1 - Ge_kp1)];
    
    x = x_k + f_k*tau + tau^2/(2*dt)*(f_kp1 - f_k);
    
end
   

end

