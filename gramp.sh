#!/usr/bin/env bash
#======================HEADER=========================================|
#AUTOR
# Jefferson 'Slackjeff' Rocha <root@slackjeff.com.br>
#
#Gramp - Graphical Mazon Package
#Instalador Grafico de pacotes para mazon. Inspirado no Gdebi.
#
#=====================================================================|


#=============================| VARS
PRG="Gramp"

#=============================| FUNCTIONS

_PACK_EXIST()
{
    local pack="$1"

    if [[ ! -e "$pack" ]]; then
        yad --title="$PRG" \
        --width="300"      \
        --height="100"     \
        --center           \
        --text             \
        "<big>O pacote $pack não foi encontrado!</big>"
        return 1
    else
        return 0
    fi

}
# Função pra configuração do pacote.
_CONF()
{
    local pack="$1"
    temp_dir=$(mktemp -d)
    local ret
    
    # Descompactando descrição
    tar xvf "${pack}" -C "$temp_dir" "./info/desc" | yad --progress \
    --title "Aguarde..."                   \
    --width="300"                          \
    --progress-text="Descompactando $pack" \
    --pulsate                              \
    --auto-close                           \
    --auto-kill                            \
    --no-buttons
    [[ "$?" != 0 ]] && return 1
    [[ -e "${temp_dir}/info/desc" ]] && source "${temp_dir}/info/desc"
    maintainer=${maintainer//<*/} # Tirando fora email.
    dep=$(echo "${dep[@]}")
    [[ -z "$dep" ]] && dep="Nenhuma."

    yad --title="$PRG"                      \
    --width="700"                           \
    --height="280"                          \
    --center                                \
    --button="Instalar Pacote"!gtk-yes:0    \
    --image="packagegramp.png"              \
    --text                                  \
"
<b>Pacote:</b> $pkgname
<b>Versão:</b> $version
<b>Mantenedor:</b> ${maintainer}
<b>Dependências:</b> ${dep}

<b>Descrição do Pacote:</b>
${desc}
"
    ret="$?"

    if [[ "$ret" = 0 ]]; then
        if pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY xterm -e banana -i "$pack"; then
            yad --title="$PRG"                      \
            --width="500"                           \
            --height="100"                          \
            --center                                \
            --button="Ok"!gtk-yes:0    \
            --image="packagegrampok.png"              \
            --text "\n\n\n<big>Instalação $pkgname Conclúida com sucesso.</big>"
        else
            return 1
        fi
    else
        return 1
    fi

    # Removendo diretório temporário.
    rm -r "$temp_dir"
}

#=============================| INICIO
case $1 in
    -i|install)
        shift # Rebaixando
        while [[ -n $1 ]]; do
            _PACK_EXIST "$1" || exit 1
            _CONF "$1" || exit 1
            shift # Rebaixando
        done
    ;;
esac
