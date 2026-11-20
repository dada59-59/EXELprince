#!/usr/bin/env python3
"""intro2exl.py -- l'image d'introduction d'EXLPRINCE, tiree de VOTRE exemplaire de SDLPoP.

    python3 intro2exl.py DOSSIER_SDLPOP [-o prince_intro.asm] [--motifs 160] [--apercu intro.png]
                         [--seuil 50] [--couleur]
    python3 intro2exl.py --image MON_IMAGE.png [-o prince_intro.asm] ...

L'ecran titre du jeu (data/TITLE/res51.png, le palais) recoit le titre (res54.png) a sa
place (24, 107), comme le fait le jeu. Les 320 x 200 points deviennent 40 x 20 cases de
8 x 10 points, un motif par case.
Par defaut en NOIR ET BLANC : un point est blanc si sa luminance depasse --seuil (50 %).
Avec --couleur : deux couleurs par case, parmi les 8 du TMS3556 (table TITRE ci-dessous
pour les couleurs du jeu, la plus proche pour les autres).
Il y a beaucoup plus de motifs differents que de caracteres : on garde les --motifs
plus utiles (160 par defaut, 252 au plus ; chacun coute 10 octets de ROM), chaque case
prend le plus proche (ou son inverse : fond et forme echanges).

Avec --image, n'importe quelle image de 320 x 200 points (PNG). Sans --image ni SDLPoP : --vide, une introduction sans image
(la musique seule), pour assembler le moteur sans l'ecran titre.

La musique (mu_air, jouee au buzzer pendant l'introduction) est ecrite dans le meme fichier :
  --musique sdlpop    le theme de l'introduction du jeu, dans sa version pour le haut-parleur
                      du PC (data/IBM_SND2/res10054.bin : le son 54), un octave plus haut
                      (--octave pour changer) ; par defaut avec un dossier SDLPoP
  --musique original  un air original (mode hijaz sur re) ; par defaut sans dossier SDLPoP
Avec, les deux musiques de la mort (sx_mort : la mort ordinaire, son 24 ; sx_mortc : la mort au
combat, l'epee a la main, son 28 ; data/IBM_SND1), prises de la meme facon, ou deux airs originaux.

Le fichier produit s'assemble avec prince_jeu.asm (#include "prince_intro.asm").
Avec l'image ou le theme du jeu, il en derive : ne le diffusez pas.

Rangement dans la ROM (le moteur le decode au demarrage) :
  IN_N           nombre de motifs (0 : pas d'image)
  in_glyf        10 octets par motif, la ligne du bas d'abord ; le motif k va dans le
                 generateur BAGC2 (k < 126) ou BAGC3, code (k mod 126) + 1, 32 saute
                 (BAGC1 est alphanumerique : pas de couleur de fond, on ne s'en sert pas)
  in_scr         les 20 lignes de 40 cases, un octet de commande par case :
                   00 fffbbb     nouveau motif (le suivant), couleurs f (forme) et b (fond)
                   01 fffbbb, k  motif k
                   10 nnnnnn     la case precedente, encore n + 1 fois
                   11 fffbbb     le motif de la case du dessus

  mu_air         silence entre deux notes (en battements ; 0 : notes liees), prediviseur p,
                 puis par note : recharge r de la minuterie (307200 / ((p + 1) (r + 1))
                 battements par seconde, 2 par periode ; r = 0 : silence, battements comme
                 r = 101), nombre de battements (fort, faible) ; 0,0,0 : fin, on recommence

Aucune dependance : Python 3 seul."""
import sys, os, argparse
from itertools import combinations
from pop2exl import png_read
from decor2exl import png_write_rgb

PAL = [(0, 0, 0), (255, 0, 0), (0, 255, 0), (255, 255, 0), (0, 0, 255), (255, 0, 255), (0, 255, 255), (255, 255, 255)]
# les 16 couleurs de l'ecran titre de SDLPoP -> les 8 du TMS3556 (choix fait a l'oeil : nuit noire
# piquee d'or, roches magenta et bleues, carreaux bleus et cyan, cadre rouge)
TITRE = {(0, 0, 0): 0, (16, 0, 96): 4, (128, 0, 0): 1, (240, 240, 240): 7, (192, 112, 16): 3, (32, 0, 64): 0,
         (144, 80, 16): 0, (224, 160, 0): 3, (112, 48, 16): 0, (112, 32, 96): 5, (224, 192, 112): 7,
         (80, 16, 128): 4, (0, 48, 128): 4, (16, 96, 144): 6, (176, 0, 0): 1, (32, 144, 208): 6}
