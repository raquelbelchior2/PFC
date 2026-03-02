% =========================================================
% SCRIPT 1 – Estimação da Gravidade via Mínimos Quadrados
% Baseado nos slides do Prof. Pinheiro (Aula 16)
% TCC – Engenharia Eletrônica
% =========================================================
% Referência: slides 5-8
% Conceito: corpo em queda livre, medidas contaminadas por ruído
% Modelo: v_i = g * t_i  →  y = X * a  onde a = [g]

clear; clc; close all;

%% --- Parâmetros ---
g_real = 9.81;              % valor verdadeiro (desconhecido no experimento)
t = 0:0.2:2;                % instantes de medição (s)
rng(42);                    % semente para reprodutibilidade

%% --- Medidas simuladas (com ruído gaussiano) ---
v_exato = g_real * t;
v_medido = v_exato + randn(size(t));  % ruído instrumental

%% --- Montagem da Matriz X e vetor y (slide 7) ---
% Modelo: v_i = g * t_i
% Reescrevendo: y = X * a,  onde X = t' e a = [g]
X = t';          % vetor coluna (k x 1)
y = v_medido';   % vetor coluna (k x 1)

%% --- Estimação pela Pseudo-Inversa (slide 10-11) ---
% a_hat = (X'X)^(-1) * X'y
a_hat = (X' * X) \ (X' * y);
g_estimado = a_hat(1);

fprintf('=== ESTIMAÇÃO DA GRAVIDADE ===\n');
fprintf('Valor verdadeiro : g = %.4f m/s²\n', g_real);
fprintf('Valor estimado   : g = %.4f m/s²\n', g_estimado);
fprintf('Erro relativo    : %.4f %%\n', abs(g_real - g_estimado)/g_real * 100);

%% --- Figura 1: Medidas e ajuste ---
figure('Name','Estimação da Gravidade','Position',[100 100 800 500]);

t_plot = linspace(0, 2, 200);
v_real_plot = g_real * t_plot;
v_est_plot  = g_estimado * t_plot;

plot(t, v_medido, 'ko', 'MarkerFaceColor','k', 'MarkerSize',6, ...
     'DisplayName','Medidas com ruído'); hold on;
plot(t_plot, v_real_plot, 'b-', 'LineWidth', 2, ...
     'DisplayName',['g real = ' num2str(g_real) ' m/s²']);
plot(t_plot, v_est_plot, 'r--', 'LineWidth', 2, ...
     'DisplayName',['g estimado = ' num2str(g_estimado,'%.4f') ' m/s²']);

xlabel('Tempo (s)', 'FontSize', 12);
ylabel('Velocidade (m/s)', 'FontSize', 12);
title('Estimação da Gravidade – Mínimos Quadrados', 'FontSize', 13);
legend('Location','northwest', 'FontSize', 11);
grid on; grid minor;

% Salvar figura em alta resolução para o relatório
print('-dpng','-r300','fig01_estimacao_gravidade.png');
fprintf('\nFigura salva: fig01_estimacao_gravidade.png\n');
