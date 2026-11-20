#!/usr/bin/env python3
"""pop2exl.py -- convertisseur : images et tables de SDLPoP -> caracteres semi-graphiques EXL100.

    python3 pop2exl.py DOSSIER_SDLPOP [-o prince_data.asm] [--apercu apercu.png]
                       [--mode lum|silhouette] [--seuil 40] [--sol 17] [--depart 30]
                       [--grain 1|2|4|8] [--scenario fichier.txt]
    python3 pop2exl.py DOSSIER_SDLPOP --jeu [-o prince_jeu_data.asm]      (pilotage clavier / manette)

DOSSIER_SDLPOP est VOTRE exemplaire de SDLPoP (il doit contenir data/KID/res*.png et
src/seg006.c, src/seqtbl.c). Rien de SDLPoP n'est contenu dans ce programme : les images
et les tables sont lues chez vous, au moment de la conversion. Ne diffusez pas le fichier
produit (il derive des images du jeu) ; diffusez le moteur et ce convertisseur.

Version 2 : un scenario de sequences du jeu (course, saut, arret, demi-tour, pas
prudent, saut sur place, accroupi, potion...), joue au point pres dans les deux sens.
Chaque pas de l'animation devient une "pose" : une fenetre de cases (8 x 10 points par
case), avec le plan de ses cases pleines et leurs motifs, plus la case ou la poser.
Les poses ne sont rangees que dans un sens : le moteur fabrique le miroir.
Le scenario se change avec --scenario (une sequence de seqtbl.c par ligne).

Avec --jeu, plus de scenario : le fichier produit contient les sequences elles-memes
(course, saut, demi-tour...) et les REGLES qui font passer de l'une a l'autre selon le
clavier ou la manette (table REGLES, plus bas). Il s'assemble avec prince_jeu.asm.
Le personnage se deplace alors par case entiere (une pose par image du jeu).

Aucune dependance : Python 3 seul (lecture et ecriture PNG incluses)."""
import sys, os, re, zlib, struct, argparse
from collections import Counter

# ---------------------------------------------------------------- PNG (lecture, ecriture)
def png_read(path):
    """-> (largeur, hauteur, lignes) ; chaque point = (r, v, b, a)"""
    d = open(path, 'rb').read()
    if d[:8] != b'\x89PNG\r\n\x1a\n': raise ValueError(path + " : pas un PNG")
    p = 8; idat = b''; plte = None; trns = None
    while p < len(d):
        n, typ = struct.unpack('>I4s', d[p:p + 8]); body = d[p + 8:p + 8 + n]; p += 12 + n
        if typ == b'IHDR': w, h, depth, ctype, _, _, inter = struct.unpack('>IIBBBBB', body)
        elif typ == b'PLTE': plte = [tuple(body[i:i + 3]) for i in range(0, len(body), 3)]
        elif typ == b'tRNS': trns = body
        elif typ == b'IDAT': idat += body
        elif typ == b'IEND': break
    if inter: raise ValueError(path + " : PNG entrelace non gere")
    chans = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}[ctype]
    bpp = max(1, chans * depth // 8); stride = (w * chans * depth + 7) // 8
    raw = zlib.decompress(idat); rows = []; prev = bytearray(stride); q = 0
    for _ in range(h):
        f = raw[q]; cur = bytearray(raw[q + 1:q + 1 + stride]); q += 1 + stride
        for i in range(stride):
            a = cur[i - bpp] if i >= bpp else 0; b = prev[i]; c = prev[i - bpp] if i >= bpp else 0
            if f == 1: cur[i] = (cur[i] + a) & 255
            elif f == 2: cur[i] = (cur[i] + b) & 255
            elif f == 3: cur[i] = (cur[i] + ((a + b) >> 1)) & 255
            elif f == 4:
                pa, pb, pc = abs(b - c), abs(a - c), abs(a + b - 2 * c)
                cur[i] = (cur[i] + (a if pa <= pb and pa <= pc else b if pb <= pc else c)) & 255
        rows.append(cur); prev = cur
    def samples(row):
        if depth == 8: return list(row)
        if depth == 16: return [row[i] for i in range(0, len(row), 2)]
        out = []; mask = (1 << depth) - 1
        for byte in row:
            for s in range(8 - depth, -1, -depth): out.append((byte >> s) & mask)
        return out
    img = []
    for row in rows:
        s = samples(row)[:w * chans]; line = []
        for x in range(w):
            v = s[x * chans:(x + 1) * chans]
            if ctype == 3:
                i = v[0]; r, g, b = plte[i] if i < len(plte) else (0, 0, 0)
                a = trns[i] if trns is not None and i < len(trns) else (0 if trns is None and i == 0 else 255)
            elif ctype == 0: k = v[0] * 255 // ((1 << min(depth, 8)) - 1); r = g = b = k; a = 255
            elif ctype == 4: r = g = b = v[0]; a = v[1]
            elif ctype == 2: r, g, b = v; a = 255
            else: r, g, b, a = v
            line.append((r, g, b, a))
        img.append(line)
    return w, h, img

def png_write_gray(path, w, h, pix):
    """pix : liste de h lignes de w niveaux de gris"""
    raw = b''.join(b'\x00' + bytes(row) for row in pix)
    def chunk(t, b): return struct.pack('>I', len(b)) + t + b + struct.pack('>I', zlib.crc32(t + b) & 0xFFFFFFFF)
    open(path, 'wb').write(b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 0, 0, 0, 0))
                           + chunk(b'IDAT', zlib.compress(raw, 9)) + chunk(b'IEND', b''))

# ---------------------------------------------------------------- tables de SDLPoP
def lire_frames(src, table='frame_table_kid'):
    """frame_table_kid (ou frame_tbl_guard) de seg006.c -> liste de (image, sword, dx, dy, flags)"""
    t = open(os.path.join(src, 'seg006.c'), encoding='latin-1').read()
    m = re.search(table + r'\[\]\s*=\s*\{(.*?)\n\};', t, re.S)
    if not m: raise ValueError(table + " introuvable dans seg006.c")
    out = []
    for e in re.findall(r'\{([^{}]*)\}', m.group(1)):
        v = [eval(x.strip(), {}) for x in e.split(',')]          # "0x40| 4" etc.
        img, sword, dx, dy, flags = v
        out.append((img, sword, dx if dx < 128 else dx - 256, dy if dy < 128 else dy - 256, flags))
    return out

