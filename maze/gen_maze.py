#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Programme qui permet de générer les différents labyrinthes
# à partir d'un fichier ASCII art

#Imports
import os              #Libairie Fichier
import sys             #Librairie Systeme


def gen_maze(filename):
    """
    Génération du plan.
    Comme elle est la meme pour toutes les images, on la prend pour le plan dont le nom est
    rentrée en parametre en argv[1].
    """

    #On ouvre le fichier dont le nom a été tapé en entrée
    fs = open(filename, 'r')

    #On crée le fichier carte correspondant
    basename, extension = os.path.splitext(filename)
    fd = open("%s.lst"%basename, "w")

    # On y stocke une donnée par ligne qui corespond à un nombre entre
    # 1 et 6
    while 1:
        txt = fs.read(1)
        if txt == "*" : txt = "1"
        elif txt == "o" : txt = "2"
        elif txt == "^" : txt = "5"
        elif txt == " " : txt = "0"
        elif txt == "v" : txt = "6"
        elif txt == "<" : txt = "4"
        elif txt == ">" : txt = "3"
        elif txt == "1" : txt = "p"
        elif txt == "2" : txt = "P"
        elif txt == "#" :
            txt = fs.readline()
            txt = ""
        elif txt =="": break

        fd.write(txt)
    fs.close()
    fd.close()
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

    # Génération de la carte
    for name in sys.argv[1:]:
        gen_maze(name)


if __name__ == "__main__":
    main()


