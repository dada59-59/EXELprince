#!/usr/bin/env python3
"""decor2exl.py -- le decor de prince_jeu -> prince_decor.asm (+ un apercu PNG).

Deux sources :

  1. un fichier texte (voir decor.txt) : des tuiles de 8 x 10 points, une couleur par
     tuile, et une carte de 25 lignes de 40 cases. Il ne contient rien de SDLPoP : il
     peut etre diffuse avec le moteur.
         python3 decor2exl.py [decor.txt]

  2. une IMAGE : une capture d'ecran d'une salle, faite avec VOTRE SDLPoP (touche F12 ;
     avec les triches, H J U N montrent les salles voisines, sans le personnage).
         python3 decor2exl.py --image capture.png [--seuil 25] [--contour] [--plafond 101]
                                                  [--etage 1] [--sol 17]
     --contour dessine au trait ; avec plusieurs seuils (--seuil 25,45), les traits s'ajoutent.
     L'image (320 x 200, ou un multiple) est passee en noir et blanc, calee pour que le
     sol de l'etage choisi (0 en haut, 1 au milieu, 2 en bas) tombe sur la ligne --sol,
     puis decoupee en cases. Le fichier produit derive des images du jeu : ne le
     diffusez pas.

     Avec un plan de niveau entier (Maj+F12 dans SDLPoP, triches actives), choisir la
     salle : --salle COLONNE,RANGEE (a partir de 0,0 en haut a gauche), ou les convertir
     toutes d'un coup : --toutes DOSSIER  (-> DOSSIER/salle_C_R.asm et salle_C_R.png).

Options communes : [-o prince_decor.asm] [--apercu decor.png]
Le moteur a deux generateurs de caracteres pour le decor : 252 tuiles differentes au
plus. Au-dela, les tuiles les plus ressemblantes sont confondues (c'est affiche).

Aucune dependance : Python 3 seul."""
import sys, os, zlib, struct, argparse

COUL = {'noir': 0, 'rouge': 1, 'vert': 2, 'jaune': 3, 'bleu': 4, 'magenta': 5, 'cyan': 6, 'blanc': 7}
RVB = [(0, 0, 0), (255, 0, 0), (0, 255, 0), (255, 255, 0), (0, 0, 255), (255, 0, 255), (0, 255, 255), (255, 255, 255)]
MAXT = 252                                       # 2 generateurs de 126 codes (sans 0 ni le delimiteur $20)
NUMS = [t for t in range(1, 256) if t not in (32, 128, 160)]   # numeros de tuile utilisables
Y_SOL = (55, 118, 181)                           # ligne des pieds dans le jeu, par etage

def png_write_rgb(path, w, h, pix):
    raw = b''.join(b'\x00' + bytes(v for p in row for v in p) for row in pix)
    def chunk(t, b): return struct.pack('>I', len(b)) + t + b + struct.pack('>I', zlib.crc32(t + b) & 0xFFFFFFFF)
    open(path, 'wb').write(b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 2, 0, 0, 0))
                           + chunk(b'IDAT', zlib.compress(raw, 9)) + chunk(b'IEND', b''))

def lire(path):
    L = open(path, encoding='utf-8').read().split('\n')
    tuiles = {}; ordre = []; carte = None; i = 0
    def err(msg): raise ValueError("%s ligne %d : %s" % (path, i + 1, msg))
    while i < len(L):
        l = L[i].rstrip('\r')
        if l.strip() == '' or l.lstrip().startswith('#'): i += 1; continue
        m = l.split()
        if m[0] == 'tuile':
            if len(m) < 3 or len(m[1]) != 1 or m[1] == ' ': err("attendu : tuile LETTRE COULEUR [FOND]")
            if m[2] not in COUL: err("couleur inconnue (%s)" % ", ".join(COUL))
            if len(m) > 3 and m[3] != 'noir': err("le fond est toujours noir (generateurs alphanumeriques)")
            if m[1] in tuiles: err("tuile %s definie deux fois" % m[1])
            rows = []
            for k in range(10):
                i += 1
                r = L[i].rstrip('\r').strip() if i < len(L) else ''
                if len(r) != 8 or set(r) - set('#.'): err("une tuile a 10 lignes de 8 caracteres # ou .")
                rows.append(sum(1 << (7 - b) for b in range(8) if r[b] == '#'))
            tuiles[m[1]] = (COUL[m[2]], rows); ordre.append(m[1]); i += 1
        elif m[0] == 'carte':
            carte = []
            for k in range(25):
                i += 1
                r = (L[i].rstrip('\r') if i < len(L) else '').ljust(40)
                if len(r) > 40: err("une ligne de la carte a 40 caracteres au plus")
                for ch in r:
                    if ch != ' ' and ch not in tuiles: err("tuile inconnue dans la carte : %r" % ch)
                carte.append(r)
            i += 1
        else: err("attendu : tuile, carte ou # commentaire")
    if carte is None: raise ValueError(path + " : pas de carte")
    if len(ordre) > MAXT: raise ValueError("%d tuiles : %d au plus" % (len(ordre), MAXT))
    # -> liste de tuiles (couleur, 10 octets) et carte de numeros (0 = rien, n = n-ieme tuile)
    num = {k: i + 1 for i, k in enumerate(ordre)}
    return [tuiles[k] for k in ordre], [[num[ch] if ch != ' ' else 0 for ch in r] for r in carte]

