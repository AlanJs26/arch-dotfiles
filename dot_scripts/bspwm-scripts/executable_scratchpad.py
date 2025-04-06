#!/usr/bin/env python3
"""
Um scratchpad para bspwm.

Este script permite esconder/exibir janelas com base em filtros definidos
por expressões regulares para título, classe e instância. Além disso, ele
oferece diferentes modos de comportamento, semelhantes ao scratchpad do i3,
swap, nomark e toggleall.
"""

import re
import os
import bspc
from bspc.classes import Node
from argparse import ArgumentParser, RawTextHelpFormatter


def parse_args():
    """
    Configura e retorna os argumentos de linha de comando.
    """
    parser = ArgumentParser(
        description="Um scratchpad para bspwm",
        formatter_class=RawTextHelpFormatter,
    )

    # Filtros para título da janela
    parser.add_argument(
        "title_query",
        nargs="?",
        default="",
        help="Regex para títulos de janelas",
    )
    parser.add_argument(
        "-T",
        "--not_title_query",
        "--not_title",
        default="",
        metavar="not_title_query",
        help="Regex negativa para títulos de janelas",
    )

    # Filtros para classe da janela
    parser.add_argument(
        "-c",
        "--class_query",
        "--class",
        default="",
        metavar="class_query",
        help="Regex para classes de janelas",
    )
    parser.add_argument(
        "-C",
        "--not_class_query",
        "--not_class",
        default="",
        metavar="not_class_query",
        help="Regex negativa para classes de janelas",
    )

    # Filtros para instância da janela
    parser.add_argument(
        "-i",
        "--instance_query",
        "--instance",
        default="",
        metavar="instance_query",
        help="Regex para instâncias de janelas",
    )
    parser.add_argument(
        "-I",
        "--not_instance_query",
        "--not_instance",
        default="",
        metavar="not_instance_query",
        help="Regex negativa para instâncias de janelas",
    )

    # Outras opções
    parser.add_argument(
        "--floating",
        action="store_true",
        help="Considera apenas janelas flutuantes",
    )
    parser.add_argument(
        "-r",
        "--run",
        default="",
        help="Comando a ser executado quando não há janelas correspondentes",
    )
    parser.add_argument(
        "-b",
        "--behaviour",
        choices=["i3", "swap", "nomark", "toggleall"],
        default="i3",
        help="""Modo de comportamento:
<i3> (padrão): comporta-se como o scratchpad do i3.
<swap>: esconde a janela atual e exibe a próxima em um único comando.
<nomark>: não utiliza marcas do bspwm, podendo resetar a posição das janelas.
<toggleall>: alterna todas as janelas flutuantes visíveis.
""",
    )
    return parser.parse_args()


def window_matches(node: Node) -> bool:
    """
    Verifica se a janela (node) corresponde aos critérios definidos
    pelos argumentos de filtro (título, classe e instância).
    """
    # Validação para o título da janela
    if args.title_query and not re.search(args.title_query, node.name, flags=re.I):
        return False
    if args.not_title_query and re.search(args.not_title_query, node.name, flags=re.I):
        return False

    # Validação para a classe da janela
    if args.class_query and not re.search(args.class_query, node.className, flags=re.I):
        return False
    if args.not_class_query and re.search(
        args.not_class_query, node.className, flags=re.I
    ):
        return False

    # Validação para a instância da janela (se houver informação de client)
    if node.client:
        if args.instance_query and not re.search(
            args.instance_query, node.client["instanceName"], flags=re.I
        ):
            return False
        if args.not_instance_query and re.search(
            args.not_instance_query, node.client["instanceName"], flags=re.I
        ):
            return False

    return True


def handle_toggleall(
    matched_nodes, visible_nodes, hidden_nodes, marked_nodes, focused_node
):
    """
    Trata o comportamento 'toggleall': alterna todas as janelas flutuantes.
    """
    if visible_nodes & bspc.query.nodes(desktop_selector=".!focused"):
        # Se há janelas visíveis que não estão focadas, foca a primeira marcada ou a primeira visível
        node = marked_nodes.first() or visible_nodes.first()
        if node:
            node.to_monitor("focused", follow=True)
            node.focus()
        # Atualiza a exibição de todas as janelas correspondentes
        for node in matched_nodes:
            node.to_monitor("focused", follow=True)

    elif hidden_nodes:
        # Torna visíveis todas as janelas ocultas que correspondem
        for node in hidden_nodes:
            node.hidden = False
            node.to_monitor("focused", follow=True)
        marked_hidden = marked_nodes & hidden_nodes
        node = marked_hidden.first() or hidden_nodes.first()
        if node:
            node.focus()

    elif visible_nodes:
        # Esconde todas as janelas correspondentes e marca a janela atualmente focada
        for node in matched_nodes:
            node.marked = False
            node.hidden = True
        if focused_node:
            focused_node.marked = True

    else:
        marked_hidden = marked_nodes & hidden_nodes
        node = marked_hidden.first() or hidden_nodes.first()
        if node:
            node.hidden = False
            node.to_monitor("focused", follow=True)
            node.focus()
        for node in hidden_nodes:
            node.hidden = False
            node.to_monitor("focused", follow=True)
        if args.run and not matched_nodes.first():
            os.system(args.run)


