#!/usr/bin/env python3
"""niveau2exl.py -- un niveau pour prince_jeu : decor et carte logique.

  1. IMPORT d'un niveau de VOTRE SDLPoP :
        python3 niveau2exl.py DOSSIER_SDLPOP PLAN.png [--niveau 1] [--seuil 25]
                              [--depart SALLE,ETAGE,CASE]
     -> niveau.txt (le niveau en clair, modifiable), prince_niveau.cram, niveau.png

  2. COMPILATION d'un niveau.txt (apres l'avoir modifie) :
        python3 niveau2exl.py niveau.txt
     -> prince_niveau.cram, niveau.png

     L'import refuse d'ecraser un niveau.txt existant (--texte autre.txt, ou --ecraser).

prince_niveau.cram est une image de l'Exelmemoire (16 384 octets, $8000-$BFFF) : le niveau n'est
plus dans la ROM. C'est un volume du CROS (le systeme de l'Exelmemoire) avec un seul fichier, PRINCE :
DIR, TST et BKP le reconnaissent. La charger dans l'emulateur, ou dans une vraie Exelmemoire
(cram2k7.py en fait une cassette pour BKP ; bkp2cram.py --inverse un .BKP). Sans elle, ou si elle
est d'un ancien format, prince_jeu s'arrete sur un bord rouge.

Options communes : [-o prince_niveau.cram] [--apercu niveau.png]

Pour l'import, il faut deux choses :
  - le dossier de SDLPoP, pour le fichier du niveau (data/LEVELS/res20NN.bin) : les 24
    salles de 10 x 3 cases, le type de chaque case (sol, mur, vide, pics...) et les
    salles voisines. C'est la carte LOGIQUE : le moteur s'en sert pour les murs.
  - PLAN.png : le plan du meme niveau, fait dans SDLPoP par Maj+F12 (triches actives :
    lancer le jeu avec "megahit"). C'est l'APPARENCE.

Une case du jeu fait 32 x 63 points. Ici elle fait 4 x 6 caracteres, soit 32 x 60 : on
retire 3 lignes par etage (une par rang de briques), et tout tombe sur des caracteres
entiers. Les blocs de 4 x 6 caracteres identiques ne sont ranges qu'une fois : une salle
tient en 30 numeros de bloc, et tout le niveau partage 252 caracteres au plus.

Le personnage marche sur le haut de la 6e ligne de chaque etage : convertir le prince
avec   python3 pop2exl.py DOSSIER_SDLPOP --jeu   (sol a la ligne 14, par defaut).

Un niveau importe derive des images et des niveaux du jeu : ne le diffusez pas (ni
niveau.txt, ni prince_niveau.cram). Un niveau.txt entierement de votre main est a vous.
Aucune dependance : Python 3 seul (pop2exl.py et decor2exl.py dans le meme dossier)."""
import sys, os, argparse
from pop2exl import png_read
from decor2exl import png_write_rgb
MAXT = 126                                      # un seul generateur (BAGC2) : codes 1 a 127, sauf le delimiteur $20
NUMS = [t for t in range(1, 128) if t != 32]

RETIRE = (10, 31, 45)                            # lignes retirees dans un etage de 63
GARDE = [r for r in range(63) if r not in RETIRE]
HAUT = 3                                         # ligne de caracteres du haut de la salle (3 + 18 + 4 = 25)
TBL_PV = (4, 3, 3, 3, 3, 4, 5, 4, 4, 5, 5, 5, 4, 6)    # points de vie des gardes, par niveau (comme le jeu)
NOMS = {0: 'vide', 1: 'sol', 2: 'pics', 3: 'pilier', 4: 'grille', 5: 'bloque', 6: 'bouton_ferme', 7: 'linteau_sol',
        8: 'gpilier_bas', 9: 'gpilier_haut', 10: 'potion', 11: 'fragile', 12: 'linteau', 13: 'miroir',
        14: 'debris', 15: 'bouton_ouvre', 16: 'sortie_g', 17: 'sortie_d', 18: 'machoire', 19: 'torche', 20: 'mur',
        21: 'squelette', 22: 'epee', 23: 'balcon_g', 24: 'balcon_d', 30: 'debris_torche',
        0xA4: 'grille_ouverte',
        0x2A: 'potion_vie', 0x4A: 'potion_grande', 0x6A: 'potion_poison'}   # (la case 10 ; les 3 bits du haut : sa nature)                 # (la meme case 4 ; les 3 bits du haut : l'ouverture, 0 a 5)
TYPES = {v: k for k, v in NOMS.items()}

# Le modele d'un niveau, commun a l'import et au fichier texte :
#   cars   : liste de caracteres (10 octets, du haut vers le bas) ; le numero 1 est cars[0], 0 = vide
#   blocs  : liste de blocs (24 numeros de caractere, 6 lignes de 4) ; le numero 1 est blocs[0], 0 = vide
#   salles : {numero: (30 numeros de bloc, 30 types de case, (gauche, droite, haut, bas))}
#   depart : (salle, etage, case)
#   pics   : liste de (bloc des pics rentres, bloc des pics sortis)
#   liens  : liste de ((salle, etage, case) d'un bouton, (salle, etage, case) de la grille qu'il commande)

def placer(salles, depart):
    """place des salles sur le plan, de proche en proche a partir de la salle de depart (comme SDLPoP)"""
    pos = {depart: (0, 0)}; pile = [depart]
    while pile:
        r = pile.pop(); x, y = pos[r]
        for k, (dx, dy) in enumerate(((-1, 0), (1, 0), (0, -1), (0, 1))):
            n = salles[r][2][k]
            if n and n in salles and n not in pos: pos[n] = (x + dx, y + dy); pile.append(n)
    mx = min(p[0] for p in pos.values()); my = min(p[1] for p in pos.values())
    return {r: (x - mx, y - my) for r, (x, y) in pos.items()}


# --- murs generes (ligne "murs GRAINE POINTS EPAIS [ECLATS]") : 48 caracteres de briques fabriques ici,
# copies par le moteur dans le generateur BAGC1 (hors des 126 du decor) et places case par case
# (prince_jeu.asm : wall_ch). Meme calcul dans atelier_decor.html.
def _rnd_table():
    t = []; x = 0x1234
    for i in range(256):
        x = (x * 25173 + 13849) & 0xFFFF; t.append(x >> 8)
    return t
RND = _rnd_table()
MURS = None
FRAGA = []                                        # sols fragiles animes : (bloc normal, image 1, image 2), 14 au plus
FTEMPO = [2]
TOMBE = {}
DEBRIS = [None]
PLAFOND = [None]                                  # ligne plafond : le bloc dont la 6e rangee fait le plafond mince
COULEURS = {}                                     # lignes couleur : caractere -> couleur (0-7) ; 7 au plus
FLAMME = [None]                                   # ligne flamme : les 4 caracteres de la flamme des torches (animee)
BULLE = [None]                                    # ligne bulle : le caractere des bulles des potions (anime)
NOMS_COUL = ['noir', 'rouge', 'vert', 'jaune', 'bleu', 'magenta', 'cyan', 'blanc']
ENFONCE = {}                                      # (salle, etage, case) d'un bouton -> (bloc enfonce, bloc enfonce de sa voisine de droite ou None)                                   # le bloc des debris laisses par une dalle tombee (None : automatique)                                        # (salle, etage, case) d'un sol fragile -> son bloc une fois tombe                                      # ... et leur tempo : pas par image (1-8)
FORMES = (((0, 2), (1, 1), (2, 0), (3, 1), (4, 2)), ((2, 0), (1, 1), (0, 2), (1, 3), (2, 4)),
          ((0, 3), (1, 2), (2, 1), (3, 0)), ((0, 0), (1, 1), (2, 2), (3, 3)), ((0, 0), (1, 1), (1, 2), (2, 3)),
          ((0, 0), (0, 1), (0, 2), (1, 2), (2, 2)), ((0, 1), (1, 0), (2, 1), (3, 0)))   # fissures (ligne, colonne)
def pierres_cars(S, F, T, O):
    """style "pierres" (comme la version Macintosh) : memes 48 places que les briques (0-15 joints, 16-31
    haut, 32-47 bas). Pierre blanche ; mortier noir (ligne 0 du haut, colonne(s) du joint) ; ombre en damier
    cale sur l'ecran (O lignes en bas, O colonnes a gauche du joint) ; coins arrondis contre le joint ;
    une fissure (chevron ou trait) sur F % des caracteres. Meme calcul dans atelier_decor.html."""
    out = []
    for n in range(48):
        x = [(S * 7919 + n * 104729 + 12345) & 0xFFFFFFFF]
        def r(m):
            x[0] = (x[0] * 1664525 + 1013904223) & 0xFFFFFFFF
            return (x[0] >> 16) % m
        if n < 16: part = n & 1; p = 1 + r(6); w = 2 if r(100) < T else 1
        else: part = (n - 16) >> 4; p = None; w = 0
        dam = lambda y, b: 1 if (y + b) & 1 == 0 else 0
        g = [[1] * 8 for _ in range(10)]
        if part == 0: g[0] = [0] * 8
        else:
            for y in range(10 - O, 10):
                for b in range(8): g[y][b] = dam(y, b)
        if p is not None:
            for y in range(10):
                if part == 0 and y == 0: continue
                for b in range(max(0, p - O), p): g[y][b] = dam(y, b)
                for b in range(p, min(8, p + w)): g[y][b] = 0
            yc = 1 if part == 0 else 9
            for b in (p - 1, p + w):
                if 0 <= b < 8: g[yc][b] = 0
        face = [(y, b) for y in range(2 if part == 0 else 0, 9 - O if part == 1 else 9) for b in range(8)
                if g[y][b] and (p is None or b < p - O - 1 or b > p + w)]
        dedans = set(face)
        if face and r(100) < F:
            f = FORMES[r(len(FORMES))]
            for _ in range(8):
                y, b = face[r(len(face))]
                pts = [(y + dy, b + dx) for dy, dx in f]
                if all(q in dedans for q in pts):
                    for yy, bb in pts: g[yy][bb] = 0
                    break
        out.append(tuple(sum(g[y][b] << (7 - b) for b in range(8)) for y in range(10)))
    return out
def murs_cars(S, D, T, E=4, style=0):
    """les 48 caracteres (generateur BAGC1, hors des 126 du decor) : 0-15 joints (variante v = n//2,
    haut/bas = n%2), 16-31 briques pleines (haut), 32-47 (bas). Haut de brique : la ligne 0 est le mortier. Sur chaque caractere, au hasard : 0 a E
    eclats (1 a 3 points noirs collees au mortier : briques ebrechees) et 0 a D points noirs isoles.
    Meme calcul dans atelier_decor.html (generateur 32 bits identique). style 1 : pierres_cars."""
    if style == 1: return pierres_cars(S, D, T, E)
    out = []
    for n in range(48):
        x = [(S * 7919 + n * 104729 + 12345) & 0xFFFFFFFF]
        def r(m):
            x[0] = (x[0] * 1664525 + 1013904223) & 0xFFFFFFFF
            return (x[0] >> 16) % m
        if n < 16:
            part = n & 1; p = r(7); w = 2 if r(100) < T else 1
            mask = sum(0x80 >> (p + k) for k in range(w))
        else:
            part = (n - 16) >> 4; mask = 0
        g = [[(0xFF & ~mask) >> (7 - b) & 1 for b in range(8)] for y in range(10)]
        if part == 0: g[0] = [0] * 8
        V = ((-1, 0), (1, 0), (0, -1), (0, 1))
        def bord(y, b):                           # une case allumee contre le mortier (ou le bas de la brique)
            if part == 1 and y == 9: return True
            return any(0 <= y + dy < 10 and 0 <= b + db < 8 and not g[y + dy][b + db] for dy, db in V)
        allum = [(y, b) for y in range(10) for b in range(8) if g[y][b]]
        bords = [q for q in allum if bord(*q)]; dedans = [q for q in allum if not bord(*q)]
        h = [ligne[:] for ligne in g]
        for _ in range(r(E + 1) if bords else 0):  # eclats
            y, b = bords[r(len(bords))]; h[y][b] = 0; pts = [(y, b)]
            for _ in range(r(3)):
                c = [(yy + dy, bb + db) for yy, bb in pts for dy, db in V
                     if 0 <= yy + dy < 10 and 0 <= bb + db < 8 and h[yy + dy][bb + db]]
                if not c: break
                yy, bb = c[r(len(c))]; h[yy][bb] = 0; pts.append((yy, bb))
        for _ in range(r(D + 1) if dedans else 0):  # points isoles
            y, b = dedans[r(len(dedans))]; h[y][b] = 0
        out.append(tuple(sum(h[y][b] << (7 - b) for b in range(8)) for y in range(10)))
    return out
