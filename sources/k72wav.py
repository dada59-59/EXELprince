#!/usr/bin/env python3
"""k72wav.py -- cassette Exelvision (.k7 : les octets enregistres) -> son (.wav) a jouer vers la prise
magnetophone de l'EXL100 / EXELTEL, comme une vraie cassette.

    python3 k72wav.py prince_niveau.k7                 ->  prince_niveau.wav
    python3 k72wav.py jeu.k7 -o jeu.wav --taux 48000 --pause 1

Le signal est celui qu'ecrit le BIOS de l'EXL100 (trap 14, routine $FD5F, bit par bit en $FDE5) :
  - chaque octet, du bit de poids fort au bit de poids faible ; chaque bit : deux periodes carrees
    (niveau bas, puis haut ; sortie : bit 3 du port P6) ;
  - un 1 : demi-periodes de 498, 509, 498, puis 548 cycles ; un 0 : 971, 982, 971, puis 1021 cycles ;
    la derniere demi-periode prend 7 cycles de plus quand le bit suivant est un 1 ;
  - entre deux octets, le temps du programme qui les envoie : 64 cycles de plus dans l'amorce, 72 apres
    l'octet $70, 80 dans le nom et les adresses, 205 entre deux donnees, 46 entre les deux octets de somme
    (mesures dans l'emulateur, en faisant tourner la routine du BIOS) ;
  - horloge : quartz de 4,9152 MHz, divise par 2 dans le TMS7020 : 2 457 600 cycles par seconde.
Un 1 dure ainsi 0,84 ms, un 0 1,6 ms : 16 Ko (une Exelmemoire) font 2 min 40 environ.

Un .k7 est une suite de blocs : 255 x $55 (l'amorce), $70, le nom (4 octets), 5 octets (registre, fin,
debut), les donnees, puis leur somme deux fois. Entre deux blocs : --pause secondes de silence (le
lecteur de l'EXL100 se recale sur l'amorce du bloc suivant). Le lecteur du BIOS ($FCA8, entree : bit 4
du port P4) suit l'une ou l'autre polarite.

--verifier relit le .wav (comme le BIOS : une periode par bit, courte = 1) et le compare au .k7.
Aucune dependance : Python 3 seul.
"""
import argparse, os, struct, sys, wave

HORLOGE = 2457600
DEMI = {1: (498, 509, 498, 548), 0: (971, 982, 971, 1021)}
SUIVANT_1 = 7
# temps ajoute apres le dernier bit d'un octet, selon sa place dans le bloc (et avant quoi)
ENTRE = {'amorce': 64, 'amorce>sync': 62, 'sync': 72, 'nom': 80, 'nom>adr': 85, 'adr': 80,
         'adr>data': 147, 'data': 205, 'data>somme': 128, 'somme': 46, 'fin': 0}


def blocs(k):
    """decoupe le .k7 en blocs [(octets, places)] ; places : pour chaque octet, sa place (cle de ENTRE)"""
    out, i = [], 0
    while i < len(k):
        j = i
        while j < len(k) and k[j] == 0x55: j += 1
        if j + 10 > len(k) or k[j] != 0x70:
            return None                                       # pas un .k7 de l'EXL100 bien forme
        r31, fl, fh, dl, dh = k[j + 5:j + 10]
        n = (fh << 8 | fl) - (dh << 8 | dl) + 1
        if n <= 0 or j + 12 + n > len(k): return None
        fin = j + 12 + n
        pl = (['amorce'] * (j - i - 1) + ['amorce>sync'] if j > i else []) + ['sync'] + ['nom'] * 3 + ['nom>adr'] \
             + ['adr'] * 4 + ['adr>data'] + ['data'] * (n - 1) + ['data>somme'] + ['somme', 'fin']
        out.append((k[i:fin], pl))
        i = fin
    return out


