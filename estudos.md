# Registro de Estudos

Arquivo de acompanhamento pessoal dos tópicos estudados ao longo do PFC.
Atualizado conforme o progresso.

---

## Tópico 1 — Teoria dos Mínimos Quadrados

**Referência:** Slides Prof. Pinheiro, Aula 16 — Controle Ótimo (2021)

### O que é

O método dos mínimos quadrados encontra os parâmetros de um modelo matemático que melhor se ajusta a um conjunto de medidas com erros e ruídos. O critério é minimizar a soma dos quadrados dos erros:

$$J = \sum_{i=1}^{k} e_i^2 = \sum_{i=1}^{k}(y_i - \hat{y}_i)^2$$

### Por que o quadrado

Elevar ao quadrado evita que erros positivos e negativos se cancelem, e garante que a função $J$ seja diferenciável — o que permite encontrar o mínimo de forma analítica.

### Exemplo estudado

Estimação da aceleração da gravidade a partir de medidas de velocidade com ruído. O modelo é $v_i = g \cdot t_i$, e a estimativa ótima é:

$$\hat{g} = \frac{\sum v_i t_i}{\sum t_i^2}$$

**Script:** `matlab/script01_gravidade.m`

---

## Tópico 2 — Formulação Matricial e Pseudo-Inversa

**Referência:** Slides Prof. Pinheiro, Aula 16 (slides 9–13)

### O que é

Quando há mais medidas do que parâmetros (sistema sobredeterminado), não existe solução exata. O sistema é escrito como:

$$\mathbf{y} = \mathbf{X}\hat{\mathbf{a}} + \mathbf{e}$$

A **pseudo-inversa** encontra a solução que minimiza o erro total:

$$\hat{\mathbf{a}} = (\mathbf{X}^T\mathbf{X})^{-1}\mathbf{X}^T\mathbf{y}$$

### Por que "pseudo"

Porque $\mathbf{X}$ não é quadrada — a inversa verdadeira não existe. A pseudo-inversa faz o papel da inversa nessa situação.

### No MATLAB

```matlab
a_hat = (X' * X) \ (X' * y);
```

---

## Tópico 3 — Ajuste Polinomial 2D

**Referência:** Slides Prof. Pinheiro, Aula 16 (slides 14–18)

### O que é

Dado um conjunto de pontos $(z_i, y_i)$, ajustar o polinômio $P(z) = a_0 + a_1 z + a_2 z^2 + \cdots$ que melhor passa pelos dados.

### Como se monta a matriz X

Cada ponto vira uma linha. As colunas são as potências de $z$:

$$\mathbf{X} = \begin{bmatrix} 1 & z_1 & z_1^2 \\ 1 & z_2 & z_2^2 \\ \vdots & \vdots & \vdots \end{bmatrix}$$

A pseudo-inversa retorna os coeficientes do polinômio.

### Observação importante

Grau alto demais causa *overfitting* — o polinômio passa por todos os pontos mas oscila muito entre eles e não serve para prever novos dados.

**Script:** `matlab/script02_ajuste_polinomial_2d.m`

---

## Tópico 4 — Extensão para 3D: Ajuste de Plano

### O que é

Dado um conjunto de pontos $(x_i, y_i, z_i)$ no espaço, ajustar o plano $z = a_0 + a_1 x + a_2 y$.

### Como se monta a matriz X

Mesma lógica do caso 2D — cada ponto vira uma linha, as colunas agora são as duas variáveis independentes:

$$\mathbf{X} = \begin{bmatrix} 1 & x_1 & y_1 \\ 1 & x_2 & y_2 \\ \vdots & \vdots & \vdots \end{bmatrix}$$

A fórmula da pseudo-inversa não muda nada. Só muda o que entra em $\mathbf{X}$.

**Script:** `matlab/script03_calibracao_3d.m`

---

## Tópico 5 — Calibração Kinect–Projetor

### O problema

O Kinect vê um ponto na areia como $(u_k, v_k, d_k)$ — coluna, linha e profundidade em mm. O projetor precisa saber em qual pixel dele acender a luz para iluminar exatamente aquele ponto: $(u_p, v_p)$.

Calibrar é encontrar o mapeamento entre esses dois espaços.

### Por que modelo quadrático

Um modelo linear não captura distorções de lente e efeitos de perspectiva. O modelo quadrático com 10 parâmetros lida melhor com essas não-linearidades:

$$u_p \approx a_0 + a_1 u_k + a_2 v_k + a_3 d_k + a_4 u_k^2 + a_5 v_k^2 + a_6 d_k^2 + a_7 u_k v_k + a_8 u_k d_k + a_9 v_k d_k$$

### Como coletar os dados

1. Projetar um tabuleiro de xadrez sobre a areia (as coordenadas do projetor são conhecidas pois geramos a imagem)
2. O Kinect fotografa a cena — o OpenCV detecta os cantos do xadrez e fornece $(u_k, v_k, d_k)$
3. Repetir em diferentes alturas da areia
4. Aplicar a pseudo-inversa com os pares coletados

### Métrica de qualidade — RMSE

O RMSE (Raiz do Erro Quadrático Médio) mede o erro médio da calibração em pixels. Quanto menor, mais precisa a correspondência entre Kinect e projetor.

### Próximo passo

Coletar dados reais com o hardware físico e validar os modelos linear e quadrático.

---

## Tópico 6 — Formulação Recursiva

### O que é

Em vez de usar todos os pares de calibração de uma vez, o método recursivo atualiza os coeficientes a cada novo par coletado, sem recalcular tudo do zero.

Útil se a calibração precisar ser atualizada em tempo real.

**Script:** `matlab/script04_recursivo.m`

---

## Dúvidas em aberto

- [ ] Quantos pares de calibração são necessários na prática para o modelo quadrático?
- [ ] Qual é o critério de qualidade adequado para esta aplicação militar — em pixels ou em mm?
- [ ] Com que frequência a calibração precisará ser refeita?

---

*Última atualização: fevereiro de 2026*
