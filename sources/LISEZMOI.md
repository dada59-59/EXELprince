# EXLPRINCE — Prince of Persia sur EXL100 / EXELTEL

**Version 1 — 19-11-2026.** Un moteur de jeu « à la Prince of Persia » en assembleur TMS7020 pour
l'Exelvision EXL100 / EXELTEL, et les convertisseurs qui fabriquent chez vous, à partir de votre
exemplaire de SDLPoP, les poses du prince et des gardes, le niveau et l'écran titre.

Ce que fait la version 1 : le niveau 1 du jeu en entier, jouable au clavier et à la manette (course,
sauts, s'accrocher et grimper, se rattraper en tombant, épée et combats contre les gardes, potions,
grilles et boutons, sols fragiles, dalles du plafond, pics, porte de sortie, torches et bulles
animées, couleurs, bruitages, musiques de l'introduction et de la mort). Le niveau est dans
l'Exelmémoire (un vrai volume du CROS) ; la ROM se charge comme une cartouche. Vérifié dans
l'émulateur, et sur un vrai EXL100 avec l'ExelPicoCart.

**Pour commencer : `MODE_EMPLOI_RAPIDE.md`.** Ce LISEZMOI-ci est la référence détaillée.

## Ce que contient le dossier

| Fichier | Rôle |
|---|---|
| `prince_jeu.asm` | le moteur (TMS7020, TASM 3.2) : VERSION 1, 19-11-2026 19h30 |
| `joyexl.asm` | lecture de la manette infrarouge et du clavier (incluse par le moteur) |
| `7020.equ`, `3556.equ` | les définitions habituelles du TMS7020 et du TMS3556 |
| `pop2exl.py` | les poses du prince et des gardes, et leurs séquences, depuis SDLPoP → `prince_jeu_data.asm`, `prince_poses.bin` |
| `niveau2exl.py` | le niveau : import depuis SDLPoP et un plan (→ `niveau.txt`), puis compilation (→ `prince_niveau.cram`, volume du CROS) |
| `intro2exl.py` | l'écran titre, le thème et les musiques de la mort, depuis SDLPoP → `prince_intro.asm` |
| `decor2exl.py` | fonctions d'images utilisées par `niveau2exl.py` |
| `atelier_decor.html` | l'atelier : éditeur de `niveau.txt` dans le navigateur (caractères, blocs, salles, couleurs...) |
| `cram2k7.py` | met un `.cram` sur cassette (`.k7`), au format de la commande BKP de l'Exelmémoire |
| `k72wav.py` | fait d'un `.k7` de l'EXL100 le son à jouer vers la prise magnétophone (`.wav`) |
| `LISEZMOI.md`, `MODE_EMPLOI_RAPIDE.md` | ce document, et le mode d'emploi rapide |

Python 3 seul suffit (aucun module à installer). Pour assembler : TASM 3.2 (`-tEXL`) et `obj2exl.exe`.

## Ce qu'on diffuse, ce qu'on ne diffuse pas

- **Diffusables** : tous les fichiers de ce dossier. Ils ne contiennent rien de SDLPoP ni du jeu
  d'origine (les bruitages du moteur sont originaux).
- **À ne pas diffuser** : ce que les scripts fabriquent à partir de SDLPoP — `prince_jeu_data.asm`,
  `prince_poses.bin`, `prince_intro.asm`, un `niveau.txt` importé, `.cram`, `.k7`, `.wav`, la ROM, les
  aperçus et les captures. Ces images, niveaux et sons sont ceux du jeu d'origine et appartiennent à
  son éditeur. Chacun les convertit chez soi, à partir de son propre exemplaire.
- Les convertisseurs lisent quelques tables du code de SDLPoP (`seg006.c`, `seqtbl.c`, licence GPL v3)
  au moment de la conversion ; ils n'en recopient rien dans ce dossier.
- Un `niveau.txt` entièrement de votre main (caractères, blocs, salles) est à vous.

## Pilotage au clavier et à la manette (`--jeu`)

```
python3 pop2exl.py DOSSIER_SDLPOP --jeu          → prince_jeu_data.asm
tasm -tEXL -a -b prince_jeu.asm prince_jeu.obj
obj2exl.exe prince_jeu.obj prince_jeu.rom -t:ROM -r:0x200 -p
```

`prince_jeu.asm` inclut `prince_jeu_data.asm` et `joyexl.asm` ; le niveau est à part, dans l'Exelmémoire (lecture des manettes infrarouges, la même
routine que dans EXLCART). Avec les images de SDLPoP : 125 poses, 18 séquences, environ 18 Ko de ROM.
Il n'y a plus de ROM d'essai fournie : le niveau vient forcément de votre SDLPoP.

### Commandes

| Action | Manette (Exelvision, ou adaptateur DB9) | Clavier |
|---|---|---|
| courir | gauche / droite, tenu | flèches |
| arrêt | relâcher | |
| demi-tour | la direction opposée | |
| saut sur place, ou **grimper** s'il y a un rebord au-dessus devant | haut | flèche haut |
| saut en longueur | haut + avant (diagonale) | `O` (haut-droite), `T` (haut-gauche) |
| s'accroupir ; **dos au vide, près du bord : descendre en s'accrochant** | bas | flèche bas |
| **en sautant ou en tombant : se rattraper au rebord devant** (puis haut : monter ; lâcher : tomber) | feu, tenu | ESPACE |
| pendu au rebord : y rester | feu, tenu | ESPACE |
| un pas prudent : jusqu'au bord ; au bord, tâter du pied, puis avancer quand même | feu | ESPACE |
| en courant : saut, glissade | haut, bas | |
| boire une potion, ramasser l'épée (debout, devant ou dessus) | feu | ESPACE |
| **en garde** (avec l'épée, un garde devant) : frapper | feu (un coup par appui) | ESPACE |
| en garde : parer | haut | flèche haut |
| juste après une parade : riposter | feu | ESPACE |
| en garde : avancer, reculer | avant, arrière | flèches |
| en garde : ranger l'épée | bas | flèche bas |

Le personnage qui sort d'un côté de l'écran passe dans la salle voisine.

Limites connues :
- le clavier et la manette infrarouge n'envoient qu'**un code à la fois** : pour sauter en courant, il faut
  passer de la flèche de côté à la flèche haut (ou à la diagonale de la manette) sans attendre l'arrêt ;
- la zone d'échange `EXLJ`, où EXLCART écrivait la manette DB9, est retirée depuis le 19-11-2026
  18h30 (18 octets de ROM) ; la touche `B` aussi (18h45) : elle ne servait plus, on boit avec « feu »
  devant ou sur la potion.

### Comment ça marche

- **La cadence** : 12 pas par seconde, comme le jeu. La minuterie, qui joue aussi les sons, compte le
  temps (400 battements par seconde quand rien ne sonne) ; à la fin de chaque pas, `fr_wait` attend
  que 83 ms se soient écoulées depuis le précédent (`FRAME_U`). Mesuré dans l'émulateur : 12 pas par
  seconde dans une salle sans garde ; avec un garde, dessiner les deux personnages prend plus de 83 ms,
  et l'on tombe à 10,5-11 pas par seconde (contre 7,5 avec l'ancienne attente fixe).

- Déplacement **par case entière** : une seule pose par image du jeu, rangée tournée vers la gauche.
- Le moteur garde l'abscisse du jeu (`R_X`, 3,5 unités par case). Chaque pas l'avance dans le sens du
  personnage ; la table `pr_col` donne la colonne du bord avant. Les bords de l'écran sont découpés.