def mur_n(room, ti, rc, S):
    """le caractere (0-47) a la place rc (ligne x 4 + colonne) de la case ti (etage x 10 + case)"""
    x = RND[(room * 29 + ti * 13 + S + (rc >> 3) * 71) & 255]
    part = (rc >> 2) & 1
    if (rc & 3) == (x & 3): return ((x >> 4) & 0x0E) + part
    return 16 + part * 16 + (RND[(x + (rc & 3) * 53 + part * 97) & 255] & 15)

def ecrire_texte(path, cars, blocs, salles, depart, source, liens=(), pics=(), gardes=(), portes=(), entree=None):
    usage = {}                                    # ou sert chaque bloc : le type de case le plus frequent
    for r, (bl, ty, _) in salles.items():
        for b, t in zip(bl, ty): usage.setdefault(b, {}); usage[b][t] = usage[b].get(t, 0) + 1
    with open(path, 'w', encoding='utf-8') as f:
        f.write("""# niveau.txt -- un niveau de prince_jeu, en clair. %s
#   python3 niveau2exl.py niveau.txt        -> prince_niveau.cram et niveau.png
#
# depart SALLE ETAGE CASE      (etage 0 en haut ; case 0 a gauche)
# car N    : un caractere, 10 lignes de 8 points (# allume, . eteint). 252 au plus.
# bloc N   : une case du jeu, 6 lignes de 4 numeros de caractere (0 = vide). 255 au plus.
#            La 6e ligne est celle du sol : le personnage marche sur son bord haut.
# salle N voisines G D H B     (numeros des salles voisines, 0 = aucune), puis
#   3 lignes de 10 numeros de bloc : l'IMAGE de la salle, etage par etage ;
#   3 lignes de 10 types de case   : la LOGIQUE (le moteur ne regarde que ca).
#   Types : %s
#   L'image et la logique sont independantes : a vous de les garder d'accord.
# bouton SALLE ETAGE CASE -> SALLE ETAGE CASE : ce bouton (bouton_ouvre ou bouton_ferme) commande cette
#   grille (grille : fermee au depart ; grille_ouverte), ou la porte de sortie (sortie_g, avec un
#   bouton_ouvre). Une ligne par grille commandee.
#   Les images de la grille qui monte et du bouton enfonce sont fabriquees a la compilation.
# garde SALLE ETAGE CASE gauche|droite NIVEAU PV : le garde de la salle (un au plus), tourne de ce cote,
#   son niveau d'escrime (0 a 3) et ses points de vie.
# pics BLOC -> BLOC : une case de pics qui a la premiere image prend la seconde quand ils sortent.
# porte SALLE ETAGE CASE ouverte BLOC BLOC : la porte de sortie (sortie_g ; sortie_d a sa droite), et les
#   images grande ouverte des deux cases a sa droite (le battant y est dessine, comme dans le jeu). Le bouton qui l'ouvre la fait monter ; ouverte, "haut"
#   devant elle finit le niveau.
# entree bouton SALLE ETAGE CASE : a chaque depart du niveau, le jeu appuie lui-meme sur ce bouton (niveau 1
#   du jeu : le prince entre en tombant et la grille de la salle 5 se ferme).
# murs GRAINE POINTS EPAIS [ECLATS] : les cases mur dessinees par le moteur (briques blanches, joints)
#   au lieu de leurs blocs. GRAINE 0-255 : le tirage ; POINTS 0-20 : au plus autant de points noirs isoles
#   par caractere ; EPAIS 0-100 : part des joints de 2 points ; ECLATS 0-20 (4 si absent) : au plus autant
#   d'ecornures contre le mortier par caractere. Sans cette ligne : les blocs.
# murs pierres GRAINE FISSURES EPAIS OMBRE : le meme placement, en pierres facon Macintosh (pierre blanche,
#   joint noir, ombre en damier en bas et a droite, coins arrondis). FISSURES 0-100 : part des caracteres
#   qui ont une fissure ; EPAIS 0-100 : part des joints de 2 points ; OMBRE 1-4 : largeur de l'ombre.
# fragile BLOC -> BLOC BLOC [TEMPO] : une case fragile qui a la premiere image tremble en montrant la 2e,
#   la 3e, puis la 1re (quand le prince arrive sur son etage, retombe sur cet etage, ou s'arrete dessus).
#   TEMPO : chaque image dure autant de pas (1 a 8, 2 si absent ; le meme pour toutes). 14 lignes au plus.
#   Les autres blocs de sol fragile du niveau prennent tout seuls l'animation de la 1re ligne (ses retouches).
# enfonce SALLE ETAGE CASE BLOC [BLOC] : les images de ce bouton enfonce (sinon un sol nu du niveau) et de sa
#   voisine de droite, ou sa dalle deborde (l'atelier les fait : case bouton, « Bouton en perspective »).
# flamme HG HD BG BD : les 4 caracteres (haut gauche, haut droite, bas gauche, bas droite) de la flamme des
#   torches ; le moteur y recopie a chaque pas une des 9 images de la flamme du jeu (lignes 2 a 19 du carre).
#   Tout caractere de ces 4 numeros s'anime, partout : a ne pas employer ailleurs.
# bulle CAR : le caractere des bulles des potions ; le moteur y recopie tour a tour les 7 images des bulles du jeu
#   (tout ce caractere : a ne pas employer ailleurs).
# couleur CAR COULEUR : ce caractere du decor, partout, dans cette couleur (noir rouge vert jaune bleu magenta cyan
#   blanc) au lieu du blanc ; 7 lignes au plus. La ou passe le prince, la case prend sa couleur a lui.
# plafond BLOC : un plafond mince (la ligne au-dessus de la salle) : chaque case non vide y prend le caractere
#   de sa colonne (0-3) dans la 6e rangee de ce bloc (par exemple un joint puis 3 dalles). Sans : le bas des blocs.
# debris BLOC : l'image de la case de sol ou se pose une dalle fragile tombee (elle devient des debris ;
#   sinon, le bloc de debris le plus courant du niveau).
# tombe SALLE ETAGE CASE BLOC : l'image de ce sol fragile une fois tombe (sinon, choisie par niveau2exl.py :
#   le trou le plus courant du niveau a cote d'une case comme sa voisine de gauche).
# Les numeros doivent se suivre a partir de 1. Tout ce qui suit un # est un commentaire.

""" % (source, " ".join(NOMS[k] for k in sorted(NOMS))))
        f.write("depart %d %d %d\n\n" % depart)
        for i, c in enumerate(cars):
            f.write("car %d\n" % (i + 1) + "".join("".join('#' if v >> (7 - k) & 1 else '.' for k in range(8)) + "\n" for v in c) + "\n")
        for i, b in enumerate(blocs):
            u = usage.get(i + 1)
            com = ("   # surtout : %s (%d fois en tout)" % (NOMS.get(max(u, key=u.get), '?'), sum(u.values()))) if u else "   # inutilise"
            f.write("bloc %d%s\n" % (i + 1, com) + "".join(" ".join("%3d" % v for v in b[j:j + 4]) + "\n" for j in range(0, 24, 4)) + "\n")
        for r in sorted(salles):
            bl, ty, vo = salles[r]
            f.write("salle %d voisines %d %d %d %d\n" % ((r,) + tuple(vo)))
            for e in range(3): f.write(" ".join("%3d" % v for v in bl[e * 10:e * 10 + 10]) + "\n")
            for e in range(3): f.write(" ".join(NOMS.get(v, str(v)) for v in ty[e * 10:e * 10 + 10]) + "\n")
            f.write("\n")
        for b, g in liens: f.write("bouton %d %d %d -> %d %d %d\n" % (b + g))
        for p in pics: f.write("pics %d -> %d\n" % tuple(p))
        for g in gardes: f.write("garde %d %d %d %s %d %d\n" % (g[0], g[1], g[2], 'gauche' if g[3] else 'droite', g[4], g[5]))
        for k, og, od in portes: f.write("porte %d %d %d ouverte %d %d\n" % (k + (og, od)))
        if entree: f.write("entree bouton %d %d %d\n" % tuple(entree))
        if MURS: f.write("murs %s%s\n" % ("pierres " if len(MURS) > 4 and MURS[4] == 1 else "", " ".join(str(v) for v in MURS[:4])))
        for v in FRAGA: f.write("fragile %d -> %d %d %d\n" % (tuple(v) + (FTEMPO[0],)))
        for k in sorted(TOMBE): f.write("tombe %d %d %d %d\n" % (k + (TOMBE[k],)))
        if DEBRIS[0] is not None: f.write("debris %d\n" % DEBRIS[0])
        if PLAFOND[0] is not None: f.write("plafond %d\n" % PLAFOND[0])
        for c in sorted(COULEURS): f.write("couleur %d %s\n" % (c, NOMS_COUL[COULEURS[c]]))
        if FLAMME[0]: f.write("flamme %d %d %d %d\n" % tuple(FLAMME[0]))
        if BULLE[0]: f.write("bulle %d\n" % BULLE[0])
        for k in sorted(ENFONCE): f.write("enfonce %d %d %d %d%s\n" % (k + (ENFONCE[k][0],) + ((" %d" % ENFONCE[k][1]) if ENFONCE[k][1] is not None else "",)))

