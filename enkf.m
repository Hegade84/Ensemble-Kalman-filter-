function [x_tr, x_estbar, ybar] = enkf(f, h, x_tr, x_ini, w, z, num_iterations, n) 
[dummy, num_members] = size(x_ini);    %calculate size of ensemble
p1 = length(f);                        %calculate length of function
m1 = length(h);
var_vector = [];
xV = zeros(p1, num_iterations);        %save estimate
sV = zeros(p1, num_iterations);        %save actual 
zV = zeros(m1, num_iterations);
x_est = x_ini;

for j = 1 : p1                         %create vector containing variables x1 to xn
  eval(sprintf(' syms x%d', j));
  temp = sprintf('x%d ',j);
  var_vector = [var_vector; sym(temp)];
end

Zcov = eye(m1);                        %create measurement noise covariance matrix
for j = 1 : m1
  Zcov(j,j) = z(j)^2;
end

fprintf('********* Estimation started **********\n');

for i = 1 : num_iterations                                           %compute true value of 
   x_tr = double(subs(f,var_vector,x_tr) + w.* randn(p1,1));         %state at next time step
   for j = 1 : num_members
     W(:,j) = w.* randn(p1,1);                                       %create process noise
     Z(:,j) = z.* randn(m1,1);                                       %create measurement noise
     x_est(:,j) = double(subs(f,var_vector,x_est(:,j)) + W(:,j));    %forecast state
     y(:,j) = double(subs(h,var_vector,x_tr) + Z(:,j));              %make measurement
     y_for(:,j) = double(subs(h,var_vector,x_est(:,j)));             %forecast measurement   
   end
   sV(:,i) = x_tr;
   x_estbar = mean(x_est, 2);                    
   ybar = mean(y, 2);
   y_forbar = mean(y_for, 2);

   for j = 1 : p1                            %A = X - E(X)
     Ex(j,:) = [x_est(j,:) - x_estbar(j)];
   end

   for j = 1 : m1                            %HA = HX - E(HX), but h(x)=Hx
     Ey(j,:) = [y_for(j,:) - y_forbar(j)];
   end

   Pxy = Ex * Ey' / (num_members - 1);       %A * (HA)^T / N-1
   Pyy = Ey * Ey' / (num_members - 1) + Zcov;
   K = Pxy * inv(Pyy);                       %Kalman gain
   x_est = x_est + K * (y - y_for);          %posterior ensemble X^p
   if i == num_iterations
       x_estbar = mean(x_est, 2);
   end
   zV(:,i) = ybar;
   xV(:,i) = x_estbar;
end
%% Plot the estimation results   
if n == 1
    for k = 1 : 2
        subplot(2, 1, k)
        plot(1:num_iterations, sV(k,:),'-', 1:num_iterations, xV(k,:),'--')
        legend('actual', 'estimate')
    end
else
    for k = 1 : 3
        subplot(3, 1, k)
        plot(1:num_iterations, sV(k,:),'-', 1:num_iterations, xV(k,:),'--')
        legend('actual', 'estimate')
    end
end