def handle_i3_swap(visible_nodes, hidden_nodes, marked_nodes, focused_node):
    """
    Trata os comportamentos 'i3' e 'swap', similares ao scratchpad do i3.
    """
    if visible_nodes & bspc.query.nodes(desktop_selector=".focused"):
        # Obtém o próximo nó oculto após o nó focado
        next_node = hidden_nodes.next(focused_node) if focused_node else None
        for node in visible_nodes:
            node.hidden = True
            if next_node:
                node.marked = False

        if next_node:
            next_node.marked = True
            if args.behaviour == "swap":
                next_node.hidden = False
                if next_node.layout == "floating":
                    next_node.to_monitor("focused", follow=True)
                next_node.focus()
    elif visible_nodes:
        # Se há janelas visíveis, foca nelas
        for node in visible_nodes:
            if node.layout == "floating":
                node.to_monitor("focused", follow=True)
            else:
                node.focus()
    else:
        # Se não há janelas visíveis, exibe uma janela oculta (priorizando as marcadas)
        marked_hidden = marked_nodes & hidden_nodes
        current_node = marked_hidden.first() or hidden_nodes.first()
        if current_node:
            current_node.hidden = False
            if current_node.layout == "floating":
                current_node.to_monitor("focused", follow=True)
            current_node.focus()
        elif args.run and not visible_nodes.first():
            os.system(args.run)


def handle_nomark(visible_nodes, hidden_nodes, focused_node):
    """
    Trata o comportamento 'nomark', que não utiliza marcas do bspwm.
    """
    if visible_nodes & bspc.query.nodes(desktop_selector=".focused"):
        # Esconde todas as janelas visíveis
        for node in visible_nodes:
            node.hidden = True
        current_node = hidden_nodes.next(focused_node) if focused_node else None
    elif visible_nodes:
        current_node = visible_nodes.first()
    else:
        current_node = hidden_nodes.first()

    if current_node:
        current_node.hidden = False
        if current_node.layout == "floating":
            current_node.to_monitor("focused", follow=True)
        current_node.focus()
    elif args.run and not visible_nodes.first():
        os.system(args.run)


def main():
    global args
    args = parse_args()

    # Obtém todos os nós ocultos
    hidden_nodes = bspc.query.nodes(".hidden")

    # Seleciona os nós com base no parâmetro --floating ou no título
    if args.title_query == ".*" or args.floating:
        all_nodes = bspc.query.nodes(".floating").sort(lambda x: x.id)
    else:
        all_nodes = bspc.query.nodes(".window").sort(lambda x: x.id)

    # Filtra os nós que correspondem aos critérios especificados
    matched_nodes = all_nodes.filter(window_matches)

    # Separa os nós visíveis dos ocultos
    visible_nodes = matched_nodes - hidden_nodes
    hidden_matched_nodes = hidden_nodes & matched_nodes

    # Obtém os nós marcados e o nó atualmente focado dentre os visíveis
    marked_nodes = bspc.query.nodes(".marked") & matched_nodes
    focused_nodes = bspc.query.nodes(".focused") & visible_nodes
    focused_node = focused_nodes.pop() if focused_nodes else None

    # Chama a função de tratamento conforme o comportamento escolhido
    if args.behaviour == "toggleall":
        handle_toggleall(
            matched_nodes,
            visible_nodes,
            hidden_matched_nodes,
            marked_nodes,
            focused_node,
        )
    elif args.behaviour in ["i3", "swap"]:
        handle_i3_swap(visible_nodes, hidden_matched_nodes, marked_nodes, focused_node)
    elif args.behaviour == "nomark":
        handle_nomark(visible_nodes, hidden_matched_nodes, focused_node)
    else:
        print("Modo de comportamento desconhecido.")


if __name__ == "__main__":
    main()