def lire_epee(src):
    """sword_tbl de seg006.c -> liste de (image, dx, dy) : l'epee tenue, par rapport au personnage"""
    t = open(os.path.join(src, 'seg006.c'), encoding='latin-1').read()
    m = re.search(r'sword_tbl\[\]\s*=\s*\{(.*?)\n\};', t, re.S)
    if not m: return []
    return [tuple(eval(x.strip(), {}) for x in e.split(',')) for e in re.findall(r'\{([^{}]*)\}', m.group(1))]

def lire_sequences(src):
    """seqtbl.c -> (operations, etiquettes)
    operations : ('frame', n) ('dx', n) ('dy', n) ('jmp', nom) ('flip', 0)"""
    t = open(os.path.join(src, 'seqtbl.c'), encoding='latin-1').read()
    m = re.search(r'byte\s+seqtbl\[\]\s*=\s*\{(.*?)\n\};', t, re.S)
    if not m: raise ValueError("seqtbl introuvable dans seqtbl.c")
    body = re.sub(r'//[^\n]*', '', m.group(1)); body = re.sub(r'/\*.*?\*/', '', body, flags=re.S)
    body = re.sub(r'#\s*\w+[^\n]*', '', body)
    ops = []; lab = {}
    for mm in re.finditer(r'LABEL\((\w+)\)|\bjmp\((\w+)\)|\bdx\(\s*(-?\d+)\s*\)|\bdy\(\s*(-?\d+)\s*\)|\bframe_(\d+)\w*|\b(SEQ_FLIP)\b|\b(SEQ_KNOCK_DOWN)\b|\b(SEQ_KNOCK_UP)\b|\bsnd\(\s*(\w+)\s*\)', body):
        if mm.group(1): lab[mm.group(1)] = len(ops)
        elif mm.group(2): ops.append(('jmp', mm.group(2)))
        elif mm.group(3): ops.append(('dx', int(mm.group(3))))
        elif mm.group(4): ops.append(('dy', int(mm.group(4))))
        elif mm.group(5): ops.append(('frame', int(mm.group(5))))
        elif mm.group(6): ops.append(('flip', 0))
        elif mm.group(7): ops.append(('knock', 0))           # reception : les dalles fragiles de l'etage tremblent
        elif mm.group(8): ops.append(('kup', 0))             # la tete cogne le plafond : la dalle fragile du dessus tombe
        else: ops.append(('snd', mm.group(9)))   # un son du jeu : seul SND_FOOTSTEP (un pas) est repris
    return ops, lab

# ---------------------------------------------------------------- conversion
CW, CH = 8, 10                                   # une case : 8 points de large, 10 de haut

def allume(px, mode, seuil):
    r, g, b, a = px
    if a < 128: return 0
    if mode == 'silhouette': return 1
    return 1 if (299 * r + 587 * g + 114 * b) // 1000 * 100 >= seuil * 255 else 0

# Le scenario par defaut : une sequence par ligne, "nom" ou "nom nombre_de_poses".
# Sans nombre, la sequence est jouee jusqu'a son retour a "stand" ou a la course.
SCENARIO = """
stand 6
startrun 10
runjump
runcyc1 2
runstop
stand 5
turn
stand 4
step14
stand 4
standjump
stand 5
stoop 7
standup
stand 4
highjump
stand 5
startrun 8
runturn
runcyc7 10
runstop
stand 5
drinkpotion
stand 6
turn
stand 4
startrun 10
runturn
runcyc7 4
runstop
stand 8
"""
# ---------------------------------------------------------------- pilotage (--jeu)
# Entrees, vues du personnage : haut, bas, avant, arriere, feu, boire (touche B).
# "!avant" = avant relache. Plusieurs conditions : "haut+avant".
# Les regles sont attachees aux IMAGES du jeu (numero de frame) : apres l'affichage de
# cette image, la premiere regle vraie fait sauter a la sequence indiquee (une etiquette
# de seqtbl.c) ; sinon la sequence continue.
COURSE = [('arriere', 'runturn'), ('haut', 'runjump'), ('bas', 'rdiveroll')]
REGLES = {
    # (boire : "feu" devant une potion, lance par le moteur)
    15: [('arriere', 'turn'),      # debout
         ('haut+avant', 'standjump'), ('haut', 'highjump'),       # ("feu" : le pas prudent, gere par le moteur)
         ('bas', 'stoop'), ('avant', 'startrun')],
    7: COURSE + [('!avant', 'runstop')], 11: COURSE + [('!avant', 'runstop')],            # course : on ne
    8: COURSE, 9: COURSE, 10: COURSE, 12: COURSE, 13: COURSE, 14: COURSE,                 # s'arrete qu'a 7 et 11
    109: [('!bas', 'standup')],                                                           # accroupi
}
DEPART_JEU = 'stand'
# sequences lancees par le moteur lui-meme (prince_jeu.asm les appelle par leur nom, pj_...) :
# la chute, la reception, et le saut pour s'agripper au rebord du dessus
# ("jumpup" : saut sur place sous un sol ou un mur, la tete cogne le plafond ; "highjump", la regle de "haut",
#  monte 6 points plus haut : il n'y a rien au-dessus)
MOTEUR = ['stepfall', 'softland', 'medland', 'hardland', 'jumphangLong', 'jumphangMed', 'step11', 'jumpup', 'fallhang', 'jumpfall', 'rjumpfall',
          'climbup', 'climbdown', 'hangdrop', 'testfoot', 'impale', 'drinkpotion', 'pickupsword',
          'engarde', 'advance', 'retreat', 'strike', 'readyblock', 'blocktostrike', 'blockedstrike', 'stabbed', 'dropdead', 'alertstand']   # escrime (le prince et le garde)
ESCRIME = {154: 1, 150: 2, 161: 2, 152: 3, 162: 3, 153: 4}   # sans regle : 0,n -- 1 le coup porte, 2 la parade, 3 le coup part, 4 il arrive
# le garde : ses propres images (data/GUARD) pour les images 150 a 189 du prince (frame_tbl_guard) ;
# ses sequences (le moteur les lui donne) ne doivent employer que celles-la
GARDE_SEQ = ('alertstand', 'ready', 'retreat', 'readyblock', 'strike', 'advance', 'blockedstrike', 'stabbed', 'dropdead')
GARDE = 1000                                    # image du garde n : n + GARDE (pour les poses)
EPEE = set(range(150, 175)) - {166} | set(range(207, 211)) | set(range(229, 238))   # images ou l'epee est tenue
PRUDENT = ('step11', 'testfoot')                           # l'avance de cette sequence est limitee par le moteur (jusqu'au bord)
SUITE = {'jumphangLong': 'hang1', 'jumphangMed': 'hang1', 'fallhang': 'hang1'}   # (fallhang : rattrape au rebord en tombant)   # apres la prise : pendu (la meme boucle qu'en descendant)
CLAIRSEMEES = ('resheathe', 'pickupsword', 'drinkpotion')   # gestes rares : une image sur deux (la precedente
                                                # est gardee un pas de plus : meme duree, moitie moins de poses)