def demi_periodes(octets, places):
    """les durees (en cycles) des demi-periodes, en commencant par un niveau bas"""
    bits = [v >> (7 - b) & 1 for v in octets for b in range(8)]
    d = []
    for n, bit in enumerate(bits):
        a, b, c, e = DEMI[bit]
        if n + 1 < len(bits) and bits[n + 1]: e += SUIVANT_1
        if n % 8 == 7: e += ENTRE[places[n // 8]]
        d += [a, b, c, e]
    return d


def main():
    ap = argparse.ArgumentParser(description="cassette Exelvision .k7 -> .wav")
    ap.add_argument('k7')
    ap.add_argument('-o', '--sortie', help="le .wav (defaut : le nom du .k7, en .wav)")
    ap.add_argument('--taux', type=int, default=44100, help="echantillons par seconde (44100)")
    ap.add_argument('--pause', type=float, default=0.5, help="silence entre deux blocs, en secondes (0.5)")
    ap.add_argument('--volume', type=float, default=0.8, help="amplitude, de 0 a 1 (0.8)")
    ap.add_argument('--8bits', dest='b8', action='store_true', help="echantillons de 8 bits (sinon 16)")
    ap.add_argument('--inverse', action='store_true', help="inverser la polarite (le BIOS suit l'une ou l'autre)")
    ap.add_argument('--horloge', type=int, default=HORLOGE, help="cycles par seconde du TMS7020 (2457600)")
    ap.add_argument('--verifier', action='store_true', help="relire le .wav produit et le comparer au .k7")
    a = ap.parse_args()

    k = open(a.k7, 'rb').read()
    bl = blocs(k)
    if bl is None:
        print("attention : %s n'a pas la forme d'un .k7 de l'EXL100 (amorce, $70, nom, adresses, somme) : "
              "ses octets sont joues a la suite, sans pause" % a.k7)
        bl = [(k, ['nom'] * (len(k) - 1) + ['fin'])]
    sortie = a.sortie or os.path.splitext(a.k7)[0] + '.wav'
    amp = max(0.0, min(1.0, a.volume)) * (-1 if a.inverse else 1)
    haut, bas = (amp, -amp)
    ech = bytearray()
    def pose(niveau, n):
        if a.b8: ech.extend(bytes([max(0, min(255, int(round(128 + 127 * niveau))))]) * n)
        else: ech.extend(struct.pack('<h', int(round(32767 * niveau))) * n)
    t = 0.0; pos = 0                                       # temps (cycles) et echantillons poses
    def jusqua(niveau, t_fin):
        nonlocal pos
        n = int(round(t_fin * a.taux / a.horloge)) - pos
        if n > 0: pose(niveau, n); pos += n
    silence = int(a.pause * a.horloge)
    t += int(0.5 * a.horloge); jusqua(0.0, t)              # une demi-seconde de silence au debut
    for numero, (octets, places) in enumerate(bl):
        if numero: t += silence; jusqua(0.0, t)
        t += 2000; jusqua(haut, t)                         # le niveau haut du repos, juste avant
        niveau = bas
        for dp in demi_periodes(octets, places):
            t += dp; jusqua(niveau, t)
            niveau = haut if niveau == bas else bas
    t += int(0.5 * a.horloge); jusqua(0.0, t)
    with wave.open(sortie, 'wb') as w:
        w.setnchannels(1); w.setsampwidth(1 if a.b8 else 2); w.setframerate(a.taux)
        w.writeframes(bytes(ech))
    duree = pos / a.taux
    print("%s : %d bloc(s), %d octets -> %d min %02d s a %d Hz, %d bits"
          % (sortie, len(bl), len(k), int(duree) // 60, int(duree) % 60, a.taux, 8 if a.b8 else 16))
    if a.verifier:
        relu = relire(sortie, a.horloge)
        ok = [o for o, _ in bl] == relu
        print("verification : %d bloc(s) relu(s), %s" % (len(relu), "identiques au .k7" if ok else "DIFFERENTS du .k7"))
        if not ok: sys.exit(1)


def relire(chemin, horloge=HORLOGE):
    """relit un .wav de k72wav.py : les periodes entre deux fronts descendants ; une periode courte
    (moins de 1 500 cycles) : un 1 ; deux periodes par bit ; un silence separe les blocs"""
    with wave.open(chemin, 'rb') as w:
        taux, larg, n = w.getframerate(), w.getsampwidth(), w.getnframes()
        brut = w.readframes(n)
    v = list(brut) if larg == 1 else [s for (s,) in struct.iter_unpack('<h', brut)]
    zero = 128 if larg == 1 else 0
    signe = [1 if x > zero else -1 if x < zero else 0 for x in v]
    blocs_lus, per, precedent, dernier = [], [], 0, None
    def fin_bloc():
        if per:
            bits = [1 if p < 1500 else 0 for p in per[0::2]]
            blocs_lus.append(bytes(sum(b << (7 - j) for j, b in enumerate(bits[i:i + 8])) for i in range(0, len(bits) - 7, 8)))
            per.clear()
    for i, s in enumerate(signe):
        if s == 0:                                         # silence : fin du bloc
            if dernier is not None: fin_bloc(); dernier = None
            precedent = 0; continue
        if precedent == 1 and s == -1:                     # front descendant
            tc = i * horloge / taux
            if dernier is not None: per.append(tc - dernier)
            dernier = tc
        precedent = s
    fin_bloc()                                             # (le dernier bit n'a que sa 1re periode : elle suffit)
    return blocs_lus


if __name__ == '__main__':
    main()
