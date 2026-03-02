% =========================================================
% SCRIPT 2 – Ajuste Polinomial 2D via Pseudo-Inversa
% Baseado nos slides do Prof. Pinheiro (Aula 16, slides 14-18)
% TCC – Engenharia Eletrônica
% =========================================================
% Conceito: dado um conjunto de pontos (z_i, y_i), encontrar
% o polinômio P(z) de grau n que melhor se ajusta aos dados
% usando mínimos quadrados com a pseudo-inversa.

clear; clc; close all;

%% --- Dados do exemplo dos slides (slide 16) ---
z = [0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.2, 1.4, 1.6, 1.8, 2.0, ...
     2.2, 2.4, 2.6, 2.8, 3.0, 3.2, 3.4, 3.6, 3.8, 4.0, ...
     4.2, 4.4, 4.6, 4.8, 5.0]';

y = [-2.406, -0.8653, 0.1095, 1.8885, 1.1370, 0.9499, 1.7459, ...
      0.0454, 4.2913,  5.3139, 6.6837, 13.1982, 14.8193, ...
      18.9415, 18.6470, 17.3773, 25.3529, 30.6731, 35.7602, ...
      33.7587, 41.8929, 44.9600, 53.0066, 56.2503, 57.6078, 64.8606]';

%% =====================================================
%  FUNÇÃO AUXILIAR: montar_X
%  Monta a matriz de regressão polinomial (Vandermonde)
%  Cada linha i: [1, z_i, z_i^2, ..., z_i^n]  (slide 15)
% =====================================================
function X = montar_X_poli(z, n)
    k = length(z);
    X = zeros(k, n+1);
    for j = 0:n
        X(:, j+1) = z .^ j;
    end
end

%% =====================================================
%  FUNÇÃO AUXILIAR: pseudo_inversa
%  a_hat = (X'X)^{-1} X'y  (slide 10)
% =====================================================
function a_hat = pseudo_inversa(X, y)
    a_hat = (X' * X) \ (X' * y);
end

%% --- Ajuste com diferentes graus ---
graus = [1, 2, 3, 5, 10];
z_plot = linspace(min(z), max(z), 300)';
cores = lines(length(graus));

figure('Name','Ajuste Polinomial – Diferentes Graus',...
       'Position',[100 100 900 600]);

hold on;
scatter(z, y, 40, 'ko', 'filled', 'DisplayName','Dados medidos');

for idx = 1:length(graus)
    n = graus(idx);
    X = montar_X_poli(z, n);
    a_hat = pseudo_inversa(X, y);

    % Avaliação do polinômio nos pontos de plot
    X_plot = montar_X_poli(z_plot, n);
    y_plot = X_plot * a_hat;

    % Erro quadrático médio nos dados originais
    y_est = X * a_hat;
    rmse = sqrt(mean((y - y_est).^2));

    plot(z_plot, y_plot, '-', 'Color', cores(idx,:), 'LineWidth', 1.8, ...
         'DisplayName', ['Grau ' num2str(n) '  (RMSE=' num2str(rmse,'%.3f') ')']);
end

xlabel('z', 'FontSize', 12);
ylabel('y', 'FontSize', 12);
title('Ajuste Polinomial via Mínimos Quadrados (Pseudo-Inversa)', 'FontSize', 13);
legend('Location','northwest', 'FontSize', 10);
grid on; grid minor;
ylim([-15 80]);
print('-dpng','-r300','fig02_ajuste_polinomial.png');
fprintf('Figura salva: fig02_ajuste_polinomial.png\n');

%% --- Tabela de RMSE por grau ---
fprintf('\n=== RMSE POR GRAU DO POLINÔMIO ===\n');
fprintf('%-8s %-12s %-10s\n','Grau','N parâmetros','RMSE');
fprintf('%s\n', repmat('-',1,35));
for n = graus
    X = montar_X_poli(z, n);
    a_hat = pseudo_inversa(X, y);
    y_est = X * a_hat;
    rmse = sqrt(mean((y - y_est).^2));
    fprintf('%-8d %-12d %.6f\n', n, n+1, rmse);
end

%% --- Figura extra: comparação ordem 2 vs ordem 5 com resíduos ---
figure('Name','Resíduos – Grau 2 vs Grau 5','Position',[100 100 900 700]);

for idx = 1:2
    n = graus(idx+1);  % grau 2 e grau 3
    X = montar_X_poli(z, n);
    a_hat = pseudo_inversa(X, y);
    y_est = X * a_hat;
    residuos = y - y_est;
    rmse = sqrt(mean(residuos.^2));

    subplot(2,2,(idx-1)*2+1);
    X_plot = montar_X_poli(z_plot, n);
    y_plot = X_plot * a_hat;
    scatter(z, y, 30, 'ko','filled'); hold on;
    plot(z_plot, y_plot, 'b-','LineWidth',2);
    title(['Grau ' num2str(n) ' – Ajuste (RMSE=' num2str(rmse,'%.3f') ')'],'FontSize',11);
    xlabel('z'); ylabel('y'); grid on;

    subplot(2,2,(idx-1)*2+2);
    stem(z, residuos, 'filled', 'Color',[0.8 0.2 0.2]);
    yline(0,'k--','LineWidth',1.2);
    title(['Grau ' num2str(n) ' – Resíduos e_i = y_i - \hat{y}_i'],'FontSize',11);
    xlabel('z'); ylabel('Resíduo'); grid on;
end

sgtitle('Análise de Resíduos – Mínimos Quadrados 2D','FontSize',13);
print('-dpng','-r300','fig03_residuos_2d.png');
fprintf('Figura salva: fig03_residuos_2d.png\n');

%% --- Detalhes dos coeficientes para o grau 2 (quadrático) ---
n = 2;
X = montar_X_poli(z, n);
a_hat = pseudo_inversa(X, y);
fprintf('\n=== COEFICIENTES DO POLINÔMIO QUADRÁTICO (Grau 2) ===\n');
fprintf('P(z) = %.4f + %.4f*z + %.4f*z^2\n', a_hat(1), a_hat(2), a_hat(3));
fprintf('\nInterpretação da matriz (X''X) e vetor (X''y):\n');
disp('X''X ='); disp(X'*X);
disp('X''y ='); disp(X'*y);
