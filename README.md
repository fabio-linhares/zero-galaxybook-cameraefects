# 🎥 Zero Galaxy Book Camera Effects
### *A Solução Definitiva de Câmera e Studio Effects por IA para Samsung Galaxy Book no Linux*
**Open-Source AI Studio Camera Effects & Virtual Webcam Suite**  
*Desenvolvido e Otimizado para Samsung Galaxy Book3 Ultra (NP960XFH), Galaxy Book3/4 Series e Laptops Híbridos com Linux (Wayland, Intel IPU6, Iris Xe & NVIDIA)*

---

## 📖 A História: Por que este projeto existe?

Se você chegou até este repositório, é muito provável que você compartilhe da mesma dor que nós enfrentamos:

> **Você investiu uma quantia significativa em um laptop topo de linha — um Samsung Galaxy Book3 Ultra (ou modelo da família Book3/4) —, se recusa a ficar preso ao Windows 11, instalou sua distribuição Linux favorita (Fedora, Arch, Ubuntu) e descobriu que a câmera simplesmente não funciona ou entrega uma imagem deplorável.**

Quando procuramos o suporte do fabricante, a resposta é invariavelmente a mesma:  
*“Este dispositivo é homologado exclusivamente para Windows 11. Não oferecemos suporte para Linux.”*

Na internet, em fóruns e no Reddit (`r/GalaxyBook`, `r/linuxhardware`), o cenário até agora era desolador: centenas de usuários relatando frustração e tópicos sem solução há mais de dois anos. As poucas alternativas existentes na comunidade entregavam resultados inaceitáveis:
1. **O Pesadelo da "Tela Branca":** Ao tentar abrir a câmera, o sensor emitia quadros 100% brancos (saturados no teto de 10-bit), travando no primeiro frame.
2. **A Ilusão do "Verde-Musgo da CPU":** Quando algum script conseguia forçar a captura via `libcamera` por força bruta na CPU, o resultado era uma imagem escura, granulada, com tons de pele esverdeados e sem contraste, consumindo 50% de CPU e drenando a bateria em minutos.
3. **Recursos de Fábrica Perdidos:** Todos os recursos inteligentes vendidos na caixa do notebook — o **Studio Mode** da Samsung (Enquadramento Automático, Desfoque de Fundo e Cancelamento de Ruído do Microfone) — eram dados como "impossíveis" de ter no Linux.

**Decidimos que não aceitaríamos esse veredito.** Fizemos a engenharia reversa do hardware, corrigimos os drivers no nível de registrador e construímos esta suíte integrada para provar que o **Galaxy Book no Linux pode ser tão bom (ou melhor) quanto no Windows 11.**

---

## 🔬 O Que Descobrimos e Inovamos (A Engenharia por Baixo dos Panos)

A câmera do Samsung Galaxy Book3 Ultra **não é uma webcam USB convencional (UVC)**. Ela é um subsistema de captura de padrão industrial composto por:
- **Sensor:** OmniVision OV02C10 (módulo Samsung `KBFC645`, 2 Megapixels, matriz Bayer GRBG-10).
- **Barramento Físico:** MIPI CSI-2 de alta velocidade operando com 2 pistas de dados a 1296 Mbps.
- **Processador:** Receptor de silício **Intel IPU6 (Image Processing Unit 6)** na CPU Intel Core de 13ª geração.

### O Que Nós Resolvemos:

1. **Correção do Driver de Kernel (`ov02c10.c`):**
   - **Fim da Tela Branca:** O driver upstream continha um erro crasso de cálculo de deslocamento de bits (`ctrl->val << 7`), multiplicando o ganho por 8 e estourando o conversor analógico-digital (ADC). Corrigimos a escala analógica linear para `anal_gain << 4`.
   - **Group Hold Atômico (`0x3208`):** O sensor travava durante ajustes dinâmicos de exposição. Implementamos a trava de grupo atômica do registrador `0x3208`, sincronizando as escritas estritamente com o intervalo vertical (*VBLANK*).