NPC = 126                                   # codes par generateur (1-127 sans 32)

def proche(c):
    return min(range(8), key=lambda t: sum((a - b) ** 2 for a, b in zip(c, PAL[t])))

def image_titre(dossier):
    t = os.path.join(dossier, 'data', 'TITLE')
    w, h, fond = png_read(os.path.join(t, 'res51.png'))
    lw, lh, logo = png_read(os.path.join(t, 'res54.png'))
    if (w, h) != (320, 200): raise ValueError("res51.png fait %d x %d points (320 x 200 attendus)" % (w, h))
    img = [[p[:3] for p in ligne] for ligne in fond]
    for y in range(lh):
        for x in range(lw):
            p = logo[y][x]
            if p[3] >= 128 and 0 <= 107 + y < 200 and 0 <= 24 + x < 320: img[107 + y][24 + x] = p[:3]
    return img, TITRE

def convertir(img, table, nmot, nb=False, seuil=0.5):
    D = [[sum((a - b) ** 2 for a, b in zip(PAL[s], PAL[t])) ** 0.5 for t in range(8)] for s in range(8)]
    cache = {}
    def idx(c):
        if c not in cache: cache[c] = table[c] if c in table else proche(c)
        return cache[c]
    if nb:      # noir et blanc : chaque point blanc si sa luminance passe le seuil
        ix = [[7 if (0.299 * p[0] + 0.587 * p[1] + 0.114 * p[2]) / 255 > seuil else 0 for p in ligne] for ligne in img]
        paires = [(0, 7)]
    else:
        ix = [[idx(tuple(p)) for p in ligne] for ligne in img]
        paires = list(combinations(range(8), 2))
    cases = []                              # (couleur 1, couleur 0, motif 80 bits, poids)
    for cy in range(20):
        for cx in range(40):
            px = [ix[cy * 10 + y][cx * 8 + x] for y in range(10) for x in range(8)]
            n = [px.count(t) for t in range(8)]
            best = None
            for f, b in paires:
                e = sum(n[s] * min(D[s][f], D[s][b]) for s in range(8))
                if best is None or e < best[0]: best = (e, f, b)
            _, f, b = best
            m = 0
            for v in px: m = (m << 1) | (1 if D[v][f] < D[v][b] else 0)
            if m >> 79: m ^= (1 << 80) - 1; f, b = b, f          # forme canonique : 1er point a 0
            if m == 0: f = b
            cases.append([f, b, m, D[f][b] + 1])
    # cout exact d'un motif p pour une case : cB + S(p) tel quel, cF - S(p) inverse, ou S(p) est la
    # somme, sur les points allumes de p, de (cout de la couleur 1 - cout de la couleur 0) ;
    # S se lit dans une table de 256 sommes par ligne de la case.
    TOUS = (1 << 80) - 1
    tabs = []; cbf = []
    for ci, (f, b, m, w) in enumerate(cases):
        cy, cx = divmod(ci, 40); tl = []; cB = cF = 0.0
        for y in range(10):
            d = []
            for x in range(8):
                v = ix[cy * 10 + y][cx * 8 + x]; d.append(D[v][f] - D[v][b]); cB += D[v][b]; cF += D[v][f]
            t = [0.0] * 256
            for k in range(1, 256):
                low = k & -k; t[k] = t[k ^ low] + d[7 - (low.bit_length() - 1)]
            tl.append(t)
        tabs.append(tl); cbf.append((cB, cF))
    def cout(ci, m):
        tl = tabs[ci]; S = 0.0
        for y in range(10): S += tl[y][(m >> (8 * (9 - y))) & 255]
        cB, cF = cbf[ci]; e1 = cB + S; e2 = cF - S
        return (e1, False) if e1 <= e2 else (e2, True)
    mots = sorted(set(c[2] for c in cases) | {0})
    E = [[cout(ci, m)[0] for m in mots] for ci in range(800)]
    vivant = [True] * len(mots); iz = mots.index(0)
    def deux(ci):
        r = E[ci]; b1 = b2 = None
        for j, v in enumerate(r):
            if not vivant[j]: continue
            if b1 is None or v < r[b1]: b2 = b1; b1 = j
            elif b2 is None or v < r[b2]: b2 = j
        return [b1, b2]
    bs = [deux(ci) for ci in range(800)]
    nviv = len(mots)
    # on retire un a un le motif dont l'absence coute le moins (les cases passent a leur 2e choix)
    while nviv > nmot:
        perte = [0.0] * len(mots)
        for ci, (b1, b2) in enumerate(bs): perte[b1] += E[ci][b2] - E[ci][b1]
        j = min((j for j in range(len(mots)) if vivant[j] and j != iz), key=lambda j: perte[j])
        vivant[j] = False; nviv -= 1
        for ci in range(800):
            if j in bs[ci]: bs[ci] = deux(ci)
    garde = [m for j, m in enumerate(mots) if vivant[j]]
    # affinage : chaque motif devient le meilleur motif pour l'ensemble des cases qui le prennent
    # (point par point : allume si cela fait baisser la somme des couts)
    def placer():
        out = []
        for ci in range(800):
            best = None
            for k, m in enumerate(garde):
                e, inv = cout(ci, m)
                if best is None or e < best[0]: best = (e, k, inv)
            out.append(best)
        return out
    for _ in range(3):
        pl = placer(); gain = [[0.0] * 80 for _ in garde]
        for ci, (e, k, inv) in enumerate(pl):
            cy, cx = divmod(ci, 40); f, b = cases[ci][0], cases[ci][1]
            if inv: f, b = b, f
            g = gain[k]
            for y in range(10):
                for x in range(8):
                    v = ix[cy * 10 + y][cx * 8 + x]; g[y * 8 + x] += D[v][f] - D[v][b]
        for k in range(len(garde)):
            if garde[k] == 0: continue
            v = 0
            for i in range(80): v = (v << 1) | (1 if gain[k][i] < 0 else 0)
            if v >> 79: v ^= TOUS
            if v: garde[k] = v
    pl = placer()
    print("erreur moyenne par case : %.0f" % (sum(p[0] for p in pl) / 800))
    res = []
    for ci, (e, k, inv) in enumerate(pl):
        f, b = cases[ci][0], cases[ci][1]
        if inv: f, b = b, f
        if garde[k] == 0: f = b
        res.append((k, f, b))
    return garde, res

