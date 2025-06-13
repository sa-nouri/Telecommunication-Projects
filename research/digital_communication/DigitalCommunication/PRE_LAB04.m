%% Pre Lab 04 --- Linear Digital Modulation Introducing

close all ;clear ; clc;

%%  Part 2 ;

[ qam_4 , ~]  = constellation(4 , 'qam') ;
[ qpsk , ~]  = constellation(4 , 'psk') ;
[ pam_8 , ~]  = constellation(8 , 'pam') ;
[ qpsk_16 , ~]  = constellation(16 , 'psk') ;
[ qam_32 , ~]  = constellation(32, 'qam') ;
scatterplot(qam_4);
scatterplot(qpsk);
scatterplot(pam_8);
scatterplot(qpsk_16);
scatterplot(qam_32);

%% Bit Producing

function b = bit_gen( N , k ) 
    % k = log2(M) 
    b = randi([0,1], N, k );
 
end

%% Costellation

function [cons, Es_avg] = constellation(M, modulation) 
    switch modulation
        case 'pam'
            i =  -(M-1): 2 : M-1;
            Es_avg=sum(abs(i).^2)/M;
            cons=i'/sqrt(Es_avg);
            Es_avg=sum(abs(cons).^2)/M;

        case 'psk'
            i= 1 : M ;
            s = sin(2 * pi * (i-1) / M );
            c = cos(2 * pi * (i-1) / M );
            Es_avg = sum( ( s.^2 + c.^2 ) ) / M;
            cons=cat(1,c,s)';
            
        case 'qam'
            i =  0 : M-1 ;
            A = floor(i/4) + 1;
            B = (A) * pi/4;
            c = (A) .* cos( 2 * pi * (i) / (4+B ));
            s = (A) .* sin(2 * pi * (i) / (4+B) );
            Es_avg = sum(sum( ( s.^2 + c.^2) )) / M;
            cons=cat(1 , c/sqrt(Es_avg) , s/sqrt(Es_avg) )';
            Es_avg = sum(sum( abs( cons' ).^2 ) )/M;
    end 

end

%% Pulse Shape

 function [p, t] = pulse_shape(pulse_name, fs, smpl_per_symbl, varargin)
    
    t=[0:smpl_per_symbl-1]/fs;
    Ts=smpl_per_symbl/fs;
    switch pulse_name
        case 'rectangular'
            amp = sqrt(Ts);
            p =zeros(1,length(t));
            p = p+amp;
        case 'triangular'
            a = Ts/2-abs(t-Ts/2);
            b = zeros(1,length(t));
            c = cat(1,a,b);
            p = max(c);
        
        case 'sine'
            p = zeros(1,length(t));
            p =p + sin(pi*t/Ts);
    
    
 end


