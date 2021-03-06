%% This script builds the stacked Data matrix from kym_Lev_410or470 OR kym_5mM_410or470) 
%Next step: Cell boundaries
%% PARAMETERS from user

% string metadata
expID='120515_4Genot_2do_5mM_plt1';


% numeric metadata
date = 120515;
condition= 0;   % or '5' (if 1mM needed -> change second case in time vector generation

tp=11;
nworms=32;      %I lost wm #26 in TB series, I am erasingit manually (to preserve time delay order)
n_plt_rep=1;    % exp 10mM was the second plate of the day (change manually in Data matrix)
nframes=tp*nworms;

t_res=2;                %time resolution in mins or sec

nQ=8;                   % number of quadrants continues numenclature (even if quadrants are in different plates)
nworms_perQ=4;

delay_Q_1= 10;
delay_Q_2= 8;
delay_Q_3= 6;
delay_Q_4= 4;
delay_Q_5= 4;
delay_Q_6= 6;
delay_Q_7= 8;
delay_Q_8= 10;
%delay_Q_9= 6;

% Genotype or treatment per quadrant 
Gen_Q_1= 233.2;     % WT 
Gen_Q_2= 233.2; 
Gen_Q_3= 233.2; 
Gen_Q_4= 233.2; 
Gen_Q_5= 233.6; 
Gen_Q_6= 233.6; 
Gen_Q_7= 233.6; 
Gen_Q_8= 233.6; 
%Gen_Q_9= 233;


%Exception 1
if nworms_perQ * nQ ~=nworms
 'total nworm is NOT equal to #wms * quadrant'
end
 
%Exception 2
if condition== 0
        if kym_PreLev_410(1,1)==kym_PreLev_470(1,1)
        'IJ ERROR= Kymographs in the two wavelengths are identical'
        end
    elseif condition== 5

        if kym_TB_410(1,1)==kym_TB_470(1,1)
        'IJ ERROR= Kymographs in the two wavelengths are identical'
        end
end



%% 'string' metadata
 % col_expID= repmat(expID, 100*nframes, 1); 
col_date= repmat(date, 100*nframes, 1);
col_conc= repmat(condition, 100*nframes, 1);



plt_rep_mat=zeros(100,nframes);
 for i=1:n_plt_rep 
     plt_rep_block = repmat(i, 100, tp*(nworms/n_plt_rep)); %create block matrix ONLY works when each replicate has the same number of worms
     plt_rep_mat(: , ((i*tp*(nworms/n_plt_rep))-(tp*(nworms/n_plt_rep)-1)): i*tp*(nworms/n_plt_rep))= plt_rep_block;
 end
col_plt_rep= reshape(plt_rep_mat,(100*nframes),1);

strain_mat=zeros(100,nframes);
 for j=1:nQ 
     strain_perQ = repmat(eval(['Gen_Q_' int2str(j)]),100, tp*nworms_perQ);     %create block matrix
     strain_mat(: , ((j*tp*nworms_perQ)-(tp*nworms_perQ-1)): j*tp*nworms_perQ)= strain_perQ; %populate empty matrix with block matrix
 end
 col_strain=reshape(strain_mat,(100*nframes),1);



    
%% Generate linearized worm vector 
% worm number is NOT the worm ID. Each experiment counts worms independently and is determined by their position 
% in the imaging plate. The the right worm ID should include
% ExpName_date_genotype_plt_wormNumber
% Also generates the original frame number = columns

col_frameNum=[1:nframes]';

worm_mat=zeros(100,nframes);                %empty matrix to be filled up with 'worm block'
worm_n=ones(100,tp);                        %worm block matrix to be multiplied through loop
       
    for i=1:nworms       
            worm_mat(: , ((i*tp)-(tp-1)) : (i*tp))= worm_n*i; 
    end
col_worm=reshape(worm_mat,(100*nframes),1); %reshape matrix into a linearized vector

    
%% Generate time vector for either baseline OR response 

time_mat=zeros(100,nframes);
time_n=ones(100,1);

if condition== 0
    %% PreLev doesn't deals with quadrants delays and counts time in negative integers
    t_start=(0-((tp-1)*t_res));
    t_final=0;
    time_row= t_start: t_res : t_final ;
    
        for i=1:nworms
            time_mat(: , ((i*tp)-(tp-1)) : (i*tp))= time_n*time_row; 
        end
    col_time=reshape(time_mat,(100*nframes),1);
    %%
elseif condition== 5 %OJO!!! change to the TB concentration needed
    %% Response to oxidation considers time delays between quadrants
    for j=1:nQ %counter for all the quadrants (in separate replicates)
        t_start= (0+ eval(['delay_Q_' int2str(j)]));        %counter for the quadrants of a single plate
        t_final= ((tp*t_res - 1) + eval(['delay_Q_' int2str(j)]));
        time_row= t_start: t_res : t_final;
        
        time_block_perQ=repmat(time_row,100,nworms_perQ);  % concatenate horz "time_row" for nworms_perQ times
        
        time_mat(: , ((j*tp*nworms_perQ)-(tp*nworms_perQ-1)): j*tp*nworms_perQ)= time_block_perQ; %populate empty matrix with block matrix
        
    end
    col_time=reshape(time_mat,(100*nframes),1);
end




%% Generate linearized pixel coordinates vector

pixels=[1:100]';
px_mat=zeros(100,nframes);

    for i=1:nframes
       px_mat(:,i)=pixels;
    end
col_px=reshape(px_mat,(100*nframes),1);

%% Intensity Values in each channel and build the final Data_condition matrices

if condition== 0
    col_Lev_410=reshape(kym_PreLev_410,(100*nframes),1);
    col_Lev_470=reshape(kym_PreLev_470,(100*nframes),1);
    col_R1000= 1000*(col_Lev_410./col_Lev_470);
    col_ln= log(col_Lev_410) - log(col_Lev_470);

    Data_Lev=[col_date, col_plt_rep, col_conc, col_strain, col_worm, col_time, col_px, col_Lev_410, col_Lev_470, col_R1000, col_ln];

elseif condition== 5 %OJO!!! change to the TB concentration needed
    col_TB_410=reshape(kym_TB_410,(100*nframes),1);
    col_TB_470=reshape(kym_TB_470,(100*nframes),1);
    col_R1000 = 1000*(col_TB_410 ./ col_TB_470);
    col_ln= log(col_TB_410) - log(col_TB_470);

    Data_TB=[col_date, col_plt_rep, col_conc, col_strain, col_worm, col_time, col_px, col_TB_410, col_TB_470, col_R1000, col_ln];
    %Data=[col_date, col_plt_rep, col_conc, col_strain, col_worm, col_time, col_px];
end


