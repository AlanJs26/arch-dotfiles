# 🏠 Arch Dotfiles (arch-dotfiles)

Bem-vindo(a)! Este repositório contém minha configuração de **dotfiles** para Arch Linux, pensada para ser **reprodutível**, fácil de manter e simples de aplicar em uma instalação nova.

A gestão dos dotfiles aqui é feita com o **[`dots`](https://github.com/AlanJs26/dots)** ✨ — um CLI que organiza o fluxo de instalação/atualização e usa o **chezmoi por trás dos panos** para aplicar os arquivos no lugar certo.

---

## ✅ Pré-requisitos (antes de rodar qualquer coisa)

Algumas coisinhas evitam dor de cabeça com certificados, chaves e repositórios.

### 🕒 1) Verifique o horário (SSL)

Se o relógio do sistema estiver errado, você pode ter erro de certificado SSL. Ative NTP:

```bash
sudo timedatectl set-ntp true
```

### 📦 2) Instale o yay (AUR helper)

Instale o [yay](https://github.com/Jguer/yay) (como você preferir).

### 🔑 3) Atualize keyring/PGP (evita erro ao instalar)

```bash
yay -Sy archlinux-keyring

sudo rm /etc/pacman.d/gnupq/*
sudo pacman-key --init && sudo pacman-key --populate
sudo pacman-key --refresh-keys
```

### 🔄 4) Atualize tudo

```bash
yay -Syuu
```

---

## 🚀 Gerenciando os dotfiles com `dots`

O `dots` é o jeito recomendado de usar este repositório. Ele cuida do fluxo padrão e **automatiza a configuração inicial** (incluindo o `chezmoi init` quando necessário).

> Em outras palavras: você usa `dots`, e ele usa **chezmoi** por trás para aplicar os arquivos.

### 🧩 Instalação do `dots`

Siga as instruções do repositório do projeto:

- https://github.com/AlanJs26/dots

(Se você já tem o `dots` instalado, pode pular essa parte.)

### 🏁 1) Primeira vez: inicializar e aplicar

Em uma instalação nova (ou em uma máquina nova), use o comando de init do `dots`:

```bash
dots init
```

Esse comando é o ponto de partida: ele faz a configuração inicial necessária e prepara o gerenciamento dos dotfiles para este repo.

### 🔄 2) Sincronizar / aplicar mudanças

Depois que tudo está inicializado, o fluxo normal é manter os dotfiles sincronizados. Dependendo do seu uso, você vai alternar entre:

- puxar atualizações
- ver o que mudou
- aplicar mudanças

Se você quiser entender o que vai ser alterado **antes** de aplicar, procure no `dots` os comandos equivalentes de *diff*/*apply* (ele delega isso ao chezmoi).

### ✍️ 3) Fazendo modificações nos seus dotfiles

O workflow mental aqui é bem “git-like”:

1. você altera arquivos no seu sistema
2. adiciona/atualiza esses arquivos no gerenciador
3. confere o diff
4. aplica
5. commita e faz push

Se você já usava `chezmoi add`, `chezmoi diff` e `chezmoi apply`, saiba que continua valendo — só que o recomendado é **fazer isso através do `dots`**, que mantém o processo mais guiado e consistente.

---

## 🧠 Dicas e Truques

Aqui ficam as dicas que não são diretamente “gerenciamento de dotfiles”, mas que ajudam muito no setup.

### 🌱 Direnv

O direnv permite adicionar variáveis de ambiente específicas dependendo da pasta em questão.

Tutorial oficial (bem completo):
- https://github.com/direnv/direnv/wiki

### 🧩 Eww (GPG)

Na época que eu escrevi este README, o pacote [eww-x11](https://aur.archlinux.org/packages/eww-x11) podia falhar se as chaves GPG abaixo não fossem importadas explicitamente.

```bash
curl -sS https://github.com/elkowar.gpg | gpg --import -i -;
curl -sS https://github.com/web-flow.gpg | gpg --import -i -
```

### 🐚 Zsh

O Zsh precisa ser configurado manualmente. Recomendo:
- [oh-my-zsh](https://ohmyz.sh)
- [zinit](https://github.com/zdharma-continuum/zinit)

Instalar oh-my-zsh:

```bash
sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
```

Instalar zinit:

```bash
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
```

### 💾 Montando partições automaticamente (fstab)

Para montar partições ao iniciar o sistema é preciso criar uma entrada no `/etc/fstab`. Como isso pode ser chato de fazer manualmente, muitas vezes é mais rápido usar o **gnome-disks** e configurar por lá.

> Lembre-se de criar a pasta no ponto de montagem, senão a montagem vai falhar.

### 🐍 Python: pip não existe

No Arch, você pode acabar com Python instalado mas sem o pip disponível como esperado. Uma forma de resolver é:

```bash
python -m ensurepip
```

---

## 📌 Notas

- Este repositório foca em **dotfiles** e no fluxo de aplicação via `dots`.
- Se algo estiver quebrando no seu ambiente, abra uma issue com:
  - distro/versão
  - logs
  - o que você tentou rodar

Boa configuração! ✨
