# EXLPRINCE — mode d'emploi rapide (version 1, 19-11-2026)

Fabriquer le jeu chez soi, à partir de son propre exemplaire de SDLPoP, puis y jouer dans l'émulateur
ou sur un vrai EXL100. Le détail de tout est dans `LISEZMOI.md`.

## Ce qu'il faut

- **Python 3** (rien à installer en plus).
- **SDLPoP** : le dossier qui contient `data/` et `src/`. Dans les commandes, c'est `.` : lancer les
  scripts depuis ce dossier, ou remplacer `.` par son chemin.
- **TASM 3.2** (`-tEXL`) et **obj2exl.exe**, avec `7020.equ` et `3556.equ` à côté de `prince_jeu.asm`.
- **Le plan du niveau** (`niv1.png`), fait dans SDLPoP par Maj+F12, triches actives (lancer le jeu
  avec `megahit`). Il ne sert qu'à l'import, une fois.

## Fabriquer le jeu

```
1. python3 pop2exl.py . --grain 8 --jeu --decalage 0                  poses du prince et des gardes
2. python3 niveau2exl.py . niv1.png --trames --ecraser                import du niveau 1 -> niveau.txt
      (il indique la valeur de --cram-debut à prendre)
3. python3 pop2exl.py . --grain 8 --jeu --decalage 0 --cram-debut N   avec ce N (par exemple 37248)
4. python3 niveau2exl.py niveau.txt                                   -> prince_niveau.cram
5. python3 intro2exl.py .                                             écran titre et musiques
6. tasm -tEXL -a -b prince_jeu.asm
   obj2exl.exe prince_jeu.obj prince_jeu.rom -t:ROM -r:0x0200 -p      -> prince_jeu.rom
```

L'étape 2 ne se fait qu'une fois : ensuite, on retouche `niveau.txt` (dans l'atelier, voir plus bas)
et on ne refait que l'étape 4.

| Ce qu'on a changé | Ce qu'on refait |
|---|---|
| `niveau.txt` (dans l'atelier ou à la main) | 4 (et 3 puis 4 si elle le demande, puis 6) |
| un nouveau `prince_jeu.asm` | 6 (et ce que sa livraison demande) |
| l'image ou la musique de l'introduction | 5 puis 6 |
| tout (nouvelle version des scripts) | 1 à 6 |

Si l'étape 4 répond « le niveau déborde sur les poses du prince... --cram-debut N » : refaire
l'étape 3 avec ce N, puis la 4, puis la 6.

## Retoucher le niveau : l'atelier

Ouvrir `atelier_decor.html` dans un navigateur, y charger `niveau.txt`, le modifier (caractères,
blocs, salles, types de case, boutons, gardes, couleurs, flammes des torches, bulles des potions...),
puis l'enregistrer et refaire l'étape 4. `niveau2exl.py` vérifie tout et dit ce qui ne va pas.

## Jouer dans l'émulateur

Charger `prince_jeu.rom` comme cartouche et `prince_niveau.cram` dans l'Exelmémoire, puis lancer.
L'écran titre et sa musique s'affichent ; une touche (ou la manette) lance la partie.

## Jouer sur un vrai EXL100

- **Avec EXLCART ou l'ExelPicoCart** : copier `prince_niveau.cram` dans l'Exelmémoire depuis le menu,
  puis lancer `prince_jeu.rom`.
- **Par cassette** (une Exelmémoire, sans cartouche programmable pour le niveau) :

  ```
  7. python3 cram2k7.py prince_niveau.cram     -> prince_niveau.k7
  8. python3 k72wav.py prince_niveau.k7        -> prince_niveau.wav   (environ 2 min 40)
  ```

  Sur l'EXL100, avec la cartouche EXELBASIC et l'Exelmémoire :
  1. Taper `CALL CROS`, puis `BKP`, puis `1` (`-TAPE->CRAM`), en validant par ENTRÉE.
  2. À `CRAM NAME?`, taper `PRINCE`.
  3. À `PRESS ENTER TO START`, lancer la lecture du `.wav` vers la prise magnétophone, puis ENTRÉE.
  4. Retour au menu du CROS : `DIR` montre le volume `PRINCE` ; [ESC] ramène au BASIC.
  5. Éteindre, mettre la cartouche du jeu (`prince_jeu.rom`), rallumer.

  Ne pas utiliser `FMT` ni `STR` dans le CROS : ils écraseraient le niveau. `BKP` puis `0` le
  sauvegarde sur une vraie cassette.

## Les commandes

| Action | Manette | Clavier |
|---|---|---|
| courir | gauche / droite | flèches |
| sauter sur place, grimper au rebord | haut | flèche haut |
| saut en longueur | diagonale haut-avant | `O` / `T` |
| s'accroupir ; près du bord, dos au vide : descendre en s'accrochant | bas | flèche bas |
| pas prudent ; boire une potion ; ramasser l'épée | feu | ESPACE |
| en sautant ou en tombant : se rattraper au rebord (feu tenu) | feu | ESPACE |
| en garde : frapper / parer / ranger l'épée | feu / haut / bas | ESPACE / flèche haut / flèche bas |

## Si quelque chose ne va pas

| Ce qu'on voit | Pourquoi | Que faire |
|---|---|---|
| page rouge au démarrage | pas de niveau dans l'Exelmémoire, ou un `.cram` d'un ancien format | charger `prince_niveau.cram` ; sinon refaire l'étape 4 |
| page magenta au démarrage | les poses du `.cram` ne sont pas celles de la ROM | refaire l'étape 4 après la 3, puis la 6 |
| l'assemblage ne trouve pas `sx_mort` | `prince_intro.asm` d'avant le 19-11-2026 19h00 | refaire l'étape 5 |
| « le niveau déborde sur les poses » | le niveau a grossi | étape 3 avec le `--cram-debut` indiqué, puis 4 et 6 |
| le CROS dit `Err 0,26` après `DIR` | un `.cram` d'avant le 19-11-2026 18h00 (pas encore un volume du CROS) | refaire l'étape 4, recharger |
| l'EXL100 ne lit pas le `.wav` | volume, polarité ou précision | volume du lecteur ; `k72wav.py --taux 48000`, `--inverse` |

## Ce qu'on ne diffuse pas

Tout ce que les scripts fabriquent à partir de SDLPoP : `prince_jeu_data.asm`, `prince_poses.bin`,
`prince_intro.asm`, le `niveau.txt` importé, `.cram`, `.k7`, `.wav`, la ROM et les aperçus. Seuls le
moteur, les scripts, l'atelier et ces documents se partagent.