def encoder(garde, res):
    ordre = {}; mots = []
    for k, f, b in res:
        if k not in ordre: ordre[k] = len(ordre); mots.append(garde[k])
    cel = [(ordre[k], (f << 3) | b) for k, f, b in res]
    s = bytearray(); nxt = 0; i = 0
    while i < 800:
        if i:
            r = 0
            while i + r < 800 and cel[i + r] == cel[i - 1] and r < 64: r += 1
            if r: s.append(0x80 | (r - 1)); i += r; continue
        k, c = cel[i]
        if k == nxt: s.append(c); nxt += 1
        elif i >= 40 and k == cel[i - 40][0]: s.append(0xC0 | c)
        else: s += bytes((0x40 | c, k))
        i += 1
    glyf = bytearray()
    for m in mots:
        lignes = [(m >> (8 * (9 - y))) & 255 for y in range(10)]
        glyf += bytes(reversed(lignes))     # la ligne du bas d'abord
    return mots, cel, glyf, s

def decoder(mots, cel):
    """l'image telle que l'EXL100 l'affichera (pour l'apercu)"""
    pix = [[(0, 0, 0)] * 320 for _ in range(200)]
    for i, (k, c) in enumerate(cel):
        f, b = c >> 3, c & 7; m = mots[k]; cx, cy = i % 40, i // 40
        for y in range(10):
            for x in range(8):
                pix[cy * 10 + y][cx * 8 + x] = PAL[f] if m >> (79 - y * 8 - x) & 1 else PAL[b]
    return pix

# l'air original : mode hijaz sur re (re mib fa# sol la sib do re), croche = 0,19 s
_E = 0.19
AIR = [('D4', 1), ('Eb4', 1), ('F#4', 2), ('G4', 1), ('F#4', 1), ('Eb4', 2),
       ('D4', 1), ('Eb4', 1), ('F#4', 1), ('G4', 1), ('A4', 4),
       ('Bb4', 1), ('A4', 1), ('G4', 1), ('F#4', 1), ('G4', 2), ('A4', 2),
       ('F#4', 1), ('G4', 1), ('Eb4', 1), ('F#4', 1), ('D4', 4),
       ('A4', 1), ('D5', 1), ('C5', 1), ('Bb4', 1), ('A4', 2), ('G4', 2),
       ('Bb4', 1), ('A4', 1), ('G4', 1), ('F#4', 1), ('G4', 1), ('A4', 1), ('Bb4', 2),
       ('A4', 1), ('G4', 1), ('F#4', 1), ('Eb4', 1), ('F#4', 2), ('G4', 1), ('F#4', 1),
       ('Eb4', 1), ('D4', 1), ('Eb4', 1), ('F#4', 1), ('D4', 4), ('-', 4)]
