%%  Pre Lab 2 ----- Digital Communication Laboratory

clear ; close all ; clc

%% Problem 1 Test

x = [ -2 3 3 3 1 7 9];
h = [ 0 1 0 2 3  ];
y = conv(x,h)
yy = conv_m(x,h)
Equal = isequal(y,yy)

%% Problem 2
% 4 part of this question is seperate

%% part a

x = 1:5 ;
h = 6:9 ;
y = conv_m(x,h);

%% part b 

x = x' ; y = y' ; h = h' ;

H = hmat(h,length(x));

yb = H * x ; 
Equal2 = isequl(yb,y);

%% part c

T = toeplitz(h);
display(T)

%% part d

x = [ -2 3 3 3 1 7 9];
h = [ 0 1 0 2 3  ];

[y1, y2 ] = conv_tp(x,h);
Equal_d = isequal(y1,y2);

%% Problem 3 

% Calculating Weight Matrix

N = 16 ;
Coefficent = [ 0 1 9  ] ; d = 0 : N-1 ;
Wn = exp(-1i * 2 * pi * Coefficent' .* d / N) ;

f = -125e6 : 250e6/(256^2) : 125e6 ;
z = exp(1i * 2 * pi * f) ;
z = z' .^ d ;

W = flip(Wn,2)';

X = abs(sum(W .* z,1)) ;
 

%% Convolution 

function y = conv_m(x,h)
    K = length(x) + length(h) -1;
    x = [x zeros(1,length(x))];
    h = [h zeros(1,length(h)+1)];
    
    for i= 1:K
        y(i)=0;
        for j=1:length(h)+1
            if(i-j+1>0)
                y(i)=y(i)+x(j)*h(i-j+1);
            end
        end
    end
   
end

%% H - Covolution as Matrix

function H = hmat(h,lx) 
    % h should be column vector
    H = zeros(lx,lx+length(h)-1);
        for j = 1:lx
            H(j,j:length(h)+j-1) = h ;
        end
    H = H' ;
end


%% Toeplitz Matrix

function T = Toeplitz(h)
    lh = length(h) ;
    h = [ h ; zeros(length(h),1)];
    temp = h;
    for i = 1 : lh
        h = cat(2,h,circshift(temp,1));
    end
end

%% Convolution with Toeplitz Matrix

function [ y , Conv_fcn ]  = conv_tp(x,h)
    
    Conv_fcn = conv_m(x,h)';

    h = [h, zeros(1, (length(x) -1))];
    p = zeros;
    p = [h(1), zeros(1, (length(x) - 1))];
    
    t = toeplitz(h,p);

    m = x';
    y = t*m;
    disp('Convolved Sequence');
    convolution=y';

    disp('Verification of Sequence using inbuilt conv function');
    
end

%%