def lire_texte(path):
    points = lambda l: len(l.strip()) == 8 and not set(l.strip()) - set('#.')      # une ligne de caractere
    L = [l.strip() if points(l) else l.split('#', 1)[0].rstrip() for l in open(path, encoding='utf-8').read().split('\n')]
    cars = []; blocs = []; salles = {}; depart = None; liens = []; pics = []; gardes = []; portes = []; entree = None; i = 0
    def err(msg): raise ValueError("%s ligne %d : %s" % (path, i + 1, msg))
    def suivante():
        nonlocal i
        i += 1
        while i < len(L) and L[i].strip() == '': i += 1
        if i >= len(L): err("fin de fichier inattendue")
        return L[i]
    def nombres(l, n, maxi, quoi):
        try: v = [int(x) for x in l.split()]
        except ValueError: err("attendu : %d numeros de %s" % (n, quoi))
        if len(v) != n: err("attendu : %d numeros de %s, trouve %d" % (n, quoi, len(v)))
        for x in v:
            if not 0 <= x <= maxi: err("%s %d inconnu (de 0 a %d)" % (quoi, x, maxi))
        return v
    lus = []                                      # les blocs et salles sont verifies a la fin : tout est alors connu
    while i < len(L):
        m = L[i].split()
        if not m: i += 1; continue
        if m[0] == 'depart' and len(m) == 4: depart = tuple(int(x) for x in m[1:]); i += 1
        elif m[0] == 'car':
            if len(m) != 2 or int(m[1]) != len(cars) + 1: err("attendu : car %d" % (len(cars) + 1))
            rows = []
            for _ in range(10):
                r = suivante().strip()
                if len(r) != 8 or set(r) - set('#.'): err("un caractere a 10 lignes de 8 points # ou .")
                rows.append(sum(1 << (7 - k) for k in range(8) if r[k] == '#'))
            cars.append(tuple(rows)); i += 1
        elif m[0] == 'bloc':
            if len(m) != 2 or int(m[1]) != len(blocs) + 1: err("attendu : bloc %d" % (len(blocs) + 1))
            b = []
            for _ in range(6): b += nombres(suivante(), 4, 252, "caractere")
            lus.append((i, 'bloc', b)); blocs.append(b); i += 1
        elif m[0] == 'salle':
            if len(m) != 7 or m[2] != 'voisines': err("attendu : salle N voisines G D H B")
            r = int(m[1]); vo = tuple(int(x) for x in m[3:])
            if not 1 <= r <= 24 or r in salles: err("numero de salle de 1 a 24, une seule fois")
            bl = []
            for _ in range(3): bl += nombres(suivante(), 10, 255, "bloc")
            ty = []
            for _ in range(3):
                mots = suivante().split()
                if len(mots) != 10: err("attendu : 10 types de case")
                for x in mots:
                    if x in TYPES: ty.append(TYPES[x])
                    elif x.isdigit() and int(x) < 256: ty.append(int(x))
                    else: err("type de case inconnu : %s" % x)
            lus.append((i, 'salle', bl)); salles[r] = (bl, ty, vo); i += 1
        elif m[0] == 'bouton':
            try:
                v = [int(x) for x in m[1:4] + m[5:8]]
                if len(m) != 8 or m[4] != '->': raise ValueError
            except ValueError: err("attendu : bouton SALLE ETAGE CASE -> SALLE ETAGE CASE")
            lus.append((i, 'bouton', v)); liens.append((tuple(v[:3]), tuple(v[3:]))); i += 1
        elif m[0] == 'pics':
            if len(m) != 4 or m[2] != '->' or not (m[1].isdigit() and m[3].isdigit()): err("attendu : pics BLOC -> BLOC")
            lus.append((i, 'pics', [int(m[1]), int(m[3])])); pics.append((int(m[1]), int(m[3]))); i += 1
        elif m[0] == 'garde':
            try:
                if len(m) != 7 or m[4] not in ('gauche', 'droite'): raise ValueError
                g = (int(m[1]), int(m[2]), int(m[3]), m[4] == 'gauche', int(m[5]), int(m[6]))
                if not (1 <= g[0] <= 24 and 0 <= g[1] <= 2 and 0 <= g[2] <= 9 and 0 <= g[4] <= 7 and 1 <= g[5] <= 15): raise ValueError
            except ValueError: err("attendu : garde SALLE ETAGE CASE gauche|droite NIVEAU(0-7) PV(1-15)")
            if any(x[0] == g[0] for x in gardes): err("salle %d : un seul garde par salle" % g[0])
            gardes.append(g); i += 1
        elif m[0] == 'porte':
            try:
                if len(m) != 7 or m[4] != 'ouverte': raise ValueError
                v = [int(x) for x in m[1:4] + m[5:7]]
            except ValueError: err("attendu : porte SALLE ETAGE CASE ouverte BLOC BLOC")
            lus.append((i, 'porte', v)); portes.append((tuple(v[:3]), v[3], v[4])); i += 1
        elif m[0] == 'murs':
            global MURS
            if len(m) > 1 and m[1] == 'pierres':
                try:
                    if len(m) != 6: raise ValueError
                    MURS = tuple(int(x) for x in m[2:]) + (1,)
                    if not (0 <= MURS[0] <= 255 and 0 <= MURS[1] <= 100 and 0 <= MURS[2] <= 100 and 1 <= MURS[3] <= 4): raise ValueError
                except ValueError: err("attendu : murs pierres GRAINE(0-255) FISSURES(0-100) EPAIS(0-100) OMBRE(1-4)")
            else:
              try:
                if len(m) not in (4, 5): raise ValueError
                MURS = tuple(int(x) for x in m[1:])
                if not (0 <= MURS[0] <= 255 and 0 <= MURS[1] <= 20 and 0 <= MURS[2] <= 100 and (len(MURS) < 4 or 0 <= MURS[3] <= 20)): raise ValueError
              except ValueError: err("attendu : murs GRAINE(0-255) POINTS(0-20) EPAIS(0-100) [ECLATS(0-20)], ou murs pierres GRAINE FISSURES(0-100) EPAIS(0-100) OMBRE(1-4)")
            i += 1
        elif m[0] == 'enfonce':
            if len(m) not in (5, 6) or not all(x.isdigit() for x in m[1:]): err("attendu : enfonce SALLE ETAGE CASE BLOC [BLOC_DE_LA_VOISINE]")
            v = [int(x) for x in m[1:]]
            lus.append((i, 'enfonce', v)); ENFONCE[tuple(v[:3])] = (v[3], v[4] if len(v) > 4 else None); i += 1
        elif m[0] == 'bulle':
            if len(m) != 2 or not m[1].isdigit(): err("attendu : bulle CARACTERE")
            lus.append((i, 'bulle', [int(m[1])])); BULLE[0] = int(m[1]); i += 1
        elif m[0] == 'flamme':
            if len(m) != 5 or not all(x.isdigit() for x in m[1:]): err("attendu : flamme HAUT_GAUCHE HAUT_DROITE BAS_GAUCHE BAS_DROITE (4 caracteres)")
            v = [int(x) for x in m[1:]]
            lus.append((i, 'flamme', v)); FLAMME[0] = v; i += 1
        elif m[0] == 'couleur':
            if len(m) != 3 or not m[1].isdigit() or not (m[2] in NOMS_COUL or m[2].isdigit() and int(m[2]) < 8):
                err("attendu : couleur CARACTERE COULEUR (%s, ou 0-7)" % " ".join(NOMS_COUL))
            v = [int(m[1]), NOMS_COUL.index(m[2]) if m[2] in NOMS_COUL else int(m[2])]
            lus.append((i, 'couleur', v)); COULEURS[v[0]] = v[1]; i += 1
        elif m[0] == 'plafond':
            if len(m) != 2 or not m[1].isdigit(): err("attendu : plafond BLOC")
            lus.append((i, 'plafond', [int(m[1])])); PLAFOND[0] = int(m[1]); i += 1
        elif m[0] == 'debris':
            if len(m) != 2 or not m[1].isdigit(): err("attendu : debris BLOC")
            lus.append((i, 'debris', [int(m[1])])); DEBRIS[0] = int(m[1]); i += 1
        elif m[0] == 'tombe':
            if len(m) != 5 or not all(x.isdigit() for x in m[1:]): err("attendu : tombe SALLE ETAGE CASE BLOC")
            v = [int(x) for x in m[1:]]
            lus.append((i, 'tombe', v)); TOMBE[tuple(v[:3])] = v[3]; i += 1
        elif m[0] == 'fragile':
            if len(m) not in (5, 6) or m[2] != '->' or not all(x.isdigit() for x in m[1:2] + m[3:]): err("attendu : fragile BLOC -> BLOC BLOC [TEMPO]")
            v = [int(m[1]), int(m[3]), int(m[4])]
            if len(m) == 6:
                if not 1 <= int(m[5]) <= 8: err("fragile : TEMPO de 1 a 8 (pas par image)")
                FTEMPO[0] = int(m[5])
            if any(q[0] == v[0] for q in FRAGA): err("fragile : le bloc %d a deja son animation" % v[0])
            lus.append((i, 'fragile', v)); FRAGA.append(tuple(v)); i += 1
        elif m[0] == 'entree':
            try:
                if len(m) != 5 or m[1] != 'bouton': raise ValueError
                entree = tuple(int(x) for x in m[2:5])
            except ValueError: err("attendu : entree bouton SALLE ETAGE CASE")
            lus.append((i, 'entree', list(entree))); i += 1
        else: err("attendu : depart, car, bloc, salle, bouton, pics, garde, porte, entree, murs, fragile, tombe, debris ou enfonce")
    for ligne, quoi, v in lus:
        i = ligne
        if quoi == 'bloc' and max(v) > len(cars): err("ce bloc utilise le caractere %d, qui n'existe pas" % max(v))
        if quoi == 'salle' and max(v) > len(blocs): err("cette salle utilise le bloc %d, qui n'existe pas" % max(v))
        if quoi == 'pics' and not (1 <= min(v) and max(v) <= len(blocs)): err("pics : le bloc %d n'existe pas" % (max(v) if max(v) > len(blocs) else min(v)))
        if quoi == 'enfonce':
            r, e, c = v[:3]
            if r not in salles or not 0 <= e <= 2 or not 0 <= c <= 9 or salles[r][1][e * 10 + c] & 0x1F not in (6, 15): err("enfonce : la case %d %d %d n'est pas un bouton" % (r, e, c))
            if max(v[3:]) > len(blocs): err("enfonce : le bloc %d n'existe pas" % max(v[3:]))
        if quoi == 'debris' and not 1 <= v[0] <= len(blocs): err("debris : le bloc %d n'existe pas" % v[0])
        if quoi == 'plafond' and not 1 <= v[0] <= len(blocs): err("plafond : le bloc %d n'existe pas" % v[0])
        if quoi == 'flamme' and not all(1 <= c <= len(cars) for c in v): err("flamme : un de ces caracteres n'existe pas")
        if quoi == 'bulle' and not 1 <= v[0] <= len(cars): err("bulle : le caractere %d n'existe pas" % v[0])
        if quoi == 'couleur':
            if not 1 <= v[0] <= len(cars): err("couleur : le caractere %d n'existe pas" % v[0])
            if len(COULEURS) > 7: err("couleur : 7 caracteres au plus")
        if quoi == 'tombe':
            r, e, c, b = v
            if r not in salles or not 0 <= e <= 2 or not 0 <= c <= 9 or salles[r][1][e * 10 + c] & 0x1F != 11: err("tombe : la case %d %d %d n'est pas un sol fragile" % (r, e, c))
            if b > len(blocs): err("tombe : le bloc %d n'existe pas" % b)
        if quoi == 'fragile' and not (1 <= min(v) and max(v) <= len(blocs)): err("fragile : le bloc %d n'existe pas" % (max(v) if max(v) > len(blocs) else min(v)))
        if quoi == 'entree':
            r, e, c = v
            if r not in salles or not 0 <= e <= 2 or not 0 <= c <= 9 or salles[r][1][e * 10 + c] & 0x1F not in (6, 15):
                err("entree : salle %d etage %d case %d n'est pas un bouton" % (r, e, c))
        if quoi == 'porte':
            r, e, c = v[:3]
            if r not in salles or not 0 <= e <= 2 or not 0 <= c <= 9 or salles[r][1][e * 10 + c] & 0x1F != 16:
                err("salle %d etage %d case %d : attendu une case sortie_g" % (r, e, c))
            if not (1 <= min(v[3:]) and max(v[3:]) <= len(blocs)): err("porte : bloc inexistant")
        if quoi == 'bouton':
            for (r, e, c), noms in ((v[:3], ('bouton_ouvre', 'bouton_ferme')), (v[3:], ('grille', 'grille_ouverte', 'sortie_g'))):
                if r not in salles or not 0 <= e <= 2 or not 0 <= c <= 9: err("salle %d etage %d case %d : cette case n'existe pas" % (r, e, c))
                if NOMS.get(salles[r][1][e * 10 + c] if salles[r][1][e * 10 + c] != 0xA4 else 0xA4) not in noms:
                    err("salle %d etage %d case %d : attendu une case %s" % (r, e, c, " ou ".join(noms)))
    i = len(L) - 1
    if len(cars) > MAXT: err("%d caracteres : %d au plus" % (len(cars), MAXT))
    if len(blocs) > 255: err("%d blocs : 255 au plus" % len(blocs))
    if not salles: err("aucune salle")
    for r, (_, _, vo) in salles.items():
        for n in vo:
            if n and n not in salles: err("la salle %d a pour voisine la salle %d, qui n'existe pas" % (r, n))
    if depart is None: depart = (min(salles), 1, 0)
    if depart[0] not in salles or not 0 <= depart[1] <= 2 or not 0 <= depart[2] <= 9: err("depart : salle existante, etage 0-2, case 0-9")
    if len(pics) > 15: err("%d images de pics : 15 au plus" % len(pics))
    if len(FRAGA) > 14: err("%d animations de sol fragile : 14 au plus" % len(FRAGA))
    return cars, blocs, salles, depart, liens, pics, gardes, portes, entree