MIDI = {'D4': 62, 'Eb4': 63, 'F#4': 66, 'G4': 67, 'A4': 69, 'Bb4': 70, 'C5': 72, 'D5': 74}

def prediv(fmin):
    """le prediviseur p de la minuterie (F = 307200 / ((p + 1) (r + 1)), r <= 255) pour
    que la note la plus grave tienne"""
    for p in (2, 5, 11, 23):
        if 307200 / (p + 1) / 256 / 2 <= fmin: return p
    raise SystemExit("note de %.0f Hz trop grave pour le buzzer" % fmin)

def note(f, d, p, gap=0.0):
    """(recharge, battements) d'une note de f Hz pendant d secondes (f = 0 : silence) ;
    p : prediviseur"""
    base = 307200 / (p + 1)
    if f <= 0: return (0, max(1, min(65535, round(base / 102 * d))))
    r = round(base / 2 / f) - 1
    if not 1 <= r <= 255: raise ValueError("note de %.0f Hz hors de portee du buzzer" % f)
    return (r, max(1, min(65535, int(2 * base / 2 / (r + 1) * (d - gap)))))

# les musiques de la mort, quand il n'y a pas celles de SDLPoP : deux airs originaux (mode hijaz sur re)
AIR_MORT = [('A4', 1), ('G4', 1), ('F#4', 1), ('Eb4', 2), ('D4', 5)]
AIR_MORTC = [('D5', 2), ('Bb4', 1), ('A4', 1), ('G4', 2), ('F#4', 1), ('Eb4', 1), ('F#4', 2), ('D4', 7)]

def air_original(octave=0, air=None):
    fr = [(None if n == '-' else 440 * 2 ** ((MIDI[n] - 69) / 12 + octave), k * _E) for n, k in (air or AIR)]
    p = prediv(min(f for f, d in fr if f))
    out = [note(0, d, p) if f is None else note(f, d, p, 0.02) for f, d in fr]
    return round(0.02 * 307200 / (p + 1) / 102), p, out

def air_sdlpop(dossier, octave=1, pause=1.5, son=54):
    """un son de SDLPoP pour le haut-parleur du PC : 54 le theme, 24 la mort, 28 la mort au combat"""
    import struct
    for sd in ('IBM_SND2', 'IBM_SND1'):
        fn = os.path.join(dossier, 'data', sd, 'res%d.bin' % (10000 + son))
        if os.path.exists(fn): break
    else:
        raise SystemExit("son %d introuvable (data/IBM_SND1 ou 2/res%d.bin) : --musique original ?" % (son, 10000 + son))
    d = open(fn, 'rb').read()
    if d[0] != 0: raise SystemExit("%s n'est pas un son pour le haut-parleur du PC" % fn)
    tempo = struct.unpack('<H', d[1:3])[0]; notes = []
    for i in range(3, len(d) - 2, 3):
        f, l = struct.unpack('<HB', d[i:i + 3])
        if f == 0x12: break
        notes.append((f if f > 1 else 0, l / tempo))
    m = 2 ** octave
    p = prediv(min(f for f, l in notes if f) * m)
    out = [note(f * m, l, p) for f, l in notes]
    if pause: out.append(note(0, pause, p))
    return 0, p, out