PLAFOND = ('jumpup',)
ETIQ = {('runjump', 44): 'pj_rj44', ('standjump', 26): 'pj_sj26'}   # apres ces pas, une etiquette : s'il n'y a pas de sol,
                                                # le moteur fait tomber avec l'elan du saut (start_fall du jeu : rjumpfall, jumpfall)                           # la tete cogne : rien du personnage au-dessus de son etage (bit 5 de la ligne)
PENDU = ('hang1',)                              # sur ces sequences, c'est le moteur qui decide (regles pj_rhang)
SANS_MUR = ('jumphangLong', 'jumphangMed', 'fallhang', 'climbup', 'climbdown', 'hang1')          # en grimpant, on passe devant le mur du dessous            # apres la prise, on se retablit aussitot (pas de suspension)
BITS = {'haut': 1, 'bas': 2, 'arriere': 4, 'avant': 8, 'feu': 16, 'boire': 32}

FINS = ('stand', 'runcyc1', 'runcyc7')           # un saut vers ces etiquettes termine une sequence
ROM_LIBRE = 0x7FFC - 0x1000 - 0x400             # place pour les donnees (le moteur fait ~0,9 Ko)
ROM_LIBRE_JEU = 0x7FFC - 0x0200 - 0x1E00        # moteur pilote : ~7,5 Ko
CRAM_POSES = 0x9E00                             # une partie des poses va dans l'Exelmemoire, de --cram-debut a $BADF
CRAM_POSES_FIN = 0xBAE0                         # (niveau2exl.py l'y range, avec le niveau, si prince_poses.bin est la)

