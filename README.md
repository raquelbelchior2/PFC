# Caixão de Areia com Realidade Aumentada

**Projeto Final de Curso — Engenharia Eletrônica**  

---

## Contexto

No contexto do preparo e da emissão de ordens no nível tático, o reconhecimento do terreno é uma etapa fundamental do planejamento militar. A representação física do terreno por meio de um caixão de areia é uma prática consolidada nas forças armadas, permitindo ao comandante visualizar e comunicar de forma concreta o posicionamento inicial e final das tropas, os eixos de deslocamento e os pontos de interesse.

Este projeto propõe modernizar essa ferramenta integrando tecnologias de realidade aumentada, sensoriamento de profundidade e fontes de dados geoespaciais abertas — tornando o caixão de areia não apenas um modelo físico, mas um sistema interativo capaz de comparar o terreno modelado com dados cartográficos reais e fornecer feedback quantitativo sobre sua fidelidade.

---

## Objetivos

1. Utilizando o sensor Kinect, ler a topologia e topografia de um caixão de areia
2. Comparar o modelo gerado com o modelo digital de terreno da carta topográfica de referência do local
3. Fornecer feedback sobre a fidedignidade do caixão de areia em relação ao modelo digital do terreno
4. Integrar fontes de dados abertas (Google Earth, OpenStreetMap) para navegação no terreno em outra tela, a partir de ponto indicado no caixão de areia

---

## O Problema de Calibração

Para que a imagem projetada coincida com precisão com o relevo detectado pelo Kinect, os dois dispositivos precisam estar **calibrados entre si**. Esse é o problema matemático central da parte de Engenharia Eletrônica do projeto.

O Kinect reporta cada ponto detectado como uma tripla:

```
(u_k, v_k, d_k)
 coluna  linha  profundidade
 pixel   pixel     em mm
```

O projetor, para iluminar exatamente esse ponto, precisa acender um pixel diferente:

```
(u_p, v_p)
 coluna  linha
 pixel   pixel
```

Calibrar o sistema significa encontrar o mapeamento matemático entre esses dois espaços de coordenadas. Esse mapeamento não é trivial porque envolve perspectivas diferentes, distorção de lente e a influência da profundidade na posição projetada — o que motiva o uso de um **modelo quadrático** estimado via Mínimos Quadrados.

---

## Fundamentação Matemática

### Teoria dos Mínimos Quadrados

O método dos mínimos quadrados resolve o seguinte problema: dado um conjunto de medidas com ruído e erros instrumentais, encontrar os parâmetros de um modelo matemático que melhor se ajusta a esses dados.

O critério de otimização é minimizar a soma dos quadrados dos erros entre os valores medidos $y_i$ e os valores estimados pelo modelo $\hat{y}_i$:

$$J = \sum_{i=1}^{k} e_i^2 = \sum_{i=1}^{k} \left( y_i - \hat{y}_i \right)^2$$

Nenhum modelo vai acertar todas as medidas perfeitamente quando há ruído nos dados. O que os mínimos quadrados garantem é que os parâmetros encontrados são aqueles que **erram o mínimo possível em todas as medidas ao mesmo tempo**.

---

### Formulação Matricial e a Pseudo-Inversa

Quando se têm $k$ medidas e $n$ parâmetros desconhecidos, com $k > n$, o sistema é chamado **sobredeterminado** — equações demais para poucas incógnitas. Ele é escrito na forma matricial:

$$\mathbf{y} = \mathbf{X}\,\hat{\mathbf{a}} + \mathbf{e}$$

onde $\mathbf{y}$ é o vetor de medidas $(k \times 1)$, $\mathbf{X}$ é a matriz de regressores $(k \times n)$ montada a partir dos dados conhecidos, $\hat{\mathbf{a}}$ é o vetor de parâmetros a estimar $(n \times 1)$ e $\mathbf{e}$ é o vetor de erros $(k \times 1)$.

Minimizando $J = \mathbf{e}^T \mathbf{e}$ e derivando em relação a $\hat{\mathbf{a}}$, chega-se à solução pela **pseudo-inversa**:

$$\boxed{\hat{\mathbf{a}} = \left(\mathbf{X}^T\mathbf{X}\right)^{-1}\mathbf{X}^T\,\mathbf{y}}$$

O termo $(\mathbf{X}^T\mathbf{X})^{-1}\mathbf{X}^T$ recebe o nome de pseudo-inversa porque faz o papel de uma inversa em situações onde a inversa verdadeira de $\mathbf{X}$ não existe — o que ocorre sempre que $\mathbf{X}$ não é quadrada.

---

### Do Polinômio 2D ao Plano 3D

A pseudo-inversa resolve problemas de naturezas diferentes com a mesma fórmula. O que muda entre os casos é apenas o que se coloca nas colunas da matriz $\mathbf{X}$.

**Ajuste polinomial (2D):** dado um conjunto de pontos $(z_i, y_i)$, ajusta-se um polinômio de grau $n$. Cada medida vira uma linha da matriz com as potências de $z$ nas colunas:

