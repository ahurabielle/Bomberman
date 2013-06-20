#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Programme qui permet de générer les différentes listes à stocker sur les ROM
# ainsi que la palette de 256 couleurs associée

#Imports
from PIL import Image  #Librairie Image
import os              #Libairie Fichier
import sys             #Librairie Systeme


def generate_palette(filename):
    """
    Génération de la Liste Palette.
    Comme elle est la meme pour toutes les images, on la prend pour l'image dont le nom est
    rentrée en parametre en argv[1].
    Attention : notre palette ne fait que 254 couleurs, d'ou le 253*3 dans cette fonction.
    """
    im = Image.open("%s" %filename)
    if im.mode != 'P' :
        print "Erreur, l'image %s n'est pas en mode palette"%(filename)
        sys.exit(-1)

    #On crée le fichier palette.lst
    fichier = open("palette.lst", "w")
    palette = im.palette
    s = [ord(x) for x in palette.getdata()[1]]
    for i in range(0, (len(palette.getdata()[1]))-1, 3):
        fichier.write ("%02x%02x%02x\n"%(s[i], s[i+1], s[i+2]))
    fichier.close()


def generate_sprite(filename):
    """
    Ouvre un fichier png, et dump les pixels dans un fichier d'initialisation
    de rom (*.lst). L'image doit être au format png paletté.
    """
    #On ouvre l'image dont le nom a été tapé en entrée
    im = Image.open(filename)
    if im.mode != 'P' :
        print "Erreur, l'image %s n'est pas en mode palette"%(filename)
        sys.exit(-1)

    (x,y) = im.size

    #On crée le fichier sprite correspondant
    basename, extension = os.path.splitext(filename)
    fichier = open("%s.lst"%basename, "w")

    #On y stocke une donnée par ligne qui corespond à un nombre entre
    # 0 et 255 pour chaque pixel de l'image
    for j in range(y):
        for i in range(x):
            nombre = im.getpixel((i,j))
            fichier.write("%x\n"%nombre)
    fichier.close()


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

    # Génération des sprite
    for name in sys.argv[1:]:
        generate_sprite(name)

    # Génération de la palette
    generate_palette(sys.argv[1])


if __name__ == "__main__":
    main()