2. **Paridade com a Calibração de Fábrica do Windows 11 (Hardware ISP):**
   - Em vez de processar pixels na CPU por software (*SoftwareIsp*), ativamos o coprocessador dedicado **Intel IPU6 PSYS (Hardware ISP)**.
   - Carregamos o perfil de calibração laboratorial original da Samsung (`.aiqb`), ativando em silício a correção de sombreamento da lente (*Lens Shading Correction - LSC*), redução de ruído temporal/espacial 3D (*3DNR*) e curvas WDR.
   - **Resultado:** Full HD 1080p a 30fps consumindo **0% de CPU e 0% de GPU**.

3. **A Suíte de Efeitos de Estúdio por IA (Zero Galaxy Book AI):**
   - Desenvolvemos este projeto (`zero-linux-broadcast`) para trazer de volta os efeitos de estúdio da Samsung para o Linux em uma segunda câmera virtual (`/dev/video40`):
     - 🎯 **Auto-Framing (Center Stage):** Rastreia seu rosto e busto, aplicando pan e zoom dinâmico suave sem solavancos.
     - 🎨 **Background Blur:** Desfoque de profundidade ajustável em tempo real (slider contínuo de 4 a 32 px).
     - 🖼️ **Fundo Virtual:** Substituição instantânea do plano de fundo por imagens personalizadas.
     - ⚡ **Zero-Lag em Laptops Híbridos (Wayland / Mesa EGL):** Em notebooks com tela conectada na iGPU Intel Iris Xe e placa discreta NVIDIA, janelas Wayland costumam engasgar. Criamos wrappers que forçam a renderização na iGPU via `DRI_PRIME`, garantindo taxa de quadros fluida.
     - 🔋 **Modo Lazy Producer:** Consumo zero de energia quando nenhuma chamada está ativa. A IA só processa quando um app solicita o vídeo.

---

## 📊 Comparativo Laboratorial (Windows 11 vs. Linux Upstream vs. Nossa Solução)

| Métrica de Avaliação | Windows 11 OEM (De Fábrica) | Linux Padrão Upstream (libcamera) | Zero Galaxy Book Suite (Nossa Solução) |
| :--- | :---: | :---: | :---: |
| **Resolução Nativa** | 1920 × 1080 (Full HD) | 1920 × 1092 (Distorcido) | **1920 × 1080 (Full HD)** |
| **Luminância Média (Y)** | `148.45` | `121.78` | **`153.43` (Idêntica / Superior)** |
| **Balanço de Cor ($\Delta \text{RGB}$)** | $\Delta = 4.39$ ($R \approx G \approx B$) | $\Delta = 55.48$ (Verde-Musgo aberrante) | **$\Delta = 5.92$ (Tons de pele naturais)** |
| **Processamento do Sensor**| Silício Intel IPU6 PSYS | Força bruta na CPU (SoftISP) | **Silício Intel IPU6 PSYS (0% CPU)** |
| **Uso de CPU em Repouso** | < 1% | 45% a 65% contínuo | **< 1%** |
| **Auto-Framing por IA** | Sim (Samsung Studio Mode) | Não | **Sim (`zero-linux-broadcast`)** |
| **Desfoque de Fundo (Blur)**| Sim | Não | **Sim (Ajustável em tempo real)** |
| **Câmera Virtual Isolada** | Não | Não | **Sim (`/dev/video40` independente)** |

---

## 🚀 Como Instalar e Usar (Guia Rápido)

### Pré-requisitos
- Distribuição Linux com suporte a `v4l2loopback` (Fedora 40+, Arch Linux, Ubuntu 22.04+, Debian).
- Rust e Cargo (caso deseje compilar do código-fonte).

### 1. Instalação em 1 Comando
Clone este repositório e execute o instalador universal:

```bash
git clone https://github.com/fabio-linhares/zero-galaxybook-cameraefects.git
cd zero-galaxybook-cameraefects
./install.sh
```