def main():
    ap = argparse.ArgumentParser(description="image d'introduction pour EXLPRINCE")
    ap.add_argument('sdlpop', nargs='?', help="votre dossier SDLPoP (il contient data/TITLE)")
    ap.add_argument('--image', help="une autre image PNG de 320 x 200 points")
    ap.add_argument('--vide', action='store_true', help="pas d'image (la musique seule)")
    ap.add_argument('-o', default='prince_intro.asm')
    ap.add_argument('--motifs', type=int, default=160, help="nombre de caracteres de l'image (2-252, 10 octets chacun)")
    ap.add_argument('--apercu', default='intro.png')
    ap.add_argument('--couleur', action='store_true', help="en couleurs (par defaut : noir et blanc)")
    ap.add_argument('--musique', choices=('sdlpop', 'original'), help="le theme du jeu (par defaut avec un dossier SDLPoP) ou un air original")
    ap.add_argument('--octave', type=int, help="transposer l'air de N octaves (par defaut : +1 pour le theme du jeu, 0 pour l'air original)")
    ap.add_argument('--seuil', type=int, default=50, help="noir et blanc : luminance (en %%) au-dessus de laquelle un point est blanc")
    a = ap.parse_args()
    if not 2 <= a.motifs <= 252: raise SystemExit("--motifs : de 2 a 252")
    musique = a.musique or ('sdlpop' if a.sdlpop else 'original')
    if musique == 'sdlpop':
        if not a.sdlpop: raise SystemExit("--musique sdlpop : donnez le dossier SDLPoP")
        octv = 1 if a.octave is None else a.octave
        gap, pdiv, air = air_sdlpop(a.sdlpop, octv)
        msrc = "theme de l'introduction de SDLPoP (haut-parleur PC), %+d octave(s) : ne pas diffuser" % octv
        morts = [air_sdlpop(a.sdlpop, octv, 0, 24), air_sdlpop(a.sdlpop, octv, 0, 28)]
        dsrc = "sons 24 et 28 de SDLPoP (haut-parleur PC) : ne pas diffuser"
    else:
        octv = a.octave or 0
        gap, pdiv, air = air_original(octv); msrc = "air original, %+d octave(s)" % octv
        morts = [air_original(octv, AIR_MORT), air_original(octv, AIR_MORTC)]; dsrc = "airs originaux"
    if a.vide:
        glyf, scr, n, src = b'', b'', 0, "aucune image"
    else:
        if a.image:
            w, h, p = png_read(a.image)
            if (w, h) != (320, 200): raise SystemExit("%s fait %d x %d points (320 x 200 attendus)" % (a.image, w, h))
            img, table, src = [[q[:3] for q in l] for l in p], {}, os.path.basename(a.image)
        elif a.sdlpop:
            img, table = image_titre(a.sdlpop); src = "ecran titre de SDLPoP (res51 + res54) : ne pas diffuser"
        else:
            raise SystemExit("donnez le dossier SDLPoP, ou --image, ou --vide")
        garde, res = convertir(img, table, a.motifs, nb=not a.couleur, seuil=a.seuil / 100)
        mots, cel, glyf, scr = encoder(garde, res)
        n = len(mots)
        png_write_rgb(a.apercu, 320, 200, decoder(mots, cel))
    with open(a.o, 'w', encoding='latin-1', newline='\r\n') as f:
        f.write("; prince_intro.asm -- produit par intro2exl.py (%s)\n" % src)
        f.write("; %d motifs (%d octets), ecran %d octets\n" % (n, len(glyf), len(scr)))
        f.write("IN_N            .equ    %d\n" % n)
        f.write("in_glyf:\n")
        for i in range(0, len(glyf), 10): f.write("        .byte   " + ",".join("$%02X" % v for v in glyf[i:i + 10]) + "\n")
        f.write("in_scr:\n")
        for i in range(0, len(scr), 16): f.write("        .byte   " + ",".join("$%02X" % v for v in scr[i:i + 16]) + "\n")
        f.write("in_scr_fin:\n")
        f.write("; musique : %s, %d notes, %.1f s\n" % (msrc, len(air), sum((c * (102 if r == 0 else r + 1) * (pdiv + 1) / 307200) for r, c in air)))
        f.write("mu_air: .byte   %d,%d                 ; silence entre deux notes, prediviseur\n" % (gap, pdiv))
        for i in range(0, len(air), 5):
            f.write("        .byte   " + ", ".join("%d,%d,%d" % (r, c >> 8, c & 255) for r, c in air[i:i + 5]) + "\n")
        f.write("        .byte   0,0,0\n")
        f.write("; musiques de la mort (%s) : ordinaire, puis au combat ; la priorite juste avant\n" % dsrc)
        for nom, (g, p, t) in zip(('sx_mort', 'sx_mortc'), morts):
            f.write("        .byte   2                       ; (priorite)\n")
            f.write("%s: .byte %d,%d\n" % (nom, g, p))
            for i in range(0, len(t), 5):
                f.write("        .byte   " + ", ".join("%d,%d,%d" % (r, c >> 8, c & 255) for r, c in t[i:i + 5]) + "\n")
            f.write("        .byte   0,0,0\n")
    tm = sum(3 * len(t) + 6 for g, p, t in morts)
    taille = len(glyf) + len(scr) + 3 * len(air) + 5 + tm
    print("%s : %d motifs (%d octets) + ecran %d octets + musique %d octets (%s) + mort %d octets = %d octets de ROM%s"
          % (a.o, n, len(glyf), len(scr), 3 * len(air) + 5, musique, tm, taille, "" if a.vide else " ; apercu : " + a.apercu))

if __name__ == '__main__':
    main()
