% =========================================================
% SCRIPT 3 – Ajuste de Plano 3D via Mínimos Quadrados
% Extrapolação do caso 2D para 3D
% TCC – Engenharia Eletrônica – Calibração Kinect-Projetor
% =========================================================
% Conceito: dado um conjunto de pontos 3D (x_i, y_i, z_i),
% encontrar o PLANO  z = a0 + a1*x + a2*y  que melhor
% se ajusta usando a pseudo-inversa.
% Isso é a generalização direta do ajuste 2D: a matriz X
% agora tem colunas [1, x, y] em vez de [1, z, z^2].

clear; clc; close all;

%% =====================================================
%  PARTE 1 – Ajuste de Plano Simples
%  Modelo: z = a0 + a1*x + a2*y
% =====================================================

fprintf('=== PARTE 1: AJUSTE DE PLANO AO CONJUNTO DE PONTOS 3D ===\n\n');

%% --- Pontos 3D simulados (plano verdadeiro + ruído) ---
rng(7);
N = 40;

% Plano verdadeiro: z = 2 + 0.5*x - 0.3*y
a0_real=2.0; a1_real=0.5; a2_real=-0.3;

[xg, yg] = meshgrid(linspace(0,5,ceil(sqrt(N))), linspace(0,5,ceil(sqrt(N))));
x = xg(:); y = yg(:);
x = x(1:N); y = y(1:N);
z_real   = a0_real + a1_real.*x + a2_real.*y;
z_medido = z_real + 0.3*randn(N,1);   % ruído gaussiano σ=0.3

%% --- Montagem da matriz X (equivalente ao slide 15, agora 2 variáveis) ---
% Cada linha i: [1, x_i, y_i]
X = [ones(N,1), x, y];   % dimensão: (N x 3)
y_vec = z_medido;         % dimensão: (N x 1)

% Verificação da dimensionalidade (didático)
fprintf('Dimensão da matriz X : %d x %d\n', size(X,1), size(X,2));
fprintf('Dimensão do vetor y  : %d x 1\n', length(y_vec));
fprintf('Sistema: %d equações, %d incógnitas → sobredeterminado\n\n', ...
        size(X,1), size(X,2));