- Les séquences de `seqtbl.c` sont recopiées en blocs de pas (8 octets : pose, demi-tour, avance, décalage
  de l'image, ligne, règles).
- Les **règles** disent quand quitter une séquence. Elles sont dans la table `REGLES` de `pop2exl.py`,
  attachées aux images du jeu : `15` (debout), `7` à `14` (course), `109` (accroupi). Exemple :
  `('haut+avant', 'standjump')`. Pour ajouter un mouvement, il suffit d'y ajouter une ligne avec le nom
  d'une séquence de `seqtbl.c` : le convertisseur suit les enchaînements et ajoute les poses nécessaires.
- Pas de chute ni d'obstacle pour l'instant : le décor est une image de fond, le personnage marche sur la
  ligne `--sol`. `--depart` donne la colonne de départ.

### Le niveau : décor et carte logique (`niveau2exl.py`)

```
python3 pop2exl.py DOSSIER_SDLPOP --grain 8 --jeu --decalage 0 [--cram-debut 0x9E00]
        → prince_jeu_data.asm (pour la ROM) et prince_poses.bin (poses pour l'Exelmémoire)
python3 niveau2exl.py DOSSIER_SDLPOP PLAN.png [--niveau 1] [--seuil 25 | --trames [55,60,80,95]] [--reprendre ANCIEN.txt] [--depart SALLE,ETAGE,CASE]
        → prince_niveau.cram (image de l'Exelmémoire : le niveau ET prince_poses.bin), niveau.txt, niveau.png
```

**Dans cet ordre, et dans le même dossier** : `niveau2exl.py` range dans le `.cram` les poses que
`pop2exl.py` a mises de côté (les plus grosses, de `--cram-debut` à `$BADF`), ce qui libère autant de ROM. Chaque fois que le prince est reconverti, il faut refaire le `.cram` (import ou
`niveau2exl.py niveau.txt`). Le moteur vérifie au démarrage l'empreinte de ces poses : si le `.cram` ne
correspond pas à `prince_jeu_data.asm`, il s'arrête sur une **page magenta** (page rouge : pas de niveau).
Le niveau doit tenir avant `--cram-debut` (`$9E00` par défaut : 7,7 Ko ; le niveau 1 en fait 5,1). Après
chaque import, `niveau2exl.py` dit où le niveau finit et, s'il reste de la place, la valeur de
`--cram-debut` qui la donnerait aux poses (puis relancer `pop2exl.py`, réassembler et relancer
`niveau2exl.py`) ; si le niveau déborde sur les poses, il le dit aussi, avec la valeur à prendre. Avec
`pop2exl.py … --tout-rom`, toutes les poses restent en ROM et `prince_poses.bin` n'est pas écrit.

L'import écrit aussi **`niveau.txt`**, le niveau en clair. Pour le modifier :

```
(éditer niveau.txt)
python3 niveau2exl.py niveau.txt        → prince_niveau.cram et niveau.png
(recharger le .cram ; la ROM ne change pas)
```

`niveau.txt` contient les caractères (`car N` : 10 lignes de 8 points en `#` et `.`), les blocs (`bloc N` :
6 lignes de 4 numéros de caractère, avec en commentaire le type de case où il sert le plus), les salles
(`salle N voisines G D H B`, puis 3 lignes de 10 numéros de bloc pour l'**image** et 3 lignes de 10 types
pour la **logique**) et le `depart`. L'image et la logique sont indépendantes : à vous de les garder
d'accord. L'import refuse d'écraser un `niveau.txt` existant (`--texte autre.txt` ou `--ecraser`).
Un `niveau.txt` importé dérive du jeu ; un niveau entièrement dessiné par vous est à vous.

Il faut le dossier de SDLPoP (pour `data/LEVELS/res20NN.bin`) **et** le plan du même niveau, fait dans
SDLPoP par **Maj+F12** (triches actives : lancer avec `megahit`). Sans toucher au clavier :
`prince megahit 1 --screenshot --screenshot-level` (le numéro est celui du niveau) enregistre le plan
dans `screenshots/screenshot_000.png` et quitte.

- **Trames** (`--trames`, conseillé) : au lieu d'un seuil unique (un point est allumé ou non selon sa
  luminosité, `--seuil`), chaque couleur du jeu prend une **trame** selon sa luminosité (0-255) : noir
  sous la 1re valeur, puis 25 %, 50 %, 75 % de points allumés, blanc au-dessus de la 4e. Sans valeur :
  `55,60,80,95` (pierres et faces claires en blanc, dessus des sols en 75 %, côtés des piliers et
  ombres en damier, joints et fond en noir), dans l'esprit de la version Macintosh. Les trames sont
  calées sur la grille des caractères (période de 2 points) : une surface unie donne partout le même
  caractère. `--trames` ajoute la ligne `murs pierres 7 50 20 3` (les murs sont générés ; leurs
  caractères importés passent en dernier dans le compte des 126). Sur le niveau 1 : 276 caractères
  différents hors murs (236 avec le seuil), ramenés à 126 par la fusion habituelle.
- **Reprendre un ancien niveau** (`--reprendre ANCIEN.txt`, avec `--texte NOUVEAU.txt`) : un nouvel import
  repart du plan de SDLPoP ; cette option y recopie ce qui avait été ajouté à la main dans l'ancien
  `niveau.txt` : le **départ**, la ligne **murs** si elle est en pierres, les **sols fragiles animés**
  (le bloc normal devient celui que le nouvel import met dans les mêmes cases ; les deux images de
  tremblement gardent seulement leurs retouches, posées sur la nouvelle image), les images **une fois
  tombées** et le bloc des **débris** (le bloc des mêmes cases dans le nouvel import ; un bloc qui n'est
  dans aucune salle est recopié tel quel), les **boutons en perspective** (refaits sur les nouvelles
  images comme l'outil « Fabriquer » de l'atelier, réglages de départ). Les retouches de dessin faites
  directement dans les salles ne sont pas reprises. Exemple :
  `python3 niveau2exl.py SDLPOP plan.png --trames --reprendre niveau.txt --texte niveau_trames.txt`.

- **Carte logique** : SDLPoP ne déduit rien de l'image. Un niveau, c'est 24 salles de 10 × 3 cases, chaque
  case ayant un type (vide, sol, mur, pics, grille, sol fragile...) et chaque salle ses 4 voisines. Le
  convertisseur recopie ces types et ces liens ; le moteur s'en sert pour les **murs** et le **passage
  d'une salle à l'autre** par les bords gauche et droit.
- **Apparence** : prise sur le plan. Une case du jeu fait 32 × 63 points ; ici **4 × 6 caractères**, soit
  32 × 60 : on retire 3 lignes par étage (une par rang de briques), et tout tombe sur des caractères
  entiers. La salle occupe les lignes 3 à 20 de l'écran.
- **Compacité** : les blocs de 4 × 6 caractères identiques ne sont rangés qu'une fois. Le niveau 1 entier
  tient en 126 caractères, 160 blocs et 64 octets par salle : environ 5,1 Ko.
- **126 caractères au plus** : s'il y en a davantage, `niveau2exl.py` fusionne les plus proches (ceux
  qui diffèrent de quelques points) jusqu'à ce que le décor tienne dans un seul générateur.
- **Murs générés** (ligne `murs GRAINE POINTS JOINTS [ECLATS]` dans `niveau.txt`, facultative) : les cases
  de type mur ne sont plus dessinées avec des blocs, mais avec 48 caractères faits par `niveau2exl.py` :
  8 joints (haut et bas de brique) et 16 briques pleines (haut, bas), en briques blanches à contour de
  mortier. Sur chaque caractère, un nombre tiré au hasard d'**écornures** (1 à 3 points noirs collés au
  mortier : briques ébréchées, au plus `ECLATS`, 0-20, 4 si absent) et de **points noirs isolés** au
  milieu des briques (au plus `POINTS`, 0-20) : certaines briques restent nettes, d'autres sont abîmées.
  `GRAINE` (0-255) change le tirage, `JOINTS` (0-100) la part de joints de 2 points. Le moteur choisit,
  pour chaque morceau de mur, une brique ou un joint d'après la salle, la case et la rangée (une table de
  256 nombres au hasard) : deux murs voisins ne se ressemblent pas, mais un même mur est toujours dessiné
  pareil. Les blocs des cases mur ne servent plus (l'éditeur les enlève à l'optimisation).
  Les 48 caractères de briques sont **dans le générateur BAGC1** (codes 64 à 111 ; le garde n'y emploie
  que les codes 1-27 et 33-59) : ils ne prennent **rien aux 126 caractères du décor** (BAGC2). Leur tuile
  vaut `$C0 + n` (bit 7 : BAGC1, comme le prévoit `attr_b`) ; là où le prince ou le garde passent devant
  un mur, le moteur va chercher le dessin de la brique dans sa table (`put_pose`, et le tremblement des
  dalles). Dans l'Exelmémoire, la table des 48 caractères (10 lignes de 48, celle du bas d'abord) suit
  les rangées : 480 octets de plus, donc `--cram-debut` augmente d'autant (`niveau2exl.py` donne la
  valeur). En-tête : `$8042` <> 0 si les murs sont générés, `$8043` la graine, `$8044-$8045` l'adresse
  de la table. Coût : environ 800 octets de ROM ; une salle pleine de murs se dessine en 50 000
  instructions au lieu de 30 000. L'aperçu `niveau.png` et l'éditeur (onglet « Murs ») montrent les
  mêmes murs que le moteur. `prince_jeu.asm` et `niveau2exl.py` du 17-11-2026 12h30 vont ensemble.
