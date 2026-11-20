#!/usr/bin/env python3
"""cram2k7.py -- image d'Exelmemoire (.cram, 16 384 octets, $8000-$BFFF) -> cassette .k7 au format
de la commande BKP du CROS (CALL CROS, puis BKP, choix (1) -TAPE->CRAM) : sur un vrai EXL100 avec
une Exelmemoire, on recharge ainsi la CRAM depuis la cassette (le .k7 joue en son par un lecteur de .k7).

    python3 cram2k7.py prince_niveau.cram                  ->  prince_niveau.k7
    python3 cram2k7.py prince_niveau.cram -o niveau1.k7

Sur l'EXL100 (cartouche EXELBASIC + Exelmemoire) :
    CALL CROS   puis   BKP   puis   1   (TAPE->CRAM)
    CRAM NAME?: le nom du volume (PRINCE ; cram2k7.py le rappelle : les 4 premieres lettres comptent)
    PRESS ENTER TO START : lancer la cassette, puis ENTREE.
    Fin : retour au menu du CROS ; DIR montre le volume PRINCE et son fichier PRINCE ; [ESC] : BASIC.

Ce que fait BKP (CROS V1.5, J.-L. Jonca 1985, routine $E482 ; cassette : trap 14 du BIOS, $FCA1) :
  - deux blocs : un en-tete de 4 octets (charge en $C0FB-$C0FE, 1er octet 0), puis les 16 Ko
    $8000-$BFFF tels quels ;
  - chaque bloc : 255 x $55, $70, nom (4 octets, du 4e caractere au 1er), puis R31, fin (faible,
    fort), debut (faible, fort), les donnees, et leur somme (modulo 256) deux fois ;
  - le nom du bloc des donnees a son 3e caractere inverse ;
  - au rechargement, le CROS ne prend que les blocs dont le nom est les 4 premieres lettres du
    nom tape a CRAM NAME?, puis verifie un CRC 16 bits de la CRAM (sans $BFE5-$BFE6) contre les
    deux octets $BFE5-$BFE6 (sinon I/O ERROR, mais les 16 Ko sont deja en place).

Les 16 Ko passent en entier. Le .cram de niveau2exl.py (format 4, 19-11-2026 18h) est un volume du
CROS ($AA en $BFE1) : le CRC va en $BFE5-$BFE6, comme le ferait BKP, et le nom de la cassette est
celui du volume. Pour une autre image (pas un volume du CROS), --nom donne le nom, et on recale le CRC
avec deux octets libres (--recalage ADR) pour ne pas toucher a $BFE5-$BFE6 ; sans cela, le CROS dit
I/O ERROR et remet a 0 quelques octets de son repertoire ($BFE2, $BFF0, $BFF5, $BFFA).
"""
import argparse, os, sys

TAILLE = 0x4000
CRC_A = 0x3FE5                      # $BFE5-$BFE6 : le CRC du CROS (R17, puis R18)
ENTETE = bytes([0x00, 0x50, 0x4B, 0x30])   # $C0FB-$C0FE ecrits par BKP (0, puis "PK0" : la commande et le choix)
R31 = 0xE6                          # octet sans role pour un bloc vers la memoire (BKP y laisse $E6)


def crc_cros(m):
    """CRC du CROS (routine $EF58) sur $8000-$BFFF sans $BFE5-$BFE6 -> (octet de $BFE5, octet de $BFE6)"""
    r17 = r18 = 0
    for i in range(TAILLE):
        if i == CRC_A or i == CRC_A + 1:
            continue
        a = m[i] ^ r17
        r17 = r18
        b = a
        a = 0
        for _ in range(8):          # xor B,A (C = 0) ; rlc B
            a ^= b
            b = (b << 1) & 0xFF
        r18 = a
        r17 ^= a >> 7               # rlc B ; rlc A ; xor A,R17
        r17 ^= ((a >> 1) & 1) << 7 | (a & 1) << 6   # rrc A ; rrc B ; rrc A ; rrc B ; xor B,R17
        r18 ^= a >> 2               # xor A,R18
    return r17, r18


def recale(m, pos, cible):
    """change m[pos], m[pos+1] pour que crc_cros(m) == cible (le CRC est lineaire : 16 inconnues)"""
    m[pos] = m[pos + 1] = 0
    base = crc_cros(m)
    vec = lambda c: c[0] << 8 | c[1]
    lignes = []                     # (effet sur le CRC, bit de l'inconnue)
    for k in range(16):
        m[pos + (k >> 3)] = 1 << (k & 7)
        lignes.append((vec(crc_cros(m)) ^ vec(base), 1 << k))
        m[pos + (k >> 3)] = 0
    # elimination de Gauss sur GF(2)
    piv = {}
    for e, x in lignes:
        for bit in sorted(piv, reverse=True):
            if e >> bit & 1:
                e ^= piv[bit][0]; x ^= piv[bit][1]
        if e:
            piv[e.bit_length() - 1] = (e, x)
    if len(piv) < 16:
        raise ValueError("ces deux octets ne suffisent pas a recaler le CRC")
    reste, x = vec(cible) ^ vec(base), 0
    for bit in sorted(piv, reverse=True):
        if reste >> bit & 1:
            reste ^= piv[bit][0]; x ^= piv[bit][1]
    m[pos], m[pos + 1] = x & 0xFF, x >> 8
    assert crc_cros(m) == tuple(cible)


