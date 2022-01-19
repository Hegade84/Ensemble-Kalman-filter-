clear
clc;
value = input('Select 1 for Linear function and 2 for Non-linear functions : ');

switch value
    case 1
        fprintf('****** Running Linear function ******\n');
        Linear_function();
    case 2
        fprintf('****** Running Non-linear function ******\n');
        Non_linear_function();
    otherwise
        fprintf('Invalid selection\n');
end

function Linear_function()
    n = 1;
    syms x1 x2;  
    f = [x1+.1*x2+.005; x2+.1];
    h = [x1];
    x_tr = [0; 1];                     %initial value of state
    x_ini = ones(2, 20);               %ensemble of initial estimate of the state
    w = [10^-3; .02];                  %process noise standard deviation
    z = [10];                          %measurement noise standard deviation
    num_iterations = 50;
    enkf(f,h,x_tr,x_ini,w,z,num_iterations,n);
end

function Non_linear_function()
    n = 2;
    syms x1 x2 x3;  
    f = [x2;x3;0.05.*x1.*(x2+x3)];
    h = [x1];
    x_tr = [0; 1; 1];                   %initial value of state
    x_ini = ones(3, 20);                %ensemble of initial estimate of the state
    w = [10^-3; .02; 0.01];             %process noise standard deviation
    z = [10];                           %measurement noise standard deviation
    num_iterations = 50;
    enkf(f,h,x_tr,x_ini,w,z,num_iterations,n);
end