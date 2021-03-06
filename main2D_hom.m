Grid.Nx=60; Grid.hx=20*.3048;           % Dimension in x-direction
Grid.Ny=220; Grid.hy=10*.3048;          % Dimension in y-direction
Grid.Nz=1; Grid.hz=2*.3048;             % Dimension in z-direction
N=Grid.Nx*Grid.Ny*Grid.Nz;              % Number of grid celles
Grid.V=Grid.hx*Grid.hy*Grid.hz;         % Volume of each cells
Fluid.vw=3e-4; Fluid.vo=3e-3;           % Viscosities
Fluid.swc=0.2; Fluid.sor=0.2;           % Irreducible saturations
St = 5;                                 % Maximum saturation time step
Pt = 100;                               % Pressure time step
ND = 2000;                              % Number of days in simulation
Q=zeros(Grid.Nx,Grid.Ny,1);                     % Source term for injection
IR=795*(Grid.Nx*Grid.Ny/ (60*220*85));          % and production. Total
Q(1,1,:)=IR; Q(Grid.Nx,Grid.Ny,:)=-IR; Q=Q(:);  % rate scaled to one layer

%load spe_perm.dat;
%disp(['spe_perm size: ', num2str(size(spe_perm(:)))]);
%Perm=reshape(spe_perm',3*N,1);
%Kx=reshape(Perm(1:N),Grid.Nx,Grid.Ny,Grid.Nz);
%Ky=reshape(Perm(N+1:2*N),Grid.Nx,Grid.Ny,Grid.Nz);
%Kz=reshape(Perm(2*N+1:3*N),Grid.Nx,Grid.Ny,Grid.Nz);
%Grid.K=[Kx(1:Grid.Nx,1:Grid.Ny,1);Ky(1:Grid.Nx,1:Grid.Ny,1);Kz(1:Grid.Nx,1:Grid.Ny,1)];

Grid.K=ones(3,Grid.Nx,Grid.Ny,1);
Por=0.1*ones(Grid.Nx,Grid.Ny,1);

%load spe_phi.dat; Por=spe_phi(1:Grid
%load Udata; Grid.K=KU(:,1:Grid.Nx,1:Grid.Ny,1); % Permeability in layer 1
%Por=pU(1:Grid.Nx,1:Grid.Ny,1);                  % Preprocessed porosity in layer 1
Grid.por=max(Por(:),1e-3);
S=Fluid.swc*ones(N,1);                  % Initial saturation
Pc=[0; 1]; Tt=0;                        % For production curves
for tp=1:ND/Pt;
        [P,V]=Pres(Grid,S,Fluid,Q);     % Pressure solver
        for ts=1:Pt/St;
                S=NewtRaph(Grid,S,Fluid,V,Q,St);                % Implicit saturation solver
                subplot('position' ,[0.05 .1 .4 .8]);           % Make left subplot
                pcolor(reshape(S,Grid.Nx,Grid.Ny,Grid.Nz)');    % Plot saturation
                shading flat; caxis([Fluid.swc 1-Fluid.sor]);   %   
                [Mw,Mo]=RelPerm(S(N),Fluid); Mt=Mw+Mo;          % Mobilities in well-block
                Tt=[Tt,(tp-1)*Pt+ts*St];                        % Compute simulation time
                Pc=[Pc,[Mw/Mt; Mo/Mt]];                         % Append production data
                subplot('position' ,[0.55 .1 .4 .8]);           % Make right subplot
                plot(Tt,Pc(1,:),Tt,Pc (2,:));                   % Plot production data
                axis([0,ND,-0.05,1.05]);                        % Set correct axis
                legend('Water cut','Oil cut');                  % Set legend
                drawnow;                                        % Force update of plot
        end 
end