def bloc(nom4, debut, donnees):
    """un bloc de cassette du BIOS EXL100 (trap 14, ecriture $FD5F)"""
    fin = debut + len(donnees) - 1
    s = sum(donnees) & 0xFF
    return (bytes([0x55] * 255 + [0x70]) + bytes(reversed(nom4))
            + bytes([R31, fin & 0xFF, fin >> 8, debut & 0xFF, debut >> 8]) + bytes(donnees) + bytes([s, s]))


def main():
    ap = argparse.ArgumentParser(description="image d'Exelmemoire .cram -> cassette .k7 (BKP du CROS)")
    ap.add_argument('cram')
    ap.add_argument('-o', '--sortie', help="le .k7 (defaut : le nom du .cram, en .k7)")
    ap.add_argument('--nom', help="nom a taper a CRAM NAME? (defaut : celui du volume ; 4 lettres au moins)")
    g = ap.add_mutually_exclusive_group()
    g.add_argument('--recalage', help="(pas un volume du CROS) adresse de deux octets libres pour recaler le CRC ; 'non' : CRC faux")
    g.add_argument('--crc', action='store_true', help="ecrire le CRC en $BFE5-$BFE6 (defaut pour un volume du CROS)")
    a = ap.parse_args()

    m = bytearray(open(a.cram, 'rb').read())
    if len(m) != TAILLE:
        sys.exit("%s : %d octets, une image d'Exelmemoire en fait 16384" % (a.cram, len(m)))
    volume = m[CRC_A - 4] == 0xAA                # $BFE1
    nom_vol = bytes(m[0x3FD1:0x3FDD]).decode('ascii', 'replace').rstrip()
    nom = (a.nom or (nom_vol if volume else 'PRINCE')).upper()
    if not 4 <= len(nom) <= 12 or any(not ' ' < c <= 'Z' for c in nom):
        sys.exit("--nom : de 4 a 12 caracteres, lettres majuscules, chiffres ou signes, sans espace")
    nom4 = nom[:4].encode('ascii')

    if volume and nom[:4] != nom_vol[:4]:
        print("attention : le volume s'appelle %s ; au rechargement, le CROS lui donnera le nom tape a CRAM NAME?" % nom_vol)
    if a.crc or (volume and not a.recalage):
        m[CRC_A], m[CRC_A + 1] = crc_cros(m)
        mode = ("volume du CROS %s, " % nom_vol if volume else "") + "CRC ecrit en $BFE5-$BFE6"
    elif not a.recalage:
        sys.exit("%s n'est pas un volume du CROS ($BFE1 <> $AA) : refaites-le avec niveau2exl.py, ou choisissez "
                 "--recalage ADR (deux octets libres), --recalage non ou --crc" % a.cram)
    elif a.recalage.lower() in ('non', 'aucun'):
        mode = "CRC non recale : le CROS dira I/O ERROR (les 16 Ko sont quand meme charges)"
    else:
        adr = int(a.recalage.replace('$', '0x').replace('&H', '0x'), 0)
        if not (0x8000 <= adr <= 0xBFFE) or {adr, adr + 1} & {0xBFE5, 0xBFE6}:
            sys.exit("--recalage : deux octets entre $8000 et $BFFF, hors de $BFE5-$BFE6")
        avant = m[adr - 0x8000], m[adr - 0x8000 + 1]
        recale(m, adr - 0x8000, (m[CRC_A], m[CRC_A + 1]))
        mode = "CRC recale par $%04X-$%04X : %02X %02X -> %02X %02X" % (adr, adr + 1, *avant,
                                                                          m[adr - 0x8000], m[adr - 0x8000 + 1])
        if avant != (0, 0) and avant != (0xFF, 0xFF):
            print("attention : $%04X-$%04X n'etaient pas vides (%02X %02X) : sont-ils vraiment libres ?"
                  % (adr, adr + 1, *avant))

    entete = bloc(nom4, 0xC0FB, ENTETE)
    nom_d = bytearray(nom4); nom_d[2] ^= 0xFF
    k7 = entete + bloc(bytes(nom_d), 0x8000, m)
    sortie = a.sortie or os.path.splitext(a.cram)[0] + '.k7'
    open(sortie, 'wb').write(k7)
    print("%s : %d octets (en-tete + 16384 octets de $8000-$BFFF) ; nom a taper : %s ; %s"
          % (sortie, len(k7), nom, mode))


if __name__ == '__main__':
    main()
