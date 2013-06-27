#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Programme qui permet de générer les différents labyrinthes
# à partir d'un fichier ASCII art

#Imports
import os              #Libairie Fichier
import sys             #Librairie Systeme


def gen_maze(filename, fd):
    """
    Génération du plan.
    Comme elle est la meme pour toutes les images, on la prend pour le plan dont le nom est
    rentrée en parametre en argv[1].
    """

    #On ouvre le fichier dont le nom a été tapé en entrée
    fs = open(filename, 'r')

    # On y stocke une donnée par ligne qui corespond à un nombre entre
    # 1 et 6
    for line in fs:
        # si une ligne commence par # c'est un commentaire, on l'ignore
        if line[0] == '#':
            continue

        # Vérifie que la ligne fait bien 25 caractères de large
        line = line.strip("\r\n")
        if len(line) != 25:
            raise Exception("La ligne %s ne contient pas 25 caractères" %line)

        # Lit les caractère de la ligne courante un par un, et génère le fichier de sortie
        for txt in line:
            if txt == "*" : fd.write("1\n")
            if txt == "o" : fd.write("2\n")
            if txt == "^" : fd.write("5\n")
            if txt == " " : fd.write("0\n")
            if txt == "v" : fd.write("6\n")
            if txt == "<" : fd.write("4\n")
            if txt == ">" : fd.write("3\n")
            if txt == "1" : fd.write("7\n")
            if txt == "2" : fd.write("8\n")


        # On comble par 7 octets à 0 (==sprite vide) pour aligner les lignes sur
        # des frontières de 8 mots
        for i in range(7):
            fd.write("0\n")

    # On comble par 15*32 octets à 0 (==sprite vide) pour aligner les colonnes sur
    # des frontières de 8 mots
    for i in range(15*32):
        fd.write("0\n")

    # Fermeture des fichiers
    fs.close()
    return

def usage():
    """
    Explique comment utiliser ce programme.
    """
    print "Usage : %s fichier1 [fichier2] [fichier3] [etc]"%(sys.argv[0])


def main():
    """
    Ouvre les images passées en arguments et le convertit en des fichiers d'init de ROM.
    La palette, commune à toutes ces images est extraite de la première image seulement.
    """
    # Vérifie qu'on a assez d'arguments
    if len(sys.argv) < 2:
        usage()
        sys.exit(-1)

    # on ouvre le fichier de sortie
    fd = open("maze.lst", "w")

    # Génération de la carte
    for name in sys.argv[1:]:
        gen_maze(name, fd)

    # On ferme de fichier de sortie
    fd.close()

if __name__ == "__main__":
    main()


