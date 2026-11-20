# EXELPRINCE — Prince of Persia sur EXL100 / EXELTEL

**Version 1 — 19-11-2026.** 
Un moteur de jeu « à la Prince of Persia » en assembleur TMS7020 pour
l'Exelvision EXL100 / EXELTEL - mode texte semi_graphique (non bitmap),
et les convertisseurs qui fabriquent chez vous, à partir de votre
exemplaire de SDLPoP, les poses du prince et des gardes, le niveau et l'écran titre.


Ce que fait la version 1 : le niveau 1 du jeu en entier, jouable au clavier et à la manette (course,
sauts, s'accrocher et grimper, se rattraper en tombant, épée et combats contre les gardes, potions,
grilles et boutons, sols fragiles, dalles du plafond, pics, porte de sortie, torches et bulles
animées, couleurs, bruitages, musiques de l'introduction et de la mort). Le niveau est dans
l'Exelmémoire (un vrai volume du CROS) ; la ROM se charge comme une cartouche. Vérifié dans
l'émulateur, et sur un vrai EXL100 avec l'ExelPicoCart.

### Commandes

| Action | Manette (Exelvision, ou adaptateur DB9 par EXELpicoCart) | Clavier |
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


Limites connues :
- le clavier et la manette infrarouge n'envoient qu'**un code à la fois** : pour sauter en courant, il faut
  passer de la flèche de côté à la flèche haut (ou à la diagonale de la manette) sans attendre l'arrêt ;

  