def jeu(a, frames, ops, lab, image, pose, poses, tailles, ecrire_poses, apercu, avant, garde_img):
    """--jeu : les sequences du jeu en blocs de pas, avec leurs regles de pilotage"""
    y_sol = a.sol * CH - 1 - frames[15][3]        # debout (image 15), les pieds sur le sol
    def regle(cond):
        m = v = 0
        for mot in cond.split('+'):
            b = BITS[mot.lstrip('!')]; m |= b
            if not mot.startswith('!'): v |= b
        return m, v
    for fr, rl in REGLES.items():
        for cond, cible in rl:
            regle(cond)
            if cible not in lab: raise ValueError("regle de l'image %d : sequence inconnue : %s" % (fr, cible))
    blocs = {}; ordre = []; attente = [(m, 0) for m in MOTEUR] + [(DEPART_JEU, 0)]
    def nom(b): return "pj_%s%s%s" % (b[0], "" if b[1] == 0 else ("_m%d" % -b[1] if b[1] < 0 else "_p%d" % b[1]), "_c" if len(b) > 2 else "")
    npas = 0; galt = {}; kup_vu = [0]; fst = []; etiq_vu = set()                          # galt : pose du prince -> (pose du garde, ecart de ligne, de decalage)
    while attente:
        b = attente.pop()
        if b in blocs: continue
        pc = lab[b[0]]; y = b[1]; pdx = 0; pflip = 0; lignes = []; garde = 0      # pflip : drapeaux en attente
        plaf = b[0] in PLAFOND or len(b) > 2      # (la suite d'un saut sous le plafond, jusqu'au retour debout : une copie "_c")
        choc = 0; dern = None                     # choc : le prochain pas ebranle le sol (bit 7 de la ligne)
        nimg = 0; vprec = None                    # (CLAIRSEMEES : le rang de l'image dans le bloc, la precedente)
        pas = 0                                   # pas : apres le prochain pas, une etiquette pj_fN (bruit de pas ; table pj_fst)
        kup = 0                                   # kup : apres le prochain pas, l'etiquette pj_kup (le moteur y fait tomber
                                                  # la dalle fragile du dessus ; dans "jumpup" seulement)
        while True:
            garde += 1
            if garde > 400: raise ValueError("sequence sans fin : " + b[0])
            op, v = ops[pc]; pc += 1
            if op == 'dx': pdx += v
            elif op == 'dy':
                if abs(v) == 63: pflip |= 4 if v < 0 else 8     # un etage : c'est le moteur qui en change
                else: y += v
            elif op == 'flip': pdx = -pdx; pflip ^= 1      # le moteur retourne d'abord, avance ensuite
            elif op == 'knock': choc = 128
            elif op == 'kup': kup = b[0] == 'jumpup'
            elif op == 'snd': pas = pas or v == 'SND_FOOTSTEP'
            elif op == 'frame':
                if b[0] in CLAIRSEMEES:
                    nimg += 1
                    if nimg % 2 == 0 and vprec is not None and not ({v, vprec} & (set(REGLES) | set(ESCRIME))):
                        v = vprec                 # une image sur deux : la precedente, encore un pas
                    vprec = v
                img, sword, fdx, fdy, flags = frames[v]; w, h, _ = image(v, -1)
                t = y_sol + y + fdy - h + 1; row = t // CH
                W = (w + CW - 1) // CW; H = (t + h - 1) // CH - row + 1
                if row < 0 or row + H > 25: raise ValueError("image %d de %s : hors de l'ecran en hauteur ; changez --sol" % (v, b[0]))
                i = pose(v, 0, t, w, h, W, H, row, sol=False, serre=True)
                fg = garde_img(v)
                if fg:                            # la meme image, pour le garde : sa pose, et les ecarts
                    gw, gh, _ = image(GARDE + v, -1)  # de ligne et de decalage avec celle du prince
                    gt = y_sol + y + fg[3] - gh + 1; grow = gt // CH
                    gW = (gw + CW - 1) // CW; gH = (gt + gh - 1) // CH - grow + 1
                    if grow < 0 or grow + gH > 25: raise ValueError("image %d du garde : hors de l'ecran en hauteur ; changez --sol" % v)
                    gi = pose(GARDE + v, 0, gt, gw, gh, gW, gH, grow, sol=False, serre=True)
                    goff = (fg[2] + (avant.get(GARDE + v, 0) * 7 + 8) // 16) - (fdx + (avant.get(v, 0) * 7 + 8) // 16)
                    alt = (gi, grow - row, goff)
                    if galt.setdefault(i, alt) != alt: raise ValueError("pose %d : deux poses de garde" % i)
                if v in REGLES:
                    for _, cible in REGLES[v]: attente.append((cible, 0))
                dern = len(lignes)
                lignes.append("        .byte   pr_p%d>>8,pr_p%d&$FF,%d,%d,%d,%d,%s,%s        ; image %d" % (
                    i, i, pflip | (2 if flags & 0x40 and b[0] != 'impale' else 0) | (16 if v == 106 else 0) | (32 if b[0] in SANS_MUR else 0) | (64 if v in (185, 177) else 0) | (128 if b[0] in PRUDENT else 0),
                    pdx & 255, (fdx + (avant.get(v, 0) * 7 + 8) // 16) & 255, (fdx - (flags & 0x1F)) & 255, "%d|CHOC" % (row | (64 if 7 <= v <= 14 or 34 <= v <= 39 or v in (26, 43) else 0) | (32 if plaf else 0)),
                    "pj_rhang>>8,pj_rhang&$FF" if b[0] in PENDU else ("pj_r%d>>8,pj_r%d&$FF" % (v, v)) if v in REGLES else "0,%d" % ESCRIME.get(v, 0), v))
                if choc: lignes[dern] = lignes[dern].replace("|CHOC", "|$80"); choc = 0
                if kup: lignes.append("pj_kup:"); kup = 0; kup_vu[0] = 1
                if (b[0], v) in ETIQ and len(b) == 2 and b[1] == 0: lignes.append(ETIQ[(b[0], v)] + ":"); etiq_vu.add(ETIQ[(b[0], v)])
                if pas: fst.append(len(fst) + 1); lignes.append("pj_f%d:" % len(fst)); pas = 0
                pdx = 0; pflip = 0; npas += 1
            elif op == 'jmp':
                if choc and dern is not None: lignes[dern] = lignes[dern].replace("|CHOC", "|$80")   # (juste avant la suite : au dernier pas)
                if pas and dern is not None: fst.append(len(fst) + 1); lignes.append("pj_f%d:" % len(fst)); pas = 0
                c = (SUITE.get(b[0], v), y) + ((1,) if plaf and v not in FINS else ()); attente.append(c)
                lignes.append("        .byte   0,%d,%d,%s>>8,%s&$FF        ; -> %s" % (pflip | (32 if b[0] in SANS_MUR else 0), pdx & 255, nom(c), nom(c), v))
                break
        blocs[b] = [l.replace("|CHOC", "") for l in lignes]; ordre.append(b)
    # pas repetes : une suite de pas identiques (meme pose, meme avance, memes regles) devient le 1er pas puis
    # une ligne de repetition "0,$40,N,pas (2)" : le moteur le refait N fois de plus. Pas dans les sequences
    # du garde (le moteur y vise des pas par leur rang, et le compteur est celui du prince), ni autour
    # d'une etiquette (pj_fN, pj_kup : le moteur y vise un pas precis).
    garde_bl = set(); pile = [nom((g, 0)) for g in GARDE_SEQ]
    noms = {nom(b): b for b in blocs}
    while pile:
        n = pile.pop()
        if n in garde_bl or n not in noms: continue
        garde_bl.add(n)
        for l in blocs[noms[n]]:
            m = re.search(r'\.byte\s+0,\d+,\d+,(pj_\w+)>>8', l)
            if m: pile.append(m.group(1))
    nrep = [0]; gain = 0
    def corps(l): return l.split(';')[0].rstrip()
    for b in ordre:
        if nom(b) in garde_bl: continue
        ls = blocs[b]; out = []; i = 0
        while i < len(ls):
            l = ls[i]
            if l.lstrip().startswith('.byte   pr_p'):
                k = i + 1
                while k < len(ls) and corps(ls[k]) == corps(l): k += 1
                if k - i >= 2 and not (k < len(ls) and ls[k].endswith(':')):
                    nrep[0] += 1; lab_r = "pj_rp%d" % nrep[0]
                    out.append(lab_r + ":"); out.append(l)
                    out.append("        .byte   0,$40,%d,%s>>8,%s&$FF        ; -> %d fois de plus" % (k - i - 1, lab_r, lab_r, k - i - 1))
                    gain += 9 * (k - i - 1) - 5; i = k; continue
            out.append(l); i += 1
        blocs[b] = out
    if nrep[0]: print("pas repetes : %d suites, %d octets gagnes" % (nrep[0], gain))
    if garde_img(150):                            # le garde n'a que ses images : ses sequences n'en demandent pas d'autres
        for s in GARDE_SEQ:
            pc = lab[s]; vu = set()
            while pc not in vu:
                vu.add(pc); op, v = ops[pc]; pc += 1
                if op == 'frame' and not garde_img(v): raise ValueError("sequence %s du garde : image %d sans image de garde" % (s, v))
                if op == 'jmp':
                    if v in FINS: break
                    pc = lab[v]
        print("garde : %d poses (ses images, data/GUARD)" % len(set(g[0] for g in galt.values())))
    # colonne de l'ancrage (le bord avant du personnage) selon l'abscisse du jeu
    def colonne(x): return ((x * 2 - 116) * 320 // 280 + a.decalage + CW // 2) // CW
    coltab = [colonne(x) & 255 for x in range(256)]
    x0 = min(range(256), key=lambda x: abs(colonne(x) - a.depart))
    # bords : le personnage sort quand son bord avant depasse l'ecran de la largeur d'une pose de
    # course (images 1 a 14), et rentre aussitot par l'autre cote
    marge = max((image(v, -1)[0] + CW - 1) // CW for v in range(1, 15)) + 1
    tour = 40 + marge + (marge & 1)               # nombre pair de cases : 3,5 unites du jeu par case
    xmin = 58 - (marge * 7 + 1) // 2; xmax = 58 + (40 + marge) * 7 // 2
    kmax = max(p[3] for p in poses)
    if kmax > 27: raise ValueError("pose trop grande : %d cases pleines (27 au plus)" % kmax)
    # compression par quartets (fort d'abord) : 0 n = n+1 octets nuls (1 a 16) ; 1 a 14 = l'octet
    # pr_ntab[q-1] (les 14 octets non nuls les plus frequents) ; 15 h l = l'octet hl.
    cnt = Counter(v for i in _BRUT for v in _BRUT[i][1] if v)
    ntab = [v for v, _ in cnt.most_common(14)]; ntab += [0] * (14 - len(ntab))
    def quartets(brut):
        q = []; j = 0
        while j < len(brut):
            v = brut[j]
            if v == 0:
                n = j
                while n < len(brut) and brut[n] == 0 and n - j < 16: n += 1
                q += [0, n - j - 1]; j = n
            elif v in ntab: q.append(ntab.index(v) + 1); j += 1
            else: q += [15, v >> 4, v & 15]; j += 1
        if len(q) & 1: q.append(0)
        return [q[k] << 4 | q[k + 1] for k in range(0, len(q), 2)]
    avant = tailles[0]; tailles[0] = 0
    for i in range(len(poses)):
        if i in _BRUT:
            key, _, cells, K = poses[i]; hdr, brut = _BRUT[i]
            poses[i] = (key, hdr + quartets(brut), cells, K)
        tailles[0] += len(poses[i][1])
    print("poses compressees par quartets : %d -> %d octets" % (avant, tailles[0]))
    nregles = sum(4 * len(r) + 1 for r in REGLES.values())
    # les plus grosses poses vont dans l'Exelmemoire, tant qu'il y a de la place (4 octets d'en-tete)
    debut = a.cram_debut
    if not 0x8000 < debut < CRAM_POSES_FIN: raise ValueError("--cram-debut : entre 32768 ($8000) et %d" % CRAM_POSES_FIN)
    libre = CRAM_POSES_FIN - debut - 4; en_cram = {}; adr = debut + 4
    if not a.tout_rom:
        for i in sorted(range(len(poses)), key=lambda i: -len(poses[i][1])):
            if i in galt: continue                # (les poses du prince qui ont une pose de garde restent en ROM :
            n = len(poses[i][1])                  # les 4 octets qui la designent sont juste avant)
            if n <= libre: en_cram[i] = adr; adr += n; libre -= n
    blob = bytearray()
    for i in sorted(en_cram, key=en_cram.get): blob += bytes(poses[i][1])
    h = 0
    for v in blob: h = (h * 31 + v) & 0xFFFF
    total = tailles[0] - len(blob) + 4 * len(galt) + 9 * npas + 5 * len(blocs) + nregles + 256 + 14 - gain + 325 + 71   # (+ la flamme : 9 x 36 + 1 ; les bulles : 7 x 10 + 1)
    if total > ROM_LIBRE_JEU:
        raise ValueError("%d octets de donnees : trop pour une ROM de 32 Ko (%d libres). Retirez des sequences de REGLES." % (total, ROM_LIBRE_JEU))
    with open(a.o, 'w', encoding='latin-1', newline='\r\n') as f:
        f.write("; prince_jeu_data.asm -- produit par pop2exl.py --jeu a partir de VOTRE exemplaire de SDLPoP.\n")
        f.write("; Ce fichier derive des images du jeu : ne le diffusez pas.\n")
        f.write("; %d poses, %d sequences, %d pas, %d octets, mode %s\n" % (len(poses), len(blocs), npas, total, a.mode))
        f.write("PR_SET          .equ    %d              ; taille d'un jeu de codes (la plus grande pose)\n" % kmax)
        f.write("PR_CRAM         .equ    %d              ; octets de poses dans l'Exelmemoire (prince_poses.bin)\n" % len(blob))
        f.write("PR_CRAMP        .equ    $%04X           ; ... a partir d'ici (en-tete \"PO\" et empreinte, puis les poses)\n" % debut)
        f.write("PR_CHASH        .equ    $%04X           ; ... et leur empreinte (le moteur la verifie au demarrage)\n" % h)
        for i in sorted(en_cram): f.write("pr_p%d .equ $%04X                     ; pose dans l'Exelmemoire\n" % (i, en_cram[i]))
        f.write("PR_FLOOR        .equ    %d              ; ligne de cases du sol (son haut : la ou marche le personnage)\n" % a.sol)
        f.write("PR_X0           .equ    %d              ; abscisse de depart (unites du jeu)\n" % x0)
        f.write("PR_XMIN         .equ    %d              ; sortie a gauche (colonne %d)\n" % (xmin, -marge))
        f.write("PR_XMAX         .equ    %d              ; sortie a droite (colonne %d)\n" % (xmax, 40 + marge))
        f.write("PR_TOUR         .equ    %d              ; %d cases : on rentre par l'autre cote\n" % (tour * 7 // 2, tour))
        f.write("; pas : pose (fort, faible), drapeaux, avance, decalage de l'image, poids du corps, ligne (+ $80 : le sol est ebranle ; + $40 : course ou saut, mortel sur des pics), regles (fort, faible ; 0,n = aucune, n : escrime, 1 coup porte, 2 parade, 3 coup qui part, 4 coup qui arrive)\n")
        f.write("; drapeaux : 1 demi-tour, 2 il faut un sol sous les pieds, 4 un etage plus haut, 8 plus bas, 16 chute libre, 32 les murs n'arretent pas, 64 mort, 128 pas prudent\n")
        f.write("; fin : 0, demi-tour, avance, sequence suivante (fort, faible)\n")
        f.write("pr_start:                               ; la premiere sequence\n")
        for b in ordre:
            f.write("%s:\n" % nom(b))
            for l in blocs[b]: f.write(l + "\n")
        if not kup_vu[0]: f.write("pj_kup  .equ    1                       ; (pas de SEQ_KNOCK_UP dans jumpup)\n")
        for e in sorted(set(ETIQ.values()) - etiq_vu): f.write("%s  .equ    1                       ; (pas trouve)\n" % e)
        f.write("; bruits de pas (snd(SND_FOOTSTEP) du jeu) : les pas apres lesquels le moteur fait \"toc\" ; 0 = fin\n")
        # la flamme des torches : les 9 images du jeu (data/PRINCE, res151-159 : 16 x 18 points), 2 octets par
        # ligne (gauche, droite) ; le moteur en recopie une au hasard a chaque pas dans les 4 caracteres de la
        # ligne "flamme" de niveau2exl.py (lignes 2 a 19 du carre de 2 x 2 caracteres)
        fl = []
        for n in range(151, 160):
            try: fw, fh, fpx = png_read(os.path.join(a.sdlpop, 'data', 'PRINCE', 'res%d.png' % n))
            except OSError: break
            if fw > 16 or fh > 18: break
            im = []
            for y in range(18):
                yy = y - (18 - fh)
                v = 0
                for x in range(16):
                    if 0 <= yy < fh and x < fw and fpx[yy][x][3] >= 128: v |= 0x8000 >> x
                im += [v >> 8, v & 255]
            fl.append(im)
        f.write("; la flamme des torches : %d images de 18 lignes (gauche, droite), data/PRINCE res151-159\n" % len(fl))
        f.write("pj_fln: .byte   %d\npj_flam:\n" % len(fl))
        for im in fl:
            for k in range(0, 36, 12): f.write("        .byte   " + ",".join("$%02X" % v for v in im[k:k + 12]) + "\n")
        # les bulles des potions : les 7 images du jeu (data/PRINCE, res166-172 : 5 x 9 points ; bubble_next_frame),
        # posees dans un caractere (2 points du bord gauche, sous la 1re ligne) : 10 octets chacune, le haut d'abord
        bl = []
        for n in range(166, 173):
            try: bw, bh, bpx = png_read(os.path.join(a.sdlpop, 'data', 'PRINCE', 'res%d.png' % n))
            except OSError: break
            if bw > 6 or bh > 9: break
            im = [0] * 10
            for y in range(bh):
                for x in range(bw):
                    if bpx[y][x][3] >= 128: im[1 + y] |= 0x80 >> (2 + x)
            bl.append(im)
        f.write("; les bulles des potions : %d images d'un caractere (le haut d'abord), data/PRINCE res166-172\n" % len(bl))
        f.write("pj_bln: .byte   %d\npj_bul:\n" % len(bl))
        for im in bl: f.write("        .byte   " + ",".join("$%02X" % v for v in im) + "\n")
        f.write("pj_fst:\n")
        for n in fst: f.write("        .byte   pj_f%d>>8,pj_f%d&$FF\n" % (n, n))
        f.write("        .byte   0\n")
        f.write("; regles : masque, valeur, sequence (fort, faible) ; $FF = fin\n")
        f.write("; bits : 0 haut, 1 bas, 2 arriere, 3 avant, 4 feu, 5 touche B\n")
        f.write("pj_rhang:                               ; pendu : le moteur decide (haut, feu, ou rien)\n        .byte   $FF\n")
        for fr in sorted(REGLES):
            f.write("pj_r%d:\n" % fr)
            for cond, cible in REGLES[fr]:
                m, v = regle(cond); c = nom((cible, 0))
                f.write("        .byte   $%02X,$%02X,%s>>8,%s&$FF        ; %s -> %s\n" % (m, v, c, c, cond, cible))
            f.write("        .byte   $FF\n")
        f.write("pr_gflag:                               ; 1 : le garde a ses images (4 octets avant les poses du prince)\n        .byte   %d\n" % (1 if galt else 0))
        f.write("pr_cflag:                               ; 1 : des poses sont dans l'Exelmemoire\n        .byte   %d\n" % (1 if blob else 0))
        f.write("pr_ntab:                                ; compression par quartets : l'octet des quartets 1 a 14\n")
        f.write("        .byte   " + ",".join("$%02X" % v for v in ntab) + "\n")
        f.write("pr_col:                                 ; abscisse du jeu -> colonne de l'ancrage (signee)\n")
        for j in range(0, 256, 16):
            f.write("        .byte   " + ",".join("$%02X" % v for v in coltab[j:j + 16]) + "\n")
        for i, (key, octets, _, K) in enumerate(poses):
            if i in en_cram: continue
            if i in galt:
                gi, dr, do = galt[i]
                f.write("        .byte   pr_p%d>>8,pr_p%d&$FF,%d,%d        ; le garde : sa pose, ecarts de ligne et de decalage\n" % (gi, gi, dr & 255, do & 255))
            f.write("pr_p%d:                                 ; pose %d du jeu, decalage %d,%d\n" % ((i,) + key[:3]))
            for j in range(0, len(octets), 16):
                f.write("        .byte   " + ",".join("$%02X" % v for v in octets[j:j + 16]) + "\n")
    nb = os.path.join(os.path.dirname(os.path.abspath(a.o)), 'prince_poses.bin')
    if blob:
        open(nb, 'wb').write(bytes([debut >> 8, debut & 255, ord('P'), ord('O'), h >> 8, h & 255]) + blob)
        print("%s : %d poses, %d octets, pour l'Exelmemoire en $%04X : relancez niveau2exl.py ensuite" % (os.path.basename(nb), len(en_cram), len(blob) + 4, debut))
    elif os.path.exists(nb): os.remove(nb)
    apercu()
    print("%s : %d poses, %d sequences, %d pas, %d octets sur %d (%d %%) ; plus grande pose : %d cases ; apercu : %s"
          % (a.o, len(poses), len(blocs), npas, total, ROM_LIBRE_JEU, total * 100 // ROM_LIBRE_JEU, kmax, a.apercu))

_BRUT = {}
def main():
    ap = argparse.ArgumentParser(description="SDLPoP -> caracteres semi-graphiques EXL100")
    ap.add_argument('sdlpop'); ap.add_argument('-o'); ap.add_argument('--apercu', default='apercu.png')
    ap.add_argument('--mode', choices=('lum', 'silhouette'), default='lum'); ap.add_argument('--seuil', type=int, default=40)
    ap.add_argument('--sol', type=int, default=None, help="ligne de cases du sol (0-24)")
    ap.add_argument('--depart', type=int, default=6, help="abscisse de depart, en points (avec --jeu : en cases)")
    ap.add_argument('--grain', type=int, default=1, choices=(1, 2, 4, 8),
                    help="pas du deplacement horizontal, en points : 1 = au point pres, 4 = par demi-case, 8 = par case")
    ap.add_argument('--trace', action='store_true', help="affiche le trajet, sequence par sequence")
    ap.add_argument('--decalage', type=int, default=0, help="--jeu : decale l'image du personnage de N points vers la droite (negatif : vers la gauche) par rapport au decor ; la logique ne change pas")
    ap.add_argument('--cram-debut', type=lambda x: int(x, 0), default=CRAM_POSES, help="--jeu : adresse ou commencent les poses dans l'Exelmemoire (defaut 0x9E00) ; niveau2exl.py dit quelle valeur choisir")
    ap.add_argument('--sans-garde', action='store_true', help="--jeu : le garde prend les images du prince (sans data/GUARD)")
    ap.add_argument('--tout-rom', action='store_true', help="--jeu : toutes les poses en ROM (sans prince_poses.bin)")
    ap.add_argument('--jeu', action='store_true', help="pilotage clavier / manette : sequences et regles, pour prince_jeu.asm")
    ap.add_argument('--scenario', help="fichier texte : une sequence par ligne (voir SCENARIO dans ce programme)")
    a = ap.parse_args()
    if a.sol is None: a.sol = 14 if a.jeu else 17      # --jeu : le sol de l'etage du milieu de niveau2exl.py
    if not a.o: a.o = 'prince_jeu_data.asm' if a.jeu else 'prince_data.asm'
    data = os.path.join(a.sdlpop, 'data', 'KID'); src = os.path.join(a.sdlpop, 'src')
    frames = lire_frames(src); ops, lab = lire_sequences(src); epee = lire_epee(src); avant = {}
    try: frames_g = lire_frames(src, 'frame_tbl_guard') if a.jeu and not a.sans_garde else []
    except ValueError: frames_g = []
    data_g = os.path.join(a.sdlpop, 'data', 'GUARD')
    def garde_img(fr):                            # l'image du garde pour l'image fr du prince (None : aucune)
        k = fr - 149
        if not frames_g or not 1 <= k < len(frames_g) or frames_g[k][0] == 255: return None
        return frames_g[k] if os.path.exists(os.path.join(data_g, 'res%d.png' % (751 + frames_g[k][0]))) else None
    scen = open(a.scenario, encoding='utf-8').read() if a.scenario else SCENARIO
    cache = {}
    def image(fr, sens):                          # image de la pose fr en 0/1 ; sens +1 : tournee vers la droite
        if (fr, sens) not in cache:
            if fr >= GARDE:                       # le garde : ses images sont en gris (la palette du niveau
                fg = garde_img(fr - GARDE)        # les colore) : toute sa silhouette est allumee
                w, h, px = png_read(os.path.join(data_g, 'res%d.png' % (751 + fg[0])))
                px = [[(255, 255, 255, 255) if q[3] >= 128 else (0, 0, 0, 0) for q in r] for r in px]
                sf = fg[1] & 0x3F
                tenue = sf != 0
            else:
                img = frames[fr][0]
                w, h, px = png_read(os.path.join(data, 'res%d.png' % (401 + img)))
                sf = frames[fr][1] & 0x3F
                tenue = fr in EPEE
            fic = os.path.join(a.sdlpop, 'data', 'PRINCE', 'res%d.png' % (701 + epee[sf][0])) if sf < len(epee) else ''
            if a.jeu and tenue and sf < len(epee) and epee[sf][0] != 255 and os.path.exists(fic):
                # --jeu : l'epee tenue est ajoutee a l'image (data/PRINCE, comme le jeu la pose par-dessus) :
                # son bord gauche a epee.dx points devant celui du personnage, son bas epee.dy sous le sien
                sid, sdx, sdy = epee[sf]
                sw, sh, spx = png_read(os.path.join(a.sdlpop, 'data', 'PRINCE', 'res%d.png' % (701 + sid)))
                sx = -sdx; sb = min(h - 1, h - 1 + sdy)
                x0 = min(0, sx); x1 = max(w, sx + sw); y0 = min(0, sb - sh + 1)
                nw, nh = x1 - x0, h - y0
                vide = (0, 0, 0, 0); npx = [[vide] * nw for _ in range(nh)]
                for y in range(sh):
                    for x in range(sw):
                        if spx[y][x][3] >= 128: npx[sb - sh + 1 + y - y0][sx + x - x0] = spx[y][x]
                for y in range(h):
                    for x in range(w):
                        if px[y][x][3] >= 128: npx[y - y0][x - x0] = px[y][x]
                w, h, px = nw, nh, npx; avant[fr] = -x0
            cache[fr, sens] = (w, h, [[allume(p, a.mode, a.seuil) for p in (reversed(row) if sens > 0 else row)] for row in px])
        return cache[fr, sens]
    # --- le scenario : liste de (pose du jeu, x, y, sens) ; x, y en unites du jeu
    etat = {'x': 0, 'y': 0, 'sens': 1}; film = []
    def jouer(nom, n):
        if nom not in lab: raise ValueError("sequence inconnue : " + nom)
        pc = lab[nom]; fait = 0; garde = 0
        while True:
            garde += 1
            if garde > 5000: raise ValueError("sequence sans fin : %s (donnez un nombre de poses)" % nom)
            op, v = ops[pc]; pc += 1
            if op == 'jmp':
                if n is None and v in FINS: return
                pc = lab[v]
            elif op == 'dx': etat['x'] += v * etat['sens']
            elif op == 'dy': etat['y'] += v
            elif op == 'flip': etat['sens'] = -etat['sens']
            elif op == 'frame':
                film.append((v, etat['x'], etat['y'], etat['sens'])); fait += 1
                if n is not None and fait >= n: return
    bornes = []                                   # (ligne du scenario, premier pas, dernier pas)
    for ligne in scen.splitlines():
        mots = ligne.split('#')[0].split()
        if mots:
            d = len(film); jouer(mots[0], int(mots[1]) if len(mots) > 1 else None); bornes.append((' '.join(mots), d, len(film)))
    def boite(fr, x, y, sens):                    # rectangle a l'ecran, en points, avant decalage
        img, sword, fdx, fdy, flags = frames[fr]; w, h, _ = image(fr, sens)
        ox = (x + fdx * sens) * 2 - 116
        d = 0x00 if sens > 0 else 0xFF            # ((flags ^ direction) >= 0, en octet signe)
        if not ((flags ^ d) & 0x80): ox += 1
        sx = ox * 320 // 280                      # l'ancrage : bord avant du personnage
        return sx, y + fdy - h + 1, w, h
    # decalage : la premiere pose a l'abscisse --depart, les pieds sur le sol
    g0, t0, w0, h0 = boite(*film[0]); bas0 = t0 + h0 - 1
    dx_ecran = a.depart - (g0 - w0 if film[0][3] > 0 else g0); dy_ecran = (a.sol * CH - 1) - bas0
    if a.trace:                                   # ou va le personnage, sequence par sequence
        for nom, d, f in bornes:
            ws = [boite(*film[k])[2] for k in range(d, f)]
            gs = [boite(*film[k])[0] + dx_ecran - (w if film[k][3] > 0 else 0) for k, w in zip(range(d, f), ws)]
            ts = [boite(*film[k])[1] + dy_ecran for k in range(d, f)]
            print("  %-14s %3d poses, points %4d a %4d (ecran : 0 a 319), haut %3d" % (nom, f - d, min(gs), max(g + w for g, w in zip(gs, ws)) - 1, min(ts)))
    poses = []; index = {}; tailles = [0]
    def pose(fr, dec, t, w, h, W, H, row, sol=True, serre=False):   # -> numero de la pose (fabriquee une seule fois)
        # la ligne du sol traverse la fenetre ? (avec --jeu, le sol fait partie du decor du moteur)
        sol_rel = a.sol - row if sol and row <= a.sol < row + H else -1
        key = (fr, dec, t % CH, sol_rel)
        if key not in index:
            _, _, bits = image(fr, -1)
            cells = [[0] * (W * CW) for _ in range(H * CH)]
            for yy in range(h):
                for xx in range(w):
                    if bits[yy][xx]: cells[t % CH + yy][dec + xx] = 1
            plan = []; motifs = []                # cases pleines, dans l'ordre du plan
            for cy in range(H):
                for cx in range(W):
                    lig = [sum(cells[cy * CH + yl][cx * CW + b] << (7 - b) for b in range(CW)) for yl in range(CH)]
                    if cy == sol_rel: lig[0] |= 0xFF       # le sol : la ligne du haut de la case (comme CH_FLOOR)
                    if any(lig): motifs.append(lig); plan.append(len(motifs))
                    else: plan.append(0)
            K = len(motifs)
            if serre:                             # --jeu : case par case, et les suites de zeros en 2 octets (0, n)
                brut = [motifs[i][CH - 1 - L] for i in range(K) for L in range(CH)]; flux = []; j = 0
                while j < len(brut):
                    if brut[j]:
                        flux.append(brut[j]); j += 1
                    else:
                        n = j
                        while n < len(brut) and brut[n] == 0 and n - j < 255: n += 1
                        flux += [0, n - j]; j = n
                octets = [W, H, K] + plan + flux
            else:
                octets = [W, H, K] + plan + [motifs[i][CH - 1 - L] for L in range(CH) for i in range(K)]
            if sol_rel >= 0:
                for xx in range(W * CW): cells[sol_rel * CH][xx] = 1
            if serre: _BRUT[len(poses)] = ([W, H, K] + plan, brut)   # recompresse par quartets dans jeu()
            index[key] = len(poses); poses.append((key, octets, cells, K)); tailles[0] += len(octets)
        return index[key]
    def ecrire_poses(f):
        for i, (key, octets, _, K) in enumerate(poses):
            f.write("pr_p%d:                                 ; pose %d du jeu, decalage %d,%d\n" % ((i,) + key[:3]))
            for j in range(0, len(octets), 16):
                f.write("        .byte   " + ",".join("$%02X" % v for v in octets[j:j + 16]) + "\n")
    def apercu():                                 # toutes les poses, grossies 2 fois, quadrillage des cases
        par = 10; ech = 2
        cw = max(len(p[2][0]) for p in poses) * ech + 6; chh = max(len(p[2]) for p in poses) * ech + 6
        rows = (len(poses) + par - 1) // par
        sheet = [[40] * (par * cw) for _ in range(rows * chh)]
        for i, (_, _, cells, _) in enumerate(poses):
            ox, oy = (i % par) * cw + 3, (i // par) * chh + 3
            for y in range(len(cells) * ech):
                for x in range(len(cells[0]) * ech):
                    on = cells[y // ech][x // ech]
                    grid = (x // ech) % CW == 0 or (y // ech) % CH == 0
                    sheet[oy + y][ox + x] = 255 if on else (22 if grid else 0)
        png_write_gray(a.apercu, par * cw, rows * chh, sheet)
    if a.jeu: return jeu(a, frames, ops, lab, image, pose, poses, tailles, ecrire_poses, apercu, avant, garde_img)
    pas = []; total = 0
    for k, (fr, x, y, sens) in enumerate(film):
        sx, t, w, h = boite(fr, x, y, sens); sx += dx_ecran; t += dy_ecran
        sx = (sx + a.grain // 2) // a.grain * a.grain     # l'ancrage avance par pas de --grain points :
        g = sx - w if sens > 0 else sx                    # les deux sens restent miroirs l'un de l'autre
        col, row = g // CW, t // CH; W = (g + w - 1) // CW - col + 1; H = (t + h - 1) // CH - row + 1
        if col < 0 or col + W > 40 or row < 0 or row + H > 25:
            raise ValueError("pas %d (pose %d) : le personnage sort de l'ecran (case %d,%d, %d x %d) ; changez --depart, --sol ou le scenario" % (k, fr, col, row, W, H))
        # une seule pose pour les deux sens : celle tournee vers la gauche. Vers la droite, le moteur
        # retourne la fenetre ; le decalage de la pose rangee est alors celui du miroir.
        dec = g % CW if sens < 0 else (col + W) * CW - (g + w)
        pas.append((pose(fr, dec, t, w, h, W, H, row), col, row, sens > 0))
    total = tailles[0]
    kmax = max(p[3] for p in poses)
    if 2 * kmax > 94: raise ValueError("pose trop grande : %d cases pleines (47 au plus)" % kmax)
    total += 4 * len(pas) + 1
    if total > ROM_LIBRE:
        raise ValueError("%d octets de donnees : trop pour une ROM de 32 Ko (%d libres). Raccourcissez le scenario." % (total, ROM_LIBRE))
    with open(a.o, 'w', encoding='latin-1', newline='\r\n') as f:
        f.write("; prince_data.asm -- produit par pop2exl.py a partir de VOTRE exemplaire de SDLPoP.\n")
        f.write("; Ce fichier derive des images du jeu : ne le diffusez pas.\n")
        f.write("; %d poses, %d pas, %d octets, mode %s, grain %d\n" % (len(poses), len(pas), total, a.mode, a.grain))
        f.write("PR_SET          .equ    %d              ; taille d'un jeu de codes (la plus grande pose)\n" % kmax)
        f.write("PR_FLOOR        .equ    %d              ; ligne de cases du sol\n" % a.sol)
        f.write("pr_steps:                               ; pose (fort, faible ; bit 7 du fort : miroir), colonne, ligne ; 0 = fin\n")
        for i, c, r, mir in pas:
            f.write("        .byte   pr_p%d>>8%s,pr_p%d&$FF,%d,%d\n" % (i, "|$80" if mir else "", i, c, r))
        f.write("        .byte   0\n")
        ecrire_poses(f)
    apercu()
    print("%s : %d poses, %d pas, %d octets sur %d (%d %%) ; plus grande pose : %d cases ; apercu : %s"
          % (a.o, len(poses), len(pas), total, ROM_LIBRE, total * 100 // ROM_LIBRE, kmax, a.apercu))

if __name__ == '__main__':
    main()