- **Murs en pierres, façon Macintosh** (ligne `murs pierres GRAINE FISSURES EPAIS OMBRE`, ou bouton
  « Pierres » de l'onglet « Murs » de l'éditeur) : le même placement que les briques (mêmes 48 places,
  même `wall_ch` dans le moteur, qui ne change pas), mais un autre dessin : pierre blanche, joint noir,
  **ombre en damier** en bas et à droite de chaque pierre (`OMBRE` : 1 à 4 points de large), coins
  arrondis contre le joint, et une **fissure** (chevron ou petit trait) sur `FISSURES` % des caractères
  (0-100). `EPAIS` (0-100) : part des joints de 2 points. Le damier est calé sur l'écran (période de
  2 points), si bien que deux pierres voisines se raccordent. Réglage de départ : `murs pierres 7 25 20 3`.
  Fabriqué entièrement par `niveau2exl.py` (rien n'est tiré de SDLPoP) ; l'éditeur fait le même calcul.
- **Sols fragiles qui cèdent** : jusqu'à 3 à la fois, chacun avec son compte à rebours (deux dalles
  voisines : la première cède, et la seconde aussi si le prince y a mis les pieds entre-temps ; avant,
  une seule cédait à la fois et le prince pouvait traverser la seconde). Quand la seconde tombe et
  que sa voisine est déjà un trou, elle prend l'image d'un vide à côté d'un vide (`niveau2exl.py` la
  met en `$BCFF`, avec `$BCFE` = 1 s'il y a deux fragiles voisines), et non plus le bout de dalle de
  sa voisine. Une fragile voisine qui reste debout (le prince n'y a pas marché) prend l'image d'une
  case de son type à côté d'un vide, ou à défaut celle d'un sol à côté d'un vide (son bord gauche),
  au lieu de garder une dalle coupée net ; elle n'a plus alors l'animation de la ligne `fragile`.
- **Boutons en perspective** : une dalle vue par le joueur est un parallélogramme qui déborde sur la case
  de droite ; un bouton s'enfonce donc sur deux blocs. Dans l'atelier, case bouton, « Bouton en
  perspective » : à partir des blocs de sol de la case et de sa voisine de droite, il fabrique les blocs
  du bouton relevé et les pose : la dalle, fermée par un trait noir en diagonale à droite (et à gauche
  quand le sol de la case de gauche continue), monte de 1 à 3 points ; enfoncé, c'est le sol d'origine
  (ligne `enfonce SALLE ETAGE CASE BLOC [BLOC_DE_LA_VOISINE]`). Le dessus de la dalle est trouvé tout
  seul, même quand un décor tramé la touche par-dessus ; sinon « dessus à la ligne » (0-19) le donne. Le moteur change les deux cases quand le prince monte sur le bouton ou en
  descend (la voisine seulement si elle montre encore l'image attendue : une dalle fragile voisine
  tombée reste un trou). Table des boutons : 7 octets par commande (31 au plus) : … bloc enfoncé, bloc normal, puis
  ceux de la voisine de droite (égaux : elle ne change pas).
- **Dalles qui tombent** : quand un sol fragile cède, sa dalle (la 5e rangée de son bloc : le dessus du
  sol) descend à l'écran au point près, de plus en plus vite (4, 8… 20 points par pas), à travers les
  vides et jusque dans la salle du dessous (2 à la fois au plus). Elle est dessinée dans 8 caractères
  à elle du générateur BAGC1 (codes 112-127), fondue avec le décor qu'elle traverse. Elle se brise en 3 morceaux (2 colonnes, 1, 1) : les petits
  prennent jusqu'à 5 points d'avance en accélérant (tables `fd_pc`, `fd_po`). Elle se pose sur la première case qui n'est pas un vide : si c'est du
  sol, la case devient des **débris** (type `debris`, le bloc de la ligne `debris BLOC`, sinon le bloc de
  débris le plus courant du niveau ; dans l'atelier : case fragile, « Débris »). Si le prince est sur
  cette case, il perd un point de vie. Tout est noté au journal : au départ du niveau, tout revient.
  En-tête : `$BCFC` = 1 (dalles qui tombent) + 2 (débris), `$BCFD` le bloc des débris.
- **L'image d'un sol fragile tombé** : `niveau2exl.py` la choisit seul (le trou le plus courant du
  niveau à côté d'une case du même genre que sa voisine de gauche : sol, pilier, vide…). Pour en
  imposer une : ligne `tombe SALLE ETAGE CASE BLOC` dans `niveau.txt`, ou dans l'atelier, case
  fragile, « Une fois tombée » (l'atelier montre le choix automatique). Sans animation, seule la
  dernière commencée tremble (décalée) ; avec, chacune tremble avec ses images.
- **Sols fragiles animés** (lignes `fragile BLOC -> BLOC BLOC [TEMPO]` dans `niveau.txt`, 14 au plus ;
  dans l'atelier : choisir une case fragile, « Tremblement », image 1, image 2 et tempo). `TEMPO` (1 à 8,
  2 si absent, le même pour toutes) : chaque image dure autant de pas (un pas : environ 0,1 s) ; un
  tremblement d'arrivée dure 6 x tempo + 1 pas. Une case fragile dont
  le bloc est le premier tremble en montrant le 2e, le 3e, puis de nouveau le premier
  (normal, 1, 2, normal…), au lieu du décalage de 2 points. Toutes les dalles fragiles de l'étage
  tremblent quand le prince **arrive sur l'étage** (en entrant dans la salle, en grimpant, en
  descendant) ou y **retombe** (normal, 1, 2, normal, 1, 2, normal) ; celle **sous ses
  pieds** tremble ainsi jusqu'à ce qu'elle tombe. Pour cette dernière, le bloc de la case change
  aussi dans la salle le temps de l'animation, pour que le prince soit dessiné devant l'image du
  moment ; il reprend son bloc normal avant de tomber, et si le prince meurt. Seules les 4 colonnes de la case changent (l'ancien tremblement décalait
  aussi celles de la case de droite, où déborde la dalle du jeu). **Une seule ligne suffit** :
  `niveau2exl.py` anime tout seul les autres blocs de sol fragile du niveau (un bord différent, une
  torche derrière…) en recopiant les retouches de la 1re ligne (les points de ses images qui diffèrent
  de son bloc normal) sur chacun d'eux, et le dit (« sols fragiles : N blocs de plus animés ») ; s'il
  ne reste plus de caractères libres (126), les cases qui en manquent reprennent celles des images de
  la 1re ligne (« animés en partie »). 14 animations en tout. En-tête : `$8046` le nombre (0-14)
  + 16 x (tempo - 1) ; la table (bloc normal, image 1, image 2) est en `$BCD2`, après celle des
  boutons (31 commandes au plus, puis 0 en `$BC99`). Les blocs des images sont protégés à
  l'optimisation, comme ceux des pics. Moteur et `niveau2exl.py` du 18-11-2026 18h00 vont ensemble.
- Le décor utilise le générateur BAGC2, le prince BAGC3, le garde BAGC1 (libre depuis que le décor tient
  en 126 caractères).
- Devant le décor, le personnage est fondu dans la case : le décor est éteint sous lui et sur un point
  **tout autour** de lui (à l'intérieur de la case), pour qu'il reste lisible devant un mur blanc.
- **Plafond** : comme dans le jeu, la ligne juste au-dessus de la salle montre la dalle (dernière rangée
  des blocs) de l'étage 2 de la salle du dessus ; rien s'il n'y a pas de salle au-dessus. Le personnage
  passe devant (en sautant ou en grimpant vers la salle du dessus). Avec les murs générés (ligne `murs`),
  les cases mur de cet étage y montrent le bas de leurs pierres (`ceil_ch`, même tirage que dans la
  salle du dessus) : avant le 18-11-2026 19h30, elles restaient noires.
  **Flamme des torches animée** (ligne `flamme HG HD BG BD`, ou « Flamme animée » dans l'onglet « Murs » de
  l'atelier ; moteur, `pop2exl.py` et `niveau2exl.py` du 19-11-2026 15h30) : les 4 caractères de la flamme,
  en carré (haut gauche, haut droite, bas gauche, bas droite). `pop2exl.py` reprend les 9 images de la
  flamme du jeu (`data/PRINCE`, res151-159, 16 x 18 points : 325 octets en ROM, table `pj_flam`) ; un pas
  sur deux, le moteur en recopie une au hasard (`animate_torch` du jeu) dans le générateur de ces 4
  caractères, lignes 2 à 19 du carré (la dernière garde aussi le haut de la torche). Toutes les torches
  changent ensemble ; environ 4 ms un pas sur deux. Ces 4 caractères s'animent partout où ils sont : ne
  pas s'en servir ailleurs (les dupliquer dans l'atelier). Sous le prince, la flamme reste celle d'origine.
  En-tête : `$804C-$804F`, les 4 codes (0 : flamme fixe).
  **Bulles des potions animées** (ligne `bulle CAR`, ou « Bulles de potion animées » dans l'onglet « Murs » ;
  moteur, `pop2exl.py` et `niveau2exl.py` du 19-11-2026 17h00) : le caractère des bulles au-dessus des
  potions. `pop2exl.py` reprend les 7 images des bulles du jeu (`data/PRINCE`, res166-172, 5 x 9 points,
  posées à 2 points du bord gauche du caractère, sous sa 1re ligne : 71 octets en ROM, table `pj_bul`) ; le
  moteur les recopie tour à tour dans tout ce caractère (`animate_potion` du jeu), un pas sur deux, en
  alternance avec la flamme (environ 2 ms). Pour placer les bulles au-dessus du goulot, c'est le dessin de
  la potion qu'on décale. Code du caractère en `$BBBF` (0 : bulles fixes).
  **Couleurs du décor** (ligne `couleur CAR COULEUR`, ou « Couleur » dans l'onglet « Caractère » de l'atelier ;
  moteur et `niveau2exl.py` du 19-11-2026 15h00) : ce caractère, partout où il est utilisé, prend cette
  couleur (noir rouge vert jaune bleu magenta cyan blanc) au lieu du blanc ; 7 caractères au plus (table
  `LV_COL` en $BBB0, entre les grilles et les boutons : rien de plus dans l'Exelmémoire). Là où passe le
  prince, la case prend sa couleur à lui le temps qu'il y est : à réserver au décor qu'il ne traverse pas
  (flammes, haut des murs). « Optimiser » ne fusionne pas deux caractères de couleurs différentes ;
  `--reprendre` garde la couleur des caractères qui gardent le même dessin. L'aperçu de l'atelier reste en
  blanc (la palette et l'éditeur de caractère montrent la couleur).
  **Plafond mince** (ligne `plafond BLOC`, ou « Plafond mince » dans l'onglet « Murs » de l'atelier) :
  chaque case non vide de cette ligne prend le caractère de sa colonne (0 à 3) dans la 6e rangée de ce
  bloc, par exemple un caractère avec un joint à gauche puis 3 caractères de dalle dont seules les
  lignes du bas sont dessinées (`42 43 43 43`). Les cases vides de la salle du dessus restent vides.
  En-tête : `$8047` = 1, `$8048-$804B` les 4 tuiles. Moteur et `niveau2exl.py` du 19-11-2026 09h30.
- **Devant ou derrière** : comme dans le jeu, la face avant d'un mur (les 4 colonnes de sa case) passe
  **devant** le personnage, qui disparaît derrière ; sa face de côté, dessinée en perspective sur la case
  voisine, reste derrière lui. Pendu à un rebord dont le mur est à droite, on ne voit presque plus le
  prince ; à gauche, on le voit en entier. Les piliers (colonnes 1 à 3 de leur bloc : le fût, sa face de
  côté et sa dalle ; la colonne 0, le bord où il s'agrippe, reste derrière lui) passent aussi devant lui, comme dans le jeu (`fore_id` de `tile_table`) : pendu au rebord
  d'un pilier ou en passant devant, il est derrière.
- La position du personnage par rapport au décor est celle du jeu (vérifiée sur le prince dessiné par
  SDLPoP sur le plan). Pour la décaler quand même : `pop2exl.py --jeu --decalage N` (N points vers la
  droite, négatif vers la gauche) ; seul l'affichage bouge, pas la logique.
- Le fichier produit dérive des images et des niveaux du jeu : **ne pas le diffuser**.

**Chute** : quand une image du jeu demande un sol (drapeau repris de `frame_table_kid`) et que la case
sous les pieds est vide, le personnage tombe jusqu'au premier sol, en passant dans la salle du dessous
s'il le faut. La réception dépend de la hauteur : un étage, accroupi (`softland`) ; deux, réception
dure (`medland`) ; trois et plus, **mort** (`hardland`), et le niveau recommence au départ après 2,5 s.
Si le puits se resserre (un mur sous la case d'où il tombe), le corps est repoussé dans la case libre d'à
côté, à 4 unités de son bord, et la chute continue, comme dans le jeu ; sans case libre à côté, il se pose.

**Pas prudent**, comme `safe_step` dans le jeu. Deux façons d'appuyer, un pas par appui : « feu » seul
(un pas à chaque appui sur « feu ») ou « feu » tenu + « avant » (un pas à chaque appui sur « avant », sans
relâcher « feu », comme Maj + flèche dans le jeu ; la manette infrarouge et le clavier
n'envoyant qu'un code à la fois).
- la case devant est un sol : un pas de 11 unités ;
- c'est un vide, un sol fragile ou un bouton : juste ce qu'il faut pour arriver au bord de sa case ;
- déjà au bord : la première fois, il **tâte du pied** sans avancer (`testfoot`) ; à l'appui suivant, il
  avance quand même d'un pas entier, sur le sol fragile ou dans le vide ;
- devant un mur : il s'arrête un peu avant, puis ne bouge plus.
Deux séquences du jeu servent (`step11`, dont le moteur limite l'avance, et `testfoot`).

La chute ne commence que lorsque le corps **et** le point situé `FALL_T` unités derrière lui sont au-dessus
du vide (3 par défaut, soit 7 points d'écran ; 0 = exactement comme le jeu).

**Grimpe** : debout, « haut » seul, comme dans le jeu (`check_jump_up`) :
- du vide au-dessus et un sol au-dessus **devant** : le personnage se place au bord de sa case, saute,
  s'agrippe et se rétablit à l'étage du dessus (dans la salle du dessus s'il le faut) ;
- le rebord **juste au-dessus** et du vide au-dessus derrière : il recule d'abord jusqu'au bord de la
  case de derrière, puis fait la même chose. Trop avancé sous le rebord (moins de 6 unités du bord
  avant), il saute sur place, sauf s'il est collé à un mur : il ne peut pas être plus loin du bord, il
  recule donc quand même (le jeu d'origine, lui, saute sur place) ;
- sinon, c'est le saut sur place : `highjump` (6 points plus haut) s'il n'y a rien au-dessus, `jumpup`
  s'il y a un sol ou un mur au-dessus (`jump_up` du jeu) : la tête cogne le plafond. Pendant `jumpup` et
  la retombée qui suit (une copie `hangdrop_c` de `hangdrop`), rien du personnage n'est dessiné au-dessus
  de la 1re ligne de son étage (bit 5 de la ligne du pas) : ses mains s'arrêtent sous le sol du dessus,
  à l'étage 0 sous le plafond (salle du dessus, ou rien). Moteur du 19-11-2026 10h00 et `pop2exl.py`
  du même jour : relancer `pop2exl.py` (puis `niveau2exl.py`) avant d'assembler.
  **Plafond cogné** (comme le jeu, à l'image 79 de `jumpup` : étiquette `pj_kup` que `pop2exl.py` place
  après elle, d'après le `SEQ_KNOCK_UP` du jeu) :
  - `check_press` : si la case au-dessus de celle du **poids à cette image** est un sol fragile, elle
    tremble `LS_DELAY` pas puis tombe. Le poids avance d'environ 5 unités pendant le saut : depuis la
    moitié droite d'une case, c'est la suivante (dans le jeu aussi : on fait tomber une dalle voisine) ;
  - sinon `check_knock` : les sols fragiles de la rangée du dessus tremblent, sans tomber (le jeu les fait
    trembler dans les deux cas ; ici, pendant qu'une dalle cède, les autres ne tremblent pas).
  Dans la salle (étage du dessus), elles tremblent comme les autres (animées si le niveau a des lignes
  `fragile`). Au plafond (étage 2 de la salle du dessus), les 4 colonnes de la case montent de 2 points un
  pas sur deux, par copie décalée : **aucun caractère ni bloc de plus**. La dalle tombée passe dans la
  salle affichée, s'y brise en débris et ôte un point de vie au prince s'il est dessous. Avec une ligne
  `plafond`, une case du plafond est pleine ou vide d'après le **type** de la case du dessus (un vide :
  rien ; sinon les 4 tuiles), plus d'après son image : une case tombée laisse un trou net. Une dalle qui
  passe dans la salle du dessous y apparaît dès le bas de la sienne. Moteur du 19-11-2026 12h00.
« Haut » avec « avant » encore tenu, le nez contre un mur (à moins de 10 unités) : un saut en longueur
n'irait nulle part, c'est donc traité comme « haut » seul (au clavier, la flèche du demi-tour reste souvent
enfoncée un instant).

**Se rattraper en tombant** (`check_grab` du jeu, moteur et `pop2exl.py` du 19-11-2026 13h30) : « feu » tenu
(la touche Maj du jeu), au premier étage passé de la chute (le jeu : tant qu'elle n'est pas trop rapide),
si la case du corps — 8 unités en arrière, comme le jeu — est du vide à l'étage du dessus et la case
devant un sol, le prince se place au bord de sa case et s'y pend (séquence `fallhang`, puis `hang1`).
**L'élan de la chute** (`start_fall` du jeu, moteur et `pop2exl.py` du 19-11-2026 14h00) : quand un saut
retombe dans le vide, la chute garde son élan, comme le jeu. Après un saut en course (image 44,
étiquette `pj_rj44`), séquence `rjumpfall` (9 unités vers l'avant) puis 3 unités par pas de chute libre ;
après un saut sur place (image 26, `pj_sj26`), `jumpfall` puis 2 ; sinon `stepfall` puis 1 (en lâchant
un rebord : 0). Sans cet élan, le prince retombait une demi-case trop court.
C'est ce qui permet un saut en course un peu court : salle 1, étage 0, en courant vers la gauche depuis
les cases 7 à 5, sauter juste avant le bord et tenir « feu » : il se rattrape à la dalle de la grille de
la salle 5 (la demi-dalle qu'on voit en case 0 de la salle 1, qui est une case vide).

**Pendu au rebord** (séquence `hang1` du jeu) : on y arrive en sautant d'en bas, ou d'en haut par « bas »
quand on tourne le dos au vide à moins de 6 unités du bord (`down_pressed` du jeu). Une fois pendu :
« haut » = se rétablir ; « feu » tenu = rester pendu, 3,5 s au plus (la durée de la séquence du jeu), puis
on lâche ; rien = se rétablir si on a sauté d'en bas, lâcher si on est descendu d'en haut. En lâchant, on
se pose debout s'il y a un sol sous le corps ou juste derrière lui (`hang_fall` du jeu : on descend ainsi
étage par étage des rebords empilés), sinon c'est la chute.

Simplifications par rapport au jeu : après un saut, on se rétablit sans avoir à tenir « haut » ; pas de
prise d'un rebord au vol pendant une chute ; pas de points de vie (deux étages ne coûtent rien) ; un
étage de 63 points du jeu est ramené à 60.

**Grilles et boutons** : un `bouton_ouvre` s'enfonce quand le prince a les pieds dessus et fait monter
ses grilles d'une ligne de caractères tous les 8 pas (`G_UP`, 3 s en tout) ; elles restent ouvertes tant qu'il est dessus, puis 50 pas
(4 s, `G_WAIT`), et redescendent d'une ligne tous les 25 pas (`G_SLOW`, 10 s en tout). Un `bouton_ferme`
les fait tomber tout de suite. Une grille arrête le prince tant qu'elle n'est pas ouverte aux 4/5 ; ses
barreaux sont au bout droit de sa case (les 4 dernières unités), comme dans le jeu. À chaque reprise,
grilles et boutons reviennent à leur état de départ.

- Dans le jeu, les barreaux sont dessinés sur la case **à droite** de la grille, au besoin dans la salle
  voisine : c'est l'image de cette case-là qui change. `niveau2exl.py` fabrique les 6 images (les
  barreaux remontés de 0 à 5 lignes) à partir de l'image fermée du plan et d'une image « sans
  barreaux » prise ailleurs dans le niveau : celle d'une grille ouverte s'il y en a une, sinon un sol nu.
  L'image du bouton enfoncé est un sol nu aux mêmes voisins.
- Les liens viennent du niveau de SDLPoP et sont écrits en clair dans `niveau.txt` :
  `bouton SALLE ETAGE CASE -> SALLE ETAGE CASE`, une ligne par grille commandée. Une grille ouverte au
  départ a le type `grille_ouverte`.
- Limites : 16 grilles et 63 commandes par niveau ; le prince ne passe pas accroupi sous une grille à
  moitié ouverte ; les images intermédiaires sont approximatives quand la case de droite est un bord de
  plateforme.

**Points de vie et potions** : trois triangles blancs (`HP_ATTR`) en bas à gauche (pleins, puis vides jusqu'au
maximum). Une chute de deux étages en coûte un ; trois étages, les pics ou le dernier point perdu tuent,
et le niveau reprend avec trois points. « Feu » debout avec une potion sous les pieds ou dans la case de
devant : le prince la boit (séquence `drinkpotion`), la case redevient un sol nu.

- `potion_vie` rend un point, `potion_grande` ajoute un point au maximum (8 au plus) et les rend tous,
  `potion_poison` en retire un ; `potion` (vide) ne fait rien. La nature vient du niveau de SDLPoP ; elle
  est rangée dans les 3 bits du haut du type de la case.
- La fiole du jeu est sombre et disparaît au seuil : `niveau2exl.py` la redessine en blanc avec un liseré
  noir, d'après l'image du jeu (`data/PRINCE`, petite ou grande fiole).
- L'image de la case sans potion est un sol nu aux mêmes voisins, pris ailleurs dans le niveau (même
  table que les sols fragiles, `$BD00` : 51 lignes en tout).
- Limites : l'effet est immédiat (au début de l'animation) ; la page est redessinée quand la potion
  disparaît ; les potions du jeu qui font flotter ou retournent l'écran ne font rien.

**Le départ du niveau 1** : comme dans le jeu, sans `--depart`, le prince arrive en tombant dans la
salle 1 (case 0 de l'étage du haut, un vide), et le jeu appuie lui-même sur le bouton de la salle 5
(étage 0, case 2), qui ferme la grille de la salle 5. Dans `niveau.txt` : `entree bouton 5 0 2` (à
chaque départ, après une mort aussi, le moteur appuie sur ce bouton et le relâche aussitôt).

**La porte de sortie** : celle du niveau (pas l'entrée, dans la salle de départ du jeu). Le plan la
montre fermée ; `niveau2exl.py` fabrique son image grande ouverte en peignant l'escalier du jeu
(`data/VDUNGEON`, `res344` et `res299`) à la place du battant, comme le fait le jeu : il dessine la
porte avec la case de droite (`sortie_d`), à 8 points de son bord gauche, et elle déborde sur la case
suivante. Ce sont ces deux cases qui changent d'image : la porte prend deux entrées de la table des
grilles (16 au plus en tout), qui changent d'image ensemble, une ligne de
caractères par cran, avec le cliquetis des grilles. Le bouton qui l'ouvre dans le jeu l'ouvre ici ;
elle monte comme une grille, mais reste ouverte. Grande ouverte, **« haut »** debout dans sa case, celle
de devant ou celle de derrière (comme le jeu) finit le niveau : le prince disparaît, une fanfare, puis
l'écran titre ; une touche, et le niveau recommence (l'Exelmémoire n'en contient qu'un). Dans
`niveau.txt` : `porte SALLE ETAGE CASE ouverte BLOC BLOC` (la case `sortie_g`, puis les images grande ouverte des deux cases à sa droite),
et la ligne `bouton … -> SALLE ETAGE CASE` du bouton qui l'ouvre.

**Le garde** : un par salle au plus, comme dans le jeu. `niveau2exl.py` lit leur place, leur sens et leur
niveau dans le niveau de SDLPoP, et leurs points de vie dans la même table que le jeu (3 au niveau 1). Ils
sont dessinés sur le plan, donc dans le décor : l'import les en efface (leur case et la suivante prennent
l'image la plus sobre des cases semblables du niveau). Dans `niveau.txt` :
`garde SALLE ETAGE CASE gauche|droite NIVEAU PV`.

- **Image** : le garde a **ses propres images** : `pop2exl.py` lit `frame_tbl_guard` (dans `seg006.c`) et
  `data/GUARD` de votre SDLPoP, comme le jeu, pour les images 150 à 189 (celles de l'escrime, les seules que
  le moteur donne au garde). Ces images sont en gris (le jeu les colore avec la palette du niveau) : toute
  leur silhouette est allumée, avec l'épée tenue par-dessus (`data/PRINCE` et `sword_tbl`, comme pour le
  prince). Chaque pose du prince qui a une image de garde est précédée en ROM de 4 octets : la pose du garde
  (fort, faible), l'écart de ligne et l'écart de décalage (le garde a ses propres `dx`, `dy` et hauteur).
  Le garde suit les mêmes séquences que le prince ; au dessin, il prend la pose désignée. Ces poses du
  prince restent en ROM (les 4 octets doivent y être), celles du garde vont où il y a de la place.
  31 poses de garde, environ 3 Ko ; en combat, le garde fait environ 8,3 pas par seconde au lieu de 8,7
  (ses silhouettes ont plus de cases pleines). `pop2exl.py … --sans-garde` revient aux poses du prince
  (sans `data/GUARD`, ou pour gagner la place). Le garde est **en blanc** : sa couleur est la constante
  `G_COUL` de `prince_jeu.asm` (`FWHITE` ; `FCYAN` pour le cyan d'avant, ou une autre couleur du
  TMS3556), qui sert aussi à ses points de vie. En blanc, le décor fondu dans ses cases garde sa couleur ;
  en cyan, il prend celle du garde. Comme le prince, il a **deux
  jeux de codes** écrits à tour de rôle (1 à 31 et 33 à 63 de BAGC1) : sa pose suivante s'écrit dans le jeu
  qui n'est pas à l'écran, il ne clignote donc pas. Le décor derrière lui est fondu dans ses cases (éteint
  sous lui et sur un point autour) ; une case n'ayant qu'une couleur, ce décor-là y prend la couleur du garde (sans effet en blanc).
  Une pose du garde a 31 cases pleines au plus. Quand le prince et lui se chevauchent, les cases vides du prince laissent voir le garde ; dans
  une case pleine des deux, c'est le prince qui est dessiné.
- **Combat** : au repos, il attend ; dès que le prince est sur son étage, il se met en garde et avance. Avec
  l'épée, le prince se met en garde tout seul en s'arrêtant face à un garde à moins de 70 unités. Les
  règles sont celles du jeu (`autocontrol_guard`, `check_hurting`) : distance mesurée comme le jeu, coup
  porté à l'image 154 entre 12 et 29 unités (8 si le prince n'a pas l'épée : il meurt d'un coup), paré si
  l'adversaire est à l'image 150 ou 161 ; le garde frappe, pare et avance avec les probabilités du jeu
  selon son niveau. Parer au moment où son coup arrive (image 153) fait parer tout de suite, comme le jeu.
  **La riposte** : « feu » pendant la parade (images 169 et 150) lance le coup court du jeu (image 162,
  puis le coup à partir de 152) ; il arrive pendant que le garde se remet de son coup paré : il ne peut
  pas le parer. C'est la façon de venir à bout des gardes qui parent bien.
- **Points de vie du garde** en bas à droite, en cyan. Mort, il reste à terre jusqu'à la reprise du niveau ;
  chaque garde garde aussi sa place quand on quitte sa salle et qu'on y revient.
- Le prince ne peut pas passer un garde vivant ; le garde reste dans sa salle et sur son étage.
- **Vitesse** : dessiner le garde prend environ un tiers de pas ; l'attente du pas est raccourcie d'autant
  (`G_DLY`), le jeu garde la même allure.
- Limites : pas de demi-tour du prince en garde (si le garde passe derrière lui, reculer) ; le garde ne
  suit pas le prince dans une autre salle, ni ne tombe ; pas de squelette ni d'ombre ; les cases du
  garde sur une face de mur sont cachées comme celles du prince.

**Épée** : « feu » debout avec l'épée sous les pieds ou dans la case de devant : le prince la ramasse
(séquences `pickupsword` puis `resheathe`), la case redevient un sol nu, et `SWORD` ($C7EC) passe à 1 pour
le combat. À la reprise après une mort, l'épée revient à sa place. Comme les potions, elle est redessinée
par `niveau2exl.py` en blanc avec un liseré noir, d'après l'image du jeu (`data/PRINCE/res160.png`), à plat
au bord gauche de sa case. Quand il la prend, la salle est redessinée deux fois en négatif, le temps d'un pas (`FLASH`, attribut
`FL_NEG` : dessin noir, fond blanc ; le prince n'est pas dessiné pendant ce pas). Pour les générateurs
alphanumériques, les 3 bits du bas de l'attribut sont la couleur du fond (d'où le fond bleu avec `INVERSE` = 4).
Limite : l'épée tenue en main n'est pas dessinée pendant l'animation.

**Pics** : ils sortent quand le prince est sur leur case ou une demi-case avant (et aussi quand il est
au-dessus, dans le vide), et rentrent 12 pas (1 s, `SP_HOLD`) après son passage. Comme dans le jeu, on les
traverse à petits pas ; ils tuent si on court ou saute dessus, ou si on tombe dessus. Le convertisseur
marque les images de course et de saut du jeu (7 à 14, 26, 34 à 39, 43) par le bit 6 de l'octet « ligne ».

- Les pics sortis ne sont pas sur le plan : `niveau2exl.py` pose les images du jeu (`data/VDUNGEON`, pics
  sortis en entier, avec un liseré noir pour les voir sur du blanc) sur l'image de la case. Dans
  `niveau.txt` : `pics BLOC -> BLOC` (image rentrée -> image sortie).
- Limites : une seule image (pas de sortie progressive) ; les pics qui débordent sur la case de droite
  dans le jeu ne sont pas dessinés ; 4 cases de pics sorties à la fois, 15 images différentes par niveau.

**Frémissement** : comme dans le jeu, quand le prince retombe sur un sol (fin d'un saut, d'une chute,
pied tâté au bord du vide), toutes les dalles fragiles de son étage tremblent 6 pas, sans tomber : c'est
ce qui les trahit. Le convertisseur repère ces pas dans les séquences du jeu (`SEQ_KNOCK_DOWN`) et les
marque par le bit 7 de l'octet « ligne ». Limite : les dalles doivent tenir dans une bande de 5 cases à
partir de la première de l'étage ; celles qui sont plus loin ne tremblent pas.

**Sol fragile** : une fois qu'on a posé le pied dessus, il tient 10 pas (0,8 s, `LS_DELAY`) en tremblant
(la dalle est redessinée un pas sur deux 2 points plus bas, avec 40 caractères libres du générateur du
prince, `$58`-`$7F` ; les cases où se trouve le prince ne bougent pas) puis tombe : la
case devient un vide, son image change et le prince tombe s'il y est encore. En courant, on a le temps de
passer. Le moteur modifie le niveau directement dans l'Exelmémoire et note chaque octet changé dans un
journal (`$BE00`) ; au départ du niveau, et à chaque reprise après une mort, le journal est rejoué à
l'envers : les dalles sont de nouveau là, même après une remise à zéro de la machine. L'image du trou est
choisie par `niveau2exl.py` (table en `$BD00`) : celle d'un vide du niveau qui a le même genre de voisin
à gauche. Manquent : le tremblement de la dalle, sa chute visible et les débris à l'étage du dessous ;
une seule dalle peut céder à la fois.

Les gardes et le prince visibles sur le plan font partie de l'image du décor (les gardes en sont effacés).

**La case du personnage**, comme dans le jeu : l'abscisse du jeu est celle du bord avant de l'image. La
case où sont les pieds se calcule à partir du **poids du corps**, donné image par image par
`frame_table_kid` (un octet de plus par pas). C'est elle qui sert pour la chute, la grimpe et le
changement de salle.

**Le niveau est dans l'Exelmémoire**, plus dans la ROM. `prince_niveau.cram` est une image de 16 384
octets (`$8000`–`$BFFF`, le format `.cram` des émulateurs) à charger avant de lancer la ROM. Elle commence
par `PNIV` (donc pas de démarrage automatique : pas de `$AA` en `$8000`) ; sans elle, ou si elle n'est pas
au format de ce moteur (version 4, en `$BC9A`), le moteur s'arrête sur une **page rouge**. Changer de
niveau, ou le retoucher, ne demande plus de réassembler.

**C'est un vrai volume du CROS** (le système de l'Exelmémoire, `CALL CROS` depuis l'EXELBASIC), comme
une Exelmémoire formatée par FMT, avec un seul fichier qui la remplit : `DIR` montre le volume `PRINCE`
et son fichier `PRINCE` (type `FXSP`, 16 327 octets, 0 octet libre). `DIR`, `TST` et `BKP` y marchent
sans rien changer ; `DEL` refuse d'effacer le fichier (il est protégé : le `P` du type). Ne pas utiliser
`STR` (démarrage automatique) ni `FMT`, qui écraseraient le niveau.

| Adresse | Contenu |
|---|---|
| `$8000` | `PNIV` |
| `$8004`–`$800B` | au CROS : la fiche vide qui clôt son répertoire, puis la fin du fichier (0, 0) |
| `$800C` | adresse de la table des rangées |
| `$8010`, `$8029` | adresse de chaque salle (forts, puis faibles) |
| `$8050` | les caractères du décor : 10 × 128 octets |
| `$8550` | 24 salles de 64 octets : 30 blocs, 30 types de case, 4 voisines |
| `$8B50` | les blocs, 7 octets chacun : les numéros de leurs 6 rangées (8 bits du bas), puis un octet de leurs 9es bits |
| ensuite | les rangées : 4 caractères chacune, rangées une seule fois (512 au plus ; la 0 est vide) |
| `--cram-debut` | poses du prince : `PO`, empreinte (2 octets), puis les poses (`prince_poses.bin`, dont les 2 premiers octets donnent l'adresse) |
| `$BAE0` | pics : paires (bloc des pics rentrés, bloc des pics sortis) |
| `$BB00` | grilles, 11 octets : adresse du type, adresse du bloc de l'image, 6 blocs (de fermée à ouverte), ouverture au départ (la porte de sortie y prend 2 entrées) |
| `$BBC0` | boutons, 7 octets par commande (31 au plus, puis 0) |
| `$BC9A` | version du format (4), puis le départ : salle, étage, abscisse ; `$BC9E` : l'entrée (adresse du type du bouton sur lequel le jeu appuie au départ ; 0 : aucun) |
| `$BCA0` | gardes : par salle, la case (`$FF` : aucun ; + `$40` en jouant : mort), puis `$80` s'il regarde à gauche + 16 × niveau + points de vie |
| `$BCD2` | sols fragiles animés |
| `$BD00` | sols fragiles : les blocs à changer quand l'un tombe |
| `$BE00` | journal des octets modifiés en jouant (vide dans le fichier) |
| `$BF00`–`$BFB8` | travail du moteur : dalles qui tremblent (`$BF00`, `$BF3C`), état et compteur des 16 grilles (`$BF50`, `$BF60`), pics sortis (`$BF70`), abscisse des gardes (`$BF7C`), le garde (`$BF94`-`$BFB8`) |
| `$BFC0`–`$BFCF` | au CROS : la fiche du fichier (attribut en `$BFD0`, liens, longueurs, nom) |
| `$BFD0`–`$BFFF` | au CROS : l'en-tête du volume (nom, haut et bas des fichiers, `$AA` en `$BFE1`, bas de la mémoire `$8004`, CRC en `$BFE5`, les 4 canaux) |

Le moteur ne lit ni n'écrit rien dans les zones du CROS. Le niveau 1 y occupe 5,1 Ko sur 16 (le reste,
jusqu'à `$BADF`, va aux poses). Sur la vraie machine, `bkp2cram.py --inverse` (outils d'EXLCART) en fait
un `.BKP`, et le menu EXLCART sait recopier un `.cram` de sa bibliothèque dans l'Exelmémoire.

**Sur une vraie Exelmémoire, par cassette** (sans EXLCART ni ExelPicoCart) : `cram2k7.py` fait du
`.cram` une cassette `.k7` au format de la commande BKP du CROS.

```
python3 cram2k7.py prince_niveau.cram      -> prince_niveau.k7
python3 k72wav.py prince_niveau.k7         -> prince_niveau.wav  (2 min 40 environ)
```

`k72wav.py` produit le son qu'écrirait le BIOS de l'EXL100 (trap 14), au cycle près : deux périodes
carrées par bit (un 1 : 0,84 ms ; un 0 : 1,6 ms), les temps entre les octets mesurés dans l'émulateur
en faisant tourner la routine du BIOS, à 2 457 600 cycles par seconde ; un silence entre deux blocs
(`--pause`, 0,5 s). Options : `--taux` (44100), `--8bits`, `--volume`, `--inverse` (le BIOS suit l'une
ou l'autre polarité), `--verifier` (relit le `.wav` et le compare au `.k7`). Il marche pour n'importe
quel `.k7` de l'EXL100 (programmes BASIC compris).

Sur l'EXL100, avec la cartouche EXELBASIC et l'Exelmémoire :

1. Taper `CALL CROS`, puis `BKP`, puis `1` (`-TAPE->CRAM`), en validant chaque fois par ENTRÉE.
2. À `CRAM NAME?`, taper `PRINCE` (le nom du volume : ses 4 premières lettres doivent être celles du `.k7`).
3. À `PRESS ENTER TO START`, lancer la lecture du `.k7` (un lecteur de `.k7` qui le joue en son), puis ENTRÉE.
4. Le CROS revient à son menu ; `DIR` montre le volume `PRINCE` ; [ESC] ramène au BASIC.
5. Éteindre l'EXL100, mettre la cartouche du jeu et rallumer : l'Exelmémoire garde son contenu.

Dans l'autre sens, `BKP` puis `0` (`-CRAM->TAPE`) sauvegarde le niveau sur une vraie cassette (après une
partie, le niveau garde les traces du jeu en cours : le moteur les efface au départ suivant).

BKP enregistre les 16 Ko de `$8000`-`$BFFF` tels quels, en deux blocs : un en-tête de 4 octets, puis
les 16 Ko. Après le chargement, le CROS vérifie un CRC 16 bits de toute la CRAM contre `$BFE5`-`$BFE6`
(`niveau2exl.py` et `cram2k7.py` l'y écrivent) ; s'il ne correspond pas, il affiche `Err 0,16` et
remet à 0 quelques octets de son en-tête. Le format des blocs vient du BIOS de l'EXL100 (trap 14).
Chaque bloc contient :

1. 255 × `$55`, puis `$70` ;
2. le nom, du 4e caractère au 1er (le 3e est inversé dans le bloc des données) ;
3. la fin, puis le début de la zone ;
4. les données, puis leur somme, deux fois.

Pour une autre image d'Exelmémoire, qui n'est pas un volume du CROS : `--nom` donne le nom, et
`--recalage ADR` recale le CRC avec deux octets libres (sans toucher à `$BFE5`-`$BFE6`).

**Place en ROM** : `prince_jeu.asm` commence en `$0200`, le début de l'espace cartouche (`-r:0x200` pour
obj2exl). Avec les images de SDLPoP, un niveau 1 allégé dans l'éditeur (3 781 octets) et `--cram-debut`
au plus juste, la ROM fait environ 22,7 Ko avec l'écran titre en noir et blanc (160 motifs), le thème du
jeu et les bruitages : il reste environ 9 Ko sur 31,5. Avec les murs générés et les images du garde
(17-11-2026), environ 24,5 Ko sans écran titre : il reste environ 7,5 Ko. La potion reste retirée des règles (15 poses, 2 Ko).

**Compression des poses (par quartets)** : chaque pose est rangée case par case ; ses octets forment un
flux de quartets (le fort d'abord) : `0 n` = n+1 octets nuls (1 à 16) ; `1` à `14` = l'un des 14 octets
non nuls les plus fréquents (table `pr_ntab`, faite par `pop2exl.py` pour vos images) ; `15 h l` = l'octet
`hl` en clair. Les poses du prince passent de 24,4 à 17,6 Ko (−6,9 Ko). Le décodage coûte environ
3 000 instructions par pose (1 700 avant) : en combat, environ 9,9 pas par seconde au lieu de 10,6 ; sans
garde, la cadence reste de 12. Ce format demande un `prince_jeu_data.asm` et un `prince_poses.bin` refaits
par le `pop2exl.py` du 16-11-2026 21h ou plus récent (un ancien fichier ne s'assemble plus : `pr_ntab`
manque).

## L'introduction : écran titre et musique (`intro2exl.py`)

Au démarrage, avant le jeu : l'écran titre de SDLPoP en noir et blanc (le palais, `data/TITLE/res51.png`,
avec le titre `res54.png` posé à sa place, comme le fait le jeu) et un petit air au buzzer. Une flèche, ESPACE ou la
manette (puis la relâcher) lance la partie.

```
python3 intro2exl.py DOSSIER_SDLPOP [--motifs 160] [--seuil 50]   → prince_intro.asm et intro.png (l'aperçu)
python3 intro2exl.py DOSSIER_SDLPOP --couleur        (en couleurs)
python3 intro2exl.py --image MON_IMAGE.png           (n'importe quelle image de 320 x 200 points)
python3 intro2exl.py --vide                          (pas d'image : la musique seule, sur fond noir)
python3 intro2exl.py DOSSIER_SDLPOP --musique original   (l'air original au lieu du thème du jeu)
```

- L'image devient 40 × 20 cases de 8 × 10 points (lignes 2 à 21 de l'écran). **Par défaut en noir et
  blanc** : un point est blanc si sa luminance dépasse `--seuil` (50 %). À 50 %, le titre, l'arche, le
  palais et le cadre restent nets, le ciel et les roches passent au noir ; à 45 %, l'or du ciel et les
  carreaux bleu clair apparaissent, plus chargé.
- Avec `--couleur` : deux couleurs par case parmi les 8 du TMS3556 ; les 16 couleurs du jeu sont
  ramenées à 8 par une table choisie à l'œil (`TITRE` dans `intro2exl.py`).
- En noir et blanc, l'image compte environ 400 motifs différents ; on garde les `--motifs` les plus
  utiles (160 par défaut, 252 au plus), chaque case prend le plus proche ou son inverse. Chaque motif
  coûte 10 octets de ROM, l'écran environ 0,9 Ko : 2,5 Ko en tout avec 160 motifs (2,2 Ko avec 128, à
  peine différent ; regardez `intro.png`). En couleurs, l'écran prend 1,35 Ko de plus.
- Les motifs vont dans BAGC2 puis BAGC3 (126 chacun), que le jeu recharge ensuite ; l'écran est rangé
  avec un octet par case (nouveau motif, motif donné, case précédente répétée, motif de la case du dessus).
- **La musique**, comme dans Exeltris : la minuterie bat deux fois par période de la note et
  l'interruption inverse le buzzer (`xorp %8,P6`). `intro2exl.py` l'écrit dans `prince_intro.asm`
  (table `mu_air`) :
  - avec un dossier SDLPoP, **le thème de l'introduction du jeu**, dans la version que le jeu joue sur
    le haut-parleur du PC (`data/IBM_SND2/res10054.bin`, le son 54 : 90 notes, 25 s), qui est déjà
    une seule voix en ondes carrées, comme le buzzer. Ses notes vont de 55 à 277 Hz, trop grave pour le
    buzzer : il est joué un octave plus haut (110 à 554 Hz ; `--octave 2` pour le monter encore,
    `--octave 0` pour l'essayer tel quel). Le prédiviseur de la minuterie est choisi d'après la note
    la plus grave. Notes liées, comme sur le PC, puis 1,5 s de silence avant de recommencer. 278
    octets de ROM. Il dérive du jeu : **ne pas le diffuser** ;
  - avec `--musique original` (ou sans dossier SDLPoP), l'air original (mode hijaz sur ré, 47 notes,
    148 octets), avec un court silence entre les notes.
  L'air tourne en boucle ; la minuterie est arrêtée quand la partie commence.
- `prince_intro.asm` fait avec l'image du jeu en dérive : **ne pas le diffuser**.

## Gagner de la place : pas répétés et gestes rares

- **Pas répétés** : une suite de pas identiques (même pose, même avance, mêmes règles) n'est écrite qu'une
  fois, suivie d'une ligne de répétition `0, $40, N, pas` : le moteur refait ce pas N fois de plus
  (`lp_rp` ; une répétition interrompue par une règle est oubliée à la fin de séquence suivante). La
  réception dure (31 fois la même image accroupie) passe ainsi de 383 à 130 octets. Ni dans les séquences
  du garde (le moteur y vise des pas par leur rang), ni autour d'une étiquette (`pj_fN`, `pj_kup`).
- **Gestes rares à une image sur deux** (`CLAIRSEMEES` en tête de `pop2exl.py` : ranger l'épée, ramasser
  l'épée, boire) : une image sur deux est remplacée par la précédente, gardée un pas de plus. Le geste dure
  autant, avec moitié moins de poses ; les deux pas identiques deviennent un pas répété. Retirer une
  séquence de `CLAIRSEMEES` lui rend toutes ses images.

Au 19-11-2026 13h00 (moteur et `pop2exl.py`), avec `--cram-debut 37312` : données 13 286 octets au lieu
de 14 707, environ 2,2 Ko de ROM libres.

## Les bruitages

Pendant la partie, la même interruption joue de courts bruitages (originaux, au buzzer), sans arrêter le
jeu. Une seule voix : un nouveau bruitage remplace celui qui sonne, **sauf si celui-ci est plus
important**. L'octet juste avant chaque table `sx_…` est sa priorité (petite = importante, comme la
`sound_prio_table` de SDLPoP) ; à priorité égale, le nouveau remplace l'ancien.

| Quand | Bruitage | Priorité |
|---|---|---|
| le prince entre dans la porte de sortie | fanfare | 1 |
| le prince meurt (6 pas après, dès que rien d'autre ne sonne) | musique de la mort : ordinaire, ou au combat s'il avait l'épée à la main | 2 |
| une parade (le prince ou le garde) | épées qui se croisent | 10 |
| un coup qui touche (le prince ou le garde) | coup sourd, descendant | 11 |
| une dalle fragile se brise sur le prince | fracas, puis le coup | 11 |
| empalé sur les pics (en tombant dessus ou en y courant) | choc métallique aigu, puis râle qui descend | 15 |
| chute de trois étages et plus | écrasement | 20 |
| réception dure (deux étages) | double choc | 25 |
| une dalle fragile se brise en touchant le sol, **même dans une autre salle** | fracas qui décroît | 26 |
| réception souple (un étage) | choc léger | 28 |
| il tombe de plus d'un étage (au 1er étage passé, s'il y a encore du vide) | son qui descend | 30 |
| une grille monte ou descend d'un cran / retombe fermée | cliquetis / choc sourd | 48 |
| des pics sortent (le prince s'approche ; rien quand ils rentrent) | clac métallique sec | 60 |
| il se cogne contre un mur (une fois : pas tant qu'il pousse au même endroit) | toc grave | 75 |
| sa tête cogne le plafond (saut sur place sous un sol) | toc | 75 |
| un bouton s'enfonce | clic | 102 |
| potion : un point de vie / grande potion / poison | glouglou / gamme montante / glissade | 125 |
| l'épée ramassée | arpège montant | 130 |
| un pas : le pied se pose (course, réception d'un saut, demi-tour en course) | tic | 160 |

**Les pas** suivent les `snd(SND_FOOTSTEP)` des séquences du jeu : `pop2exl.py` place une étiquette
`pj_fN` après chacun de ces pas et en dresse la table `pj_fst` ; le moteur fait « tic » quand le pas
affiché en est un (relancer `pop2exl.py` depuis le 19-11-2026 12h30).

**La musique de la mort** suit `play_death_music` du jeu : `sx_mortc` (le son 28 de SDLPoP, 6,5 s) si le
prince avait l'épée à la main (tué par le garde), sinon `sx_mort` (le son 24, 3 s : chute, pics, dalle).
Le niveau ne recommence qu'une fois la musique finie. Comme le thème de l'introduction, ces deux airs
viennent de votre SDLPoP (sa version pour le haut-parleur du PC, `data/IBM_SND1`) : `intro2exl.py` les
écrit dans `prince_intro.asm` (69 octets ; deux airs originaux avec `--musique original` ou sans
SDLPoP). Depuis le 19-11-2026 19h00, relancer `intro2exl.py` (étape 5), sinon l'assemblage ne trouve
pas `sx_mort`.

Ils sont dans les tables `sx_…` de `prince_jeu.asm`, au même format que l'air : on peut les changer sans
toucher au reste. Pendant un bruitage aigu, l'interruption prend du temps au jeu : ils restent courts et
sous 1 600 Hz.

## Ordre complet

Tout refaire depuis le jeu (dans le dossier où sont les scripts, `.` étant ton dossier SDLPoP) :

```
1. python3 pop2exl.py . --grain 8 --jeu --decalage 0
2. python3 niveau2exl.py . niv1.png --ecraser          (départ du jeu ; ou --depart SALLE,ETAGE,CASE)
      -> il dit la valeur de --cram-debut à prendre (« pour gagner ... octets de ROM »)
3. python3 pop2exl.py . --grain 8 --jeu --decalage 0 --cram-debut VALEUR
4. python3 niveau2exl.py niveau.txt
5. python3 intro2exl.py .
6. tasm -tEXL -a -b prince_jeu.asm
   obj2exl.exe prince_jeu.obj prince_jeu.rom -t:ROM -r:0x0200 -p
7. (vraie machine, par cassette) python3 cram2k7.py prince_niveau.cram   -> prince_niveau.k7
8. (vraie machine, par cassette) python3 k72wav.py prince_niveau.k7      -> prince_niveau.wav
```

Puis charger `prince_jeu.rom` (cartouche) et `prince_niveau.cram` (Exelmémoire) dans l'émulateur.

- `--ecraser` remplace `niveau.txt` : les retouches faites à la main (points de vie des gardes...)
  sont à refaire après un import.
- Si l'étape 2 ou 4 répond « ERREUR : le niveau déborde sur les poses du prince... refaites le prince
  avec --cram-debut N » : refaire l'étape 3 avec ce N, puis l'étape 4.
- Après une retouche de `niveau.txt` : l'étape 4 seule (et la 3 si elle le demande ; la ROM ne change
  que si la 3 a été refaite).
- Après un nouveau `prince_jeu.asm` : l'étape 6 seule, sauf si sa livraison dit le contraire.
- Livraison du 17-11-2026 (murs générés, images du garde) : tout refaire, étapes 1 à 6 (le format de
  `prince_jeu_data.asm` et du `.cram` change).
- L'étape 5 ne dépend pas des autres : elle ne se refait que pour changer l'image, la musique,
  `--motifs`, `--seuil` ou `--couleur`.
- Livraison du 19-11-2026 18h00 (le `.cram` devient un volume du CROS) : refaire les étapes 4 et 6.
- Livraison du 19-11-2026 19h00 (musique de la mort) : refaire les étapes 5 et 6.
- Page rouge au démarrage : pas de niveau dans l'Exelmémoire, ou un `.cram` d'un ancien format ; page magenta : les poses du `.cram` ne
  sont pas celles de la ROM (l'étape 4 n'a pas été refaite après la 3).

`decor2exl.py` ne sert plus qu'à `niveau2exl.py` (ses fonctions d'images) ; l'ancien décor d'une seule
salle (`decor.txt`, `prince_decor.asm`) ne sert plus.
