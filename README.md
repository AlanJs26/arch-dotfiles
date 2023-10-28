# Antes de rodar

Instalar o [yay](https://github.com/Jguer/yay)

Certificar se o horario está correto para não ocorrer erros com os certificados SSL

`sudo timedatectl set-ntp true`

instalar pacotes relacionados ao keyring e chaves PGP

`yay -Sy archlinux-keyring`

`sudo rm /etc/pacman.d/gnupq/*`

`sudo pacman-key --init && sudo pacman-key --populate`

`sudo pacman-key --refresh-keys`

Atualizar todos os pacotes atuais

`yay -Syuu`

## Direnv

O direnv permite adicionar variáveis de ambiente especificas dependendo da pasta em questão.

Um tutorial de como usar esta presente [nesta pagina](https://github.com/direnv/direnv/wiki)

## Eww

Na época que eu escrevi esse README o pacote [eww-git](https://aur.archlinux.org/packages/eww-x11) não funciona se as seguintes chaves gpg não forem instaladas explicitamente. O comando para instalar é o seguinte

```bash
curl -sS https://github.com/elkowar.gpg | gpg --import -i -;
curl -sS https://github.com/web-flow.gpg | gpg --import -i -
```

## Zsh

O zsh precisa ser configurado manualmente. São necessários o [oh-my-zsh](https://ohmyz.sh) e o gerenciador de plugins [zinit](https://github.com/zdharma-continuum/zinit)

Para instalar o oh-my-zsh execute o comando abaixo

```bash
sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
```


Para instalar o zinit execute o comando abaixo

```bash
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
```

# Montando Partições

Para montar partições ao iniciar o sistema é preciso criar uma entrada no `/etc/fstab`. Como isso é muito complicado, é mais rápido utilizar o [gnome-disks](https://archlinux.org/packages/extra/x86_64/gnome-disk-utility/) para criar essa entrada de forma automatica

Lembre-se de criar a pasta no ponto de montagem, senão a montagem vai falhar

# Usando o archdots

`archdots` é um wrapper para facilitar o uso do chezmoi e pacdef. Os principais comandos são:

`archdots sync`

Esse comando syncroniza o chezmoi e o pacdef

`archdots setup`

Esse comando contém vários scripts de instalação que o chezmoi e pacdef não fornecem de forma satisfatória

`archdots edit`

Esse comando usa o editor padrão para modificar os arquivos de pacotes do pacdef

`archdots git SUBCOMANDO`

Esse é um atalho para o git desse repo

# Gerenciando os dotfiles

os dotfiles são gerenciados pelo [chezmoi](https://www.chezmoi.io).

O comando abaixo inicia o chezmoi com esse repositório

`chezmoi init --apply https://github.com/$GITHUB_USERNAME/dotfiles.git`

## Fazendo modificações

O chezmoi é basicamente um wrapper para git, assim o seu workflow é similar a um projeto git.

Onde é possível especificar arquivos e pastas para o chezmoi gerenciar com

`chezmoi add CAMINHO`

> Isso só é preciso ser feito apenas uma vez

Agora toda vez que for feito uma mudança nesse arquivo é possível rodar o comando abaixo para ver o diff das modificações

`chezmoi diff`

Quando estiver satisfeito com as mudanças, basta rodar o comando abaixo para aplicar as mudanças.

`chezmoi -v apply`

Esses comandos adicionam e atualizam os arquivos no "banco de dados" do chezmoi. Esses arquivos são salvos em `~/.local/share/chezmoi` na forma de um repositório git, assim para adiciona-lo ao github basta rodar os comando usuais de git.

```bash
# entra na pasta do chezmoi
chezmoi cd

git add .
git commit -m "primeira vez com chezmoi"

# Adicionando um remote para git
git remote add https://github.com/username/repo.git
git push
```

> Ao rodar `chezmoi init --apply https://github.com/$GITHUB_USERNAME/dotfiles.git` não é preciso adicionar o remote no git, porque esse comando já faz isso

# Gerenciando os pacotes

O gerenciamento de pacotes é feito pelo [pacdef](https://github.com/steven-omaha/pacdef). Essa ferramenta permite gerenciar os pacotes do arch, python, rust, apt e flatpak de forma declarativa.

O seu funcionamento consiste em vários arquivos de texto localizados em `~/.config/pacdef/groups` que contém os pacotes que devem ser instalados. Esses arquivos seguem o formato toml, onde são separados por seções que especificam o tipo de pacote, sendo `[arch]`, `[debian]`, `[flatpak]`, `[python]` e `[rust]` as opções disponíveis.

## Como usar

Os dois principais comandos que serão usados ao longo do tempo são: `pacdef package sync` e `pacdef package review`

O comando `pacdef package sync` lê todos os pacotes declarados e os instala no computador. Assim esse é o comando que é executado após modificações nas listas de pacotes em `~/.config/pacdef/groups`

Já o comando `pacdef package review` vai pegar todos os pacotes que não estão sendo gerenciados e faz perguntas sobre o que fazer com eles (para qual grupo atribui-lo, desistalar, ignorar, etc)


# Python

Aqui estão listadas algumas dicas e soluções sobre como configurar o python da primeira vez

## pip não existe

O arch tem dois pacotes principais para instalar o python: `python` e `python-pip`. Embora o segundo comando pareça instalar o pip, na verdade ele só vai configurar um alias para `pip`, ou seja, é preciso antes instalar o pip na versão de python atual. Para isso é preciso rodar o comando abaixo

`python -m ensurepip`