O instalador irá:
1. Detectar o seu ambiente e compilar/configurar o motor em Rust.
2. Criar e persistir o dispositivo virtual `/dev/video40` (*Zero Galaxy Book AI Camera*).
3. Configurar as regras de prioridade do WirePlumber.
4. Adicionar o atalho **`Zero Galaxy Book AI (Efeitos de Câmera)`** ao menu de aplicativos do seu sistema.

---

### 2. Como Usar nas Suas Reuniões (Zoom, Google Meet, Teams, Discord)

Ao abrir seu aplicativo de videoconferência favorito, vá nas **Configurações de Câmera / Vídeo**:

- **Selecione `Intel MIPI Camera` (`/dev/video0`):** Para o vídeo puro direto de hardware calibrado de fábrica, com latência zero e consumo mínimo.
- **Selecione `Zero Galaxy Book AI Camera` (`/dev/video40`):** Para o vídeo com Inteligência Artificial, Auto-Framing e Desfoque de Fundo ativos.

---

### 3. Ajustando os Efeitos em Tempo Real

Abra pelo menu o aplicativo **`Zero Galaxy Book AI (Efeitos de Câmera)`** (ou digite no terminal `zero-linux-broadcast`):

- **Auto-Frame:** Marque para ativar o enquadramento dinâmico suave.
- **Blur Intensity:** Ajuste o controle deslizante para o desfoque desejado.
- **Background Replace:** Selecione uma imagem de fundo personalizada.
- **Model:** 
  - `Selfie multiclass`: Recomendado para uso na bateria (ultra-leve, 30 fps fluidos na CPU/iGPU).
  - `RVM (Robust Video Matting)`: Máxima precisão de bordas e contornos finos de cabelo.

---

## 🎙️ Bônus: Voice Focus no Linux (Áudio Cristalino)

Para equiparar o cancelamento de ruído de microfone da Samsung:
1. Instale o **`EasyEffects`** na sua distribuição (`sudo dnf install easyeffects` ou `sudo apt install easyeffects`).
2. Abra o EasyEffects, vá na aba **Microfone de Entrada** e ative o plugin **Redução de Ruído (RNNoise)** ou **DeepFilterNet**.
3. O PipeWire processará sua voz em tempo real (< 10 ms de latência), eliminando ruídos de teclado, ventilador e tráfego.

---

## 📂 Estrutura do Repositório

```text
zero-galaxybook-cameraefects/
├── install.sh                                # Instalador turnkey automatizado
├── uninstall.sh                              # Script de desinstalação limpa
├── configs/                                  # Configurações declarativas
│   ├── desktop/
│   │   ├── zero-galaxybook-ai.desktop        # Lançador do menu de aplicativos
│   │   └── zero-linux-broadcast.sh           # Wrapper Wayland / Mesa EGL anti-stutter
│   ├── systemd/
│   │   └── zero-galaxybook-ai-loopback.service # Serviço de persistência no boot
│   └── wireplumber/
│       └── 60-camera-priority.conf           # Regras de priorização do WirePlumber
├── src/                                      # Código-fonte completo em Rust
│   ├── crates/app/                           # Interface gráfica nativa em egui
│   └── crates/pipeline/                      # Pipeline de processamento GStreamer/ONNX
└── models/                                   # Modelos ONNX de segmentação (RVM / MediaPipe)
```

---

## 🤝 Contribuições e Comunidade

Este projeto é fruto do compromisso de donos de Samsung Galaxy Book que acreditam na liberdade do ecossistema Linux e na excelência do hardware.

- Encontrou um bug ou tem uma melhoria para outras variantes de Galaxy Book? Abra uma **Issue** ou envie um **Pull Request**.
- Testado com sucesso em outros modelos da linha Samsung? Deixe seu relato nos comentários das issues para ajudarmos outros usuários!

---

## 📄 Licença

Distribuído sob a licença [GNU General Public License v3.0 (GPL-3.0-or-later)](./LICENSE).  
Baseado nas fundações do projeto `linux-broadcast` com extensões arquiteturais, correções de pipeline Wayland/Mesa EGL e integração de hardware voltadas para os laptops Samsung Galaxy Book.