%% --- Pseudo-Inversa (mesma fórmula do slide 10-11) ---
% a_hat = (X'X)^{-1} X'y
a_hat = (X' * X) \ (X' * y_vec);

fprintf('Parâmetros REAIS    : a0=%.2f  a1=%.2f  a2=%.2f\n', ...
        a0_real, a1_real, a2_real);
fprintf('Parâmetros ESTIMADOS: a0=%.4f  a1=%.4f  a2=%.4f\n', ...
        a_hat(1), a_hat(2), a_hat(3));

% Erro de estimação
z_est  = X * a_hat;
residuos = z_medido - z_est;
rmse = sqrt(mean(residuos.^2));
fprintf('RMSE do ajuste      : %.6f\n\n', rmse);

%% --- Figura 1: Plano ajustado + pontos ---
figure('Name','Ajuste de Plano 3D','Position',[50 50 1000 500]);

subplot(1,2,1);
[xg2, yg2] = meshgrid(linspace(0,5,30), linspace(0,5,30));
zg_est  = a_hat(1) + a_hat(2)*xg2 + a_hat(3)*yg2;
zg_real = a0_real  + a1_real*xg2  + a2_real*yg2;

surf(xg2, yg2, zg_est, 'FaceAlpha',0.5, 'EdgeColor','none', ...
     'FaceColor',[0.2 0.5 0.9]); hold on;
scatter3(x, y, z_medido, 40, 'r', 'filled');
scatter3(x, y, z_real, 20, 'g', 'filled');
xlabel('x'); ylabel('y'); zlabel('z');
title('Plano ajustado (azul) vs pontos medidos (verm.)','FontSize',11);
legend('Plano MQ','Medidas (ruído)','Valores reais','Location','best');
grid on; view(35,25);

subplot(1,2,2);
stem3(x, y, residuos, 'filled', 'Color',[0.8 0.1 0.1]);
hold on; 
surf(xg2, yg2, zeros(size(zg_est)), 'FaceAlpha',0.15, ...
     'FaceColor','k','EdgeColor','none');
xlabel('x'); ylabel('y'); zlabel('Resíduo');
title(['Resíduos e_i = z_i - \hat{z}_i   (RMSE=' ...
       num2str(rmse,'%.4f') ')'],'FontSize',11);
grid on; view(35,25);

sgtitle('Mínimos Quadrados – Ajuste de Plano em 3D','FontSize',13);
print('-dpng','-r300','fig04_plano_3d.png');
fprintf('Figura salva: fig04_plano_3d.png\n');

%% =====================================================
%  PARTE 2 – Modelo Quadrático 3D para Calibração
%  Kinect → Projetor
%  Modelo: u_p = f(u_k, v_k, d_k) com termos quadráticos
% =====================================================

fprintf('\n=== PARTE 2: MAPEAMENTO QUADRÁTICO KINECT → PROJETOR ===\n\n');

% Num experimento real, estes pontos seriam coletados com
% um padrão de xadrez posicionado em diferentes alturas na areia.
% Aqui simulamos o mapeamento com parâmetros conhecidos.

%% --- Transformação verdadeira simulada (não-linear) ---
% u_p = 0.8*u_k + 0.01*v_k + 0.002*u_k^2 - 0.001*v_k*d_k + 50
% v_p = 0.01*u_k + 0.85*v_k + 0.003*v_k^2 + 0.002*u_k*d_k + 30

rng(42); M = 80;  % M pontos de calibração

% Coordenadas do Kinect (pixels e mm de profundidade)
u_k = 50 + 540*rand(M,1);   % colunas: 50 a 590 px
v_k = 50 + 380*rand(M,1);   % linhas : 50 a 430 px
d_k = 700 + 200*rand(M,1);  % profund: 700 a 900 mm

% Coordenadas correspondentes no projetor (verdadeiras + ruído)
u_p_real = 0.8*u_k + 0.01*v_k + 0.002*u_k.^2 - 0.001*v_k.*d_k + 50;
v_p_real = 0.01*u_k + 0.85*v_k + 0.003*v_k.^2 + 0.002*u_k.*d_k + 30;

ruido_px = 1.5;  % ruído de ±1.5 pixels na marcação
u_p = u_p_real + ruido_px*randn(M,1);
v_p = v_p_real + ruido_px*randn(M,1);

%% --- Modelo LINEAR (homografia clássica, apenas afim) ---
% u_p ≈ a0 + a1*u_k + a2*v_k + a3*d_k
X_lin = [ones(M,1), u_k, v_k, d_k];

a_u_lin = (X_lin'*X_lin) \ (X_lin'*u_p);
a_v_lin = (X_lin'*X_lin) \ (X_lin'*v_p);

u_p_est_lin = X_lin * a_u_lin;
v_p_est_lin = X_lin * a_v_lin;
erro_lin = sqrt((u_p - u_p_est_lin).^2 + (v_p - v_p_est_lin).^2);
rmse_lin = sqrt(mean(erro_lin.^2));

%% --- Modelo QUADRÁTICO ---
% u_p ≈ a0 + a1*u_k + a2*v_k + a3*d_k
%           + a4*u_k^2 + a5*v_k^2 + a6*d_k^2
%           + a7*u_k*v_k + a8*u_k*d_k + a9*v_k*d_k
X_quad = [ones(M,1), ...
          u_k,    v_k,    d_k, ...          % termos lineares
          u_k.^2, v_k.^2, d_k.^2, ...      % termos quadráticos
          u_k.*v_k, u_k.*d_k, v_k.*d_k];   % termos cruzados

fprintf('Dimensão X linear   : %d x %d (%d parâmetros)\n', ...
        size(X_lin,1), size(X_lin,2), size(X_lin,2));
fprintf('Dimensão X quadrático: %d x %d (%d parâmetros)\n\n', ...
        size(X_quad,1), size(X_quad,2), size(X_quad,2));

a_u_quad = (X_quad'*X_quad) \ (X_quad'*u_p);
a_v_quad = (X_quad'*X_quad) \ (X_quad'*v_p);

u_p_est_quad = X_quad * a_u_quad;
v_p_est_quad = X_quad * a_v_quad;
erro_quad = sqrt((u_p - u_p_est_quad).^2 + (v_p - v_p_est_quad).^2);
rmse_quad = sqrt(mean(erro_quad.^2));

fprintf('=== COMPARAÇÃO LINEAR vs QUADRÁTICO ===\n');
fprintf('Modelo linear   – RMSE reprojeção: %.4f px\n', rmse_lin);
fprintf('Modelo quadrático – RMSE reprojeção: %.4f px\n', rmse_quad);
fprintf('Ganho em precisão: %.1f%%\n\n', (1 - rmse_quad/rmse_lin)*100);

%% --- Figura 2: Erro de reprojeção por ponto ---
figure('Name','Erro de Reprojeção: Linear vs Quadrático',...
       'Position',[50 50 1000 450]);

subplot(1,2,1);
scatter(u_p, v_p, 20, erro_lin, 'filled');
colorbar; colormap('hot');
clim([0 max(erro_lin)*1.1]);
xlabel('u_p (px)'); ylabel('v_p (px)');
title(['Modelo Linear – Erro por ponto (RMSE=' ...
       num2str(rmse_lin,'%.3f') ' px)'],'FontSize',11);
grid on; axis equal;

subplot(1,2,2);
scatter(u_p, v_p, 20, erro_quad, 'filled');
colorbar; colormap('hot');
clim([0 max(erro_lin)*1.1]);   % mesma escala para comparação
xlabel('u_p (px)'); ylabel('v_p (px)');
title(['Modelo Quadrático – Erro por ponto (RMSE=' ...
       num2str(rmse_quad,'%.3f') ' px)'],'FontSize',11);
grid on; axis equal;

sgtitle('Erro de Reprojeção – Calibração Kinect-Projetor','FontSize',13);
print('-dpng','-r300','fig05_erro_reprojecao.png');
fprintf('Figura salva: fig05_erro_reprojecao.png\n');

%% --- Figura 3: Histograma dos erros ---
figure('Name','Histograma do Erro','Position',[50 50 800 420]);
nbins = 20;
histogram(erro_lin, nbins, 'FaceColor',[0.2 0.4 0.9],'FaceAlpha',0.7,...
          'DisplayName','Linear'); hold on;
histogram(erro_quad, nbins, 'FaceColor',[0.9 0.2 0.2],'FaceAlpha',0.7,...
          'DisplayName','Quadrático');
xline(rmse_lin,  'b--','LineWidth',2,...
      'Label',['RMSE_{lin}=' num2str(rmse_lin,'%.2f')],'LabelVerticalAlignment','bottom');
xline(rmse_quad, 'r--','LineWidth',2,...
      'Label',['RMSE_{quad}=' num2str(rmse_quad,'%.2f')],'LabelVerticalAlignment','top');
xlabel('Erro de reprojeção (px)','FontSize',12);
ylabel('Frequência','FontSize',12);
title('Distribuição do Erro de Reprojeção','FontSize',13);
legend('FontSize',11); grid on;
print('-dpng','-r300','fig06_histograma_erro.png');
fprintf('Figura salva: fig06_histograma_erro.png\n');

%% --- Função de predição (uso futuro no sistema real) ---
fprintf('\n=== COEFICIENTES DO MODELO QUADRÁTICO (u_p) ===\n');
fprintf('a = ['); fprintf('%.6f  ', a_u_quad); fprintf(']\n');
fprintf('\n=== COEFICIENTES DO MODELO QUADRÁTICO (v_p) ===\n');
fprintf('a = ['); fprintf('%.6f  ', a_v_quad); fprintf(']\n');

fprintf('\n--- Como usar no sistema real ---\n');
fprintf('Dado um ponto Kinect (u_k, v_k, d_k), a coordenada do projetor é:\n');
fprintf('  x_new = [1, u_k, v_k, d_k, u_k^2, v_k^2, d_k^2, u_k*v_k, u_k*d_k, v_k*d_k]\n');
fprintf('  u_p = x_new * a_u_quad\n');
fprintf('  v_p = x_new * a_v_quad\n');
