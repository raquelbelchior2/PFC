# Caixão de Areia com Realidade Aumentada

**Projeto Final de Curso**

**Instituição:** Instituto Militar de Engenharia (IME)
**Solicitante:** AMAN

---

## O que é este projeto

O caixão de areia interativo é uma ferramenta tradicional do planejamento militar — o comandante modela o terreno em areia e comunica posicionamento de tropas, eixos de deslocamento e pontos de interesse de forma concreta e visual.

Este PFC propõe modernizar essa ferramenta integrando:

- **Sensor de profundidade** (Kinect) para ler o relevo modelado na areia
- **Realidade aumentada** para projetar sobre a areia um mapa topográfico em tempo real
- **Comparação com MDT** (Modelo Digital de Terreno) de cartas topográficas reais, com feedback de fidelidade
- **Integração com Google Earth / OpenStreetMap** para navegação geoespacial a partir de pontos indicados no caixão

---

## Objetivos do PFC

1. Utilizando o Kinect, ler a topologia e topografia do caixão de areia
2. Comparar o modelo gerado com o modelo digital de terreno da carta topográfica de referência
3. Fornecer feedback sobre a fidelidade do caixão em relação ao MDT
4. Integrar fontes de dados abertas para navegação no terreno em outra tela

---

## Equipe

| Papel | Nome |
|---|---|
| Orientador | Prof. Daniel Rodrigues dos Santos |
| Orientador | TC Leonardo Assumpção Moreira |
| Orientador | TC Bruno Eduardo Madeira |
| Orientador | Cap Gabriel da Cruz Fontenelle |
| Discente | Alu CFG/Ativa Raquel Belchior Façanha Nogueira |
| Discente | Alu CFG/Ativa Mateus da Silva Maldonado |
| Discente | Alu CFG/Ativa Estevão Johnatas Ribeiro Batista |
| Discente | Alu CFG/Ativa Rafael de Figueiredo Schuinki |

---

## Estrutura do Repositório

```
.
├── relatorio/
│   └── PFC__Projeto_Final.pdf        # relatório oficial — atualizado periodicamente
│
├── estudos/
│   └── estudos.md                    # anotações de estudo por tópico (em construção)
│
├── matlab/
│   ├── script01_gravidade.m          # exemplo introdutório: estimação da gravidade
│   ├── script02_ajuste_polinomial_2d.m  # ajuste polinomial com pseudo-inversa
│   ├── script03_calibracao_3d.m      # modelo quadrático Kinect → Projetor
│   └── script04_recursivo.m         # formulação recursiva dos mínimos quadrados
│
└── README.md
```

---

## Como navegar

- Para entender o projeto e seus objetivos → você está no lugar certo
- Para acompanhar o progresso dos estudos e o que já foi entendido → veja [`ESTUDOS.md`](estudos/ESTUDOS.md)
- Para o relatório oficial → veja a pasta `relatorio/`
- Para os códigos MATLAB de calibração → veja a pasta `matlab/`

---

## Referências principais

- KREYLOS, O. **SARndbox**. UC Davis KeckCAVES, 2012. Disponível em: https://github.com/KeckCAVES/SARndbox
- AR-SANDBOX.EU. **Augmented Reality Sandbox DIY Guide**. Disponível em: https://ar-sandbox.eu/augmented-reality-sandbox-diy/
- PINHEIRO. **Teoria dos Mínimos Quadrados** — Aula 16. Notas de aula, Controle Ótimo, 2021.