def lire_image(img, seuil, etage, sol, origine, plafond=101, contour=False):
    """capture d'ecran (largeur, hauteur, points) -> (tuiles, carte, nombre de tuiles confondues)"""
    w, h, px = img
    f = max(1, w // 320) if w % 320 == 0 and origine is None else 1     # capture agrandie : 1 point sur f
    ox, oy = origine if origine else (0, 0)
    def lum(x, y):
        x = ox + x * f; y = oy + y * f
        if x >= w or y >= h: return 0
        r, g, b, a = px[y][x]
        return (299 * r + 587 * g + 114 * b) // 1000 if a >= 128 else 0
    dy = sol * 10 - 1 - Y_SOL[etage]              # le sol de l'etage sur le haut de la ligne --sol
    bits = [[0] * 320 for _ in range(250)]
    seuils = seuil if isinstance(seuil, (list, tuple)) else [seuil]
    L = [[lum(x, y) * 100 for x in range(320)] for y in range(192)]   # 192 lignes : sans la barre d'etat du bas
    for sv in (seuils if contour else seuils[:1]):
        def clair(x, y): return 0 <= x < 320 and 0 <= y < 192 and sv * 255 <= L[y][x] < plafond * 255
        for y in range(192):
            if 0 <= y + dy < 250:
                for x in range(320):
                    if not clair(x, y): continue
                    # --contour : on ne garde que le bord des zones claires (cote droit et bas) ;
                    # avec plusieurs seuils, les traits de chacun s'ajoutent
                    if contour and clair(x + 1, y) and clair(x, y + 1) and 0 < x < 319: continue
                    bits[y + dy][x] = 1
    cases = [[tuple(sum(bits[r * 10 + y][c * 8 + b] << (7 - b) for b in range(8)) for y in range(10)) for c in range(40)] for r in range(25)]
    compte = {}
    for r in cases:
        for t in r:
            if any(t): compte[t] = compte.get(t, 0) + 1
    # trop de tuiles : on confond la plus rare avec sa plus proche voisine, tant qu'il le faut
    remplace = {}; vivantes = sorted(compte, key=lambda t: -compte[t]); perdues = 0
    def dist(a, b): return sum(bin(x ^ y).count('1') for x, y in zip(a, b))
    while len(vivantes) > MAXT:
        t = vivantes.pop()
        v = min(vivantes, key=lambda u: dist(t, u)); remplace[t] = v; perdues += 1
    def final(t):
        while t in remplace: t = remplace[t]
        return t
    num = {t: i + 1 for i, t in enumerate(vivantes)}
    carte = [[num[final(t)] if any(t) else 0 for t in r] for r in cases]
    return [(7, list(t)) for t in vivantes], carte, perdues

def main():
    ap = argparse.ArgumentParser(description="decor.txt ou capture d'ecran -> prince_decor.asm")
    ap.add_argument('decor', nargs='?', default='decor.txt'); ap.add_argument('-o', default='prince_decor.asm')
    ap.add_argument('--apercu', default='decor.png')
    ap.add_argument('--image', help="capture d'ecran d'une salle (PNG), a la place du fichier texte")
    ap.add_argument('--seuil', default='25', help="luminosite (%%) a partir de laquelle un point est allume ; avec --contour, plusieurs seuils : 25,45")
    ap.add_argument('--plafond', type=int, default=101, help="luminosite (%%) a partir de laquelle un point est de nouveau eteint")
    ap.add_argument('--contour', action='store_true', help="ne garder que le bord des zones claires (briques dessinees au trait)")
    ap.add_argument('--etage', type=int, default=1, choices=(0, 1, 2), help="etage ou marche le personnage : 0 haut, 1 milieu, 2 bas")
    ap.add_argument('--sol', type=int, default=17, help="ligne de cases du sol (la meme que pour pop2exl.py)")
    ap.add_argument('--origine', help="X,Y : coin de la salle dans une grande image (plan de niveau), sans reduction")
    ap.add_argument('--salle', help="C,R : salle d'un plan de niveau de SDLPoP (Maj+F12), colonne et rangee a partir de 0")
    ap.add_argument('--toutes', metavar='DOSSIER', help="toutes les salles d'un plan de niveau : DOSSIER/salle_C_R.asm et .png")
    a = ap.parse_args()
    a.seuil = [int(v) for v in a.seuil.split(',')]
    if a.salle:                                   # sur le plan, une salle tous les 320 x 189 points
        c, r = (int(v) for v in a.salle.split(',')); a.origine = "%d,%d" % (320 * c, 189 * r)
    def ecrire(tuiles, carte, perdues, sortie, apercu, source):
        n = len(tuiles); W = 256 if n > 126 else 128
        attr = [0xE8 if t < 128 else 0xF0 for t in range(W)]; font = [[0] * W for _ in range(10)]
        for i, (coul, rows) in enumerate(tuiles):
            t = NUMS[i]; attr[t] = coul << 5 | (0x08 if t < 128 else 0x10)
            for y in range(10): font[9 - y][t] = rows[y]
        def octets(f, v):
            for j in range(0, len(v), 16): f.write("        .byte   " + ",".join("$%02X" % x for x in v[j:j + 16]) + "\n")
        with open(sortie, 'w', encoding='latin-1', newline='\r\n') as f:
            f.write("; prince_decor.asm -- produit par decor2exl.py a partir de %s\n" % (source))
            if a.image: f.write("; Ce fichier derive d'une image du jeu : ne le diffusez pas.\n")
            f.write("; %d tuiles\n" % n)
            f.write("DC_W            .equ    %d             ; numeros de tuile : 1-127 (generateur BAGC2)%s\n" % (W, ", 129-255 (BAGC1)" if W == 256 else ""))
            f.write("dc_attr:                                ; attribut de la tuile : couleur et generateur\n"); octets(f, attr)
            f.write("dc_font:                                ; 10 x DC_W octets : la ligne 9 (le bas) des tuiles, puis 8, ... 0\n")
            for L in range(10): octets(f, font[L])
            f.write("dc_map:                                 ; 25 x 40 : numero de tuile (0 = rien)\n")
            for r in carte:
                f.write("        .byte   " + ",".join("%d" % (NUMS[v - 1] if v else 0) for v in r) + "\n")
            f.write("dc_rowh:\n        .byte   " + ",".join("(dc_map+%d)>>8" % (40 * r) for r in range(25)) + "\n")
            f.write("dc_rowl:\n        .byte   " + ",".join("(dc_map+%d)&$FF" % (40 * r) for r in range(25)) + "\n")
        ech = 2; PW, PH = 320 * ech, 250 * ech
        pix = [[(0, 0, 0)] * PW for _ in range(PH)]
        for r in range(25):
            for c in range(40):
                v = carte[r][c]
                if not v: continue
                fg, rows = tuiles[v - 1]
                for y in range(10 * ech):
                    for x in range(8 * ech):
                        if rows[y // ech] >> (7 - x // ech) & 1: pix[r * 10 * ech + y][c * 8 * ech + x] = RVB[fg]
        png_write_rgb(apercu, PW, PH, pix)
        print("%s : %d tuiles, %d octets%s ; apercu : %s" % (sortie, n, 11 * W + 1050,
              (" ; %d tuiles confondues avec une voisine (252 au plus)" % perdues) if perdues else "", apercu))
    if a.image:
        from pop2exl import png_read
        img = png_read(a.image)
        if a.toutes:                              # toutes les salles d'un plan de niveau
            os.makedirs(a.toutes, exist_ok=True); faites = 0
            for r in range(max(1, img[1] // 189)):
                for c in range(max(1, img[0] // 320)):
                    tuiles, carte, perdues = lire_image(img, a.seuil, a.etage, a.sol, (320 * c, 189 * r), a.plafond, a.contour)
                    if not tuiles: continue       # pas de salle a cet endroit du plan
                    nom = os.path.join(a.toutes, "salle_%d_%d" % (c, r)); faites += 1
                    ecrire(tuiles, carte, perdues, nom + ".asm", nom + ".png", "%s, salle %d,%d" % (a.image, c, r))
            print("%d salles dans %s ; pour en utiliser une : la copier sous le nom prince_decor.asm" % (faites, a.toutes))
            return
        org = tuple(int(v) for v in a.origine.split(',')) if a.origine else None
        ecrire(*lire_image(img, a.seuil, a.etage, a.sol, org, a.plafond, a.contour), a.o, a.apercu, a.image)
    else:
        ecrire(*lire(a.decor), 0, a.o, a.apercu, a.decor)

if __name__ == '__main__':
    main()