def importer(a):
    """niveau de SDLPoP + plan -> modele"""
    d = open(os.path.join(a.source, 'data', 'LEVELS', 'res%d.bin' % (2000 + a.niveau)), 'rb').read()
    fg = d[0:720]; bg = d[720:1440]; dl1 = d[1440:1696]; dl2 = d[1696:1952]
    liens = {r + 1: tuple(d[1952 + 4 * r:1956 + 4 * r]) for r in range(24)}   # gauche, droite, haut, bas
    typ = lambda r, e, c: fg[(r - 1) * 30 + e * 10 + c] & 0x1F
    pos = placer({r: (None, None, liens[r]) for r in liens}, d[2112])
    w, h, px = png_read(a.plan)
    nc = max(p[0] for p in pos.values()) + 1; nr = max(p[1] for p in pos.values()) + 1
    if w < 320 * nc or h < 189 * nr:
        raise ValueError("%s fait %d x %d points : le plan du niveau %d devrait faire au moins %d x %d. Est-ce le bon niveau ?" % (a.plan, w, h, a.niveau, 320 * nc, 189 * nr))
    # --trames : chaque couleur prend une trame selon sa luminosite (noir, 25, 50, 75 % ou blanc), calee sur
    # la grille des caracteres (periode 2 : une surface unie donne partout le meme caractere) ; sinon un seuil
    TR = [int(v) for v in a.trames.split(',')] if a.trames else None
    if TR and (len(TR) != 4 or TR != sorted(TR)): raise ValueError("--trames : 4 luminosites croissantes (0-255), par exemple 55,60,80,95")
    def ton(r, g, b, al, dx, dy):
        if al < 128: return 0
        lum = (299 * r + 587 * g + 114 * b) // 1000
        if not TR: return 1 if lum * 100 >= a.seuil * 255 else 0
        n = sum(lum >= t for t in TR)
        return (0, 1 if not (dx | dy) & 1 else 0, 1 if (dx + dy) & 1 == 0 else 0, 0 if dx & dy & 1 else 1, 1)[n]
    def allume(x, y, dx=0, dy=0):
        if x >= w or y >= h: return 0
        return ton(*px[y][x], dx, dy)
    VIDE = (0,) * 10; compte = {}; brut = {}
    for r, (C, R) in pos.items():
        ox, oy = 320 * C, 189 * R; bl = []
        for e in range(3):
            for c in range(10):
                b = []
                for cy in range(6):
                    for cx in range(4):
                        ch = tuple(sum(allume(ox + c * 32 + cx * 8 + k, oy + 3 + 63 * e + GARDE[cy * 10 + yl], k, yl) << (7 - k) for k in range(8)) for yl in range(10))
                        b.append(ch)                  # (avec --trames, les murs seront generes : leurs caracteres passent en dernier)
                        if ch != VIDE: compte[ch] = compte.get(ch, 0) + (0 if TR and typ(r, e, c) == 20 else 1)
                bl.append(b)
        brut[r] = bl
    # les pics sortis ne sont pas sur le plan : on pose les images du jeu (pics de derriere et de devant, sortis en
    # entier) sur l'image de la case. Leurs caracteres comptent double pour ne pas etre confondus avec d'autres.
    sortis = {}
    try: lutins = [png_read(os.path.join(a.source, 'data', 'VDUNGEON', 'res%d.png' % n)) for n in (331, 342)]
    except OSError: lutins = []; print("images des pics introuvables dans %s : ils ne sortiront pas" % os.path.join(a.source, 'data', 'VDUNGEON'))
    for r in brut:
        for i in range(30):
            if typ(r, i // 10, i % 10) != 2 or not lutins: continue
            pt = [[brut[r][i][(y // 10) * 4 + x // 8][y % 10] >> (7 - x % 8) & 1 for x in range(32)] for y in range(60)]
            for passe in (0, 1):                  # d'abord un lisere noir de chaque cote (pour les voir sur du blanc), puis les pics
                for sw, sh, spx in lutins:        # coin bas gauche : le bord gauche de la case, 2 lignes au-dessus du sol
                    for sy in range(sh):
                        for sx in range(min(sw, 32)):
                            cr, cg, cb, al = spx[sy][sx]; y = 54 - (sh - 1) + sy
                            if al < 128 or not 0 <= y < 60: continue
                            if passe: pt[y][sx] = ton(cr, cg, cb, 255, sx, y % 10)
                            else:
                                for x in (sx - 1, sx + 1):
                                    if 0 <= x < 32: pt[y][x] = 0
            b = [tuple(sum(pt[cy * 10 + yl][cx * 8 + k] << (7 - k) for k in range(8)) for yl in range(10)) for cy in range(6) for cx in range(4)]
            sortis[(r, i)] = b
            for ch in b:
                if ch != VIDE: compte[ch] = compte.get(ch, 0) + 1000
    # la porte de sortie (pas l'entree, dans la salle de depart du niveau) : le plan la montre fermee. Son image
    # grande ouverte : l'escalier du jeu (data/VDUNGEON res344, res299) peint a la place du battant, comme le
    # fait le jeu : il dessine la porte avec la case de DROITE (sortie_d), a 8 points de son bord gauche ;
    # elle deborde sur la case suivante. Ce sont ces deux cases qui changent d'image.
    ouverts = {}; portes_imp = []
    try: esc = [png_read(os.path.join(a.source, 'data', 'VDUNGEON', 'res%d.png' % n)) for n in (344, 299)]
    except OSError: esc = []; print("images de l'escalier introuvables dans %s : la porte de sortie ne s'ouvrira pas" % os.path.join(a.source, 'data', 'VDUNGEON'))
    def tuile(rr, e, cc):
        C, R = pos[rr]
        return [[allume(320 * C + cc * 32 + x, 189 * R + 3 + 63 * e + y, x, GARDE.index(y) % 10 if y in GARDE else 0) for x in range(32)] for y in range(63)]
    for r in brut:
        if r == d[2112] or not esc: continue
        for e in range(3):
            for c in range(10):
                if typ(r, e, c) != 16: continue
                r1, c1 = (r, c + 1) if c < 9 else (liens[r][1], 0)
                if r1 not in brut: continue
                r2, c2 = (r1, c1 + 1) if c1 < 9 else (liens[r1][1], 0)
                if r2 not in brut: continue
                pix = [u + v for u, v in zip(tuile(r1, e, c1), tuile(r2, e, c2))]
                for (sw, sh, spx), bas in zip(esc, (42, 46)):
                    for sy in range(sh):
                        y = bas - (sh - 1) + sy
                        if not 0 <= y < 63: continue
                        for sx in range(sw):
                            if 8 + sx >= 64: break
                            cr, cg, cb, al = spx[sy][sx]
                            pix[y][8 + sx] = ton(cr, cg, cb, al, 8 + sx, GARDE.index(y) % 10 if y in GARDE else 0)
                for rr, cc, x0 in ((r1, c1, 0), (r2, c2, 32)):
                    b = [tuple(sum(pix[GARDE[cy * 10 + yl]][x0 + cx * 8 + k] << (7 - k) for k in range(8)) for yl in range(10)) for cy in range(6) for cx in range(4)]
                    ouverts[(rr, e * 10 + cc)] = b
                    for ch in b:
                        if ch != VIDE: compte[ch] = compte.get(ch, 0) + 1000
                portes_imp.append(((r, e, c), (r1, e * 10 + c1), (r2, e * 10 + c2)))
    # les potions : la fiole est sombre et disparait au seuil. On la repose en blanc, avec un lisere noir.
    # L'epee aussi (posee a plat, au bord gauche de la case, son bas 3 lignes au-dessus du bas de la case du jeu).
    try: fioles = [png_read(os.path.join(a.source, 'data', 'PRINCE', 'res%d.png' % n)) for n in (162, 163, 160)]
    except OSError: fioles = []
    for r in brut:
        for i in range(30):
            if typ(r, i // 10, i % 10) not in (10, 22) or not fioles: continue
            pt = [[brut[r][i][(y // 10) * 4 + x // 8][y % 10] >> (7 - x % 8) & 1 for x in range(32)] for y in range(60)]
            if typ(r, i // 10, i % 10) == 22: sw, sh, spx = fioles[2]; x0 = 0
            else: sw, sh, spx = fioles[1 if 2 <= bg[(r - 1) * 30 + i] & 7 <= 4 else 0]; x0 = 22
            plein = [(x0 + sx, 53 - (sh - 1) + sy) for sy in range(sh) for sx in range(sw) if spx[sy][sx][3] >= 128]
            for x, y in plein:
                for u, v in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                    if 0 <= u < 32 and 0 <= v < 60: pt[v][u] = 0
            for x, y in plein:
                if 0 <= x < 32 and 0 <= y < 60: pt[y][x] = 1
            b = [tuple(sum(pt[cy * 10 + yl][cx * 8 + k] << (7 - k) for k in range(8)) for yl in range(10)) for cy in range(6) for cx in range(4)]
            brut[r][i] = b
            for ch in b:
                if ch != VIDE: compte[ch] = compte.get(ch, 0) + 1000
    # 126 caracteres au plus pour tout le niveau : les plus rares sont confondus avec leur plus proche voisin
    vivants = sorted(compte, key=lambda t: -compte[t]); rempl = {}; perdus = 0
    dist = lambda p, q: sum(bin(x ^ y).count('1') for x, y in zip(p, q))
    while len(vivants) > MAXT:
        t = vivants.pop(); rempl[t] = min(vivants, key=lambda u: dist(t, u)); perdus += 1
    def final(t):
        while t in rempl: t = rempl[t]
        return t
    num = {t: i + 1 for i, t in enumerate(vivants)}; num[VIDE] = 0
    tbl = {}; blocs = []; salles = {}; paires = []; ouv_id = {}
    for r in sorted(brut):
        ids = []
        for b in brut[r]:
            k = tuple(num[final(ch)] for ch in b)
            if not any(k): ids.append(0); continue
            if k not in tbl: blocs.append(list(k)); tbl[k] = len(blocs)
            ids.append(tbl[k])
        # une grille ouverte au depart (son 2e octet vaut 1) : type $A4
        for i in range(30):
            if (r, i) in sortis:
                k = tuple(num[final(ch)] for ch in sortis[(r, i)])
                if k not in tbl: blocs.append(list(k)); tbl[k] = len(blocs)
                if ids[i] and (ids[i], tbl[k]) not in paires: paires.append((ids[i], tbl[k]))
            if (r, i) in ouverts:
                k = tuple(num[final(ch)] for ch in ouverts[(r, i)])
                if k not in tbl: blocs.append(list(k)); tbl[k] = len(blocs)
                ouv_id[(r, i)] = tbl[k]
        nature = lambda e, c: (10 | (bg[(r - 1) * 30 + e * 10 + c] & 7) << 5) if typ(r, e, c) == 10 else typ(r, e, c)   # potion : sa nature
        salles[r] = (ids, [0xA4 if typ(r, e, c) == 4 and bg[(r - 1) * 30 + e * 10 + c] == 1 else nature(e, c) for e in range(3) for c in range(10)],
                     tuple(n if n in pos else 0 for n in liens[r]))
    if len(blocs) > 255: raise ValueError("%d blocs differents : 255 au plus. Essayez un autre --seuil." % len(blocs))
    if a.depart: dep = tuple(int(v) for v in a.depart.split(','))
    else:
        sr, se, sc = d[2112], d[2113] // 10, d[2113] % 10
        for _ in range(12):                       # on descend jusqu'au premier sol
            if typ(sr, se, sc) not in (0, 20): break
            if se < 2: se += 1
            elif liens[sr][3]: sr = liens[sr][3]; se = 0
            else: break
        dep = (sr, se, sc)
    if dep[0] not in salles: raise ValueError("la salle %d n'est pas sur le plan" % dep[0])
    if perdus: print("%d caracteres rares confondus avec un voisin (126 au plus)" % perdus)
    # les boutons : le 2e octet de la case est le debut de sa liste dans la table des portes du niveau
    cmd = []
    for r in sorted(salles):
        for i in range(30):
            if typ(r, i // 10, i % 10) not in (6, 15): continue
            k = bg[(r - 1) * 30 + i]
            for _ in range(32):
                gr = ((dl1[k] & 0x60) >> 5) + ((dl2[k] & 0xE0) >> 3); gt = dl1[k] & 0x1F
                cible = salles[gr][1][gt] & 0x1F if gr in salles and gt < 30 else None
                if cible == 4 or (cible == 16 and typ(r, i // 10, i % 10) == 15 and (gr, gt) in [p[0][0:1] + (p[0][1] * 10 + p[0][2],) for p in portes_imp]):
                    cmd.append(((r, i // 10, i % 10), (gr, gt // 10, gt % 10)))
                if dl1[k] & 0x80 or k == 255: break
                k += 1
    # les gardes : ils sont dessines sur le plan, donc dans le decor. On les y efface : leur case et celle de
    # derriere eux (le jeu les place au bord gauche de la case suivante) prennent l'image la plus courante des
    # cases de meme type, aux memes voisines, ailleurs dans le niveau.
    gardes = []
    for r in sorted(salles):
        t = d[2119 + r - 1]
        if t < 30:
            sk = d[2215 + r - 1]; sk = 3 if sk > 3 else sk
            pv = TBL_PV[a.niveau] if a.niveau < len(TBL_PV) else 3
            gardes.append((r, t // 10, t % 10, d[2143 + r - 1] >= 128, sk, pv))
    def voisine(r, e, c):
        if c < 0: r = liens[r][0]; c = 9
        elif c > 9: r = liens[r][1]; c = 0
        return (r, e, c) if r in salles else None
    cls = lambda k: 'x' if k is None else ('m' if typ(*k) == 20 else 'v' if typ(*k) in (0, 9, 12) else 'p' if typ(*k) == 3 else 's')
    sales = set()
    for g in gardes:
        for dc in (0, 1):
            k = voisine(g[0], g[1], g[2] + dc)
            if k: sales.add(k)
    toutes = [(r, e, c) for r in salles for e in range(3) for c in range(10)]
    for k in sorted(sales):
        cle = lambda q: (typ(*q), cls(voisine(q[0], q[1], q[2] - 1)), cls(voisine(q[0], q[1], q[2] + 1)))
        for f in (lambda q: cle(q) == cle(k), lambda q: typ(*q) == typ(*k)):
            n = {}
            for q in toutes:
                if q not in sales and f(q):
                    b = salles[q[0]][0][q[1] * 10 + q[2]]; n[b] = n.get(b, 0) + 1
            if n:                                 # la plus sobre (le moins de points allumes), puis la plus courante
                viv = list(vivants)
                pts = lambda b: sum(bin(o).count('1') for ch in blocs[b - 1] if ch for o in viv[ch - 1]) if b else 0
                salles[k[0]][0][k[1] * 10 + k[2]] = min(n, key=lambda b: (pts(b), -n[b])); break
    portes = [(k, ouv_id[d1], ouv_id[d2]) for k, d1, d2 in portes_imp if d1 in ouv_id and d2 in ouv_id]
    # l'entree du niveau 1 du jeu (SDLPoP : tbl_entry_pose) : le prince tombe dans la salle de depart et le
    # jeu appuie sur le bouton de la salle 5, etage 0, case 2 (la grille de la salle 5 se ferme)
    entree = (5, 0, 2) if a.niveau == 1 and 5 in salles and salles[5][1][2] & 0x1F in (6, 15) else None
    return list(vivants), blocs, salles, dep, cmd, paires, gardes, portes, entree

def reprendre(chemin, cars, blocs, salles, paires, portes, murs_def):
    """--reprendre ANCIEN.txt : apres un nouvel import, recopie ce qui a ete ajoute a la main dans l'ancien
    niveau : le depart, la ligne murs (si elle est en pierres), les sols fragiles animes, les images une fois
    tombees, les debris, les boutons en perspective. Un bloc de l'ancien niveau devient le bloc que le nouvel
    import met dans les memes cases ; une image derivee (tremblement, bouton releve) garde seulement ses
    retouches (les points qui different de son image de base), posees sur la nouvelle image. Un bloc qui
    n'est dans aucune salle est recopie tel quel. Les retouches de dessin des salles ne sont pas reprises."""
    global MURS
    for v in (FRAGA, TOMBE, ENFONCE): v.clear()
    DEBRIS[0] = None; PLAFOND[0] = None; FTEMPO[0] = 2; MURS = None; COULEURS.clear(); FLAMME[0] = None; BULLE[0] = None
    oc, ob, os_, odep = lire_texte(chemin)[:4]
    COULEURS_LUS = {tuple(oc[c - 1]): v for c, v in COULEURS.items()}; COULEURS.clear()
    FLAMME_LUE = [tuple(oc[c - 1]) for c in FLAMME[0]] if FLAMME[0] else None; FLAMME[0] = None
    BULLE_LUE = tuple(oc[BULLE[0] - 1]) if BULLE[0] else None; BULLE[0] = None
    omurs = MURS; MURS = omurs if omurs and len(omurs) > 4 else murs_def
    FRAGA_LUS = list(FRAGA); TOMBE_LUS = dict(TOMBE); DEBRIS_LU = [DEBRIS[0]]; PLAFOND_LU = [PLAFOND[0]]; ENFONCE_LUS = dict(ENFONCE); FTEMPO_LU = [FTEMPO[0]]
    TOMBE.clear(); ENFONCE.clear(); DEBRIS[0] = None; PLAFOND[0] = None
    VIDE = (0,) * 10
    def pixels(cs, bs, b):                         # bloc -> 60 lignes de 32 points
        g = [[0] * 32 for _ in range(60)]
        if b:
            for k, c in enumerate(bs[b - 1]):
                if not c: continue
                for yl in range(10):
                    v = cs[c - 1][yl]
                    for x in range(8): g[(k >> 2) * 10 + yl][(k & 3) * 8 + x] = v >> (7 - x) & 1
        return g
    num = {t: i + 1 for i, t in enumerate(cars)}
    tbl = {tuple(b): i + 1 for i, b in enumerate(blocs)}
    def bloc_de(g):                                # 60 x 32 points -> numero de bloc (nouveaux caracteres si besoin)
        k = []
        for cell in range(24):
            ch = tuple(sum(g[(cell >> 2) * 10 + yl][(cell & 3) * 8 + x] << (7 - x) for x in range(8)) for yl in range(10))
            if ch == VIDE: k.append(0); continue
            if ch not in num: cars.append(ch); num[ch] = len(cars)
            k.append(num[ch])
        k = tuple(k)
        if not any(k): return 0
        if k not in tbl: blocs.append(list(k)); tbl[k] = len(blocs)
        return tbl[k]
    corr = {}                                      # ancien bloc -> nouveaux blocs aux memes cases
    for r, (ids, ty, _) in os_.items():
        if r not in salles: continue
        for i, b in enumerate(ids):
            if b and (ty[i] & 0x1F) != 20: corr.setdefault(b, []).append(salles[r][0][i])
    def nouveau(b):                                # le bloc qui remplace l'ancien bloc b
        if b in corr: return max(set(corr[b]), key=corr[b].count)
        return bloc_de(pixels(oc, ob, b))
    def retouche(var, base, nb):                   # l'image var (ancienne) a ete faite a partir de base : ses
        A, B, N = pixels(oc, ob, var), pixels(oc, ob, base), pixels(cars, blocs, nb)   # retouches, sur nb
        return bloc_de([[A[y][x] if A[y][x] != B[y][x] else N[y][x] for x in range(32)] for y in range(60)])
    rep = []
    fr = list(FRAGA_LUS); FRAGA[:] = []
    for n0, n1, n2 in fr:
        nn = nouveau(n0); FRAGA.append((nn, retouche(n1, n0, nn), retouche(n2, n0, nn)))
    if fr: rep.append("%d sol(s) fragile(s) anime(s)" % len(fr))
    FTEMPO[0] = FTEMPO_LU[0]
    for k, b in TOMBE_LUS.items(): TOMBE[k] = nouveau(b)
    if TOMBE_LUS: rep.append("%d image(s) une fois tombee(s)" % len(TOMBE_LUS))
    if DEBRIS_LU[0] is not None: DEBRIS[0] = nouveau(DEBRIS_LU[0]); rep.append("le bloc des debris")
    if PLAFOND_LU[0] is not None: PLAFOND[0] = bloc_de(pixels(oc, ob, PLAFOND_LU[0])); rep.append("le plafond")
    rond = lambda v: int(v + 0.5) if v >= 0 else -int(-v + 0.5)
    for (r, e, c) in ENFONCE_LUS:                 # les boutons : refaits sur les nouvelles images, comme
        if r not in salles: continue              # l'outil "Fabriquer" de l'atelier (hauteur 1, pente 1,2,
        ids = salles[r][0]; i = e * 10 + c        # joint droit a 32, joint gauche automatique, enfonce = sol)
        hasd = c < 9; W = 64 if hasd else 32
        bk = ids[i]; bd = ids[i + 1] if hasd else 0
        PK, PD = pixels(cars, blocs, bk), pixels(cars, blocs, bd)
        g = [PK[40 + y] + (PD[40 + y] if hasd else []) for y in range(20)]
        yt = yb = -1
        for y in range(20):
            if any(g[y][:32]):
                if yt < 0: yt = y
                yb = y
            elif yt >= 0: break
        def mr(y):                                # plus longue suite de points allumes (dans la case)
            m = k = 0
            for v in g[y][:32]:
                k = k + 1 if v else 0; m = max(m, k)
            return m
        if yt == 0:                               # decor trame derriere la dalle : la chercher depuis le bas
            yb = max([y for y in range(20) if mr(y) >= 3], default=-1); yt = yb
            while yb >= 0 and yt >= 1 and (mr(yt - 1) >= 3 or (0 < yt - 1 < 19 and mr(yt - 2) >= 3 and mr(yt) >= 3)): yt -= 1
        if yt < 1: print("--reprendre : pas de dalle pour le bouton salle %d etage %d case %d" % (r, e, c)); continue
        J = lambda y: 32 + rond(1.2 * (yb - y))
        if c > 0:
            L = pixels(cars, blocs, ids[i - 1])[40 + yb][31]
        else: L = g[yb][0]
        JL = (lambda y: rond(1.2 * (yb - y))) if L else (lambda y: -1)
        for y in range(yt, yb + 1):
            for x in (JL(y), J(y)):
                if 0 <= x < W: g[y][x] = 0
        up = [l[:] for l in g]
        for y in range(yt, yb + 1):
            for x in range(JL(y) + 1, min(W, J(y))): up[y][x] = 0
        for y in range(yt, yb + 1):
            for x in range(JL(y) + 1, min(W, J(y))):
                if g[y][x]: up[y - 1][x] = 1
        if L:
            for y in range(yt - 1, yb + 1):
                x = JL(y)
                if 0 <= x < W: up[y][x] = 0
        def bloc_haut(grille, base, off):
            P_ = pixels(cars, blocs, base)
            for y in range(20): P_[40 + y] = grille[y][off:off + 32]
            return bloc_de(P_)
        uk = bloc_haut(up, bk, 0); ids[i] = uk; nd = None
        if hasd:
            ud = bloc_haut(up, bd, 32)
            if ud != bd: ids[i + 1] = ud; nd = bd
        ENFONCE[(r, e, c)] = (bk, nd)
    if ENFONCE_LUS: rep.append("%d bouton(s) en perspective" % len(ENFONCE_LUS))
    # 126 caracteres au plus : les plus rares (dans les salles, hors murs generes) rejoignent leur plus proche voisin
    poids = [0] * (len(cars) + 1)
    for r, (ids, ty, _) in salles.items():
        for i, b in enumerate(ids):
            if b and not (MURS and (ty[i] & 0x1F) == 20):
                for c in blocs[b - 1]: poids[c] += 1
    speciaux = [b for v in FRAGA for b in v] + list(TOMBE.values()) + [DEBRIS[0] or 0, PLAFOND[0] or 0] + [b for v in ENFONCE.values() for b in v if b] + \
               [b for v in paires for b in v] + [b for _, og, od in portes for b in (og, od)] + \
               [salles[r][0][e * 10 + c + d] for (r, e, c) in ENFONCE for d in (0, 1) if c + d <= 9]
    for b in speciaux:
        if b:
            for c in blocs[b - 1]: poids[c] += 1000
    vivants = sorted(range(1, len(cars) + 1), key=lambda c: -poids[c]); rempl = {}
    dist = lambda p, q: sum(bin(x ^ y).count('1') for x, y in zip(cars[p - 1], cars[q - 1]))
    while len(vivants) > MAXT:
        t = vivants.pop(); rempl[t] = min(vivants, key=lambda u: dist(t, u))
    if rempl:
        def fin(c):
            while c in rempl: c = rempl[c]
            return c
        garde = sorted(vivants); nouv = {c: k + 1 for k, c in enumerate(garde)}
        for b in blocs: b[:] = [nouv[fin(c)] if c else 0 for c in b]
        cars[:] = [cars[c - 1] for c in garde]
        rep.append("%d caractere(s) confondu(s) avec un voisin" % len(rempl))
    if len(blocs) > 255: raise ValueError("--reprendre : %d blocs, 255 au plus" % len(blocs))
    for k, v in COULEURS_LUS.items():             # les couleurs : sur les caracteres de meme dessin
        if tuple(k) in [tuple(c) for c in cars]: COULEURS[[tuple(c) for c in cars].index(tuple(k)) + 1] = v
    if COULEURS_LUS: rep.append("%d couleur(s) sur %d" % (len(COULEURS), len(COULEURS_LUS)))
    if FLAMME_LUE:                                # la flamme : les caracteres de meme dessin
        tc = [tuple(c) for c in cars]
        if all(k in tc for k in FLAMME_LUE): FLAMME[0] = [tc.index(k) + 1 for k in FLAMME_LUE]; rep.append("la flamme")
        else: print("--reprendre : la flamme n'a pas ete retrouvee (ligne flamme a refaire)")
    if BULLE_LUE:
        tc = [tuple(c) for c in cars]
        if BULLE_LUE in tc: BULLE[0] = tc.index(BULLE_LUE) + 1; rep.append("les bulles")
        else: print("--reprendre : le caractere des bulles n'a pas ete retrouve (ligne bulle a refaire)")
    print("repris de %s : le depart, %s%s" % (chemin, ", ".join(rep) if rep else "rien d'autre",
          (" ; murs : " + ("ceux de l'ancien niveau" if MURS is omurs else "pierres 7 50 20 3")) if MURS else ""))
    return odep


# --- le .cram est un volume du CROS (CMOS RAM Operating System V1.5, la ROM de l'Exelmemoire), comme
# une Exelmemoire formatee par FMT, avec un seul fichier qui la remplit : DIR, TST, BKP... la
# reconnaissent sans rien y toucher. Le CROS range ses fichiers de $BFD0 vers le bas, chacun lu de son
# octet du haut (p) : attribut (p), 0 (p-1), decalage du nom (p-3,p-2 : -4), lien vers le suivant
# (p-5,p-4 : suivant = p-6 + lien), longueur d'enregistrement (p-7,p-6), longueur du nom (p-8), le
# nom (vers le bas), puis les enregistrements (longueur : 2 octets, faible en dessous ; les donnees en
# dessous) et 0,0. Le repertoire finit par une fiche vide (lien 0) ; place libre = sa position - $8004
# - 5. En-tete du volume en $BFD0-$BFFF : attribut du 1er fichier ($BFD0), nom du volume (12), haut
# des fichiers ($BFD0), bas des fichiers, $AA (volume valide), 0, bas de la memoire ($8004), CRC,
# puis les canaux ouverts (4 x 5 octets, le 1er de chacun en $BFFF, $BFFA, $BFF5, $BFF0 : 0 = libre).
VERSION_CRAM = 4                     # LV_VERS de prince_jeu.asm
CROS_NOM = 'PRINCE'                  # nom du volume et du fichier
CROS_ATTR = 0x06                     # FXS (comme les fichiers de donnees) + protege contre DEL ($04)

def crc_cros(m):
    """CRC du CROS (routine $EF58) sur $8000-$BFFF sans $BFE5-$BFE6 -> (octet de $BFE5, octet de $BFE6)"""
    r17 = r18 = 0
    for i in range(0x4000):
        if i == 0x3FE5 or i == 0x3FE6: continue
        a = m[i] ^ r17; r17 = r18; b = a; a = 0
        for _ in range(8):
            a ^= b; b = (b << 1) & 0xFF
        r18 = a
        r17 ^= (a >> 7) ^ (((a >> 1) & 1) << 7 | (a & 1) << 6)
        r18 ^= a >> 2
    return r17, r18

def volume_cros(m, nom=CROS_NOM):
    def mot(adr, v): m[adr - 0x8000] = v >> 8 & 255; m[adr - 0x8000 + 1] = v & 255   # fort en dessous
    for a in list(range(0x8004, 0x800C)) + list(range(0xBFC0, 0xC000)):
        if m[a - 0x8000]: raise ValueError("$%04X n'est pas libre : le CROS y range sa structure" % a)
    n = nom.encode('ascii'); p = 0xBFD0; fin = 0x8009      # fin : la fiche vide qui clot le repertoire
    nm = p - 8                                   # longueur du nom
    haut = nm - len(n) - 1                       # mot de longueur de l'enregistrement (haut)
    lg = haut - 1 - 0x800C                       # les donnees : $800C jusqu'a haut-2
    if haut - 1 - 0xBFB8 <= 0: raise ValueError("nom trop long")
    m[p - 0x8000] = CROS_ATTR; m[p - 1 - 0x8000] = 0
    mot(p - 3, 0x10000 - 4); mot(p - 5, (fin - (p - 6)) & 0xFFFF); mot(p - 7, lg)
    m[nm - 0x8000] = len(n)
    for k, c in enumerate(n): m[nm - 1 - k - 0x8000] = c
    m[haut - 0x8000] = lg >> 8; m[haut - 1 - 0x8000] = lg & 255
    m[0x800A - 0x8000] = m[0x800B - 0x8000] = 0             # fin des enregistrements
    mot(0x8004, 0); mot(0x8006, 0xFFFF); m[0x8008 - 0x8000] = 0; m[fin - 0x8000] = 0   # fiche vide
    v = (nom.upper() + ' ' * 12)[:12].encode('ascii')
    m[0xBFD1 - 0x8000:0xBFDD - 0x8000] = v
    mot(0xBFDD, p); mot(0xBFDF, fin); m[0xBFE1 - 0x8000] = 0xAA; m[0xBFE2 - 0x8000] = 0; mot(0xBFE3, 0x8004)
    m[0xBFE5 - 0x8000], m[0xBFE6 - 0x8000] = crc_cros(m)

def main():
    ap = argparse.ArgumentParser(description="niveau de SDLPoP + plan (Maj+F12), ou niveau.txt -> prince_niveau.cram")
    ap.add_argument('source', help="le dossier de SDLPoP (import), ou un niveau.txt (compilation)")
    ap.add_argument('plan', nargs='?', help="import : le plan du niveau (PNG, Maj+F12 dans SDLPoP)")
    ap.add_argument('--niveau', type=int, default=1)
    ap.add_argument('--seuil', type=int, default=25, help="import : luminosite (%%) a partir de laquelle un point est allume")
    ap.add_argument('--trames', nargs='?', const='55,60,80,95', help="import : des trames au lieu d'un seuil. 4 luminosites (0-255) : en dessous de la 1re, noir ; puis 25 %%, 50 %%, 75 %% de points allumes ; au-dessus de la 4e, blanc. Sans valeur : 55,60,80,95. Ajoute aussi la ligne  murs pierres 7 50 20 3")
    ap.add_argument('--reprendre', metavar='ANCIEN.txt', help="import : recopier de cet ancien niveau ce qui a ete ajoute a la main (depart, murs en pierres, sols fragiles animes, images une fois tombees, debris, boutons en perspective)")
    ap.add_argument('--depart', help="import : SALLE,ETAGE,CASE (salle 1-24, etage 0-2, case 0-9) ; par defaut : le depart du niveau, pose sur le premier sol en dessous")
    ap.add_argument('--texte', default='niveau.txt', help="import : le niveau en clair, a modifier puis a recompiler")
    ap.add_argument('--ecraser', action='store_true', help="import : remplacer un niveau.txt qui existe deja")
    ap.add_argument('--poses', default='prince_poses.bin', help="les poses du prince pour l'Exelmemoire, faites par pop2exl.py --jeu")
    ap.add_argument('-o', default='prince_niveau.cram'); ap.add_argument('--apercu', default='niveau.png')
    a = ap.parse_args()
    if os.path.isdir(a.source):
        if not a.plan: ap.error("import : il faut aussi le plan du niveau (PNG)")
        cars, blocs, salles, depart, cmd, paires, gardes, portes, entree = importer(a)
        if a.trames: globals()['MURS'] = (7, 50, 20, 3, 1)     # murs en pierres (les blocs des murs importes ne servent plus)
        if a.reprendre:
            if os.path.abspath(a.reprendre) == os.path.abspath(a.texte): raise ValueError("--reprendre : donnez un autre nom au nouveau niveau (--texte), l'ancien serait ecrase")
            depart = reprendre(a.reprendre, cars, blocs, salles, paires, portes, globals()['MURS'])
        if os.path.exists(a.texte) and not a.ecraser:
            raise ValueError("%s existe deja : je ne l'ecrase pas (vos modifications seraient perdues). Renommez-le, donnez un autre nom avec --texte, ou ajoutez --ecraser." % a.texte)
        ecrire_texte(a.texte, cars, blocs, salles, depart, "Importe du niveau %d de SDLPoP : ne pas diffuser." % a.niveau, cmd, paires, gardes, portes, entree)
        origine = "niveau %d de VOTRE SDLPoP" % a.niveau
        print("%s : le niveau en clair. Pour le modifier : l'editer, puis  python3 niveau2exl.py %s" % (a.texte, a.texte))
    else:
        cars, blocs, salles, depart, cmd, paires, gardes, portes, entree = lire_texte(a.source); origine = a.source
    sr, se, sc = depart
    pos = placer(salles, sr)
    # --- grilles et boutons : les images qui manquent sont fabriquees avec les caracteres du niveau
    classe = lambda t: 'm' if t == 20 else 'v' if t in (0, 9, 12) else 'p' if t == 3 else 's'
    def case(r, e, c):                            # (salle, etage, colonne) en passant par les salles voisines
        if c < 0: r = salles[r][2][0] if r in salles else 0; c = 9
        elif c > 9: r = salles[r][2][1] if r in salles else 0; c = 0
        return (r, e, c) if r in salles else None
    brut = lambda k: salles[k[0]][1][k[1] * 10 + k[2]] if k else 20
    typ = lambda k: brut(k) & 0x1F
    blo = lambda k: salles[k[0]][0][k[1] * 10 + k[2]]
    toutes = [(r, e, c) for r in salles for e in range(3) for c in range(10)]
    def frequent(cands):
        n = {}
        for k in cands: n[blo(k)] = n.get(blo(k), 0) + 1
        return max(n, key=n.get) if n else None
    vg = lambda k: classe(typ(case(k[0], k[1], k[2] - 1))); vd = lambda k: classe(typ(case(k[0], k[1], k[2] + 1)))
    def semblable(k, test):                       # le bloc le plus frequent des cases qui passent le test, aux voisines les plus proches
        for f in (lambda q: vg(q) == vg(k) and vd(q) == vd(k), lambda q: vg(q) == vg(k), lambda q: True):
            b = frequent([q for q in toutes if q != k and test(q) and f(q)])
            if b is not None: return b
        return None
    blocs = [list(b) for b in blocs]; connus = {tuple(b): i + 1 for i, b in enumerate(blocs)}
    def bloc_id(b):
        if not any(b): return 0
        if tuple(b) not in connus: blocs.append(list(b)); connus[tuple(b)] = len(blocs)
        return connus[tuple(b)]
    contenu = lambda i: blocs[i - 1] if i else [0] * 24
    # un sol nu : une case sol dont l'image n'a rien au-dessus du sol (4 rangees du haut vides : pas de
    # fissure, de torche...) ; a defaut, n'importe quel sol
    sol_nu = lambda q: typ(q) == 1 and not any(contenu(blo(q))[:16])
    sol_tout = lambda q: typ(q) == 1
    sol_libre = lambda k: semblable(k, sol_nu) if semblable(k, sol_nu) is not None else semblable(k, sol_tout)
    # --- sols fragiles animes : un bloc de sol fragile du niveau qui n'a pas sa ligne "fragile" prend
    #     l'animation de la 1re ligne, recopiee : ses retouches (les points de ses images qui different de
    #     son bloc normal) posees sur lui. 14 animations au plus ; pas de nouveau caractere au-dela de 126.
    FR = [tuple(v) for v in FRAGA]
    if FR:
        cars = [tuple(t) for t in cars]; ncars = {t: i + 1 for i, t in enumerate(cars)}
        def pts(i):
            g = [[0] * 32 for _ in range(60)]
            for j, c in enumerate(contenu(i)):
                if c:
                    for yl in range(10):
                        for x in range(8): g[(j >> 2) * 10 + yl][(j & 3) * 8 + x] = cars[c - 1][yl] >> (7 - x) & 1
            return g
        def cars_de(g):
            return [tuple(sum(g[(j >> 2) * 10 + yl][(j & 3) * 8 + x] << (7 - x) for x in range(8)) for yl in range(10)) for j in range(24)]
        n0, n1, n2 = FR[0]; P0, P1, P2 = pts(n0), pts(n1), pts(n2)
        faits = {v[0] for v in FR}; sans = []; approche = set()
        for k in toutes:
            b = blo(k)
            if typ(k) != 11 or not b or b in faits: continue
            faits.add(b); N = pts(b)
            if len(FR) >= 14: sans.append(b); continue
            ims = []
            for P, src in ((P1, n1), (P2, n2)):
                cel = cars_de([[P[y][x] if P[y][x] != P0[y][x] else N[y][x] for x in range(32)] for y in range(60)])
                ids = []
                for j, t in enumerate(cel):
                    if not any(t): ids.append(0)
                    elif t in ncars: ids.append(ncars[t])
                    elif len(cars) < MAXT: cars.append(t); ncars[t] = len(cars); ids.append(len(cars))
                    else: ids.append(contenu(src)[j]); approche.add(b)     # plus de place : la case de l'image d'origine
                ims.append(bloc_id(ids))
            FR.append((b,) + tuple(ims))
        if len(FR) > len(FRAGA): print("sols fragiles : %d blocs de plus animes comme le bloc %d (%s)" % (len(FR) - len(FRAGA), n0, " ".join(str(v[0]) for v in FR[len(FRAGA):])))
        if approche: print("  (126 caracteres atteints : blocs %s animes en partie avec les caracteres du bloc %d)" % (" ".join(map(str, sorted(approche))), n0))
        if sans: print("ATTENTION : sols fragiles sans animation (14 animations au plus) : blocs %s" % " ".join(map(str, sans)))
    # Dans le jeu, les barreaux d'une grille sont dessines sur la case a sa DROITE (au besoin dans la salle
    # voisine) : c'est l'image de cette case-la qui change. Barreaux : ses 3 premieres colonnes, 5 lignes.
    gauche = lambda q: brut(case(q[0], q[1], q[2] - 1))
    def voisine_de(d, test):                      # une case comme d, dont la voisine de gauche passe le test
        for f in (lambda q: typ(q) == typ(d) and vd(q) == vd(d), lambda q: typ(q) == typ(d), lambda q: classe(typ(q)) == classe(typ(d))):
            b = frequent([q for q in toutes if q != d and f(q) and test(gauche(q))])
            if b is not None: return b
        return None
    grilles = []                                  # (case, ouverture au depart, case de l'image ou None, 6 blocs : de fermee a ouverte)
    for k in toutes:
        if typ(k) != 4: continue
        ouv = 5 if brut(k) >> 5 else 0; d = case(k[0], k[1], k[2] + 1)
        if d is None: grilles.append((k, ouv, None, [0] * 6)); continue
        if ouv: O = blo(d); C = voisine_de(d, lambda t: t == 4)
        else:
            C = blo(d); O = voisine_de(d, lambda t: t == 0xA4)
            if O is None: O = voisine_de(d, lambda t: t & 0x1F != 4 and classe(t & 0x1F) == 's')
        if C is None: C = O
        if O is None: O = C
        c, o = contenu(C), contenu(O); soi = contenu(blo(d)); im = []
        for n in range(6):                        # la grille montee de n lignes
            b = list(soi)
            for y in range(5):
                for x in range(3):
                    b[y * 4 + x] = c[(y + n) * 4 + x] if y + n < 5 and c[(y + n) * 4 + x] != o[(y + n) * 4 + x] else o[y * 4 + x]
            im.append(blo(d) if n == ouv else bloc_id(b))
        grilles.append((k, ouv, d, im))
    # la porte de sortie : deux entrees de plus dans la table des grilles. Leur type est celui de la case
    # sortie_g (son ouverture : le moteur y regarde si elle est grande ouverte) ; leurs images, les deux cases
    # a sa droite, ou le jeu dessine le battant. Il monte d'une ligne de caracteres par cran ; au 5e cran,
    # l'image grande ouverte.
    porte_de = {}
    for k, og, od in portes:
        k1 = case(k[0], k[1], k[2] + 1); k2 = case(k1[0], k1[1], k1[2] + 1) if k1 else None
        porte_de[k] = []
        for kk, O in ((k1, og), (k2, od)):
            if kk is None: continue
            c, o = contenu(blo(kk)), contenu(O); im = []
            for n in range(6):
                b = [c[(j // 4 + n) * 4 + j % 4] if c[j] != o[j] and j // 4 + n < 6 and c[(j // 4 + n) * 4 + j % 4] != o[(j // 4 + n) * 4 + j % 4] else o[j] for j in range(24)]
                im.append(blo(kk) if n == 0 else O if n == 5 else bloc_id(b))
            porte_de[k].append(len(grilles)); grilles.append((k, 0, kk, im))
    if len(grilles) > 16: raise ValueError("%d grilles (la porte de sortie en compte 2) : 16 au plus" % len(grilles))
    boutons = []                                  # (case, numero de grille ou 255, bloc enfonce, bloc normal)
    for k in toutes:
        if typ(k) not in (6, 15): continue
        e = sol_libre(k); e = blo(k) if e is None else e
        vp = vn = 0                               # la voisine de droite (meme salle), ou la dalle du bouton deborde
        if k in ENFONCE:                          # (ligne "enfonce" : les images enfoncees, de l'atelier)
            e = ENFONCE[k][0]
            if ENFONCE[k][1] is not None and k[2] < 9:
                vn = blo((k[0], k[1], k[2] + 1)); vp = ENFONCE[k][1]
        cibles = [g for b, g in cmd if tuple(b) == k] or [None]
        for g in cibles:
            if g and tuple(g) in porte_de: ns = porte_de[tuple(g)]
            else: ns = [[i for i, q in enumerate(grilles) if q[0] == tuple(g)][0] if g else 255]
            for n in ns: boutons.append((k, n, e, blo(k), vp, vn))
    if len(boutons) > 31: raise ValueError("%d commandes de boutons : 31 au plus" % len(boutons))
    if len(blocs) > 255: raise ValueError("%d blocs avec les images des grilles : 255 au plus" % len(blocs))
    # l'image de l'Exelmemoire ($8000-$BFFF), aux adresses fixes que connait prince_jeu.asm
    BASE = 0x8000; A_ROOMH, A_ROOML, A_FONT, A_ROOMS, A_BLOCKS = 0x8010, 0x8029, 0x8050, 0x8550, 0x8B50
    # un bloc = 6 numeros de rangees (9 bits : 6 octets, puis un octet de leurs 9es bits) ; une rangee =
    # 4 caracteres, rangee une seule fois (la 0 : vide)
    ncar = lambda v: NUMS[v - 1] if v else 0      # numero de caractere -> code du moteur (sans 32)
    rangees = {(0, 0, 0, 0): 0}; liste = [(0, 0, 0, 0)]; blocs6 = []
    for b in [[0] * 24] + blocs:
        ids = []
        for y in range(6):
            t = tuple(ncar(v) for v in b[y * 4:y * 4 + 4])
            if t not in rangees: rangees[t] = len(liste); liste.append(t)
            ids.append(rangees[t])
        blocs6.append(ids)
    if len(liste) > 512: raise ValueError("%d rangees de 4 caracteres differentes : 512 au plus. Simplifiez le decor." % len(liste))
    nb = len(blocs) + 1; A_ROWS = A_BLOCKS + 7 * nb; fin = A_ROWS + 4 * len(liste)
    A_WF = fin; mc = murs_cars(*MURS) if MURS else []; fin += 10 * len(mc); taille = fin - BASE
    if fin > 0xC000: raise ValueError("niveau trop gros pour l'Exelmemoire : %d octets (16384 au plus)" % taille)
    m = bytearray(0x4000)
    def poke(adr, v): m[adr - BASE:adr - BASE + len(v)] = bytes(v)
    poke(0x8000, b"PNIV")                         # signature ($8004-$800B : au CROS, voir volume_cros)
    poke(0xBC9A, [VERSION_CRAM, sr, se, 58 + 14 * sc + 7 + 10])   # version du format, depart : salle, etage,
    poke(0x800C, [A_ROWS >> 8, A_ROWS & 255])     # l'adresse de la table des rangees
    # abscisse (celle du bord avant ; debout face a droite, le corps est 10 unites derriere : il est au milieu de la case)
    for r in range(1, 25):
        ad = A_ROOMS + 64 * (r - 1); m[A_ROOMH - BASE + r] = ad >> 8; m[A_ROOML - BASE + r] = ad & 255
        bl, ty, vo = salles.get(r, ([0] * 30, [20] * 30, (0, 0, 0, 0)))
        poke(ad, list(bl) + list(ty) + list(vo))
    for i, ids in enumerate(blocs6): poke(A_BLOCKS + 7 * i, [v & 255 for v in ids] + [sum((v >> 8) << k for k, v in enumerate(ids))])
    for i, t in enumerate(liste): poke(A_ROWS + 4 * i, list(t))
    # murs generes : 48 caracteres, apres les rangees (10 lignes de 48, celle du bas d'abord) ; le moteur
    # les copie dans le generateur BAGC1 (codes 64-111) : ils ne comptent pas dans les 126 du decor
    poke(0x8042, [1 if MURS else 0, MURS[0] if MURS else 0, A_WF >> 8, A_WF & 255])
    # sols fragiles animes : nombre, puis (bloc normal, image 1, image 2) ; le moteur montre normal, 1, 2,
    # normal... quand le prince arrive sur l'etage ou retombe (toutes les dalles), et sous ses pieds
    poke(0x8046, [len(FR) + 16 * (FTEMPO[0] - 1) if FR else 0])     # (table en $BCD2, apres les boutons)
    if PLAFOND[0]:                                 # plafond mince : les 4 tuiles de la 6e rangee de son bloc
        poke(0x8047, [1] + [NUMS[c - 1] if c else 0 for c in contenu(PLAFOND[0])[20:24]])
    # couleurs du decor : paires (code, attribut : couleur x 32 + generateur BAGC2 $08 / BAGC1 $10), 0 a la fin
    col = []
    for c in sorted(COULEURS):
        k = NUMS[c - 1]
        if k: col += [k, COULEURS[c] * 32 + (0x10 if k & 0x80 else 0x08)]
    poke(0xBBB0, (col + [0])[:15])
    poke(0xBBBF, [NUMS[BULLE[0] - 1] if BULLE[0] else 0])   # bulles des potions animees : le code de leur caractere
    # flamme animee : les codes de ses 4 caracteres (le moteur y recopie les images de la flamme du jeu)
    poke(0x804C, [NUMS[c - 1] for c in FLAMME[0]] if FLAMME[0] else [0, 0, 0, 0])
    for i, v in enumerate(FR): poke(0xBCD2 + 3 * i, list(v))
    for n, t in enumerate(mc):
        for y in range(10): m[A_WF - BASE + (9 - y) * 48 + n] = t[y]
    for i, t in enumerate(cars):
        for y in range(10): m[A_FONT - BASE + (9 - y) * 128 + NUMS[i]] = t[y]
    # sols fragiles : quand l'un tombe, sa case devient un vide. On cherche dans le niveau l'image d'un
    # vide qui a le meme genre de voisin a gauche, et pour sa voisine de droite l'image d'une case du
    # meme type dont la voisine de gauche est un vide. Table en $BD00 : (case cle, octet a changer, bloc).
    classe = lambda t: 'm' if t == 20 else 'v' if t in (0, 9, 12) else 'p' if t == 3 else 's'
    def case(r, e, c):                            # (salle, etage, colonne) en passant par les salles voisines
        if c < 0: r = salles[r][2][0] if r in salles else 0; c = 9
        elif c > 9: r = salles[r][2][1] if r in salles else 0; c = 0
        return (r, e, c) if r in salles else None
    typ = lambda k: (salles[k[0]][1][k[1] * 10 + k[2]] & 0x1F) if k else 20
    blo = lambda k: salles[k[0]][0][k[1] * 10 + k[2]]
    toutes = [(r, e, c) for r in salles for e in range(3) for c in range(10)]
    def frequent(cands):
        n = {}
        for k in cands: n[blo(k)] = n.get(blo(k), 0) + 1
        return max(n, key=n.get) if n else None
    A_TYPE = lambda k: A_ROOMS + 64 * (k[0] - 1) + 30 + k[1] * 10 + k[2]
    ae = A_TYPE(entree) if entree else 0
    poke(0xBC9E, [ae >> 8, ae & 255])             # l'entree : le bouton sur lequel le jeu appuie au depart (0 : aucun)
    A_BLOC = lambda k: A_ROOMS + 64 * (k[0] - 1) + k[1] * 10 + k[2]
    frag = []; nfrag = 0; deux_fragiles = False
    for k in toutes:
        if typ(k) != 11: continue
        nfrag += 1; g = classe(typ(case(k[0], k[1], k[2] - 1)))
        b = frequent([q for q in toutes if typ(q) == 0 and classe(typ(case(q[0], q[1], q[2] - 1))) == g])
        if b is None: b = frequent([q for q in toutes if typ(q) == 0])
        if k in TOMBE: b = TOMBE[k]                # (choisi dans niveau.txt : ligne "tombe")
        frag.append((A_TYPE(k), A_BLOC(k), b or 0))
        if typ(case(k[0], k[1], k[2] - 1)) == 11 or typ(case(k[0], k[1], k[2] + 1)) == 11: deux_fragiles = True
        d = case(k[0], k[1], k[2] + 1)            # la voisine de droite : la dalle debordait sur elle
        if d:                                     # (elle prend l'image d'une case du meme type a cote d'un vide ;
            gv = lambda t: frequent([q for q in toutes if typ(q) == t and classe(typ(case(q[0], q[1], q[2] - 1))) == 'v'])
            b = gv(typ(d))                        #  une fragile qui reste debout : a defaut, celle d'un sol)
            if b is None and typ(d) == 11: b = gv(1)
            if b is not None and b != blo(d): frag.append((A_TYPE(k), A_BLOC(d), b))
    for k in toutes:                              # potions et epee : une fois prises, la case prend l'image d'un sol nu (meme table)
        if typ(k) in (10, 22):
            b = sol_libre(k)
            if b is not None: frag.append((A_TYPE(k), A_BLOC(k), b))
    # deux dalles fragiles voisines : la seconde qui tombe ne doit pas montrer le bout de la dalle de sa
    # voisine (deja tombee). Le moteur lui donne alors l'image d'un vide dont la voisine de gauche est un vide.
    vv = frequent([q for q in toutes if typ(q) == 0 and classe(typ(case(q[0], q[1], q[2] - 1))) == 'v']) or 0
    # une dalle fragile qui tombe descend jusqu'a un sol, qui devient des debris (type debris, ce bloc :
    # le choix de la ligne "debris", sinon le bloc de debris le plus courant du niveau)
    usage = {}                                    # (les blocs surtout poses sur des cases debris)
    for q in toutes: usage.setdefault(blo(q), {}).setdefault(typ(q), 0); usage[blo(q)][typ(q)] += 1
    surtout_debris = lambda b: b and max(usage[b], key=usage[b].get) == 14
    db = DEBRIS[0] if DEBRIS[0] is not None else (frequent([q for q in toutes if typ(q) == 14 and surtout_debris(blo(q))])
                                                   or frequent([q for q in toutes if typ(q) == 14]))
    poke(0xBCFC, [(1 if nfrag else 0) | (2 if nfrag and db else 0), db or 0])
    poke(0xBCFE, [1 if deux_fragiles else 0, vv])          # (le bloc 0, une case vide, est permis)
    if 0xBD00 + 5 * len(frag) + 1 > 0xBE00: raise ValueError("trop de sols fragiles et de potions (%d lignes, 51 au plus)" % len(frag))
    for i, (cle, cible, b) in enumerate(frag): poke(0xBD00 + 5 * i, [cle >> 8, cle & 255, cible >> 8, cible & 255, b])
    # grilles en $BB00 : adresse du type de la case (2), adresse du bloc de son image (2 ; 0 : aucune), 6 blocs (de
    # fermee a ouverte), ouverture au depart ; 0 a la fin
    # boutons en $BBC0 : adresse du type de la case (2), numero de grille ($FF : aucune), bloc enfonce, bloc normal,
    # puis les blocs enfonce et normal de sa voisine de droite (egaux : elle ne change pas) ; 0 a la fin
    for i, (k, ouv, d, im) in enumerate(grilles):
        poke(0xBB00 + 11 * i, [A_TYPE(k) >> 8, A_TYPE(k) & 255] + ([A_BLOC(d) >> 8, A_BLOC(d) & 255] if d else [0, 0]) + im + [ouv])
    for i, (k, n, e, b, vp, vn) in enumerate(boutons): poke(0xBBC0 + 7 * i, [A_TYPE(k) >> 8, A_TYPE(k) & 255, n, e, b, vp, vn])
    # gardes en $BCA0 : par salle, la case (0-29 ; $FF : aucun ; + $40 en jouant : il est mort), puis
    # $80 s'il est tourne vers la gauche + 16 x son niveau + ses points de vie
    poke(0xBCA0, [0xFF] * 48)
    for g in gardes: poke(0xBCA0 + 2 * (g[0] - 1), [g[1] * 10 + g[2], (0x80 if g[3] else 0) | (g[4] << 4) | g[5]])
    for i, (x, y) in enumerate(paires[:15]): poke(0xBAE0 + 2 * i, [x, y])      # pics : (bloc rentre, bloc sorti) ; 0 a la fin
    if fin > 0xBAE0: raise ValueError("niveau trop gros pour l'Exelmemoire : %d octets" % taille)
    # les poses du prince que pop2exl.py --jeu a mises de cote pour l'Exelmemoire, a l'adresse qu'il a choisie
    conseil = (fin + 15) // 16 * 16
    if os.path.exists(a.poses):
        pb = open(a.poses, 'rb').read()
        if pb[2:4] != b'PO': raise ValueError("%s : ce n'est pas un fichier de poses de cette version de pop2exl.py (refaites-le)" % a.poses)
        ap = pb[0] << 8 | pb[1]; pb = pb[2:]
        if fin > ap: raise ValueError("le niveau (%d octets, jusqu'a $%04X) deborde sur les poses du prince en $%04X : refaites le prince avec  pop2exl.py ... --jeu --cram-debut %d  puis relancez niveau2exl.py" % (taille, fin - 1, ap, conseil))
        if ap + len(pb) > 0xBAE0: raise ValueError("%s : trop gros" % a.poses)
        poke(ap, list(pb))
        print("%s : %d octets de poses du prince ranges en $%04X (le niveau finit en $%04X ; %d octets libres entre les deux)" % (a.poses, len(pb), ap, fin - 1, ap - fin))
        if ap - fin >= 256: print("  pour gagner %d octets de ROM : pop2exl.py ... --jeu --cram-debut %d, puis relancer niveau2exl.py" % (ap - conseil, conseil))
    elif a.poses != 'prince_poses.bin': raise ValueError("%s introuvable" % a.poses)
    else: print("pas de prince_poses.bin ici : l'Exelmemoire n'aura que le niveau (faites le prince avec pop2exl.py --tout-rom, ou mettez prince_poses.bin ici)")
    volume_cros(m)
    open(a.o, 'wb').write(m)
    # apercu : les salles reliees au depart, telles que le moteur les affichera
    nc = max(p[0] for p in pos.values()) + 1; nr = max(p[1] for p in pos.values()) + 1
    PW, PH = nc * 322, nr * 182; pix = [[(60, 0, 0)] * PW for _ in range(PH)]
    for r, (C, R) in pos.items():
        for i, bid in enumerate(salles[r][0]):
            e, c = divmod(i, 10)
            gen = MURS and salles[r][1][i] & 0x1F == 20
            for j, n in enumerate(blocs[bid - 1] if bid else [0] * 24):
                cy, cx = divmod(j, 4)
                t = mc[mur_n(r, i, j, MURS[0])] if gen else cars[n - 1] if n else (0,) * 10
                for y in range(10):
                    for k in range(8):
                        pix[R * 182 + e * 60 + cy * 10 + y][C * 322 + c * 32 + cx * 8 + k] = (255, 255, 255) if t[y] >> (7 - k) & 1 else (0, 0, 0)
    png_write_rgb(a.apercu, PW, PH, pix)
    print("%s : %d salles, %d caracteres, %d blocs, %d rangees, %d octets ; apercu : %s" % (a.o, len(salles), len(cars), len(blocs), len(liste), taille, a.apercu))
    print("plan des salles :")
    grille = {p: r for r, p in pos.items()}
    for y in range(nr): print("   " + " ".join("%2s" % grille.get((x, y), '.') for x in range(nc)))
    hors = sorted(set(salles) - set(pos))
    if hors: print("salles non reliees au depart (absentes de l'apercu) : %s" % ", ".join(str(r) for r in hors))
    print("depart : salle %d, etage %d, case %d (%s)" % (sr, se, sc, NOMS.get(salles[sr][1][se * 10 + sc], '?')))
    print("%d grilles, %d boutons, %d commandes" % (len(grilles) - 2 * len(porte_de), len(set(b[0] for b in boutons)), len([1 for b in boutons if b[1] != 255])))
    for k in porte_de:
        nb_b = len(set(b[0] for b in boutons if b[1] in porte_de[k]))
        print("porte de sortie : salle %d, etage %d, case %d (%s)" % (k + ("ouverte par %d bouton%s" % (nb_b, "s" if nb_b > 1 else "") if nb_b else "aucun bouton ne l'ouvre",)))

if __name__ == '__main__':
    try: main()
    except ValueError as e: raise SystemExit("ERREUR : %s" % e)