$$\mathbf{X} = \begin{bmatrix} 1 & z_1 & z_1^2 & \cdots & z_1^n \\ 1 & z_2 & z_2^2 & \cdots & z_2^n \\ \vdots & \vdots & \vdots & \ddots & \vdots \\ 1 & z_k & z_k^2 & \cdots & z_k^n \end{bmatrix}$$

**Ajuste de plano (3D):** dado um conjunto de pontos $(x_i, y_i, z_i)$ no espaço, ajusta-se um plano $z = a_0 + a_1 x + a_2 y$. A matriz $\mathbf{X}$ agora tem as duas variáveis independentes nas colunas:

$$\mathbf{X} = \begin{bmatrix} 1 & x_1 & y_1 \\ 1 & x_2 & y_2 \\ \vdots & \vdots & \vdots \\ 1 & x_k & y_k \end{bmatrix}$$

A generalização do caso 2D para o 3D é direta — basta adicionar a nova variável como coluna em $\mathbf{X}$. A pseudo-inversa é aplicada da mesma forma em ambos os casos.

---

### Modelo Quadrático para Calibração Kinect–Projetor

Para a calibração, o mapeamento buscado é:

$$u_p = f(u_k,\, v_k,\, d_k), \qquad v_p = g(u_k,\, v_k,\, d_k)$$

Adota-se um **modelo quadrático completo** com 10 parâmetros para capturar as não-linearidades do sistema óptico:

$$u_p \approx a_0 + a_1 u_k + a_2 v_k + a_3 d_k + a_4 u_k^2 + a_5 v_k^2 + a_6 d_k^2 + a_7\, u_k v_k + a_8\, u_k d_k + a_9\, v_k d_k$$

A matriz de regressão tem 10 colunas e $k$ linhas — uma para cada par de pontos coletado na calibração. Resolvem-se dois sistemas independentes, um para cada coordenada do projetor:

$$\hat{\mathbf{a}}_u = \left(\mathbf{X}^T\mathbf{X}\right)^{-1}\mathbf{X}^T\,\mathbf{u}_p \qquad \hat{\mathbf{a}}_v = \left(\mathbf{X}^T\mathbf{X}\right)^{-1}\mathbf{X}^T\,\mathbf{v}_p$$

A qualidade da calibração é avaliada pelo **erro de reprojeção** em pixels:

$$\text{RMSE} = \sqrt{\frac{1}{k}\sum_{i=1}^{k} \left[(u_{p,i} - \hat{u}_{p,i})^2 + (v_{p,i} - \hat{v}_{p,i})^2\right]}$$

---

## Coleta de Dados de Calibração

1. O projetor exibe um tabuleiro de xadrez sobre a areia — como a imagem é gerada internamente, as coordenadas de cada canto no espaço do projetor são exatamente conhecidas
2. O Kinect captura a cena e o OpenCV detecta automaticamente os mesmos cantos na imagem do sensor, fornecendo $(u_k, v_k, d_k)$
3. O processo é repetido com a areia em diferentes configurações de relevo, para que o modelo aprenda o efeito da variação de profundidade
4. Os pares coletados formam a matriz $\mathbf{X}$ e a pseudo-inversa estima os coeficientes de calibração

---

## Estrutura do Repositório

```
.
├── matlab/
│   ├── script01_gravidade.m              # exemplo introdutório: estimação da gravidade
│   ├── script02_ajuste_polinomial_2d.m   # ajuste polinomial com pseudo-inversa
│   ├── script03_calibracao_3d.m          # modelo quadrático Kinect → Projetor
│   └── script04_recursivo.m             # formulação recursiva dos mínimos quadrados
├── relatorio/
│   └── relatorio_tcc.tex                # relatório de andamento em LaTeX
└── README.md
```

---

## Equipe

| Papel | Nome |
|---|---|
| Orientador | Prof. Daniel Rodrigues dos Santos |
| Orientador | TC Leonardo Assumpção Moreira |
| Orientador | TC Bruno Eduardo Madeira |
| Orientador | Cap Gabriel da Cruz Fontenelle |
| Discente (ELO) | Alu CFG/Ativa Raquel Belchior Façanha Nogueira |
| Discente | Alu CFG/Ativa Mateus da Silva Maldonado |
| Discente | Alu CFG/Ativa Estevão Johnatas Ribeiro Batista |
| Discente | Alu CFG/Ativa Rafael de Figueiredo Schuinki |

---

## Referências

- PINHEIRO. **Teoria dos Mínimos Quadrados** — Aula 16. Notas de aula, Controle Ótimo, 2021.
- HARTLEY, R.; ZISSERMAN, A. **Multiple View Geometry in Computer Vision**. Cambridge University Press, 2003.
- ZHANG, Z. A flexible new technique for camera calibration. **IEEE Transactions on Pattern Analysis and Machine Intelligence**, v. 22, n. 11, 2000.
- KeckCAVES. **Augmented Reality Sandbox**. UC Davis, 2012. Disponível em: https://arsandbox.ucdavis.edu
