% =========================================================
% SCRIPT 4 – Formulação Recursiva dos Mínimos Quadrados
% Baseado nos slides do Prof. Pinheiro (Aula 16, slides 22-24)
% TCC – Engenharia Eletrônica
% =========================================================
% Conceito: em vez de acumular TODAS as medidas e resolver de
% uma vez (batch), o método recursivo ATUALIZA o estimador
% a cada nova medida, sem re-calcular a pseudo-inversa inteira.
% Útil para sistemas em tempo real (como o caixão de areia).

clear; clc; close all;

%% --- Modelo: ajuste de reta y = a0 + a1*z (grau 1) ---
% Vamos acompanhar a estimativa dos parâmetros a cada nova medida

rng(13);
N_total = 50;         % número total de medidas
a0_real = 3.0;
a1_real = 2.5;

z = linspace(0, 5, N_total)';
y = a0_real + a1_real*z + 0.8*randn(N_total,1);

%% =====================================================
%  INICIALIZAÇÃO (slide 24)
%  P_0 = 10^3 * I  (matriz de covariância inicial grande)
%  a_hat_0 = zeros (estimativa inicial nula)
% =====================================================
n_param = 2;                       % número de parâmetros [a0, a1]
P = 1e3 * eye(n_param);            % P_0
a_hat = zeros(n_param, 1);         % â_0 = [0; 0]

% Histórico para plotagem
hist_a0   = zeros(N_total, 1);
hist_a1   = zeros(N_total, 1);
hist_rmse = zeros(N_total, 1);

%% =====================================================
%  LOOP RECURSIVO (slides 22-23)
%  Para cada nova medida k:
%    1. x_k = [1, z_k]'
%    2. K_k = P_{k-1} * x_k / (1 + x_k' * P_{k-1} * x_k)
%    3. â_k = â_{k-1} + K_k * (y_k - x_k' * â_{k-1})
%    4. P_k = P_{k-1} - K_k * x_k' * P_{k-1}
% =====================================================
for k = 1:N_total
    x_k = [1; z(k)];           % vetor de regressores (n x 1)
    y_k = y(k);                 % medida escalar

    % Ganho K_k (slide 23)
    K_k = P * x_k / (1 + x_k' * P * x_k);

    % Atualização do estimador (slide 23)
    inovacao = y_k - x_k' * a_hat;   % erro de predição
    a_hat = a_hat + K_k * inovacao;

    % Atualização da matriz P (slide 23)
    P = P - K_k * (x_k' * P);

    % Armazena histórico
    hist_a0(k)   = a_hat(1);
    hist_a1(k)   = a_hat(2);

    % RMSE nos k pontos vistos até agora (para análise)
    z_k_vis = z(1:k);
    y_k_vis = y(1:k);
    y_est_k = a_hat(1) + a_hat(2)*z_k_vis;
    hist_rmse(k) = sqrt(mean((y_k_vis - y_est_k).^2));
end

fprintf('=== ESTIMAÇÃO RECURSIVA ===\n');
fprintf('Parâmetros reais    : a0=%.4f  a1=%.4f\n', a0_real, a1_real);
fprintf('Estimativa final    : a0=%.4f  a1=%.4f\n', a_hat(1), a_hat(2));
fprintf('RMSE final          : %.6f\n', hist_rmse(end));

%% --- Batch (para comparação) ---
X_all = [ones(N_total,1), z];
a_batch = (X_all'*X_all) \ (X_all'*y);
fprintf('\nComparação com método batch:\n');
fprintf('Batch               : a0=%.4f  a1=%.4f\n', a_batch(1), a_batch(2));

%% --- Figura 1: Convergência dos parâmetros ---
figure('Name','Convergência Recursiva','Position',[50 50 900 600]);

subplot(2,2,1);
plot(1:N_total, hist_a0, 'b-o','MarkerSize',3,'LineWidth',1.5);
yline(a0_real,'r--','LineWidth',2,'Label','a_0 real');
yline(a_batch(1),'g:','LineWidth',1.5,'Label','Batch');
xlabel('Número de medidas k'); ylabel('Estimativa de a_0');
title('Convergência de a_0','FontSize',11); grid on;

subplot(2,2,2);
plot(1:N_total, hist_a1, 'b-o','MarkerSize',3,'LineWidth',1.5);
yline(a1_real,'r--','LineWidth',2,'Label','a_1 real');
yline(a_batch(2),'g:','LineWidth',1.5,'Label','Batch');
xlabel('Número de medidas k'); ylabel('Estimativa de a_1');
title('Convergência de a_1','FontSize',11); grid on;

subplot(2,2,3);
semilogy(1:N_total, hist_rmse, 'm-','LineWidth',2);
xlabel('Número de medidas k'); ylabel('RMSE (log)');
title('Evolução do RMSE','FontSize',11); grid on;

subplot(2,2,4);
z_plot = linspace(0,5,200)';
y_final = a_hat(1) + a_hat(2)*z_plot;
scatter(z, y, 25, 'ko','filled','DisplayName','Medidas'); hold on;
plot(z_plot, a0_real+a1_real*z_plot, 'r-','LineWidth',2,...
     'DisplayName','Modelo real');
plot(z_plot, y_final, 'b--','LineWidth',2,...
     'DisplayName','Estimativa recursiva');
xlabel('z'); ylabel('y');
title('Ajuste final (recursivo vs real)','FontSize',11);
legend('Location','northwest','FontSize',9); grid on;

sgtitle('Mínimos Quadrados Recursivo – Convergência','FontSize',13);
print('-dpng','-r300','fig07_recursivo.png');
fprintf('\nFigura salva: fig07_recursivo.png\n');

fprintf('\n--- Por que o método recursivo é útil no caixão de areia? ---\n');
fprintf('→ Permite atualizar a calibração em tempo real a cada novo\n');
fprintf('  par de pontos capturado, sem re-calcular a pseudo-inversa.\n');
fprintf('→ Custo computacional por iteração: O(n^2), muito menor que\n');
fprintf('  O(kn^2) do método batch para k >> n.\n');
