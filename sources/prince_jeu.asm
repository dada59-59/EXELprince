; ============================================================================
; VERSION 1 -- 19-11-2026 19h30 (version 1 de reference : niveau 1 complet, .cram volume du CROS, musique de la mort, boutons pres d'une dalle tombee)
; PRINCE_JEU.ASM -- le personnage "a la Prince of Persia" pilote au clavier ou
; a la manette, sur EXL100 / EXELTEL, en caracteres semi-graphiques redefinis
; ============================================================================
;   tasm -tEXL -a -b prince_jeu.asm prince_jeu.obj
;   obj2exl.exe prince_jeu.obj prince_jeu.rom -t:ROM -r:0x200 -p
;
; Les donnees sont dans prince_jeu_data.asm, produit par
;       python3 pop2exl.py DOSSIER_SDLPOP --jeu
; (a partir de votre exemplaire de SDLPoP, ou du bonhomme d'essai).
; L'ecran titre est dans prince_intro.asm, produit par
;       python3 intro2exl.py DOSSIER_SDLPOP      (ou --image IMAGE.png, ou --vide : sans image)
;
; COMMANDES (manette Exelvision, ou adaptateur DB9 qui la remplace, ou clavier)
;   gauche / droite     courir (dans l'autre sens : demi-tour)
;   haut                saut sur place            haut + avant (diagonale) : saut en longueur
;   bas                 s'accroupir (tant que c'est tenu)
;   feu (ESPACE)        un pas prudent
;   en courant          haut : saut ; bas : glissade ; arriere : demi-tour ; relacher : arret
;   Au clavier, les diagonales de la manette sont les touches T (haut-gauche)
;   et O (haut-droite).
;   Le personnage qui sort d'un cote de l'ecran rentre par l'autre.
;
; AFFICHAGE : comme prince.asm (page mixte de 25 lignes de texte, deux jeux de
;   codes du generateur BAGC3 ecrits a tour de role, miroir par rev_tab), avec
;   en plus le decoupage aux bords de l'ecran.
;
; DEPLACEMENT : par case entiere. R_X est l'abscisse du jeu (unites de SDLPoP,
;   3,5 par case). Chaque pas avance R_X dans le sens du personnage ; la table
;   pr_col donne la colonne du bord AVANT du personnage. La fenetre de la pose
;   part de cette colonne (face a gauche) ou y finit (face a droite).
;
; DONNEES (prince_jeu_data.asm)
;   sequence : des pas de 9 octets : pose (fort, faible), drapeaux, avance
;              (signee), decalage de l'image (signe), poids du corps, ligne, regles
;              (fort, faible ; 0 = aucune) ;
;              puis la fin, 5 octets : 0, demi-tour, avance, sequence suivante.
;   regles   : 4 octets : masque, valeur, sequence (fort, faible) ; $FF = fin.
;              Apres l'affichage du pas, la premiere regle telle que
;              (entrees ET masque) = valeur fait sauter a sa sequence.
;              Entrees : bit0 haut, bit1 bas, bit2 arriere, bit3 avant,
;              bit4 feu.
;   pose     : largeur, hauteur (cases), nombre K de cases pleines ; le plan
;              (largeur x hauteur octets : 0 = vide, n = n-ieme pleine) ;
;              les motifs : case par case, 10 octets du bas vers le haut ; un
;              octet nul est suivi du nombre de nuls a la suite.
;              Tournee vers la gauche.
; ============================================================================
#include "7020.equ"
#include "3556.equ"

BAGC3_MOSAIC    .equ    $08
FONT_BAGC3      .equ    $7600           ; generateur BAGC3 (comme le menu EXLCART)
FONT_BAGC3_M2   .equ    $75FE
SCREEN_BASE     .equ    $0600           ; page : 25 lignes de 82 octets
SCREEN_BASE_M1  .equ    $05FF
LINE_LEN        .equ    82              ; 40 cases x 2 octets + 2 de controle
MIXT_NEXT_TEXT  .equ    $00
ATTR            .equ    FWHITE|$18|BBLACK   ; $18 = BAGC3 ; blanc sur noir
; Le decor a ses propres generateurs (alphanumeriques : 8 x 10 points, fond noir) :
; tuiles 1-127 dans BAGC2, tuiles 129-255 dans BAGC1 ; code = tuile ET $7F.
; (32 et 160 ne servent pas : le code $20 est le delimiteur.)
; --- le niveau : dans l'Exelmemoire ($8000-$BFFF), ecrit par niveau2exl.py (.cram) ---
; Le .cram est un volume du CROS (le systeme de l'Exelmemoire) avec un seul fichier, PRINCE : le CROS
; garde pour lui $8004-$800B (fin de son repertoire, fin du fichier) et $BFC0-$BFFF (la fiche du
; fichier, puis l'en-tete du volume : nom, pointeurs, $AA en $BFE1, CRC en $BFE5, canaux). Le moteur
; n'y lit ni n'y ecrit rien. "PNIV" ($8000-$8003) est sous la limite basse du CROS ($8004).
LV_SIG          .equ    $8000           ; "PNIV"
LV_VER          .equ    $BC9A           ; version du format : LV_VERS (sinon : page rouge, refaire le .cram)
LV_VERS         .equ    4
LV_ROOM0        .equ    $BC9B           ; depart : salle, etage (0 en haut), abscisse du jeu
LV_ETG0         .equ    $BC9C
LV_X0           .equ    $BC9D
dc_roomh        .equ    $8010           ; adresse de chaque salle, forts puis faibles (25 + 25 ; 0 : inutilise)
dc_rooml        .equ    $8029
LV_ENT          .equ    $BC9E           ; entree : adresse du type du bouton sur lequel le jeu appuie au depart (0 : aucun)
LV_ROWS         .equ    $800C           ; adresse de la table des rangees (4 caracteres chacune)
LV_WB           .equ    $8042           ; murs generes : <> 0 (0 : non)
LV_WS           .equ    $8043           ; ... leur graine
LV_WF           .equ    $8044           ; ... l'adresse de leurs 48 caracteres (10 lignes de 48, celle du bas d'abord),
                                        ;     copies dans le generateur BAGC1, codes 64-111 ; leur tuile : $C0 + n
LV_FN           .equ    $8046           ; sols fragiles animes (ligne "fragile") : nombre (0-14) + 16 x (tempo - 1) ;
LV_FT           .equ    $BCD2           ;   (bloc normal, image 1, image 2) pour chacun, apres la table des boutons
LV_PLF          .equ    $8047           ; plafond (ligne "plafond BLOC") : <> 0 : chaque case non vide du plafond
LV_PLR          .equ    $8048           ;   prend la tuile de sa colonne (0-3) parmi ces 4 (la 6e rangee du bloc)
LV_FLM          .equ    $804C           ; flamme animee (ligne "flamme") : les codes des 4 caracteres (haut gauche,
                                        ;   haut droite, bas gauche, bas droite ; 0 : pas d'animation)
FA_E            .equ    $C7C2           ; ... l'etage qui tremble
FA_P            .equ    $C7C3           ; ... la phase (0 : normal, 1 : image 2, 2 : image 1)
FA_B            .equ    $C7C4           ; ... le bloc de la case, puis l'image a montrer
FA_LR           .equ    $C7C5           ; ... la salle et l'etage du dernier pas pose (arriver sur un etage
FA_LE           .equ    $C7C6           ;     fait trembler ses dalles)
FA_SH           .equ    $C7C7           ; ... la case sous les pieds : l'adresse de son bloc dans la salle
FA_SL           .equ    $C7C8           ;     (0 : aucune), change le temps de l'animation pour que le
FA_SV           .equ    $C7C9           ;     personnage y passe devant ; et son bloc normal
WL_H            .equ    $C7C0           ; put_pose : la ligne courante des caracteres de briques, moins $C0
WL_L            .equ    $C7C1
WC_TI           .equ    $C7DE           ; wall_ch : la case (etage x 10 + case)
WC_RC           .equ    $C7DF           ; ... la place dans le bloc (ligne x 4 + colonne)
WC_X            .equ    $C7EF           ; ... (calcul)
CL_C            .equ    $C7CC           ; ceil_ch : la colonne
CL_R            .equ    $C7CD           ; ... la salle du dessus
CLIPF           .equ    $C7CE           ; le pas affiche se cogne au plafond (bit 5 de sa ligne) : la 1re ligne
CLIPR           .equ    $C7CF           ;   de son etage (0 : non) ; put_window : rien du prince au-dessus
SHK_E           .equ    $C7A0           ; tremblement : l'etage ($FF : le plafond, etage 2 de la salle du dessus)
LS_UP           .equ    $C7A1           ; ls_new : 0 = la case sous les pieds ; sinon k_up : etage du dessus + 2
KU_C            .equ    $C7A2           ; k_up : la case (0-9) de la dalle du dessus
SN_PR           .equ    $C7A3           ; son : la priorite du bruitage qui sonne (petite : important)
BMPX            .equ    $C7A4           ; l'abscisse du dernier choc contre un mur ($FF : il a bouge depuis)
REPAH           .equ    $C7A5           ; pas repetes : la ligne de repetition en cours (fort ; 0 : aucune),
REPAL           .equ    $C7A6
REPN            .equ    $C7A7           ;   et combien de fois il faut encore refaire le pas
FALLX           .equ    $C7A8           ; chute : l'elan vers l'avant, en unites par pas de chute libre (fall_x du jeu)
AB_C            .equ    $C7A9           ; attr_b : le caractere cherche, et la place dans LV_COL
AB_I            .equ    $C7AA
FLK             .equ    $C7AB           ; fl_anim : un pas sur deux (l'autre : les bulles)
BLK             .equ    $C7AC           ; bl_anim : l'image des bulles (0 a pj_bln - 1)
LV_BUL          .equ    $BBBF           ; bulles des potions animees (ligne "bulle") : le code du caractere (0 : non)
LV_COL          .equ    $BBB0           ; couleurs du decor (ligne "couleur") : paires (code, attribut), 0 a la fin ;
                                        ;   7 au plus (entre les 16 grilles et les boutons)
BLK0            .equ    $8B50           ; les blocs : 6 numeros de rangees (8 bits du bas), puis leurs 9es bits
LV_VF           .equ    $BCFE           ; deux sols fragiles voisins (0 : aucun) ; puis le bloc d'un vide dont
LV_VV           .equ    $BCFF           ;   la voisine de gauche est un vide
LV_FRAG         .equ    $BD00           ; sols fragiles : pour chacun, les blocs a changer quand il tombe
                                        ;   (case cle : fort, faible ; octet a changer : fort, faible ; bloc) ; 0 = fin
UNDO_N          .equ    $BE00           ; journal des octets du niveau modifies en jouant : nombre, puis
UNDO_E          .equ    $BE01           ;   (adresse fort, faible, ancienne valeur) ; rejoue a l'envers au depart
UNDO_MAX        .equ    84
dc_font         .equ    $8050           ; caracteres du decor : 10 x 128 octets, la ligne du bas d'abord
DC_W            .equ    128             ; police du decor : un seul generateur (BAGC2), 10 lignes de 128
                                        ; $8C50 : 24 salles de 64 octets ; $9250 : les blocs, 24 octets chacun
FONT_A          .equ    $7000           ; generateur BAGC2
FONT_A_M2       .equ    $6FFE
FONT_B          .equ    $6A00           ; generateur BAGC1
FONT_B_M2       .equ    $69FE
DK              .equ    $C600           ; tuile du decor sous chaque case pleine de la pose (47 au plus)
SET_A           .equ    $21             ; les deux jeux de codes : $21.. et $21+N..
                                        ; (le code $20 est le delimiteur du TMS3556 :
                                        ;  toute la case prend la couleur d'avant-plan)
FRAME_U         .equ    8533            ; un pas = 83,3 ms (12 images par seconde, comme le jeu), en unites de
                                        ; la minuterie (3/307200 s) : fr_wait attend que ce temps soit ecoule

; registres (libres : la ROM n'utilise que R2-R40)
RP              .equ    40              ; paire R39:R40 : donnees
R_TY            .equ    41              ; map_at : type de la case du jeu a cet endroit de l'ecran
RV              .equ    44              ; paire R43:R44 : adresse VRAM
RC              .equ    45              ; compteurs
RL              .equ    46
RS              .equ    48              ; paire R47:R48 : pas courant
R_SET           .equ    49              ; premier code du jeu affiche
R_COL           .equ    50              ; fenetre : colonne, ligne
R_ROW           .equ    51
R_OC            .equ    52              ; ancienne fenetre
R_OR            .equ    53
R_T             .equ    54
R_U             .equ    55
R_W             .equ    56              ; fenetre : largeur, hauteur (cases)
R_H             .equ    57
R_OW            .equ    58              ; ancienne fenetre
R_OH            .equ    59
R_K             .equ    60              ; cases pleines de la pose
RM              .equ    62              ; paire R61:R62 : plan des cases
R_MIR           .equ    63              ; bit 7 : face a droite (pose retournee, miroir)
R_X             .equ    64              ; abscisse du jeu
R_IN            .equ    65              ; entrees, vues du personnage
RR              .equ    67              ; paire R66:R67 : regles du pas
R_CC            .equ    68              ; put_window : colonne ecran courante
R_F             .equ    69              ; put_window : adresse deja posee sur cette ligne
RD              .equ    71              ; paire R70:R71 : decor (carte, motifs)
R_G             .equ    72
RN              .equ    74              ; paire R73:R74 : plan des cases, garde
R_G2            .equ    75
RE              .equ    80              ; paire R79:R80 : octet du decor
R_ROOM          .equ    81              ; salle courante (1-24)
R_ETG           .equ    82              ; etage du personnage (0 en haut)
RROOM           .equ    84              ; paire R83:R84 : la salle courante (30 blocs, 30 types, 4 voisines)
R_Q             .equ    85
R_Q2            .equ    86
R_Q3            .equ    87
R_NX            .equ    88              ; abscisse demandee
R_BUMP          .equ    89              ; <> 0 : un mur a arrete le personnage
R_RDW           .equ    90              ; <> 0 : la salle a change, page a redessiner
ROOM_TOP        .equ    3               ; ligne de caracteres du haut de la salle
T_WALL          .equ    20              ; type de case : mur
T_GATE          .equ    4               ; ... grille (les 3 bits du haut de l'octet : son ouverture, 0 a 5)
T_BOPEN         .equ    15              ; ... bouton qui ouvre
T_BCLOSE        .equ    6               ; ... bouton qui ferme
R_GB            .equ    77              ; paire R76:R77 : grilles et boutons (adresse d'un bouton, numero de grille)
R_GC            .equ    78
R_GD            .equ    97
R_GE            .equ    42
LV_GATE         .equ    $BB00           ; grilles, 11 octets : adresse du type (2), adresse du bloc de l'image (2 ; 0 : aucune),
                                        ; 6 blocs (de fermee a ouverte), ouverture au depart ; 0 a la fin
LV_BTN          .equ    $BBC0           ; boutons, 7 octets : adresse du type (2), grille ($FF : aucune), bloc enfonce, bloc normal,
                                        ;   puis ceux de la case a sa droite (la dalle du bouton y deborde ; egaux : rien).
                                        ;   31 au plus, puis 0 ($BC99) : l'en-tete du niveau suit (LV_VER, $BC9A)
BT_NH           .equ    $C7CA           ; bt_do : la voisine de droite changee (adresse de son type ; 0 : aucune)
BT_NL           .equ    $C7CB
G_ST            .equ    $BF50           ; etat des 16 grilles : 0 au repos, 1 s'ouvre, 2 ouverte (attente), 3 se referme, 4 tombe
G_TM            .equ    $BF60           ; ... et leur compteur de pas
BT_AH           .equ    $C7E7           ; le bouton enfonce (adresse de son type ; 0 : aucun)
BT_AL           .equ    $C7E8
G_WAIT          .equ    50              ; une grille ouverte le reste 50 pas (4 s), puis descend d'une ligne tous les 25 pas
G_SLOW          .equ    25
G_UP            .equ    8               ; ... et monte d'une ligne tous les 8 pas (3 s en tout)
T_SWORD         .equ    22              ; type de case : epee
FLASH           .equ    $C7ED           ; eclair (l'epee prise) : pas restants, la page en jaune un pas sur deux
LV_GARD         .equ    $BCA0           ; gardes : par salle, case ($FF : aucun ; + $40 : mort), $80 tourne a gauche + 16 x niveau + PV
G_REG           .equ    $BF94           ; le garde : l'image de ses registres de dessin (R39-R40, puis R49-R63)
GR_SET          .equ    G_REG+2
GR_COL          .equ    G_REG+3
GR_ROW          .equ    G_REG+4
GR_W            .equ    G_REG+9
GR_H            .equ    G_REG+10
GR_OH           .equ    G_REG+12
GR_RMH          .equ    G_REG+14
GR_RML          .equ    G_REG+15
GR_MIR          .equ    G_REG+16
G_ON            .equ    $BFA5           ; 0 : pas de garde dans la salle, 1 : vivant, 2 : mort
G_X             .equ    $BFA6           ; abscisse (unites du jeu, comme R_X)
G_ETG           .equ    $BFA7
G_RSH           .equ    $BFA8           ; son pas courant
G_RSL           .equ    $BFA9
G_HP            .equ    $BFAA
G_HPM           .equ    $BFAB
G_SKL           .equ    $BFAC           ; niveau d'escrime (0-3)
G_T             .equ    $BFAD           ; apres une blessure, il ne frappe plus pendant G_T pas
G_TAG           .equ    $BFAE           ; marque d'escrime de son pas (1 coup porte, 2 parade, 3 coup qui part)
K_SIDE          .equ    $BFAF           ; 0 : le prince est a gauche du garde, 1 : a droite
OT_EN           .equ    $BFB0           ; <> 0 : en dessinant le prince, les cases du garde restent
RND             .equ    $BFB1
K_ARM           .equ    $BFB2           ; <> 0 : le prince a l'epee a la main
K_TAG           .equ    $BFB3           ; marque d'escrime du pas du prince
G_JB            .equ    $BFB4           ; le garde vient de parer (il riposte autrement)
P_ATTR          .equ    $BFB5           ; attribut des cases pleines du personnage qu'on dessine
G_IDX           .equ    $BFB6           ; sa ligne dans LV_GARD
G_PLH           .equ    $BFB7           ; le debut du plan de sa pose
G_PLL           .equ    $BFB8
GX_TAB          .equ    $BF7C           ; l'abscisse de chaque garde quand on a quitte sa salle (0 : sa case de depart)
G_COUL          .equ    FWHITE          ; couleur du garde : FWHITE (blanc) ou FCYAN (cyan), ou une autre
G_ATTR          .equ    G_COUL|$18      ; ... avec BAGC3 ($18) : les points de vie du garde
GB_ATTR         .equ    G_COUL|$10      ; ... avec BAGC1 ($10) : le garde (doit differer de ATTR et P_ATTR)
GS_A            .equ    1               ; ... ses deux jeux de codes dans BAGC1, ecrits a tour de role
GS_B            .equ    $21             ;     (1-31 et 33-63 : une pose de 31 cases pleines au plus)
G_REFR          .equ    10
FLNEG           .equ    $C7EE           ; <> 0 : draw_room dessine en negatif
FL_NEG          .equ    $07             ; ... en noir ($00) sur fond blanc (7 : les 3 bits du bas, la couleur du fond)
SWORD           .equ    $C7EC           ; <> 0 : le prince a l'epee
T_POT           .equ    10              ; type de case : potion (les 3 bits du haut : 1 vie, 2 grande, 3 poison)
HP              .equ    $C7EA           ; points de vie, et leur maximum
HPMAX           .equ    $C7EB
HP_ROW          .equ    22              ; ... affiches sur cette ligne de l'ecran
HP_ATTR         .equ    FRED|$18|BBLACK ; ... en rouge (BAGC3, codes 1 : plein, 2 : vide)
T_SPIKE         .equ    2               ; type de case : pics (bit 5 de l'octet : sortis)
LV_SPK          .equ    $BAE0           ; pics : paires (bloc rentre, bloc sorti) ; 0 a la fin
SP_T            .equ    $BF70           ; les 4 cases de pics sorties : adresse du type (2 ; 0 : libre), pas restants
SP_HOLD         .equ    12              ; des pics restent sortis 12 pas (1 s) apres le passage
SPKF            .equ    $C7E9           ; <> 0 : le pas affiche est une image de course ou de saut
X_LEFT          .equ    58              ; abscisse du bord gauche de la salle ; une case = 14
X_RIGHT         .equ    198
X_FRONT         .equ    5               ; le mur arrete le personnage a cette distance
R_FL            .equ    91              ; drapeaux du pas : 1 demi-tour, 2 il faut un sol, 4 etage au-dessus,
                                        ;                   8 etage au-dessous, $10 image de chute libre, $20 les murs n'arretent pas,
                                        ;                   $40 image du mort, $80 pas prudent (avance limitee par LIMC)
R_FALL          .equ    92              ; <> 0 : en chute
R_FY            .equ    93              ; chute : decalage en lignes de caracteres
R_TC            .equ    94              ; tile_at : case (-1 a 10)
R_TE            .equ    95              ; tile_at : etage (-1 a 3)
R_Q4            .equ    96
R_FN            .equ    100             ; nombre d'etages de la chute en cours
LS_AH           .equ    $C636           ; sol fragile en train de ceder : adresse de sa case (type) dans le niveau
LS_AL           .equ    $C637
LS_T            .equ    $C638           ; (plus employe : voir LS_T0)
LSN             .equ    3               ; sols fragiles qui cedent en meme temps, au plus ; pour chacun :
LS_T0           .equ    $C750           ;   pas avant qu'il tombe (0 : place libre)
LS_H0           .equ    $C753           ;   adresse de sa case (type) dans le niveau, fort
LS_L0           .equ    $C756           ;   ... faible
LS_C0           .equ    $C759           ;   sa case dans la salle (0-9), son etage, sa salle (0 : pas de dessin)
LS_E0           .equ    $C75C
LS_R0           .equ    $C75F
LS_SH0          .equ    $C762           ;   sols animes : l'adresse de son bloc s'il est change (fort ; 0 : non),
LS_SL0          .equ    $C765           ;   ... faible
LS_SV0          .equ    $C768           ;   ... et son bloc normal
LS_K            .equ    $C76B           ; la place en cours
FDN             .equ    2               ; dalles qui tombent en meme temps, au plus ; pour chacune :
FD_R            .equ    $C76D           ;   sa salle (0 : place libre)
FD_C            .equ    $C770           ;   sa case (0-9)
FD_Y            .equ    $C773           ;   sa hauteur dans la salle, en points (0-179 ; une ligne : 10)
FD_V            .equ    $C776           ;   sa vitesse (points par pas : 4, 8... 20)
FD_E            .equ    $C779           ;   le prochain etage ou elle peut se poser (3 : la salle du dessous)
FD_K            .equ    $C77C           ;   son bloc (ses 2 dernieres rangees : la dalle)
FD_D            .equ    $C77F           ;   la salle ou elle est dessinee (0 : nulle part), et a quelle ligne
FD_DY           .equ    $C782
FD_I            .equ    $C785           ; la place en cours (+1, +2 : provisoires)
FD_DT           .equ    $C788           ; le decor sous ses 8 cases (2 lignes de 4)
FD_ST           .equ    $C790           ; les 4 caracteres de sa dalle (5e rangee de son bloc : le dessus du sol)
FD_P            .equ    $C794           ; (provisoire)
FD_O            .equ    $C79A           ; pour chacune de ses 4 colonnes : le haut de sa dalle, en points, sous
                                        ;   le haut de la 1re ligne dessinee (-4 a 10 ; les morceaux)
FD_L            .equ    $C795           ; ligne du generateur (0 : le bas du caractere)
FD_SY           .equ    $C796           ; ligne (0-19) dans les 2 cases, depuis le haut
FD_CODE         .equ    112             ; ses caracteres : BAGC1, codes 112 + 8 x place (8 chacune ; le garde
                                        ;   prend 1-59, les murs 64-111)
LV_DBF          .equ    $BCFC           ; dalles qui tombent : 1 (3 : et debris a l'arrivee, bloc LV_DBB)
LV_DBB          .equ    $BCFD
T_DEBRIS        .equ    14              ; type de case : debris
LS_NEW          .equ    $C76C           ; la derniere commencee (sans animation : la seule qui tremble)
LS_DELAY        .equ    10              ; un sol fragile tient 10 pas (~0,8 s)
T_LOOSE         .equ    11              ; type de case : sol fragile
AVL             .equ    $C639           ; pas prudent : <> 0 tant que "avant" n'a pas ete relache (feu tenu + avant)
STEPR           .equ    $C63A           ; pas prudent : <> 0 si le dernier pas a avance (au bord, on tate d'abord du pied)
FIREL           .equ    $C63B           ; pas prudent : <> 0 tant que "feu" n'a pas ete relache (un pas par appui)
HDOWN           .equ    $C63C           ; pendu : <> 0 si on est descendu du rebord (0 : on y a saute)
LIMC            .equ    $C63D           ; pas prudent : avance encore permise
FALL_T          .equ    3               ; on ne tombe que si le corps ET le point situe FALL_T derriere lui sont au-dessus du vide
DEADC           .equ    $C63E           ; mort : nombre de pas ecoules
DEAD_N          .equ    30              ; ... avant de recommencer le niveau (~2,5 s ; et la musique finie)
DM_T            .equ    6               ; ... avant la musique de la mort (le jeu : alive = 6)
R_WX            .equ    99              ; abscisse du poids du corps (la ou sont les pieds), moins 7 : comme le jeu
RF              .equ    98              ; paire R97:R98 : tampon des motifs
PBUF            .equ    $C640           ; motifs de la pose, decodes : 10 octets par case pleine (27 cases au plus : les codes $58-$7F servent aux dalles)
SHK_M           .equ    $BF00           ; dalles qui tremblent (dans l'Exelmemoire) : caracteres de la carte, 3 lignes de 20
SHK_K           .equ    $BF3C           ; ... et les colonnes qui tremblent (20)
SHK_ROOM        .equ    $C7E0           ; ... la salle (0 : pas de tremblement), la ligne du bas et la 1re colonne a l'ecran
SHK_ROW         .equ    $C7E1
SHK_COL         .equ    $C7E2
SHK_ONE         .equ    $C7E3           ; ... la seule case qui tremble, ou $FF : toutes les dalles fragiles de l'etage
SHK_P           .equ    $C7E4           ; ... impair : decalees
KNOCK           .equ    $C7E5           ; le pas affiche fait trembler les dalles de l'etage (reception d'un saut, d'une chute)
KN_T            .equ    $C7E6           ; ... et nombre de pas que ca dure encore
KN_N            .equ    6
SHK_CODE        .equ    $58             ; les 40 caracteres decales, a la fin du generateur BAGC3
R_A             .equ    0               ; A et B vus comme registres (TASM)
R_B             .equ    1

        .org    $0200                   ; debut de l'espace cartouche

start:
        dint
        mov     %$64,B                  ; pile : R101-R127, au-dessus de nos registres (R40-R99).
                                        ; Il lui faut une vingtaine d'octets : appels imbriques + interruption clavier
        ldsp
        movp    P49,A                   ; valide le connecteur de l'Exelmemoire (comme le menu EXLCART
        movp    P50,A                   ; et Exelnoid) : le niveau y est, en $8000
        movp    P40,A
        movp    P36,A
        movp    P40,A
        movp    P36,A
        movp    %$04,P45
        movp    %$10,P45
        eint
        movd    %$0000,TEMP8
        trap    13                      ; police ROM (comme le menu)

        movp    %TIMEBASE,P45
        movp    %CM1MASK,P45
        movp    %DECODER,P45
        movp    %CM2MASK|LINEZERO|BAGC3_MOSAIC,P45
        movp    %SCRMODE,P45
        movp    %CM3MASK|MIXTMODE,P45
        movp    %BORDER,P45
        movp    %CM4MASK|MBLACK,P45


        movp    %COL,P45                ; base de BAGC3
        movp    %FONT_BAGC3_M2&$FF,P45
        movp    %ROW,P45
        movp    %FONT_BAGC3_M2>>8,P45
        movp    %$0E,P45
        movp    %0,P45
        movp    %0,P45

        movp    %COL,P45                ; base de BAGC2 et de BAGC1 : le decor
        movp    %FONT_A_M2&$FF,P45
        movp    %ROW,P45
        movp    %FONT_A_M2>>8,P45
        movp    %$0D,P45
        movp    %0,P45
        movp    %0,P45
        movp    %COL,P45
        movp    %FONT_B_M2&$FF,P45
        movp    %ROW,P45
        movp    %FONT_B_M2>>8,P45
        movp    %$0C,P45
        movp    %0,P45
        movp    %0,P45

        movp    %COL,P45                ; BAPA = notre page
        movp    %SCREEN_BASE_M1&$FF,P45
        movp    %ROW,P45
        movp    %SCREEN_BASE_M1>>8,P45
        movp    %REGBAPA,P45
        movp    %0,P45
        movp    %0,P45

        movp    %COL,P45                ; BAMTF : fin de la memoire video
        movp    %$FE,P45
        movp    %ROW,P45
        movp    %$7F,P45
        movp    %$0F,P45
        movp    %0,P45
        movp    %0,P45

        lda     @LV_SIG                 ; le niveau est-il dans l'Exelmemoire ? ("PNIV" en $8000)
        cmp     %'P',A
        jne     @lv_ko
        lda     @LV_SIG+1
        cmp     %'N',A
        jne     @lv_ko
        lda     @LV_SIG+2
        cmp     %'I',A
        jne     @lv_ko
        lda     @LV_SIG+3
        cmp     %'V',A
        jne     @lv_ko
        lda     @LV_VER                 ; ... et au format de ce moteur ?
        cmp     %LV_VERS,A
        jne     @lv_ko
        lda     @pr_cflag               ; (pas de poses dans l'Exelmemoire : rien a verifier)
        jeq     @lv_ok
        lda     @PR_CRAMP                 ; les poses rangees dans l'Exelmemoire sont-elles les bonnes ?
        cmp     %'P',A                  ; ("PO" et l'empreinte de prince_jeu_data.asm, en PR_CRAMP)
        jne     @lv_kp
        lda     @PR_CRAMP+1
        cmp     %'O',A
        jne     @lv_kp
        lda     @PR_CRAMP+2
        cmp     %PR_CHASH>>8,A
        jne     @lv_kp
        lda     @PR_CRAMP+3
        cmp     %PR_CHASH&$FF,A
        jne     @lv_kp
        jmp     @lv_ok
lv_kp:  movp    %BORDER,P45             ; poses absentes ou d'une autre version : bord et page magenta
        movp    %CM4MASK|MMAGENTA,P45
        mov     %$B8,R_GD
        jmp     @lv_e
lv_ko:  movp    %BORDER,P45             ; pas de niveau : bord et page rouges
        movp    %CM4MASK|MRED,P45
        mov     %$38,R_GD
lv_e:   movd    %FONT_BAGC3+3,RV        ; (le bord ne se voit pas partout : toute la page, caractere plein)
        mov     %10,R_GE
lv_g:   movd    RV,TEMP1
        trap    8
        movp    %$FF,P46
        add     %128,RV
        adc     %0,RV-1
        djnz    R_GE,@lv_g
        movd    %SCREEN_BASE,RV
        movd    RV,TEMP1
        trap    8
        mov     %25,R_GE
lv_l:   mov     %40,R_GC
lv_c:   mov     R_GD,A
        movp    A,P46
        movp    %3,P46
        djnz    R_GC,@lv_c
        movp    %MIXT_NEXT_TEXT|MBLACK,P46
        movp    %0,P46
        djnz    R_GE,@lv_l
lv_st:  jmp     @lv_st
lv_ok:
        call    @joy_init               ; manettes et clavier : la touche qui fait commencer
        call    @intro                  ; l'ecran titre et la musique, jusqu'a une touche

; --- generateur : tout a zero (1280 octets), puis le caractere du sol --------
        movd    %FONT_BAGC3,RV
        movd    RV,TEMP1
        trap    8
        mov     %5,RL                   ; 5 x 256
        clr     RC
in_gen: movp    %0,P46
        djnz    RC,@in_gen
        djnz    RL,@in_gen
        movd    %FONT_BAGC3+1,RV        ; les triangles des points de vie : codes 1 (plein) et 2 (vide)
        clr     R_Q4
in_hp:  movd    RV,TEMP1
        trap    8
        mov     R_Q4,B
        lda     @t_hp(B)
        movp    A,P46
        lda     @t_hp+1(B)
        movp    A,P46
        add     %128,RV
        adc     %0,RV-1
        add     %2,R_Q4
        cmp     %20,R_Q4
        jne     @in_hp
; --- les tuiles du decor, dans leurs generateurs ---------------------------------
        movd    %dc_font,RD
        movd    %FONT_A,RV
        call    @up_gen
        mov     %DC_W>>8,A              ; plus de 127 tuiles : le second generateur
        jeq     @df_ok
        movd    %dc_font+128,RD
        movd    %FONT_B,RV
        call    @up_gen
df_ok:  lda     @LV_WB                  ; murs generes : leurs 48 caracteres dans BAGC1, codes 64-111
        jeq     @df_w                   ; (le garde n'emploie que les codes 1-27 et 33-59)
        lda     @LV_WF
        mov     A,RD-1
        lda     @LV_WF+1
        mov     A,RD
        movd    %FONT_B+64,RV
        mov     %10,RL
df_l:   movd    RV,TEMP1
        trap    8
        mov     %48,RC
df_b:   lda     *RD
        movp    A,P46
        add     %1,RD
        adc     %0,RD-1
        djnz    RC,@df_b
        add     %128,RV
        adc     %0,RV-1
        djnz    RL,@df_l
df_w:   clr     A
        sta     @FA_SH
        sta     @LS_SH0
        sta     @LS_SH0+1
        sta     @LS_SH0+2
        sta     @LS_T0
        sta     @LS_T0+1
        sta     @LS_T0+2
        sta     @FD_R
        sta     @FD_R+1
        sta     @FD_R+2

; --- la salle de depart ---------------------------------------------------------
restart:
        call    @lv_undo                ; le niveau redevient ce qu'il etait (sols fragiles tombes)
        call    @ls_rall                ; (et les dalles animees qui cedaient)
        call    @gt_reset               ; ... les grilles et les boutons aussi
        lda     @LV_ENT                 ; l'entree du niveau : le jeu appuie lui-meme sur un bouton
        jeq     @rs_e                   ; (niveau 1 du jeu : la grille de la salle 5 se ferme)
        mov     A,R_GB-1
        lda     @LV_ENT+1
        mov     A,R_GB
        mov     %2,R_GC                 ; enfonce (sans clic), il commande ses grilles...
        call    @bt_do
        clr     R_GC                    ; ... et remonte aussitot
        call    @bt_do
rs_e:
        clr     A                       ; pas d'epee (elle est revenue a sa place avec le niveau)
        sta     @SWORD
        sta     @FLASH
        sta     @FLNEG
        sta     @K_ARM
        sta     @OT_EN
        sta     @G_ON
        mov     %24,B                   ; les gardes reprennent leur place
rs_g:   sta     @GX_TAB-1(B)
        djnz    B,@rs_g
        mov     %ATTR,A
        sta     @P_ATTR
        mov     %3,A                    ; trois points de vie
        sta     @HP
        sta     @HPMAX
        call    @hp_draw
        clr     A
        sta     @LS_T0
        sta     @LS_T0+1
        sta     @LS_T0+2
        sta     @FD_R
        sta     @FD_R+1
        sta     @FD_R+2
        sta     @DEADC
        sta     @KNOCK
        sta     @KN_T
        sta     @SHK_ROOM
        sta     @FA_LR
        sta     @HDOWN
        sta     @STEPR
        sta     @FIREL
        sta     @AVL
        sta     @RIPF
        sta     @LS_UP
        sta     @REPAH
        sta     @FALLX
        sta     @CLIPF
        dec     A
        sta     @BMPX
        inc     A
        sta     @CLIPR
        lda     @LV_ETG0
        mov     A,R_ETG
        lda     @LV_ROOM0
        call    @set_room
        call    @draw_room

; --- le jeu --------------------------------------------------------------------
        call    @joy_init               ; manettes infrarouges et clavier (joyexl.asm)
        mov     %SET_A+PR_SET,R_SET     ; le 1er pas ecrira dans le jeu A
        movd    %pr_start,RS
        lda     @LV_X0
        mov     A,R_X
        clr     R_BUMP
        clr     R_RDW
        clr     R_FALL
        clr     R_FY
        clr     R_FL
        mov     %$80,R_MIR              ; face a droite
        clr     R_OW                    ; pas d'ancienne fenetre
        clr     R_OH
loop:
        cmp     %pj_hangdrop>>8,RS-1    ; la suspension est arrivee au bout de son temps (3,5 s) apres une
        jne     @lp_0                   ; descente : meme choix qu'en lachant (se poser, ou tomber)
        cmp     %pj_hangdrop&$FF,RS
        jne     @lp_0
        lda     @HDOWN
        jeq     @lp_0
        br      @hg_rel
lp_0:
        lda     *RS                     ; pas : pose (2), demi-tour, avance, decalage, ligne, regles (2)
        jne     @lp_go
        call    @next_s                 ; 0 : fin de sequence : demi-tour, avance, suite (2)
        btjz    %$40,A,@lp_j
        br      @lp_rp                  ; ($40 : refaire un pas, pop2exl.py "pas repetes")
lp_j:   push    A
        clr     A
        sta     @REPAH                  ; (une repetition interrompue est oubliee)
        pop     A
        call    @flags_a
        call    @next_s
        call    @move_a
        call    @k_clamp
        call    @next_s
        mov     A,R_T
        call    @next_s
        mov     A,RS
        mov     R_T,RS-1
        jmp     @loop
lp_go:  mov     A,RP-1
        call    @next_s
        mov     A,RP
        call    @next_s
        call    @flags_a
        call    @next_s
        call    @move_a
        call    @k_clamp
        call    @next_s                 ; decalage de l'image, dans le sens du personnage
        btjo    %$80,R_MIR,@lp_f
        inv     A
        inc     A
lp_f:   mov     A,R_Q4
        call    @next_s                 ; poids du corps par rapport a l'abscisse, dans le sens du personnage
        btjo    %$80,R_MIR,@lp_wx
        inv     A
        inc     A
lp_wx:  add     R_X,A
        sub     %7,A
        mov     A,R_WX
        btjo    %$A0,R_FL,@lp_rx        ; (pas en grimpant, ni pendant le pas prudent)
        cmp     %X_LEFT-6,A             ; c'est le corps qui change de salle, pas le bord avant ; 6 de marge
        jhs     @lp_rh                  ; de chaque cote : le poids du corps va et vient de quelques unites d'une
                                        ; image a l'autre, sans marge le prince repassait aussitot dans l'autre salle
        mov     %60,B                   ; sorti a gauche
        call    @nb_room
        cmp     %0,A
        jeq     @lp_rx
        call    @set_room
        add     %140,R_X
        add     %140,R_WX
        mov     %1,R_RDW
        jmp     @lp_rx
lp_rh:  cmp     %X_RIGHT+6,A
        jl      @lp_rx
        mov     %61,B                   ; sorti a droite
        call    @nb_room
        cmp     %0,A
        jeq     @lp_rx
        call    @set_room
        sub     %140,R_X
        sub     %140,R_WX
        mov     %1,R_RDW
lp_rx:  mov     R_Q4,A
        add     R_X,A
        mov     A,B
        lda     @pr_col(B)              ; colonne du bord avant
        mov     A,R_COL
        call    @next_s                 ; ligne (donnee pour l'etage du milieu)
        mov     A,R_ROW
        and     %$40,A                  ; bit 6 : une image de course ou de saut (les pics la transpercent)
        sta     @SPKF
        clr     A                       ; bit 5 : la tete cogne le plafond ("jumpup") : on ne dessine rien
        btjz    %$20,R_ROW,@lp_cf       ; du prince au-dessus de la 1re ligne de son etage (le haut des
        mov     R_ETG,B                 ; mains reste sous le sol du dessus)
        lda     @t_ctop(B)
lp_cf:  sta     @CLIPF
        btjz    %$80,R_ROW,@lp_k0       ; bit 7 : ce pas ebranle le sol
        mov     %1,A
        sta     @KNOCK
lp_k0:  and     %$1F,R_ROW
        call    @next_s
        mov     A,RR-1
        call    @next_s
        mov     A,RR
        add     %1,RS
        adc     %0,RS-1
        cmp     %0,R_FALL
        jeq     @lp_cj
        clr     R_BUMP                  ; en chute, les murs n'arretent rien
        btjz    %$10,R_FL,@lp_cj
        mov     R_X,A                   ; l'elan (fall_x du jeu) : FALLX unites vers l'avant par pas
        push    A                       ; de chute libre (arrete par un mur)
        lda     @FALLX
        call    @move_a
        clr     R_BUMP
        pop     B
        mov     R_X,A
        sub     B,A
        add     R_A,R_WX                ; (le poids suit)
        add     %3,R_FY                 ; image de chute libre : 30 points plus bas
        cmp     %3,R_FY
        jne     @lp_cj
        inc     R_FN
        inc     R_ETG                   ; un etage plus bas
        cmp     %3,R_ETG
        jl      @lp_f1
        mov     %63,B                   ; ... dans la salle du dessous
        call    @nb_room
        cmp     %0,A
        jne     @lp_f0
        mov     %2,R_ETG                ; pas de salle dessous : on se pose la
        jmp     @lp_ld
lp_f0:  call    @set_room
        clr     R_ETG
        mov     %1,R_RDW
lp_f1:  mov     %-3,R_FY
        call    @fl_grab                ; "feu" tenu en tombant : il se rattrape au rebord devant lui ?
        jne     @lp_fg
        br      @loop
lp_fg:  call    @under
        cmp     %T_WALL,A               ; le corps entre dans un mur (le puits se resserre) : repousse
        jne     @lp_f2                  ; dans la case libre d'a cote, il continue de tomber (comme le jeu)
        call    @fall_out
        jeq     @lp_cj
lp_f2:  call    @is_hole
        jne     @lp_ld
        cmp     %1,R_FN                 ; encore du vide : la chute continue ; au 1er etage passe, elle
        jne     @lp_cj                  ; fera plus d'un etage : le cri
        mov     %sx_fall>>8,A
        mov     %sx_fall&$FF,B
        call    @snd
lp_cj:  br      @lp_c1
lp_ld:  clr     R_FY                    ; un sol : on se recoit
        clr     R_FALL
        call    @under
        cmp     %T_SPIKE,A
        jne     @lp_l0
        br      @sp_kill                ; ... sur des pics
lp_l0:
        cmp     %2,R_FN
        jl      @lp_l1
        jeq     @lp_l2
lp_l3:  clr     A                       ; trois etages et plus : mort
        sta     @HP
        call    @hp_draw
        mov     %sx_splat>>8,A
        mov     %sx_splat&$FF,B
        call    @snd
        movd    %pj_hardland,RS
        br      @loop
lp_l2:  lda     @HP                     ; deux : reception dure, un point de vie en moins
        dec     A
        sta     @HP
        jeq     @lp_l3
        call    @hp_draw
        mov     %sx_medland>>8,A
        mov     %sx_medland&$FF,B
        call    @snd
        movd    %pj_medland,RS
        br      @loop
lp_l1:  mov     %sx_softland>>8,A
        mov     %sx_softland&$FF,B
        call    @snd
        movd    %pj_softland,RS         ; un : reception souple
        br      @loop
lp_c1:  cmp     %0,R_BUMP               ; arrete par un mur : ce pas n'a pas lieu, retour debout
        jeq     @lp_nb
        clr     R_BUMP
        lda     @HP                     ; (sauf mort : il reste a terre, et le niveau recommence)
        jeq     @lp_nb
        lda     @BMPX                   ; il se cogne : le bruit, sauf s'il n'a pas bouge depuis le dernier
        cmp     R_X,A                   ; (on pousse contre le mur : il recommence a courir et s'y cogne
        jeq     @lp_bq                  ; tous les 4 pas)
        mov     R_X,A
        sta     @BMPX
        mov     %sx_bump>>8,A
        mov     %sx_bump&$FF,B
        call    @snd
lp_bq:
        clr     A
        sta     @KNOCK
        mov     %14,R_GC                ; arrete par un mur au bord d'un trou : il y tombe
        call    @wall_hole
        jne     @lp_b0
        br      @nf_go
lp_b0:  movd    %pr_start,RS
        br      @loop
lp_nb:  lda     @BMPX                   ; un pas sans choc, ailleurs : le prochain choc sonnera
        cmp     R_X,A
        jeq     @lp_nc
        mov     %$FF,A
        sta     @BMPX
lp_nc:  cmp     %0,R_RDW                ; nouvelle salle : on redessine la page
        jeq     @lp_nr
        clr     R_RDW
        call    @draw_room
        clr     R_OW
        clr     R_OH
        clr     A
        sta     @GR_OH                  ; (le garde aussi est a redessiner en entier)
lp_nr:  btjz    %$40,R_FL,@lp_nd        ; image du mort : DM_T pas apres, la musique de la mort (des que
        lda     @DEADC                  ; rien d'autre ne sonne, comme play_death_music du jeu) ; apres
        cmp     %DM_T,A                 ; DEAD_N pas et la fin de la musique, le niveau recommence
        jne     @dm_c
        lda     @SN_ON
        jne     @lp_nd                  ; (un bruitage sonne encore : on attend)
        lda     @K_ARM                  ; l'epee a la main (tue par le garde) : la musique du combat
        jeq     @dm_r
        mov     %sx_mortc>>8,A
        mov     %sx_mortc&$FF,B
        jmp     @dm_s
dm_r:   mov     %sx_mort>>8,A
        mov     %sx_mort&$FF,B
dm_s:   call    @snd
        lda     @DEADC
dm_c:   cmp     %DEAD_N,A
        jhs     @dm_e
        inc     A
        sta     @DEADC
        jmp     @lp_nd
dm_e:   lda     @SN_ON
        jne     @lp_nd
        br      @restart
lp_nd:  mov     R_ETG,B                 ; la ligne est donnee pour l'etage du milieu
        lda     @t_eoff(B)
        add     R_A,R_ROW
        add     R_FY,R_ROW
        lda     *RP                     ; pose : largeur, hauteur, nombre de cases pleines
        mov     A,R_W
        call    @next_p
        mov     A,R_H
        call    @next_p
        mov     A,R_K
        add     %1,RP
        adc     %0,RP-1
        movd    RP,RM                   ; RM = le plan des cases (R_W x R_H octets)
        mov     R_H,B                   ; RP = les motifs, apres le plan
lp_m:   add     R_W,RP
        adc     %0,RP-1
        djnz    B,@lp_m
        btjz    %$80,R_MIR,@lp_w        ; face a droite : la fenetre FINIT au bord avant
        sub     R_W,R_COL
lp_w:
        cmp     %SET_A,R_SET            ; l'autre jeu
        jeq     @lp_b
        mov     %SET_A,R_SET
        jmp     @lp_s
lp_b:   mov     %SET_A+PR_SET,R_SET
lp_s:
        call    @g_step                 ; le garde (s'il y en a un) : son pas, son dessin, les coups
        call    @scan_dk                ; 0. le decor sous chaque case pleine
        call    @put_pose               ; 1. les motifs (decor compris), dans le jeu cache
        lda     @CLIPF
        sta     @CLIPR
        call    @put_window             ; 2. la fenetre, avec ce jeu
        clr     A
        sta     @CLIPR
        call    @erase_old              ; 3. les restes de l'ancienne
        mov     R_COL,R_OC
        mov     R_ROW,R_OR
        mov     R_W,R_OW
        mov     R_H,R_OH

        call    @fr_wait                ; cadence fixe : 12 pas par seconde, quel que soit le travail du pas

; --- le sol fragile : il tient LS_DELAY pas une fois qu'on a marche dessus ---------
        call    @hp_draw                ; les points de vie, reaffiches a chaque pas
        lda     @FLASH                  ; l'eclair : un pas sur deux, la salle est redessinee en negatif
        jeq     @fl_0                   ; (noir sur fond blanc) le temps d'un pas, puis normalement
        dec     A
        sta     @FLASH
        and     %1,A
        jeq     @fl_0
        mov     %1,A
        sta     @FLNEG
        call    @draw_room
        clr     A
        sta     @FLNEG
        mov     %1,R_RDW                ; (au pas suivant : la salle normale, et le personnage)
        call    @fr_wait
fl_0:
        lda     @LV_FN                  ; sols fragiles animes : arriver sur un etage (ou dans une salle)
        jeq     @fa_k                   ; fait trembler ses dalles, comme une reception
        btjz    %2,R_FL,@fa_k
        btjo    %$A0,R_FL,@fa_k
        cmp     %0,R_FALL
        jne     @fa_k
        lda     @FA_LR
        cmp     R_ROOM,A
        jne     @fa_g
        lda     @FA_LE
        cmp     R_ETG,A
        jeq     @fa_k
fa_g:   mov     R_ROOM,A
        sta     @FA_LR
        mov     R_ETG,A
        sta     @FA_LE
        mov     %1,A
        sta     @KNOCK
fa_k:   lda     @KNOCK                  ; il vient de retomber : les dalles fragiles de l'etage tremblent
        jeq     @kn_0
        clr     A
        sta     @KNOCK
        lda     @KN_T                   ; (un tremblement en cours, celui du plafond cogne par exemple :
        jne     @kn_0                   ; on le laisse finir)
        call    @ls_any
        jne     @kn_0                   ; (pas pendant qu'une dalle est en train de ceder)
        mov     %$FF,A
        call    @shk_init
        lda     @SHK_ROOM
        jeq     @kn_0
        call    @fa_kn                  ; (la duree : KN_N + 1 pas, ou 6 x tempo + 1 si animes)
        sta     @KN_T
kn_0:   lda     @KN_T
        jeq     @kn_1
        dec     A
        sta     @KN_T
        call    @shk_draw               ; (le dernier, pair, les remet en place)
kn_1:   clr     A                       ; les sols fragiles qui cedent (LSN au plus a la fois)
        sta     @LS_K
lk_l:   lda     @LS_K
        mov     A,B
        lda     @LS_T0(B)
        jeq     @lk_n
        dec     A
        sta     @LS_T0(B)
        cmp     %0,A
        jeq     @lk_b
        call    @ls_vis                 ; il tremble
        jmp     @lk_n
lk_b:   call    @ls_brk                 ; il tombe : la case devient un vide
lk_n:   lda     @LS_K
        inc     A
        sta     @LS_K
        cmp     %LSN,A
        jne     @lk_l
        call    @fd_step                ; les dalles qui tombent
ls_0:   btjz    %2,R_FL,@ls_1           ; (seulement les images posees sur le sol)
        btjo    %$A0,R_FL,@ls_1
        cmp     %0,R_FALL
        jne     @ls_1
        call    @under                  ; RD = l'adresse de la case sous les pieds
        cmp     %T_LOOSE,A
        jne     @ls_1
        call    @ls_new                 ; (s'il ne cede pas deja)
ls_1:   cmp     %pj_kup>>8,RS-1         ; la tete vient de cogner le plafond (image 79 de "jumpup") :
        jne     @ku_x                   ; une dalle fragile juste au-dessus tremble, puis tombe
        cmp     %pj_kup&$FF,RS          ; (check_press du jeu)
        jne     @ku_x
        call    @k_up
ku_x:   call    @fs_chk                 ; un pas qui pose le pied (snd(SND_FOOTSTEP) du jeu) : "toc"
        call    @fl_anim                ; la flamme des torches : une image au hasard
; --- les boutons : enfonce tant qu'on a les pieds dessus ; les grilles bougent -------
        clr     R_GB-1
        clr     R_GB
        btjz    %2,R_FL,@bt_c           ; (seulement les images posees sur le sol)
        btjo    %$A0,R_FL,@bt_c
        cmp     %0,R_FALL
        jne     @bt_c
        call    @under
        cmp     %T_BOPEN,A
        jeq     @bt_y
        cmp     %T_BCLOSE,A
        jne     @bt_c
bt_y:   movd    RD,R_GB
bt_c:   lda     @BT_AH
        mov     A,R_GD
        lda     @BT_AL
        mov     A,R_GE
        cmp     R_GB,A
        jne     @bt_ch
        mov     R_GD,A
        cmp     R_GB-1,A
        jeq     @bt_same
bt_ch:  mov     R_GB-1,A
        sta     @BT_AH
        mov     R_GB,A
        sta     @BT_AL
        cmp     %0,R_GD
        jeq     @bt_n
        mov     R_GD,R_GB-1             ; l'ancien remonte
        mov     R_GE,R_GB
        clr     R_GC
        call    @bt_do
        lda     @BT_AH
        mov     A,R_GB-1
        lda     @BT_AL
        mov     A,R_GB
bt_n:   cmp     %0,R_GB-1
        jeq     @bt_end
        mov     %1,R_GC                 ; le nouveau s'enfonce
        call    @bt_do
        jmp     @bt_end
bt_same:
        cmp     %0,R_GB-1
        jeq     @bt_end
        mov     %2,R_GC                 ; toujours dessus : la grille reste ouverte
        call    @bt_do
bt_end: call    @gt_run
; --- les pics : ils sortent a l'approche, et transpercent qui court ou saute dessus ---
        call    @sp_step
        lda     @SPKF
        jeq     @sp_s
        btjo    %$40,R_FL,@sp_s
        cmp     %0,R_FALL
        jne     @sp_s
        call    @under
        cmp     %T_SPIKE,A
        jne     @sp_s
sp_kill:
        mov     R_WX,A                  ; empale, au milieu de la case
        call    @tcol
        cmp     %10,A
        jhs     @sk_1
        mov     A,B
        lda     @t_x14(B)
        mov     A,R_X
sk_1:   clr     A
        sta     @SPKF
        sta     @HP
        call    @hp_draw
        mov     %sx_impale>>8,A         ; les pics le transpercent
        mov     %sx_impale&$FF,B
        call    @snd
        movd    %pj_impale,RS
        br      @loop
sp_s:
; --- le sol manque sous les pieds : la chute commence ----------------------------
        btjz    %2,R_FL,@nf_x
        btjo    %$A0,R_FL,@nf_x         ; (pas pendant la grimpe : le corps n'est pas encore au-dessus du rebord ;
                                        ;  ni pendant le pas prudent : il s'arrete toujours sur un sol)
        cmp     %0,R_FALL
        jne     @nf_x
        call    @under                  ; il faut du vide sous le corps...
        call    @is_hole
        jne     @nf_w
        call    @under_r                ; ... et aussi FALL_T derriere lui
        call    @is_hole
        jne     @nf_w
        jmp     @nf_go
nf_go:  mov     %1,R_FALL               ; la chute commence, selon le pas qui n'a pas trouve de sol
        clr     R_FY                    ; (start_fall du jeu) : apres un saut en course, avec son elan
        clr     R_FN                    ; (rjumpfall, puis 3 unites par pas) ; apres un saut sur place
        cmp     %pj_rj44>>8,RS-1        ; (jumpfall, 2) ; sinon stepfall, 1
        jne     @ng_1
        cmp     %pj_rj44&$FF,RS
        jne     @ng_1
        mov     %3,A
        sta     @FALLX
        movd    %pj_rjumpfall,RS
        br      @loop
ng_1:   cmp     %pj_sj26>>8,RS-1
        jne     @ng_2
        cmp     %pj_sj26&$FF,RS
        jne     @ng_2
        mov     %2,A
        sta     @FALLX
        movd    %pj_jumpfall,RS
        br      @loop
ng_2:   mov     %1,A
        sta     @FALLX
        movd    %pj_stepfall,RS
        br      @loop
nf_w:   mov     %8,R_GC
        call    @wall_hole
        jne     @nf_x
        br      @nf_go
nf_x:
; --- les entrees, puis les regles du pas ---------------------------------------
        lda     @HP                     ; mort (coup d'epee, chute, pics) : plus de commandes
        jne     @in_ok
        br      @loop
in_ok:
        lda     @joy_state0             ; manette infrarouge, fleches et ESPACE du clavier
        and     %$1F,A
        mov     A,R_IN
        btjo    %$80,R_MIR,@in_r        ; face a droite : droite = avant, c'est deja ca
        mov     R_IN,A                  ; face a gauche : on echange gauche et droite
        and     %$0C,A
        jeq     @in_r
        cmp     %$0C,A
        jeq     @in_r
        xor     %$0C,R_IN
in_r:   cmp     %(pj_readyblock+9)>>8,RS-1      ; la parade : "feu" = la riposte, comme le jeu (162, puis
        jne     @in_rp                  ; le coup a partir de 152 : il arrive avant que l'adversaire soit pret)
        cmp     %(pj_readyblock+9)&$FF,RS
        jne     @in_rp
        btjz    %$10,R_IN,@in_r9        ; image 169 (debut de la parade) : on s'en souvient
        lda     @FIREL
        jne     @in_r9
        mov     %1,A
        sta     @RIPF
        sta     @FIREL
        jmp     @in_r9
in_rp:  cmp     %0,RR-1                 ; image de parade (150, 161) ?
        jne     @in_rz
        cmp     %2,RR
        jne     @in_rz
        lda     @RIPF
        jne     @in_rg
        btjz    %$10,R_IN,@in_r9
        lda     @FIREL
        jne     @in_r9
        mov     %1,A
        sta     @FIREL
in_rg:  clr     A
        sta     @RIPF
        movd    %pj_blocktostrike,RS
        br      @loop
in_rz:  clr     A
        sta     @RIPF
in_r9:  movd    RS,RE                   ; en garde, l'epee a la main (images 158, 170, 171) ?
        call    @rdy_re
        jne     @in_r1
        br      @in_fight
in_r1:  cmp     %pj_rhang>>8,RR-1       ; pendu au rebord ?
        jne     @in_r0
        cmp     %pj_rhang&$FF,RR
        jne     @in_r0
        br      @in_hang
in_r0:  cmp     %pj_r15>>8,RR-1         ; debout, "haut" seul : s'agripper au rebord du dessus ?
        jne     @in_qk
        cmp     %pj_r15&$FF,RR
        jne     @in_qk
        btjz    %$01,R_IN,@in_x0        ; "haut" : devant la porte de sortie ouverte, on sort
        call    @ex_try
in_x0:  clr     A                       ; debout : l'epee est rangee
        sta     @K_ARM
        call    @k_engage               ; un garde devant, et l'epee : en garde
        jeq     @in_e0
        br      @loop
in_e0:  btjo    %$10,R_IN,@in_fk        ; "feu" relache : un nouvel appui fera un nouveau pas
        clr     A
        sta     @FIREL
        sta     @AVL
in_fk:  mov     R_IN,A                  ; "feu" sans "haut" : le pas prudent, un pas par appui :
        and     %$11,A
        cmp     %$10,A
        jne     @in_c0
        btjo    %$08,R_IN,@in_fa
        clr     A                       ; - "feu" seul : un pas a chaque appui sur "feu"
        sta     @AVL
        lda     @FIREL
        jne     @in_fx
        br      @in_feu
in_fa:  lda     @AVL                    ; - "feu" tenu + "avant" : un pas a chaque appui sur "avant",
        jne     @in_fx                  ;   sans relacher "feu" (comme Maj + fleche dans le jeu)
        br      @in_feu
in_fx:  br      @in_x                   ; (toujours le meme appui : rien, et surtout pas de course)
in_qk:  br      @in_q
in_c0:  mov     R_IN,A                  ; "bas" seul : descendre en s'accrochant au bord ?
        and     %$0F,A
        cmp     %2,A
        jne     @in_c1
        br      @in_bas
in_c1:  mov     R_IN,A
        and     %$0D,A
        cmp     %1,A
        jeq     @in_up
        cmp     %9,A                    ; haut + avant, le nez contre un mur : un saut en longueur n'irait
        jne     @in_qj                  ; nulle part, c'est donc "haut" (la touche d'avant encore tenue)
        call    @wall_ahead
        jne     @in_qj
in_up:
        mov     R_WX,A
        call    @tcol                   ; A = case, R_Q3 = place dans la case (0-13)
        mov     A,R_Q4
        mov     R_Q3,A                  ; R_NX = distance au bord de la case, dans le sens du personnage
        btjz    %$80,R_MIR,@in_dd
        mov     %13,A
        sub     R_Q3,A
in_dd:  mov     A,R_NX
        call    @wall_fr                ; contre un mur : le corps compte comme dans la case qui le touche
        mov     R_Q4,R_TC
        mov     R_ETG,A
        dec     A
        mov     A,R_TE
        call    @tile_at                ; la case du dessus
        call    @is_hole
        jne     @in_k
        ; --- 1er cas : du vide au-dessus, un sol au-dessus devant -------------------
        mov     %1,A
        call    @col_a
        call    @tile_at
        call    @is_hole
        jeq     @in_q
        cmp     %T_WALL,A
        jeq     @in_q
        mov     R_NX,A                  ; pres du bord : on y va, saut droit
        cmp     %4,A
        jl      @in_m
        sub     %4,A                    ; sinon on s'arrete a 4 du bord, saut vers l'avant
        call    @fwd_a
        movd    %pj_jumphangLong,RS
        br      @loop
in_qj:  br      @in_q
        ; --- 2e cas : le rebord est juste au-dessus, le vide au-dessus derriere -----
in_k:   cmp     %T_WALL,A
        jeq     @in_ju
        cmp     %6,R_NX                 ; trop avance sous le rebord : simple saut (on se cogne)...
        jhs     @in_k2
        mov     %1,A                    ; ... sauf colle a un mur (devant lui, a son etage) : il ne
        call    @col_a                  ; peut pas etre plus pres du bord, il recule quand meme
        mov     R_ETG,R_TE              ; (le jeu, lui, saute sur place)
        call    @tile_at
        cmp     %T_WALL,A
        jne     @in_ju
in_k2:  mov     %-1,A
        call    @col_a
        call    @tile_at
        call    @is_hole
        jne     @in_ju
        mov     R_NX,A                  ; on recule jusqu'au bord de la case de derriere
        sub     %14,A
in_m:   call    @fwd_a
        movd    %pj_jumphangMed,RS      ; saut, prise, retablissement
        br      @loop
in_ju:  movd    %pj_jumpup,RS           ; un sol ou un mur au-dessus : saut sur place, la tete cogne
        br      @loop                   ; le plafond (jump_up du jeu) ; sinon "highjump" (regle)

in_q:   cmp     %0,RR-1
        jeq     @in_x                   ; pas de regle : la sequence continue
rl_l:   lda     *RR                     ; masque
        cmp     %$FF,A
        jeq     @in_x
        and     R_IN,A
        mov     A,R_T
        call    @next_r
        cmp     R_T,A                   ; valeur
        jne     @rl_n
        call    @next_r
        mov     A,RS-1
        call    @next_r
        mov     A,RS
        br      @loop
rl_n:   add     %3,RR
        adc     %0,RR-1
        jmp     @rl_l
in_x:   br      @loop

; --- pendu au rebord : "haut" = se retablir ; "feu" tenu = rester pendu (la sequence du
;     jeu dure 3,5 s, puis il lache) ; rien : se retablir si on y a saute, lacher si on en descend
in_hang:
        btjz    %1,R_IN,@hg_1
hg_c:   clr     A
        sta     @HDOWN
        movd    %pj_climbup,RS
        br      @loop
hg_1:   btjz    %$10,R_IN,@hg_2
        br      @in_x
hg_2:   lda     @HDOWN
        jeq     @hg_c
hg_rel: clr     A
        sta     @HDOWN
        mov     R_WX,A                  ; on lache : y a-t-il un sol sous la case de derriere, ou sous
        call    @tcol                   ; celle du corps (hang_fall du jeu) ?
        mov     A,R_Q4
        mov     %-1,A
        call    @col_a
        inc     R_TE                    ; (meme etage)
        call    @tile_at
        call    @is_hole
        jne     @hg_d
        clr     A                       ; la case du corps (un rebord sous le rebord : on s'y pose)
        call    @col_a
        inc     R_TE
        call    @tile_at
        cmp     %T_WALL,A
        jne     @hg_4
        mov     %-7,A                   ; (dans un mur : 7 en arriere, comme le jeu)
        call    @fwd_a
        jmp     @hg_d
hg_4:   call    @is_hole
        jeq     @hg_3
hg_d:   movd    %pj_hangdrop,RS         ; oui : on s'y pose
        br      @loop
hg_3:   mov     %-8,A                   ; non : on s'ecarte du rebord et la chute commence tout de
        call    @fwd_a                  ; suite (pas de pose en l'air)
        mov     %1,R_FALL
        clr     R_FY
        clr     R_FN
        clr     A                       ; (sans elan)
        sta     @FALLX
        movd    %pj_stepfall,RS
        br      @loop

; --- "bas" : dos au vide et pres du bord, on descend en s'accrochant (down_pressed du jeu)
in_bas: mov     R_WX,A
        call    @tcol
        mov     A,R_Q4
        mov     R_Q3,A                  ; R_NX = distance au bord avant de la case
        btjz    %$80,R_MIR,@bs_d
        mov     %13,A
        sub     R_Q3,A
bs_d:   mov     A,R_NX
        cmp     %8,A
        jl      @bs_no                  ; trop loin du bord arriere : on s'accroupit
        mov     %-1,A
        call    @col_a
        inc     R_TE                    ; (meme etage)
        call    @tile_at                ; derriere : il faut du vide
        call    @is_hole
        jne     @bs_no
        mov     R_NX,A
        sub     %9,A
        call    @fwd_a
        mov     %1,A
        sta     @HDOWN
        movd    %pj_climbdown,RS
        br      @loop
bs_no:  br      @in_q

; --- le pas prudent : jusqu'au bord, jamais au-dela (get_edge_distance du jeu) -----
in_feu: call    @under                  ; une potion (ou l'epee) sous les pieds ou dans la case de devant : on la prend
        cmp     %T_POT,A
        jeq     @fe_p
        cmp     %T_SWORD,A
        jeq     @fe_p
        mov     R_WX,A
        btjo    %$80,R_MIR,@fe_p1
        sub     %14,A
        jmp     @fe_p2
fe_p1:  add     %14,A
fe_p2:  call    @tcol
        mov     A,R_TC
        mov     R_ETG,R_TE
        call    @tile_at
        cmp     %T_POT,A
        jeq     @fe_p
        cmp     %T_SWORD,A
        jne     @fe_0
fe_p:   push    A                       ; (la nature de la case)
        call    @pot_take
        pop     A
        movd    %pj_drinkpotion,RS
        cmp     %T_SWORD,A
        jne     @fe_p4
        mov     %1,A                    ; l'epee : il l'a, pour la suite
        sta     @SWORD
        mov     %4,A                    ; et l'ecran s'eclaire deux fois (le jeu : 8 images, une sur deux)
        sta     @FLASH
        mov     %sx_sword>>8,A
        mov     %sx_sword&$FF,B
        call    @snd
        movd    %pj_pickupsword,RS
        br      @loop
fe_p4:
        lda     @HP
        jne     @fe_p3
        movd    %pj_hardland,RS         ; (le poison de trop)
fe_p3:  br      @loop
fe_0:   mov     R_WX,A
        call    @tcol
        mov     A,R_Q4
        mov     R_Q3,A                  ; R_NX = distance au bord de la case
        btjz    %$80,R_MIR,@fe_d
        mov     %13,A
        sub     R_Q3,A
fe_d:   mov     A,R_NX
        mov     %1,A
        call    @col_a
        inc     R_TE                    ; (meme etage)
        call    @tile_at                ; la case devant
        clr     R_Q
        cmp     %T_WALL,A
        jne     @fe_1
        mov     %1,R_Q
        sub     %4,R_NX                 ; un mur : on s'arrete un peu avant
        jhs     @fe_e
        clr     R_NX
        jmp     @fe_e
fe_1:   call    @is_hole                ; un vide, un sol fragile, un bouton : on va jusqu'au bord
        jeq     @fe_e
        cmp     %11,A
        jeq     @fe_e
        cmp     %6,A
        jeq     @fe_e
        cmp     %15,A
        jeq     @fe_e
        cmp     %5,A
        jeq     @fe_e
        mov     %11,R_NX                ; un sol : le pas normal, 11
fe_e:   cmp     %0,R_NX
        jne     @fe_g
        cmp     %0,R_Q                  ; deja au bord (safe_step du jeu) :
        jne     @fe_no                  ; - au pied d'un mur : rien
        lda     @STEPR
        jeq     @fe_go
        clr     A                       ; - la premiere fois : on tate du pied, sans avancer
        sta     @STEPR
        mov     %50,A
        sta     @LIMC
        movd    %pj_testfoot,RS
        jmp     @fe_st
fe_go:  mov     %12,A                   ; - la fois suivante : on y va quand meme, d'un pas entier
        sta     @LIMC
        movd    %pj_step11,RS
        jmp     @fe_st
fe_no:  br      @in_q
fe_g:   cmp     %12,R_NX
        jl      @fe_h
        mov     %11,R_NX
fe_h:   mov     R_NX,A
        inc     A                       ; (la sequence recule de 1 a la fin)
        sta     @LIMC
        mov     %1,A
        sta     @STEPR
        movd    %pj_step11,RS
fe_st:  mov     %1,A
        sta     @FIREL
        sta     @AVL
        br      @loop

; --- col_a : R_TC = case du personnage + A cases dans son sens ; R_TE = etage du dessus
col_a:  btjo    %$80,R_MIR,@cl_r
        inv     A
        inc     A
cl_r:   add     R_Q4,A
        mov     A,R_TC
        mov     R_ETG,A
        dec     A
        mov     A,R_TE
        rets
; --- fwd_a : avance l'abscisse de A (signe) dans le sens du personnage, sans autre test
fwd_a:  btjo    %$80,R_MIR,@fw_r
        inv     A
        inc     A
fw_r:   add     R_A,R_X
        rets

; --- shk_init : prepare le tremblement des dalles fragiles de l'etage du personnage ------
;     A = 0 : seulement celle qui est sous ses pieds ; A = $FF : toutes (il vient de retomber
;     sur ce sol). Une dalle occupe les deux dernieres lignes de son bloc, sur 8 colonnes (elle
;     deborde sur la case de droite). On traite une bande de 20 colonnes a partir de la premiere
;     dalle : ses 40 caracteres sont recopies, decales de 2 points vers le bas, dans 40 codes
;     libres de BAGC3. SHK_M : les caracteres de la carte, 3 lignes de 20 (celle du dessus, puis
;     les deux des dalles) ; SHK_K : les colonnes de la bande qui tremblent.
shk_init:
        sta     @SHK_ONE
        mov     R_ETG,A
        sta     @SHK_E
        lda     @SHK_ONE
        cmp     %$FF,A
        jeq     @shk_go
        mov     R_WX,A
        call    @tcol
        cmp     %10,A
        jl      @si_o
        clr     A
        sta     @SHK_ROOM
        rets                            ; (la dalle est dans la salle voisine : pas de tremblement)
si_o:   sta     @SHK_ONE
; shk_go : SHK_ONE = la case (ou $FF : toutes les fragiles), SHK_E = l'etage ($FF : le plafond, c.-a-d.
;     l'etage 2 de la salle du dessus : sa ligne, la 1re de l'ecran au-dessus de la salle, monte de 2 points)
shk_go: clr     A
        sta     @SHK_ROOM
        lda     @SHK_E
        inc     A
        mov     A,B
        lda     @t_erm(B)
        sta     @SHK_ROW
        lda     @SHK_ONE
        cmp     %$FF,A
        jne     @si_c
si_a:   clr     R_Q4                    ; la premiere dalle fragile de l'etage
si_a1:  mov     R_Q4,B
        rl      B
        rl      B
        call    @shk_lz
        jeq     @si_a2
        inc     R_Q4
        cmp     %10,R_Q4
        jne     @si_a1
        rets                            ; (aucune)
si_a2:  mov     R_Q4,A
si_c:   push    A
        lda     @SHK_E                  ; (le plafond : toujours decale)
        cmp     %$FF,A
        jeq     @si_c0
        lda     @LV_FN                  ; sols animes : il suffit de l'etage et de la case (SHK_ONE)
        jeq     @si_c0
        pop     A
        lda     @SHK_E
        sta     @FA_E
        mov     R_ROOM,A
        sta     @SHK_ROOM
        rets
si_c0:  pop     A
        rl      A
        rl      A
        sta     @SHK_COL
        clr     R_Q4                    ; les colonnes qui tremblent : celles d'une dalle et de la case a sa droite
        clr     R_NX                    ; (bit 0 : la case de cette colonne est fragile ; bit 1 : celle d'avant)
si_k:   mov     R_Q4,A
        and     %3,A
        jne     @si_k3
        rl      R_NX
        and     %2,R_NX
        lda     @SHK_COL
        add     R_Q4,A
        cmp     %40,A
        jhs     @si_k3
        mov     A,R_Q3
        lda     @SHK_ONE
        cmp     %$FF,A
        jeq     @si_k1
        rl      A
        rl      A
        cmp     R_Q3,A
        jne     @si_k3
        jmp     @si_k2
si_k1:  mov     R_Q3,B
        call    @shk_lz
        jne     @si_k3
si_k2:  or      %1,R_NX
si_k3:  lda     @SHK_E                  ; le plafond : seulement les colonnes de la case (le debord de
        cmp     %$FF,A                  ; la dalle sur la case de droite n'y est pas)
        jne     @si_k4
        and     %1,R_NX
si_k4:  mov     R_Q4,B
        mov     R_NX,A
        sta     @SHK_K(B)
        inc     R_Q4
        cmp     %20,R_Q4
        jne     @si_k
        clr     R_TC                    ; les caracteres de la carte : k = 0..59
        clr     R_TE
si_m0:  clr     R_Q4
si_m:   lda     @SHK_COL
        add     R_Q4,A
        mov     A,R_Q3                  ; colonne
        clr     R_NX
        cmp     %40,A
        jhs     @si_s
        lda     @SHK_ROW
        sub     %2,A
        add     R_TE,A
        mov     R_Q3,B
        call    @map_at
        mov     A,R_NX
si_s:   mov     R_TC,B
        mov     R_NX,A
        sta     @SHK_M(B)
        inc     R_TC
        inc     R_Q4
        cmp     %20,R_Q4
        jne     @si_m
        inc     R_TE
        cmp     %3,R_TE
        jne     @si_m0
        movd    %FONT_BAGC3+SHK_CODE,RV ; les 40 motifs decales, ligne par ligne du generateur (0 = le bas)
        clr     R_NX
si_g:   movd    RV,TEMP1
        trap    8
        clr     R_Q4
si_b:   mov     R_Q4,B
        lda     @SHK_E
        cmp     %$FF,A
        jne     @si_b0
        mov     R_NX,A                  ; le plafond (ligne SHK_ROW - 1) : decale de 2 points vers le HAUT
        cmp     %2,A                    ; (cogne d'en dessous)
        jl      @si_b1
        sub     %2,A                    ; lignes 2-9 : la ligne situee 2 plus bas du meme caractere
        mov     A,R_Q3
        lda     @SHK_M+20(B)
        jmp     @si_f
si_b1:  add     %8,A                    ; lignes 0-1 : les 2 du haut du caractere du dessous
        mov     A,R_Q3
        lda     @SHK_M+40(B)
        jmp     @si_f
si_b0:  mov     R_NX,A
        cmp     %8,A
        jhs     @si_u
        add     %2,A                    ; lignes 0-7 : la ligne situee 2 plus haut du meme caractere
        mov     A,R_Q3
        lda     @SHK_M+20(B)
        jmp     @si_f
si_u:   sub     %8,A                    ; lignes 8-9 : les 2 du bas du caractere du dessus
        mov     A,R_Q3
        lda     @SHK_M(B)
si_f:   mov     A,B                     ; B = caractere, R_Q3 = ligne : l'octet est en dc_font + 128 x ligne + caractere
        btjz    %$80,B,@si_n
        br      @si_w
si_n:   movd    %dc_font,RE
        add     R_B,RE
        adc     %0,RE-1
        mov     R_Q3,A
        clrc
        rrc     A                       ; ligne / 2 (le reste dans la retenue : + 128)
        jnc     @si_h
        add     %128,RE
        adc     %0,RE-1
si_h:   add     R_A,RE-1
si_r:   lda     *RE
        movp    A,P46
        inc     R_Q4
        cmp     %40,R_Q4
        jne     @si_b
        add     %128,RV
        adc     %0,RV-1
        inc     R_NX
        cmp     %10,R_NX
        jne     @si_g
        mov     R_ROOM,A
        sta     @SHK_ROOM
        rets
si_w:   lda     @LV_WF+1                ; une brique ($C0 + n) : LV_WF + 48 x ligne + n
        mov     A,RE
        lda     @LV_WF
        mov     A,RE-1
        sub     %$C0,B
        add     R_B,RE
        adc     %0,RE-1
        mov     R_Q3,B
        lda     @wf_48(B)
        add     R_A,RE
        adc     %0,RE-1
        lda     @wf_48h(B)
        add     R_A,RE-1
        br      @si_r
wf_48:  .byte   0,48,96,144,192,240,32,80,128,176     ; 48 x ligne, faibles
wf_48h: .byte   0,0,0,0,0,0,1,1,1,1                   ; ... forts

; --- shk_lz : B = colonne (0-39) -> Z si la case de cette colonne, a l'etage SHK_E, est un sol
;     fragile (le plafond : l'etage 2 de la salle du dessus). Change A, B, RD, R_TC, R_TE.
shk_lz: lda     @SHK_E
        cmp     %$FF,A
        jeq     @sl_c
        lda     @SHK_ROW
        call    @map_at
        cmp     %T_LOOSE,R_TY
        rets
sl_c:   mov     B,A
        clrc
        rrc     A
        clrc
        rrc     A
        mov     A,R_TC
        mov     %$FF,R_TE
        call    @tile_at
        cmp     %T_LOOSE,A
        rets

; --- shk_draw : les deux lignes des dalles, decalees quand A est impair, normales
;     sinon. Les cases occupees par le personnage ne sont pas touchees.
shk_draw:
        sta     @SHK_P
        lda     @SHK_ROOM
        cmp     R_ROOM,A
        jeq     @sw_0
        rets                            ; (plus dans cette salle, ou pas de tremblement)
sw_0:   lda     @LV_FN
        jeq     @sw_00
        lda     @SHK_E                  ; (le plafond : toujours decale)
        cmp     %$FF,A
        jeq     @sw_00
        br      @fa_draw
sw_00:  clr     R_Q4                    ; j = 0..39
sw_l:   lda     @SHK_E                  ; le plafond : seulement sa ligne (j < 20)
        cmp     %$FF,A
        jne     @sw_l0
        cmp     %20,R_Q4
        jhs     @sw_s
sw_l0:  mov     R_Q4,A
        cmp     %20,A
        jl      @sw_a
        sub     %20,A
sw_a:   mov     A,B
        lda     @SHK_K(B)
        jeq     @sw_s                   ; cette colonne ne tremble pas
        lda     @SHK_COL
        add     R_B,A
        mov     A,R_Q3                  ; colonne
        cmp     %40,A
        jhs     @sw_s
        lda     @SHK_ROW
        cmp     %20,R_Q4
        jhs     @sw_r
        dec     A
sw_r:   mov     A,R_NX                  ; ligne
        sub     R_OR,A                  ; dans la fenetre du personnage ?
        cmp     R_OH,A
        jhs     @sw_d
        mov     R_Q3,A
        sub     R_OC,A
        cmp     R_OW,A
        jl      @sw_s                   ; oui : on n'y touche pas
sw_d:   mov     R_NX,A
        mov     R_Q3,B
        call    @cell_addr
        movd    RV,TEMP1
        trap    8
        lda     @SHK_P
        and     %1,A
        jeq     @sw_n
        movp    %ATTR,P46               ; decalee : les codes libres de BAGC3
        mov     R_Q4,A
        add     %SHK_CODE,A
        movp    A,P46
        jmp     @sw_s
sw_n:   mov     R_Q4,B                  ; normale : le caractere de la carte
        lda     @SHK_M+20(B)
        mov     A,B
        call    @attr_b
        movp    A,P46
        mov     B,A
        and     %$7F,A
        movp    A,P46
sw_s:   inc     R_Q4
        cmp     %40,R_Q4
        jne     @sw_l
        rets

; --- fa_draw : sols fragiles animes (niveau2exl.py : lignes "fragile"). SHK_P = la phase :
;     les cases fragiles de l'etage FA_E (ou la seule SHK_ONE) dont le bloc a une animation
;     montrent, selon SHK_P mod 3, le bloc normal (0), l'image 2 (1) ou l'image 1 (2) ; SHK_P
;     descend jusqu'a 0 : normal, 1, 2, normal... et la derniere est normale. Les cases du
;     personnage ne sont pas touchees.
fa_draw:
        call    @fa_tp                  ; B = le tempo : chaque image dure B pas
        clr     R_NX
        lda     @SHK_P
fa_dv:  cmp     B,A                     ; A / tempo
        jl      @fa_dq
        sub     B,A
        inc     R_NX
        jmp     @fa_dv
fa_dq:  mov     R_NX,A
fa_m:   cmp     %3,A
        jl      @fa_p
        sub     %3,A
        jmp     @fa_m
fa_p:   sta     @FA_P
        clr     R_Q4                    ; la case 0..9
fa_t:   lda     @SHK_ONE
        cmp     %$FF,A
        jeq     @fd_a
        cmp     R_Q4,A
        jeq     @fd_a
        br      @fa_n
fd_a:   lda     @FA_E
        mov     A,B
        lda     @fa_e10(B)
        add     R_Q4,A
        movd    RROOM,RD
        add     R_A,RD
        adc     %0,RD-1
        lda     *RD                     ; son bloc
        mov     A,R_NX
        lda     @FA_SH
        jeq     @fd_b
        lda     @FA_SV                  ; (la case sous les pieds, deja changee : son bloc normal)
        mov     A,R_NX
fd_b:   add     %30,RD
        adc     %0,RD-1
        lda     *RD
        and     %$1F,A
        cmp     %T_LOOSE,A
        jeq     @fa_s0
        br      @fa_n
fa_s0:  lda     @LV_FN
        and     %15,A
        mov     A,R_Q3
        clr     B
fa_s:   lda     @LV_FT(B)
        cmp     R_NX,A
        jeq     @fa_f
        add     %3,B
        djnz    R_Q3,@fa_s
        br      @fa_n                   ; (pas d'animation pour ce bloc)
fa_f:   mov     B,R_Q3
        lda     @FA_P
        mov     A,B
        lda     @fa_o(B)
        add     R_Q3,A
        mov     A,B
        lda     @LV_FT(B)
        sta     @FA_B                   ; le bloc a montrer
        lda     @SHK_ONE                ; la case sous les pieds : son bloc change aussi dans la salle,
        cmp     %$FF,A                  ; pour que le personnage y soit dessine devant
        jeq     @fd_r0
        sub     %30,RD
        sbb     %0,RD-1
        lda     @FA_SH
        jne     @fd_w
        mov     RD-1,A
        sta     @FA_SH
        mov     RD,A
        sta     @FA_SL
        mov     R_NX,A
        sta     @FA_SV
fd_w:   lda     @FA_B
        sta     *RD
        lda     @FA_P
        jne     @fd_r0
        sta     @FA_SH                  ; (phase 0 : le bloc normal est remis)
fd_r0:  clr     R_Q2                    ; ses 6 rangees
fa_r:   lda     @FA_B
        call    @row_ad                 ; RD = la rangee R_Q2 du bloc
        lda     @FA_E
        mov     A,B
        lda     @t_erow(B)
        sub     %5,A
        add     R_Q2,A
        mov     A,R_NX                  ; ligne
        clr     R_Q3
fa_c:   lda     *RD
        mov     A,R_TC
        mov     R_Q4,A
        rl      A
        rl      A
        add     R_Q3,A
        mov     A,R_TE                  ; colonne
        mov     R_NX,A
        sub     R_OR,A                  ; dans la fenetre du personnage ?
        cmp     R_OH,A
        jhs     @fa_d
        mov     R_TE,A
        sub     R_OC,A
        cmp     R_OW,A
        jl      @fd_x                   ; oui : on n'y touche pas
fa_d:   mov     R_NX,A
        mov     R_TE,B
        call    @cell_addr
        movd    RV,TEMP1
        trap    8
        mov     R_TC,B
        call    @attr_b
        movp    A,P46
        mov     R_TC,A
        and     %$7F,A
        movp    A,P46
fd_x:   add     %1,RD
        adc     %0,RD-1
        inc     R_Q3
        cmp     %4,R_Q3
        jne     @fa_c
        inc     R_Q2
        cmp     %6,R_Q2
        jne     @fa_r
fa_n:   inc     R_Q4
        cmp     %10,R_Q4
        jeq     @fa_z
        br      @fa_t
fa_z:   rets
; --- fa_tp : B = le tempo des sols animes (pas par image, 1-8) ; fa_kn : A = la duree d'un
;     tremblement (6 x tempo + 1 : normal, 1, 2, normal, 1, 2, normal ; sans animation : KN_N + 1)
fa_tp:  lda     @LV_FN
        clrc
        rrc     A
        rrc     A
        rrc     A
        rrc     A
        and     %7,A
        inc     A
        mov     A,B
        rets
fa_kn:  lda     @LV_FN
        jne     @fk_a
        mov     %KN_N+1,A
        rets
fk_a:   call    @fa_tp
        clr     A
fk_l:   add     %6,A
        djnz    B,@fk_l
        inc     A
        rets

; --- fl_grab : en tombant, au 1er etage passe (le jeu : check_grab, fall_y < 32), "feu" tenu (Maj du jeu) :
;     si la case du corps (8 unites en arriere, comme le jeu) est du vide a l'etage du dessus et la case
;     devant un sol (un rebord), il s'y rattrape : au bord de sa case, pendu (fallhang, puis hang1 ; lacher
;     "feu" le fait tomber, "haut" le fait monter). Z : rattrape (RS change).
fl_grab:
        btjz    %$10,R_IN,@fg_n
        cmp     %1,R_FN
        jne     @fg_n
        mov     R_WX,A                  ; le poids, 8 unites en arriere
        btjo    %$80,R_MIR,@fg_r
        add     %8,A
        jmp     @fg_c
fg_r:   sub     %8,A
fg_c:   call    @tcol
        cmp     %11,A
        jhs     @fg_n                   ; (plus loin que la 1re case de la salle de droite)
        mov     A,R_Q4
        mov     R_Q3,A                  ; la distance au bord avant de la case
        btjz    %$80,R_MIR,@fg_d
        mov     %13,A
        sub     R_Q3,A
fg_d:   sub     %8,A
        mov     A,R_NX                  ; (le deplacement, depuis le poids actuel)
        clr     A                       ; au-dessus du corps : du vide (pas un mur, pas un sol)
        call    @col_a
        call    @tile_at
        cmp     %T_WALL,A
        jeq     @fg_n
        call    @is_hole
        jne     @fg_n
        mov     %1,A                    ; devant, au-dessus : un sol a saisir
        call    @col_a
        call    @tile_at
        cmp     %T_WALL,A
        jeq     @fg_n
        call    @is_hole
        jeq     @fg_n
        mov     R_NX,A                  ; au bord de sa case, pendu
        call    @fwd_a
        clr     R_FALL
        clr     R_FY
        clr     R_FN
        mov     %1,A
        sta     @HDOWN                  ; (lacher "feu" : il tombe)
        movd    %pj_fallhang,RS
        mov     %sx_grab>>8,A
        mov     %sx_grab&$FF,B
        call    @snd
        clr     A                       ; Z
        rets
fg_n:   mov     %1,A                    ; NZ
        rets

; --- lp_rp : ligne de repetition "0, $40, N, pas (fort, faible)" (RS sur son 2e octet) : la 1re fois,
;     N repetitions ; puis une de moins a chaque passage ; on refait le pas, jusqu'a la derniere, puis la
;     ligne suivante. Une suite de pas identiques n'occupe ainsi qu'un pas et 5 octets.
lp_rp:  sub     %1,RS                   ; (RS : le debut de la ligne)
        sbb     %0,RS-1
        lda     @REPAH
        cmp     RS-1,A
        jne     @rp_n
        lda     @REPAL
        cmp     RS,A
        jne     @rp_n
        lda     @REPN                   ; deja en cours : une de moins
        dec     A
        jne     @rp_s
        sta     @REPAH                  ; fini (A = 0) : la ligne suivante
        add     %5,RS
        adc     %0,RS-1
        br      @loop
rp_n:   mov     RS-1,A                  ; la premiere fois : N
        sta     @REPAH
        mov     RS,A
        sta     @REPAL
        call    @next_s
        call    @next_s
        sub     %2,RS
        sbb     %0,RS-1
rp_s:   sta     @REPN
        call    @next_s
        call    @next_s
        call    @next_s                 ; le pas a refaire
        mov     A,R_T
        call    @next_s
        mov     A,RS
        mov     R_T,RS-1
        br      @loop

; --- fl_anim : la flamme des torches (animate_torch du jeu) : a chaque pas, une des pj_fln images de
;     pj_flam (pop2exl.py) au hasard, recopiee dans le generateur BAGC2 des 4 caracteres de LV_FLM : leurs
;     lignes 2 a 19 (carre de 2 x 2) ; la derniere garde aussi les points du caractere d'origine (le haut de
;     la torche). Toutes les torches changent ensemble ; le decor sous le prince garde la flamme d'origine.
fl_anim:
        lda     @FLK                    ; un pas sur deux (6 images par seconde : la recopie prend ~4 ms) ;
        inv     A                       ; l'autre pas, les bulles des potions
        sta     @FLK
        jne     @fm_0
        br      @bl_anim
fm_0:
        lda     @LV_FLM
        jeq     @fm_x
        lda     @pj_fln
        jeq     @fm_x
        mov     A,R_Q2                  ; (nombre d'images)
        call    @rnd
fm_m:   cmp     R_Q2,A                  ; au hasard, modulo le nombre d'images
        jl      @fm_i
        sub     R_Q2,A
        jmp     @fm_m
fm_i:   movd    %pj_flam,RE             ; RE = pj_flam + 36 x image
        tsta
        jeq     @fm_r
fm_a:   add     %36,RE
        adc     %0,RE-1
        dec     A
        jne     @fm_a
fm_r:   mov     %2,R_Q3                 ; R_Q3 = ligne du carre (2-19)
fm_l:   mov     R_Q3,A
        clr     B                       ; B = 0 : caracteres du haut (LV_FLM, +1) ; 2 : du bas (+2, +3)
        cmp     %10,A
        jl      @fm_h
        sub     %10,A
        mov     %2,B
fm_h:   mov     A,R_Q4                  ; ligne dans le caractere (0 = le haut)
        call    @fm_ad                  ; le caractere de gauche
        call    @fm_b
        movp    A,P46
        lda     @LV_FLM(B)              ; celui de droite : s'il suit (code + 1), le pointeur y est deja
        inc     A
        mov     A,R_Q2
        inc     B
        lda     @LV_FLM(B)
        cmp     R_Q2,A
        jne     @fm_s
        add     %1,RV
        jmp     @fm_t
fm_s:   call    @fm_ad
fm_t:   call    @fm_b
        movp    A,P46
        inc     R_Q3
        cmp     %20,R_Q3
        jne     @fm_l
fm_x:   rets
; fm_ad : RV = FONT_A + 128 x (9 - R_Q4) + code LV_FLM(B) (le generateur : la ligne du bas d'abord), et y place l'ecriture
fm_ad:  lda     @LV_FLM(B)
fm_ac:  mov     A,RV                    ; (fm_ac : le code en A)
        mov     %FONT_A>>8,RV-1         ; (FONT_A : $xx00 ; codes < 128)
        mov     %9,A
        sub     R_Q4,A
        clrc
        rrc     A
        jnc     @fd_e
        or      %$80,RV
fd_e:   add     R_A,RV-1
        mov     RV,A                    ; l'adresse d'ecriture du TMS3556 (comme le trap 8, sans
        push    ST                      ; interruption au milieu)
        dint
        movp    %$01,P45
        movp    A,P45
        mov     RV-1,A
        movp    %$02,P45
        movp    A,P45
        pop     ST
        rets
; fm_b : A = l'octet *RE (RE avance) ; ligne 19 du carre : avec les points du caractere d'origine en RV
fm_b:   lda     *RE
        add     %1,RE
        adc     %0,RE-1
        cmp     %19,R_Q3
        jne     @fb_x
        push    A
        movd    RV,RD                   ; dc_font + (RV - FONT_A)
        sub     %FONT_A&$FF,RD
        sbb     %FONT_A>>8,RD-1
        add     %dc_font&$FF,RD
        adc     %dc_font>>8,RD-1
        lda     *RD
        mov     A,R_Q2
        pop     A
        or      R_Q2,A
fb_x:   rets

; --- bl_anim : les bulles des potions (animate_potion du jeu) : l'image suivante des pj_bln de pj_bul
;     (pop2exl.py), recopiee dans le generateur BAGC2 du caractere LV_BUL (ses 10 lignes ; ~2 ms)
bl_anim:
        lda     @LV_BUL
        jeq     @bm_x
        lda     @pj_bln
        jeq     @bm_x
        mov     A,R_Q2
        lda     @BLK                    ; l'image suivante (bubble_next_frame du jeu)
        inc     A
        cmp     R_Q2,A
        jl      @bm_i
        clr     A
bm_i:   sta     @BLK
        movd    %pj_bul,RE              ; RE = pj_bul + 10 x image
        tsta
        jeq     @bm_r
bm_a:   add     %10,RE
        adc     %0,RE-1
        dec     A
        jne     @bm_a
bm_r:   clr     R_Q4                    ; ligne 0 (le haut) a 9
bm_l:   lda     @LV_BUL
        call    @fm_ac
        lda     *RE
        movp    A,P46
        add     %1,RE
        adc     %0,RE-1
        inc     R_Q4
        cmp     %10,R_Q4
        jne     @bm_l
bm_x:   rets

; --- fs_chk : le pas affiche est-il un de ceux de pj_fst (snd(SND_FOOTSTEP) du jeu : le pied se pose) ?
;     alors le bruit de pas (le moins important des bruitages)
fs_chk: movd    %pj_fst,RE
fq_l:   lda     *RE
        jeq     @fq_x
        cmp     RS-1,A
        jne     @fq_n
        add     %1,RE
        adc     %0,RE-1
        lda     *RE
        cmp     RS,A
        jeq     @fq_y
        jmp     @fq_m
fq_n:   add     %1,RE
        adc     %0,RE-1
fq_m:   add     %1,RE
        adc     %0,RE-1
        jmp     @fq_l
fq_y:   mov     %sx_step>>8,A
        mov     %sx_step&$FF,B
        br      @snd
fq_x:   rets

; --- k_up : la tete cogne le plafond ("jumpup"), comme le jeu :
;     - check_press : si la case au-dessus de celle du poids A L'IMAGE 79 (il a avance de 5 unites
;       pendant le saut : depuis la moitie droite d'une case, c'est la suivante) est un sol fragile
;       (dans la salle, ou l'etage 2 de la salle du dessus), il tremble puis tombe ;
;     - sinon check_knock : les sols fragiles de la rangee du dessus tremblent, sans tomber (le jeu les
;       fait trembler tous dans les deux cas ; ici, pendant qu'une dalle cede, les autres ne tremblent pas).
k_up:   mov     %sx_bumpup>>8,A         ; le bruit de la tete
        mov     %sx_bumpup&$FF,B
        call    @snd
        mov     R_WX,A
        call    @tcol
        cmp     %10,A
        jhs     @ku_k                   ; (le corps dans la salle voisine)
        mov     A,R_TC
        sta     @KU_C
        mov     R_ETG,A
        dec     A
        mov     A,R_TE
        call    @tile_at                ; RD = l'adresse de son type
        cmp     %T_LOOSE,A
        jne     @ku_k
        mov     R_ETG,A                 ; etage du dessus + 2 (1 : le plafond)
        inc     A
        sta     @LS_UP
        call    @ls_new
        clr     A
        sta     @LS_UP
        rets
ku_k:   call    @ls_any
        jne     @ku_r                   ; (pas pendant qu'une dalle cede)
        lda     @KN_T                   ; un tremblement en cours : remis en place d'abord
        jeq     @ku_g
        clr     A
        sta     @KN_T
        call    @shk_draw
ku_g:   mov     R_ETG,A                 ; l'etage du dessus ($FF : le plafond), toutes ses fragiles
        dec     A
        sta     @SHK_E
        mov     %$FF,A
        sta     @SHK_ONE
        call    @shk_go
        lda     @SHK_ROOM
        jeq     @ku_r                   ; (aucune)
        call    @fa_kn
        sta     @KN_T
ku_r:   rets

; --- les sols fragiles qui cedent : jusqu'a LSN a la fois (deux dalles voisines : chacune
;     cede de son cote). ls_any : Z si aucun ; ls_new : RD = la case sous les pieds, une place
;     de plus si elle n'en a pas deja une ; ls_vis / ls_brk : la place LS_K tremble / tombe ;
;     ls_rall : (au depart) les blocs changes reprennent leur valeur.
ls_any: lda     @LS_T0
        mov     A,B
        lda     @LS_T0+1
        or      B,A
        mov     A,B
        lda     @LS_T0+2
        or      B,A
        rets
ls_new: clr     B
ln_c:   lda     @LS_T0(B)
        jeq     @ln_n
        lda     @LS_H0(B)
        cmp     RD-1,A
        jne     @ln_n
        lda     @LS_L0(B)
        cmp     RD,A
        jne     @ln_n
        rets                            ; (elle cede deja)
ln_n:   inc     B
        cmp     %LSN,B
        jne     @ln_c
        clr     B
ln_f:   lda     @LS_T0(B)
        jeq     @ln_s
        inc     B
        cmp     %LSN,B
        jne     @ln_f
        rets                            ; (plus de place)
ln_s:   mov     B,A
        sta     @LS_K
        sta     @LS_NEW
        mov     RD-1,A
        sta     @LS_H0(B)
        mov     RD,A
        sta     @LS_L0(B)
        clr     A
        sta     @LS_SH0(B)
        lda     @KN_T                   ; (un tremblement d'etage en cours : tout remettre en place d'abord)
        jeq     @ln_i
        clr     A
        sta     @KN_T
        call    @shk_draw
ln_i:   lda     @LV_FN                  ; (sans animation : la derniere qui tremblait, remise en place)
        jne     @ln_j
        clr     A
        call    @shk_draw
ln_j:   lda     @LS_UP                  ; k_up : la dalle du dessus (case KU_C)
        jeq     @ln_j0
        sub     %2,A
        sta     @SHK_E
        lda     @KU_C
        sta     @SHK_ONE
        call    @shk_go
        jmp     @ln_j1
ln_j0:  clr     A
        call    @shk_init
ln_j1:  lda     @LS_K
        mov     A,B
        mov     %LS_DELAY,A
        sta     @LS_T0(B)
        lda     @SHK_ONE
        sta     @LS_C0(B)
        lda     @SHK_E
        sta     @LS_E0(B)
        lda     @SHK_ROOM
        sta     @LS_R0(B)
        rets
ls_vis: lda     @LV_FN
        jne     @lv_a
        lda     @LS_NEW                 ; sans animation : seule la derniere tremble (decalee)
        cmp     B,A
        jne     @lv_x
        lda     @LS_T0(B)
        call    @shk_draw
lv_x:   rets
lv_a:   lda     @LS_C0(B)               ; animes : chacune avec son etat
        sta     @SHK_ONE
        lda     @LS_E0(B)
        sta     @FA_E
        sta     @SHK_E                  ; ($FF : le plafond, decale)
        lda     @LS_R0(B)
        sta     @SHK_ROOM
        call    @ls_get
        lda     @LS_K
        mov     A,B
        lda     @LS_T0(B)
        call    @shk_draw
        lda     @LS_K
        mov     A,B
        lda     @FA_SH
        sta     @LS_SH0(B)
        lda     @FA_SL
        sta     @LS_SL0(B)
        lda     @FA_SV
        sta     @LS_SV0(B)
        clr     A
        sta     @FA_SH
        rets
ls_get: lda     @LS_SH0(B)              ; FA_SH, FA_SL, FA_SV = ceux de la place B
        sta     @FA_SH
        lda     @LS_SL0(B)
        sta     @FA_SL
        lda     @LS_SV0(B)
        sta     @FA_SV
        rets
ls_brk: call    @ls_get                 ; son bloc normal d'abord, s'il etait change
        call    @fa_rest
        lda     @LS_K
        mov     A,B
        clr     A
        sta     @LS_SH0(B)
        lda     @LS_H0(B)
        sta     @LS_AH
        lda     @LS_L0(B)
        sta     @LS_AL
        call    @nb_ad                  ; le bloc de la dalle, avant sa chute
        sub     %30,RD
        sbb     %0,RD-1
        lda     *RD
        push    A
        call    @ls_break
        pop     A
        call    @fd_new                 ; elle tombe
        rets
ls_rall:
        clr     B
lr_l:   push    B
        call    @ls_get
        call    @fa_rest
        pop     B
        clr     A
        sta     @LS_SH0(B)
        inc     B
        cmp     %LSN,B
        jne     @lr_l
        rets

; --- les dalles qui tombent : fd_new (LS_AH:LS_AL = la case du sol fragile tombe, A = son bloc)
;     en prend une place ; fd_step les fait avancer d'un pas : 1, 2 puis 3 lignes par pas ; a
;     travers les vides (et la salle du dessous) jusqu'a un sol : la case devient des debris
;     (si c'etait du sol), le prince dessous perd un point de vie. Dessinees (2 rangees de 4
;     caracteres) dans la salle affichee, sauf sur le personnage.
fd_new: sta     @FD_I+1                 ; (le bloc)
        lda     @LV_DBF
        jne     @fn_0
        rets
fn_0:   clr     B
fn_f:   lda     @FD_R(B)
        jeq     @fn_s
        inc     B
        cmp     %FDN,B
        jne     @fn_f
        rets                            ; (plus de place)
fn_s:   mov     B,A
        sta     @FD_I
        call    @nb_ad                  ; RD = l'adresse - $8550 : salle x 64 + 30 + etage x 10 + case
        sub     %$50,RD
        sbb     %$85,RD-1
        mov     RD,A
        and     %$3F,A
        sub     %30,A
        clr     R_NX                    ; l'etage
fn_e:   cmp     %10,A
        jl      @fn_c
        sub     %10,A
        inc     R_NX
        jmp     @fn_e
fn_c:   mov     A,R_TC                  ; la case
        mov     RD,A                    ; la salle : fort x 4 + faible / 64 + 1
        clrc
        rlc     A
        rlc     A
        rlc     A
        and     %3,A
        mov     A,R_TE
        mov     RD-1,A
        clrc
        rlc     A
        rlc     A
        add     R_TE,A
        inc     A
        mov     A,R_TE
        lda     @FD_I
        mov     A,B
        mov     R_TE,A
        sta     @FD_R(B)
        mov     R_TC,A
        sta     @FD_C(B)
        lda     @FD_I+1
        sta     @FD_K(B)
        clr     A
        sta     @FD_V(B)
        sta     @FD_D(B)
        mov     R_NX,A
        inc     A
        sta     @FD_E(B)
        mov     R_NX,B
        lda     @fd_fp(B)               ; elle part de la dalle de son etage
        push    A
        lda     @FD_I
        mov     A,B
        pop     A
        sta     @FD_Y(B)
        rets
fd_step:
        clr     A
        sta     @FD_I
fs_l:   lda     @FD_I
        mov     A,B
        lda     @FD_R(B)
        jeq     @fs_n
        call    @fd_one
fs_n:   lda     @FD_I
        inc     A
        sta     @FD_I
        cmp     %FDN,A
        jne     @fs_l
        rets
fd_one: call    @fd_era                 ; l'image d'avant
        lda     @FD_I
        mov     A,B
        lda     @FD_V(B)                ; la vitesse : 4, 8, 12... 20 points par pas
        cmp     %20,A
        jhs     @fo_v
        add     %4,A
        sta     @FD_V(B)
fo_v:   mov     A,R_Q3
        lda     @FD_Y(B)
        add     R_Q3,A
        sta     @FD_Y(B)
fo_t:   lda     @FD_I
        mov     A,B
        lda     @FD_E(B)
        mov     A,R_NX                  ; l'etage a tester
        mov     A,B
        lda     @fd_fp(B)               ; sa dalle : 40, 100, 160 (220 : la salle du dessous)
        sub     %10,A
        cmp     %3,B
        jne     @fo_t1
        mov     %180,A                  ; (la salle du dessous : on y passe des le bas de celle-ci, pour
fo_t1:  mov     A,R_Q3                  ; l'y voir tomber depuis le haut) ; la dalle s'y pose quand elle y arrive
        lda     @FD_I
        mov     A,B
        lda     @FD_Y(B)
        cmp     R_Q3,A
        jhs     @fo_a
        br      @fd_drw                 ; pas encore : on la dessine
fo_a:   cmp     %3,R_NX
        jne     @fo_c
        lda     @FD_R(B)                ; la salle du dessous
        mov     A,B
        lda     @dc_roomh(B)
        mov     A,RD-1
        lda     @dc_rooml(B)
        mov     A,RD
        mov     %63,B
        call    @nb_from
        jne     @fo_b
        br      @fd_end                 ; (aucune : elle disparait)
fo_b:   push    A
        lda     @FD_I
        mov     A,B
        pop     A
        sta     @FD_R(B)
        lda     @FD_Y(B)
        sub     %180,A
        sta     @FD_Y(B)
        clr     A
        sta     @FD_E(B)
        jmp     @fo_t
fo_c:   lda     @FD_R(B)                ; la case de l'etage teste : RD = son type
        mov     A,B
        lda     @dc_roomh(B)
        mov     A,RD-1
        lda     @dc_rooml(B)
        mov     A,RD
        mov     R_NX,B
        lda     @t_e10(B)
        add     %30,A
        add     R_A,RD
        adc     %0,RD-1
        lda     @FD_I
        mov     A,B
        lda     @FD_C(B)
        add     R_A,RD
        adc     %0,RD-1
        lda     *RD
        and     %$1F,A
        call    @is_hole
        jne     @fo_l
        lda     @FD_I                   ; un vide : elle continue vers l'etage d'en dessous
        mov     A,B
        lda     @FD_E(B)
        inc     A
        sta     @FD_E(B)
        br      @fo_t
fo_l:   cmp     %1,A                    ; elle se pose : sur du sol, des debris
        jne     @fo_h
        lda     @LV_DBF
        and     %2,A
        jeq     @fo_h
        lda     *RD
        and     %$E0,A
        or      %T_DEBRIS,A
        call    @lv_poke
        sub     %30,RD
        sbb     %0,RD-1
        lda     @LV_DBB
        call    @lv_poke
        lda     @FD_I
        mov     A,B
        lda     @FD_R(B)
        cmp     R_ROOM,A
        jne     @fo_h
        mov     %1,R_RDW                ; (la salle sera redessinee)
fo_h:   lda     @FD_I                   ; le prince dessous : un point de vie de moins
        mov     A,B
        lda     @FD_R(B)
        cmp     R_ROOM,A
        jne     @fo_s
        cmp     R_ETG,R_NX
        jne     @fo_s
        lda     @HP
        jeq     @fo_s
        mov     R_WX,A
        call    @tcol
        mov     A,R_TC
        lda     @FD_I
        mov     A,B
        lda     @FD_C(B)
        cmp     R_TC,A
        jne     @fo_s
        lda     @HP
        dec     A
        sta     @HP
        jne     @fo_k
        movd    %pj_dropdead,RS         ; (le dernier : il meurt)
fo_k:   call    @hp_draw
        mov     %sx_crhit>>8,A          ; elle se brise sur lui : le bruit de la dalle, puis touche
        mov     %sx_crhit&$FF,B
        call    @snd
        jmp     @fd_end
fo_s:   mov     %sx_crash>>8,A          ; elle se brise (meme dans une autre salle)
        mov     %sx_crash&$FF,B
        call    @snd
fd_end: lda     @FD_I
        mov     A,B
        clr     A
        sta     @FD_R(B)
        rets
; fd_era / fd_drw : efface (le decor de la carte) / dessine (la dalle) ses 2 rangees
fd_era: lda     @FD_I
        mov     A,B
        lda     @FD_D(B)
        jeq     @fe_x
        cmp     R_ROOM,A
        jne     @fe_z
        clr     A
        call    @fd_cells
fe_z:   lda     @FD_I
        mov     A,B
        clr     A
        sta     @FD_D(B)
fe_x:   rets
fd_drw: lda     @FD_I                   ; dessinee au point pres : sa dalle (une rangee de 4 caracteres),
        mov     A,B                     ; decalee de FD_P points, sur 2 lignes de 4 cases, avec le decor
        lda     @FD_R(B)                ; dessous ; dans 8 caracteres a elle de BAGC1
        cmp     R_ROOM,A
        jeq     @fw_0
        rets
fw_0:   sta     @FD_D(B)
        lda     @FD_Y(B)                ; la 1re ligne dessinee : (Y + 4) / 10 (le haut de la dalle a 4
        add     %4,A                    ; points vides) ; FD_P = Y - 10 x ligne (-4 a 5)
        clr     R_NX
fw_d:   cmp     %10,A
        jl      @fw_e
        sub     %10,A
        inc     R_NX
        jmp     @fw_d
fw_e:   sub     %4,A
        sta     @FD_P
        mov     R_NX,A
        sta     @FD_DY(B)
        lda     @FD_V(B)                ; elle se brise : 3 morceaux (2 colonnes, 1, 1), les petits
        clrc                            ; prennent de l'avance en tombant (0 a 5 points, selon la vitesse)
        rrc     A
        clrc
        rrc     A
        mov     A,R_TE                  ; (vitesse / 4 : 0-5)
        lda     @FD_C(B)
        and     %1,A                    ; (colonne impaire : les morceaux a gauche)
        clrc
        rlc     A
        rlc     A
        mov     A,R_TC                  ; (0 ou 4)
        clr     R_Q4
fw_o:   mov     R_TC,A                  ; le morceau de cette colonne : 0, 1 ou 2
        add     R_Q4,A
        mov     A,B
        lda     @fd_pc(B)
        mov     A,B                     ; morceau x 6 + vitesse / 4
        clrc
        rlc     A
        add     R_B,A
        clrc
        rlc     A
        add     R_TE,A
        mov     A,B
        lda     @fd_po(B)
        mov     A,B
        lda     @FD_P
        add     R_B,A
        mov     R_Q4,B
        sta     @FD_O(B)
        inc     R_Q4
        cmp     %4,R_Q4
        jne     @fw_o
        lda     @FD_I
        mov     A,B
        lda     @FD_K(B)                ; les 4 caracteres de sa dalle
        mov     %4,R_Q2
        call    @row_ad
        clr     B
fw_s:   lda     *RD
        sta     @FD_ST(B)
        add     %1,RD
        adc     %0,RD-1
        inc     B
        cmp     %4,B
        jne     @fw_s
        clr     R_Q4                    ; le decor sous ses 8 cases
fw_t:   mov     R_Q4,A
        clrc
        rrc     A
        clrc
        rrc     A                       ; (rangee 0-1)
        add     R_NX,A
        clr     R_TC
        cmp     %18,A
        jhs     @fw_u                   ; (sous la salle : rien)
        add     %ROOM_TOP,A
        push    A
        lda     @FD_I
        mov     A,B
        lda     @FD_C(B)
        clrc
        rlc     A
        rlc     A
        mov     A,B
        mov     R_Q4,A
        and     %3,A
        add     R_A,B
        pop     A
        call    @map_at
        mov     A,R_TC
fw_u:   mov     R_Q4,B
        mov     R_TC,A
        sta     @FD_DT(B)
        inc     R_Q4
        cmp     %8,R_Q4
        jne     @fw_t
        lda     @FD_I                   ; ses 8 caracteres, ligne par ligne du generateur
        clrc
        rlc     A
        rlc     A
        rlc     A
        add     %FD_CODE,A
        mov     A,R_TE                  ; (son premier code)
        clr     A
        sta     @FD_L
fw_l:   movd    %FONT_B,RV
        add     R_TE,RV
        adc     %0,RV-1
        lda     @FD_L                   ; + 128 x ligne
        clrc
        rrc     A
        jnc     @fw_l1
        add     %128,RV
        adc     %0,RV-1
fw_l1:  add     R_A,RV-1
        movd    RV,TEMP1
        trap    8
        lda     @FD_L                   ; ligne depuis le haut, dans la 1re case : 9 - L
        mov     A,B
        mov     %9,A
        sub     B,A
        sta     @FD_SY
        clr     R_Q4                    ; case 0-7
fw_c:   lda     @FD_SY                  ; la ligne de la dalle : SY + 10 x rangee - P
        btjz    %4,R_Q4,@fw_c1
        add     %10,A
fw_c1:  push    A
        mov     R_Q4,A                  ; - le haut de la dalle de cette colonne
        and     %3,A
        mov     A,B
        lda     @FD_O(B)
        mov     A,B
        pop     A
        sub     B,A
        clr     R_Q3                    ; (la dalle : rien)
        jn      @fw_c2
        cmp     %10,A
        jhs     @fw_c2
        mov     A,B                     ; ligne du generateur de la dalle : 9 - ...
        mov     %9,A
        sub     B,A
        push    A
        mov     R_Q4,A
        and     %3,A
        mov     A,B
        lda     @FD_ST(B)
        pop     B
        call    @pat_l
        mov     A,R_Q3
fw_c2:  mov     R_Q4,B                  ; le decor
        lda     @FD_DT(B)
        mov     A,R_TC
        lda     @FD_L
        mov     A,B
        mov     R_TC,A
        call    @pat_l
        or      R_Q3,A
        movp    A,P46
        inc     R_Q4
        cmp     %8,R_Q4
        jne     @fw_c
        lda     @FD_L
        inc     A
        sta     @FD_L
        cmp     %10,A
        jne     @fw_l
        clr     R_Q4                    ; a l'ecran : ses 8 cases (sauf sur le personnage)
fw_w:   mov     R_Q4,A
        clrc
        rrc     A
        clrc
        rrc     A
        mov     A,R_TC
        lda     @FD_I
        mov     A,B
        lda     @FD_DY(B)
        add     R_TC,A
        cmp     %18,A
        jhs     @fz_n
        add     %ROOM_TOP,A
        mov     A,R_NX                  ; ligne d'ecran
        lda     @FD_C(B)
        clrc
        rlc     A
        rlc     A
        mov     A,R_TC
        mov     R_Q4,A
        and     %3,A
        add     R_TC,A
        mov     A,R_TC                  ; colonne d'ecran
        mov     R_NX,A
        sub     R_OR,A
        cmp     R_OH,A
        jhs     @fw_v
        mov     R_TC,A
        sub     R_OC,A
        cmp     R_OW,A
        jl      @fz_n
fw_v:   mov     R_NX,A
        mov     R_TC,B
        call    @cell_addr
        movd    RV,TEMP1
        trap    8
        mov     %$F0,B                  ; (BAGC1, blanc)
        call    @attr_b
        movp    A,P46
        mov     R_TE,A
        add     R_Q4,A
        movp    A,P46
fz_n:   inc     R_Q4
        cmp     %8,R_Q4
        jne     @fw_w
        rets
; --- pat_l : A = tuile du decor, B = ligne du generateur (0 : le bas) -> A = l'octet de son motif
pat_l:  tsta
        jeq     @pl_x
        btjo    %$80,A,@pl_w
        push    A
        movd    %dc_font,RE             ; dc_font + 128 x ligne + tuile
        mov     B,A
        clrc
        rrc     A
        jnc     @pl_1
        add     %128,RE
        adc     %0,RE-1
pl_1:   add     R_A,RE-1
        pop     A
        add     R_A,RE
        adc     %0,RE-1
        lda     *RE
pl_x:   rets
pl_w:   sub     %$C0,A                  ; une brique : LV_WF + 48 x ligne + n
        push    A
        lda     @LV_WF+1
        mov     A,RE
        lda     @LV_WF
        mov     A,RE-1
        pop     A
        add     R_A,RE
        adc     %0,RE-1
        lda     @wf_48(B)
        add     R_A,RE
        adc     %0,RE-1
        lda     @wf_48h(B)
        add     R_A,RE-1
        lda     *RE
        rets
fd_cells:                               ; A = 0 : le decor ; 1 : la dalle (rangees 4 et 5 de FD_K)
        sta     @FD_I+2
        clr     R_Q4                    ; rangee 0-1
fc_r:   lda     @FD_I
        mov     A,B
        lda     @FD_DY(B)
        add     R_Q4,A
        cmp     %18,A
        jhs     @fc_n                   ; (sous la salle)
        add     %ROOM_TOP,A
        mov     A,R_NX                  ; la ligne d'ecran
        clr     R_Q3                    ; colonne 0-3
fc_c:   lda     @FD_I
        mov     A,B
        lda     @FD_C(B)
        clrc
        rlc     A
        rlc     A
        add     R_Q3,A
        mov     A,R_TE                  ; la colonne d'ecran
        mov     R_NX,A
        sub     R_OR,A                  ; dans la fenetre du personnage ?
        cmp     R_OH,A
        jhs     @fc_d
        mov     R_TE,A
        sub     R_OC,A
        cmp     R_OW,A
        jl      @fc_x                   ; oui : on n'y touche pas
fc_d:   lda     @FD_I+2
        jne     @fc_k
        mov     R_NX,A                  ; le decor de la carte
        mov     R_TE,B
        call    @map_at
        jmp     @fc_w
fc_k:   mov     R_Q4,A                  ; la dalle : rangee 4 + R_Q4 du bloc
        add     %4,A
        mov     A,R_Q2
        lda     @FD_I
        mov     A,B
        lda     @FD_K(B)
        call    @row_ad
        add     R_Q3,RD
        adc     %0,RD-1
        lda     *RD
fc_w:   mov     A,R_TC
        mov     R_NX,A
        mov     R_TE,B
        call    @cell_addr
        movd    RV,TEMP1
        trap    8
        mov     R_TC,B
        call    @attr_b
        movp    A,P46
        mov     R_TC,A
        and     %$7F,A
        movp    A,P46
fc_x:   inc     R_Q3
        cmp     %4,R_Q3
        jne     @fc_c
fc_n:   inc     R_Q4
        cmp     %2,R_Q4
        jne     @fc_r
        rets
fd_fp:  .byte   40,100,160,220          ; etage -> hauteur de sa dalle dans la salle, en points
fd_pc:  .byte   0,0,1,2, 2,1,0,0        ; colonne -> morceau (case paire, case impaire)
fd_po:  .byte   0,0,0,0,0,0             ; morceau, vitesse / 4 -> avance en points
        .byte   0,0,1,2,3,4
        .byte   0,1,2,4,5,5

; --- fa_rest : la case sous les pieds reprend son bloc normal, s'il etait change
fa_rest:
        lda     @FA_SH
        jeq     @fr_x
        mov     A,RD-1
        lda     @FA_SL
        mov     A,RD
        lda     @FA_SV
        sta     *RD
        clr     A
        sta     @FA_SH
fr_x:   rets
fa_e10: .byte   0,10,20
fa_o:   .byte   0,2,1                   ; phase -> normal, image 2, image 1

; --- sp_step : les pics sortent sous le personnage et une demi-case devant lui (et en
;     dessous, s'il est au-dessus du vide) ; ils rentrent SP_HOLD pas apres son passage.
sp_step:
        mov     R_WX,A
        call    @sp_scan
        mov     R_WX,A
        btjo    %$80,R_MIR,@ss_r
        sub     %10,A
        jmp     @ss_2
ss_r:   add     %10,A
ss_2:   call    @sp_scan
sp_tick:
        clr     R_GB
ss_l:   mov     R_GB,B
        lda     @SP_T(B)
        jeq     @ss_n
        mov     A,RD-1
        lda     @SP_T+1(B)
        mov     A,RD
        lda     @SP_T+2(B)
        dec     A
        sta     @SP_T+2(B)
        jne     @ss_n
        clr     A                       ; ils rentrent
        sta     @SP_T(B)
        lda     *RD
        and     %$1F,A
        sta     *RD
        mov     %1,R_U
        call    @sp_swap
ss_n:   add     %3,R_GB
        cmp     %12,R_GB
        jne     @ss_l
        rets
t_x14:  .byte   68,82,96,110,124,138,152,166,180,194

; --- sp_scan : A = abscisse ; la premiere case qui n'est pas un vide, a partir de l'etage
;     du personnage : si ce sont des pics, ils sortent (ou restent sortis).
sp_scan:
        call    @tcol
        mov     A,R_Q4
        mov     R_ETG,R_GC
sc_l:   mov     R_Q4,R_TC
        mov     R_GC,R_TE
        call    @tile_at
        cmp     %T_SPIKE,A
        jeq     @sc_t
        call    @is_hole
        jne     @sc_x
        inc     R_GC
        cmp     %4,R_GC
        jl      @sc_l
sc_x:   rets
sc_t:   clr     B                       ; deja sortis : on relance leur compteur
sc_s:   lda     @SP_T(B)
        cmp     RD-1,A
        jne     @sc_s1
        lda     @SP_T+1(B)
        cmp     RD,A
        jne     @sc_s1
        mov     %SP_HOLD,A
        sta     @SP_T+2(B)
        rets
sc_s1:  add     %3,B
        cmp     %12,B
        jne     @sc_s
        clr     B
sc_f:   lda     @SP_T(B)
        jeq     @sc_n
        add     %3,B
        cmp     %12,B
        jne     @sc_f
        rets                            ; (4 cases de pics deja sorties)
sc_n:   mov     RD-1,A
        sta     @SP_T(B)
        mov     RD,A
        sta     @SP_T+1(B)
        mov     %SP_HOLD,A
        sta     @SP_T+2(B)
        lda     *RD
        or      %$20,A
        sta     *RD
        mov     %sx_spike>>8,A          ; ils sortent : "clac" (start_anim_spike du jeu ; rien quand ils
        mov     %sx_spike&$FF,B         ; rentrent)
        call    @snd
        clr     R_U
        ; (suite dans sp_swap)
; --- sp_swap : la case de pics dont le type est en RD change d'image (R_U = 0 : pics
;     sortis ; 1 : rentres), d'apres les paires de LV_SPK
sp_swap:
        movd    RD,RE
        sub     %30,RE
        sbb     %0,RE-1
        lda     *RE
        mov     A,R_Q
        movd    %LV_SPK,RN
sw2_l:  lda     *RN
        jeq     @sw2_x
        mov     A,R_Q2                  ; rentre
        call    @nx_n
        mov     A,R_Q3                  ; sorti
        add     %1,RN
        adc     %0,RN-1
        cmp     %0,R_U
        jne     @sw2_b
        mov     R_Q2,A
        cmp     R_Q,A
        jne     @sw2_l
        mov     R_Q3,A
        jmp     @sw2_w
sw2_b:  mov     R_Q3,A
        cmp     R_Q,A
        jne     @sw2_l
        mov     R_Q2,A
sw2_w:  sta     *RE
        br      @rd_tile
sw2_x:  rets

; --- bt_do : le bouton d'adresse R_GB (paire). R_GC = 0 : il remonte ; 1 : il s'enfonce ;
;     2 : il reste enfonce. Enfonce, il commande ses grilles : un bouton qui ouvre les fait
;     monter (et les tient ouvertes), un bouton qui ferme les fait tomber.
bt_do:  movd    %LV_BTN,RN
        clr     A
        sta     @BT_NH
bd_l:   lda     *RN
        jne     @bd_l0
        br      @bd_x
bd_l0:
        cmp     R_GB-1,A
        jne     @bd_s
        movd    RN,RE
        add     %1,RE
        adc     %0,RE-1
        lda     *RE
        cmp     R_GB,A
        jne     @bd_s
        add     %1,RE
        adc     %0,RE-1
        lda     *RE
        mov     A,R_Q                   ; la grille
        add     %1,RE
        adc     %0,RE-1
        lda     *RE
        mov     A,R_Q2                  ; le bloc enfonce
        add     %1,RE
        adc     %0,RE-1
        lda     *RE
        mov     A,R_Q3                  ; le bloc normal
        call    @bd_v                   ; (la voisine de droite)
        movd    R_GB,RD
        sub     %30,RD
        sbb     %0,RD-1
        cmp     %0,R_GC
        jne     @bd_p
        mov     R_Q3,A
        sta     *RD
        jmp     @bd_s
bd_p:   mov     R_Q2,A
        sta     *RD
        cmp     %1,R_GC                 ; il s'enfonce : clic
        jne     @bd_q
        mov     %sx_click>>8,A
        mov     %sx_click&$FF,B
        call    @snd
bd_q:   mov     R_Q,B
        cmp     %16,B
        jhs     @bd_s
        movd    R_GB,RD
        lda     *RD
        and     %$1F,A
        cmp     %T_BOPEN,A
        jne     @bd_c
        lda     @G_ST(B)
        cmp     %1,A
        jeq     @bd_s
        clr     A
        sta     @G_TM(B)
        mov     %1,A
        sta     @G_ST(B)
        jmp     @bd_s
bd_c:   mov     %4,A
        sta     @G_ST(B)
bd_s:   add     %7,RN
        adc     %0,RN-1
        br      @bd_l
; bd_v : RE = le bloc normal de l'entree ; ses 2 octets suivants : les blocs de la voisine de droite,
;        enfonce puis normal (egaux : rien). Selon R_GC (0 : normal), son bloc change ; BT_NH:BT_NL
;        (son type) pour la redessiner. Seulement si elle montre encore l'autre image : une dalle
;        fragile voisine tombee (un trou) reste un trou.
bd_v:   movd    RE,RF
        add     %1,RF
        adc     %0,RF-1
        lda     *RF
        mov     A,R_TC                  ; enfonce
        add     %1,RF
        adc     %0,RF-1
        lda     *RF                     ; normal
        cmp     R_TC,A
        jeq     @bv_x
        cmp     %0,R_GC
        jne     @bv_1
        mov     R_TC,B                  ; relache : elle doit montrer l'image enfoncee, elle prend la normale
        mov     A,R_TC
        jmp     @bv_2
bv_1:   mov     A,B                     ; enfonce : elle doit montrer l'image normale
bv_2:   movd    R_GB,RF                 ; son type : celui du bouton + 1 ; son bloc : - 30
        add     %1,RF
        adc     %0,RF-1
        mov     RF-1,A
        push    A
        mov     RF,A
        push    A
        sub     %30,RF
        sbb     %0,RF-1
        lda     *RF
        cmp     B,A
        jeq     @bv_3
        pop     A                       ; (elle a change : on n'y touche pas)
        pop     A
        rets
bv_3:   pop     A
        sta     @BT_NL
        pop     A
        sta     @BT_NH
        mov     R_TC,A
        sta     *RF
bv_x:   rets
bd_x:   cmp     %2,R_GC
        jeq     @bd_r
        lda     @BT_NH                  ; la voisine de droite d'abord
        jeq     @bd_y
        mov     A,RD-1
        lda     @BT_NL
        mov     A,RD
        call    @rd_tile
bd_y:   movd    R_GB,RD
        br      @rd_tile
bd_r:   rets

; --- gt_run : un pas de plus pour les grilles en mouvement -------------------------
gt_run: clr     R_GB
gr_l:   mov     R_GB,B
        lda     @G_ST(B)
        jne     @gr_l0
        br      @gr_n
gr_l0:  call    @gt_ptr
        lda     *RN
        mov     A,RD-1
        call    @nx_n
        mov     A,RD
        lda     *RD                     ; l'ouverture : les 3 bits du haut du type
        rl      A
        rl      A
        rl      A
        and     %7,A
        mov     A,R_GC
        mov     R_GB,B
        lda     @G_ST(B)
        cmp     %1,A
        jne     @gr_2
        lda     @G_TM(B)                ; 1 : elle monte d'une ligne tous les G_UP pas
        jeq     @gr_1m
        dec     A
        sta     @G_TM(B)
        jmp     @gr_n
gr_1m:  mov     %G_UP-1,A
        sta     @G_TM(B)
        cmp     %5,R_GC
        jeq     @gr_1o
        inc     R_GC
        call    @gt_set
        jmp     @gr_n
gr_1o:  lda     *RD                     ; en haut : la porte de sortie y reste,
        and     %$1F,A
        cmp     %T_GATE,A
        jeq     @gr_1g
        clr     A
        sta     @G_ST(B)
        jmp     @gr_n
gr_1g:  mov     %2,A                    ; une grille y reste un moment
        sta     @G_ST(B)
        mov     %G_WAIT,A
        sta     @G_TM(B)
        jmp     @gr_n
gr_2:   cmp     %4,A
        jeq     @gr_4
        mov     A,R_Q                   ; 2 ou 3 : on compte
        lda     @G_TM(B)
        dec     A
        sta     @G_TM(B)
        jne     @gr_n
        mov     %G_SLOW,A
        sta     @G_TM(B)
        cmp     %2,R_Q
        jne     @gr_4
        mov     %3,A
        sta     @G_ST(B)
        jmp     @gr_n
gr_4:   cmp     %0,R_GC                 ; 3 (lentement) ou 4 (a chaque pas) : elle descend d'une ligne
        jne     @gr_4d
        clr     A
        sta     @G_ST(B)
        jmp     @gr_n
gr_4d:  dec     R_GC
        call    @gt_set
gr_n:   inc     R_GB
        cmp     %16,R_GB
        jeq     @gr_e
        br      @gr_l
gr_e:   rets

; --- gt_ptr : RN = la ligne de la grille B dans la table ---------------------------
gt_ptr: movd    %LV_GATE,RN
        cmp     %0,B
        jeq     @gp_x
gp_l:   add     %11,RN
        adc     %0,RN-1
        djnz    B,@gp_l
gp_x:   rets

; --- gt_set : la grille R_GB prend l'ouverture R_GC (0 fermee a 5 ouverte) : son type,
;     l'image de la case ou sont dessines ses barreaux, et l'ecran si elle y est.
gt_set: mov     R_GB,B
        call    @gt_ptr
        lda     *RN
        mov     A,RD-1
        call    @nx_n
        mov     A,RD
        mov     R_GC,B
        call    @t_op
        call    @nx_n
        mov     A,RD-1
        call    @nx_n
        mov     A,RD                    ; le bloc de l'image
        add     %1,RN
        adc     %0,RN-1
        add     R_GC,RN
        adc     %0,RN-1
        cmp     %0,RD-1
        jeq     @gs_x
        lda     *RN
        sta     *RD
        add     %30,RD
        adc     %0,RD-1
        movd    RD,RE                   ; dans la salle affichee : un bruit
        sub     RROOM,RE
        sbb     RROOM-1,RE-1
        cmp     %0,RE-1
        jne     @gs_rt
        mov     RE,A
        sub     %30,A
        cmp     %30,A
        jhs     @gs_rt
        mov     %sx_tick>>8,A           ; un cran
        mov     %sx_tick&$FF,B
        cmp     %0,R_GC
        jne     @gs_s
        mov     %sx_slam>>8,A           ; fermee
        mov     %sx_slam&$FF,B
gs_s:   call    @snd
gs_rt:  br      @rd_tile
gs_x:   rets

; --- ex_try : debout, "haut" : la porte de sortie grande ouverte est-elle dans la case du
;     personnage, celle de derriere ou celle de devant (comme le jeu) ? Alors le niveau est fini.
ex_try: mov     R_WX,A
        call    @tcol
        mov     A,R_Q4
        call    @ex_t
        dec     R_Q4
        call    @ex_t
        inc     R_Q4
        inc     R_Q4
ex_t:   mov     R_ETG,R_TE
        mov     R_Q4,R_TC
        call    @tile_at
        cmp     %16,A
        jne     @et_x
        lda     *RD
        cmp     %$B0,A                  ; 16 + ouverture 5
        jne     @et_x
        br      @lv_fin
et_x:   rets

; lv_fin : le prince entre dans la porte : il disparait, fanfare, puis l'ecran titre ; une
; touche, et le niveau recommence (il n'y en a qu'un dans l'Exelmemoire)
lv_fin: mov     %$64,B                  ; (on repart de zero : la pile aussi)
        ldsp
        mov     %sx_fin>>8,A
        mov     %sx_fin&$FF,B
        call    @snd
        call    @draw_room              ; la salle, sans lui
        mov     %30,R_Q                 ; 2,5 s
lf_w:   call    @fr_wait
        djnz    R_Q,@lf_w
lf_r:   lda     @joy_state0             ; "haut" relache
        and     %$1F,A
        jne     @lf_r
        br      @lv_ok

; --- t_op : la case dont le type est en RD prend l'ouverture B (0-5) dans les 3 bits du haut
;     de son type (grille : 4 ; porte de sortie : 16 et 17, sa case de droite)
t_op:   mov     B,A
        rl      A
        rl      A
        rl      A
        rl      A
        rl      A
        and     %$E0,A
        mov     A,B
        lda     *RD
        and     %$1F,A
        or      B,A
        sta     *RD
        rets

; --- gt_reset : grilles et boutons comme au depart du niveau -----------------------
gt_reset:
        clr     B                       ; les pics sortis rentrent tout de suite
        mov     %1,A
gz_s:   sta     @SP_T+2(B)
        add     %3,B
        cmp     %12,B
        jne     @gz_s
        call    @sp_tick
        clr     B
        clr     A
gz_l:   sta     @G_ST(B)
        sta     @G_TM(B)
        inc     B
        cmp     %16,B
        jne     @gz_l
        sta     @BT_AH
        sta     @BT_AL
        movd    %LV_GATE,RN
gz_g:   lda     *RN
        jeq     @gz_b
        mov     A,RD-1
        call    @nx_n
        mov     A,RD
        call    @nx_n
        mov     A,RE-1
        call    @nx_n
        mov     A,RE                    ; RE = le bloc de l'image
        add     %7,RN
        adc     %0,RN-1
        lda     *RN                     ; l'ouverture au depart
        mov     A,R_GC
        mov     A,B
        call    @t_op
        sub     %6,RN
        sbb     %0,RN-1
        add     R_GC,RN
        adc     %0,RN-1
        lda     *RN
        mov     A,R_Q
        sub     R_GC,RN
        sbb     %0,RN-1
        add     %7,RN
        adc     %0,RN-1
        cmp     %0,RE-1
        jeq     @gz_g
        mov     R_Q,A
        sta     *RE
        jmp     @gz_g
gz_b:   movd    %LV_BTN,RN
gz_c:   lda     *RN
        jeq     @gz_x
        mov     A,RD-1
        call    @nx_n
        mov     A,RD
        sub     %30,RD
        sbb     %0,RD-1
        add     %3,RN
        adc     %0,RN-1
        lda     *RN
        sta     *RD
        add     %1,RN                   ; la voisine de droite : son bloc normal
        adc     %0,RN-1
        lda     *RN
        mov     A,R_TC
        add     %1,RN
        adc     %0,RN-1
        lda     *RN
        cmp     R_TC,A
        jeq     @gz_n
        add     %31,RD                  ; (bloc du bouton + 1)
        adc     %0,RD-1
        sub     %30,RD
        sbb     %0,RD-1
        sta     *RD
gz_n:   add     %1,RN
        adc     %0,RN-1
        jmp     @gz_c
gz_x:   rets

; --- rd_tile : redessine la case dont le type est a l'adresse RD, si elle est dans la
;     salle affichee (24 caracteres ; ceux qu'occupe le personnage ne sont pas touches).
rd_tile:
        movd    RD,RE
        sub     RROOM,RE
        sbb     RROOM-1,RE-1
        cmp     %0,RE-1
        jne     @rt_x
        mov     RE,A
        sub     %30,A
        cmp     %30,A
        jhs     @rt_x
        mov     %ROOM_TOP,R_GD
rt_e:   cmp     %10,A
        jl      @rt_c
        sub     %10,A
        add     %6,R_GD
        jmp     @rt_e
rt_c:   rl      A
        rl      A
        mov     A,R_GB-1                ; 1re colonne ; R_GD : 1re ligne
        clr     R_GE
rt_l:   mov     R_GE,A
        and     %3,A
        add     R_GB-1,A
        mov     A,R_Q3                  ; colonne
        mov     R_GE,A
        rr      A
        rr      A
        and     %7,A
        add     R_GD,A
        mov     A,R_NX                  ; ligne
        sub     R_OR,A                  ; dans la fenetre du personnage ?
        cmp     R_OH,A
        jhs     @rt_d
        mov     R_Q3,A
        sub     R_OC,A
        cmp     R_OW,A
        jl      @rt_s
rt_d:   mov     R_NX,A
        mov     R_Q3,B
        call    @map_at
        mov     A,R_T
        mov     R_NX,A
        mov     R_Q3,B
        call    @cell_addr
        movd    RV,TEMP1
        trap    8
        mov     R_T,B
        call    @attr_b
        movp    A,P46
        mov     B,A
        and     %$7F,A
        movp    A,P46
rt_s:   inc     R_GE
        cmp     %24,R_GE
        jne     @rt_l
rt_x:   rets

; --- attr_f : l'attribut A d'une case du decor, en negatif pendant l'eclair
attr_f: push    A
        lda     @FLNEG
        jeq     @af_n
        pop     A
        and     %$18,A                  ; (on garde le generateur)
        or      %FL_NEG,A
        rets
af_n:   pop     A
        rets

; =================================================================================
; LE GARDE : un par salle (table LV_GARD, faite par niveau2exl.py). Il est dessine avec les
; poses du prince, en couleur, par les memes routines : g_swap echange les registres de
; dessin du prince et ceux du garde. Ses pas sont lus dans les memes sequences.
; =================================================================================

; --- g_load : le garde de la salle R_ROOM (appele par set_room) -------------------
g_load: lda     @G_ON                   ; le garde de la salle qu'on quitte : on retient ou il est
        jeq     @gl_s
        lda     @G_IDX
        rr      A                       ; (2 x (salle - 1) -> salle - 1)
        mov     A,B
        lda     @G_X
        sta     @GX_TAB(B)
gl_s:   clr     A
        sta     @G_ON
        sta     @GR_OH
        sta     @G_T
        sta     @G_JB
        mov     R_ROOM,A
        dec     A
        rl      A
        mov     A,B
        sta     @G_IDX
        lda     @LV_GARD(B)
        mov     A,R_GD
        and     %$3F,A
        cmp     %30,A
        jl      @gl_0
        rets                            ; pas de garde
gl_0:   clr     R_GC                    ; etage et case
gl_e:   cmp     %10,A
        jl      @gl_c
        sub     %10,A
        inc     R_GC
        jmp     @gl_e
gl_c:   mov     A,R_GE
        mov     R_GC,A
        sta     @G_ETG
        mov     %72,A                   ; le jeu le pose au bord gauche de la case suivante
gl_x:   cmp     %0,R_GE
        jeq     @gl_y
        add     %14,A
        dec     R_GE
        jmp     @gl_x
gl_y:   sta     @G_X
        push    B
        mov     B,A
        rr      A
        mov     A,B
        lda     @GX_TAB(B)              ; deja vu : la ou on l'a laisse
        jeq     @gl_z
        sta     @G_X
gl_z:   pop     B
        lda     @LV_GARD+1(B)
        mov     A,R_GE
        and     %$0F,A
        sta     @G_HPM
        sta     @G_HP
        mov     R_GE,A
        rr      A                       ; (les 4 bits du haut : 4 rotations)
        rr      A
        rr      A
        rr      A
        and     %$03,A
        sta     @G_SKL
        clr     A
        btjo    %$80,R_GE,@gl_d
        mov     %$80,A                  ; tourne a droite
gl_d:   sta     @GR_MIR
        mov     %GS_A,A
        sta     @GR_SET
        mov     %pj_alertstand>>8,A
        sta     @G_RSH
        mov     %pj_alertstand&$FF,A
        sta     @G_RSL
        mov     %1,A
        btjz    %$40,R_GD,@gl_v
        mov     %pj_dropdead_dead>>8,A  ; deja mort
        sta     @G_RSH
        mov     %pj_dropdead_dead&$FF,A
        sta     @G_RSL
        mov     %2,A
gl_v:   sta     @G_ON
        rets

; --- g_swap : echange les registres de dessin (R39-R40, R49-R63) avec G_REG ------
g_swap: mov     %15,B
gw_l:   dec     B
        lda     @$0031(B)
        push    A
        lda     @G_REG+2(B)
        sta     @$0031(B)
        pop     A
        sta     @G_REG+2(B)
        cmp     %0,B
        jne     @gw_l
        lda     @G_REG
        push    A
        mov     RP-1,A
        sta     @G_REG
        pop     A
        mov     A,RP-1
        lda     @G_REG+1
        push    A
        mov     RP,A
        sta     @G_REG+1
        pop     A
        mov     A,RP
        rets

; --- g_step : un pas du garde : decision, pas suivant de sa sequence, dessin, coups -----
g_step: clr     A
        sta     @OT_EN
        lda     @G_ON
        jne     @gs_0
        rets
gs_0:   clr     A                       ; la marque d'escrime du pas du prince (regles 0,n)
        cmp     %0,RR-1
        jne     @gs_t
        mov     RR,A
gs_t:   sta     @K_TAG
        call    @g_ai
        lda     @G_RSH
        mov     A,RE-1
        lda     @G_RSL
        mov     A,RE
gs_r:   lda     *RE
        jne     @gs_f
        call    @nx_e                   ; fin de sequence : demi-tour, avance, suite
        call    @g_flip
        call    @nx_e
        call    @g_move
        call    @nx_e
        mov     A,R_GD
        call    @nx_e
        mov     A,RE
        mov     R_GD,RE-1
        jmp     @gs_r
gs_f:   sta     @G_REG                  ; la pose
        mov     A,RD-1
        call    @nx_e
        sta     @G_REG+1
        mov     A,RD
        clr     B                       ; ecarts de ligne et de decalage (0 : la pose du prince)
        clr     A
        lda     @pr_gflag
        jeq     @gs_p
        sub     %4,RD                   ; le garde a ses images : les 4 octets avant la pose du
        sbb     %0,RD-1                 ; prince disent la sienne, et les ecarts de ligne et de decalage
        lda     *RD
        sta     @G_REG
        call    @gd_n
        sta     @G_REG+1
        call    @gd_n
        mov     A,B
        call    @gd_n
gs_p:   push    B                       ; (ligne)
        push    A                       ; (decalage)
        call    @nx_e
        call    @g_flip
        call    @nx_e
        call    @g_move
        call    @nx_e                   ; decalage de l'image, dans le sens du garde
        mov     A,R_Q4
        pop     A
        add     R_A,R_Q4
        lda     @GR_MIR
        btjo    %$80,A,@gs_d
        inv     R_Q4
        inc     R_Q4
gs_d:   call    @nx_e                   ; (poids du corps : sans objet)
        call    @nx_e                   ; ligne
        and     %$1F,A
        mov     A,R_GB
        pop     A
        add     R_A,R_GB
        call    @nx_e
        mov     A,R_GC                  ; regles : 0,n = la marque d'escrime n
        call    @nx_e
        cmp     %0,R_GC
        jeq     @gs_g
        clr     A
gs_g:   sta     @G_TAG
        call    @nx_e
        mov     RE-1,A
        sta     @G_RSH
        mov     RE,A
        sta     @G_RSL
        lda     @G_X                    ; colonne du bord avant
        add     R_Q4,A
        mov     A,B
        lda     @pr_col(B)
        mov     A,R_GC
        lda     @G_ETG
        mov     A,B
        lda     @t_eoff(B)
        add     R_A,R_GB                ; ligne
        call    @g_swap                 ; les registres de dessin : ceux du garde
        mov     R_GC,R_COL
        mov     R_GB,R_ROW
        lda     *RP                     ; pose : largeur, hauteur, nombre de cases pleines
        mov     A,R_W
        call    @next_p
        mov     A,R_H
        call    @next_p
        mov     A,R_K
        add     %1,RP
        adc     %0,RP-1
        movd    RP,RM
        mov     RM-1,A                  ; (le debut du plan, pour oc_get : put_window deplace RM)
        sta     @G_PLH
        mov     RM,A
        sta     @G_PLL
        mov     R_H,B
gs_m:   add     R_W,RP
        adc     %0,RP-1
        djnz    B,@gs_m
        btjz    %$80,R_MIR,@gs_w
        sub     R_W,R_COL
gs_w:   cmp     %GS_A,R_SET             ; double tampon : la pose s'ecrit dans le jeu qui n'est pas
        jeq     @gs_wb                  ; a l'ecran (BAGC1), puis put_window y fait passer ses cases
        mov     %GS_A,R_SET
        jmp     @gs_wa
gs_wb:  mov     %GS_B,R_SET
gs_wa:  mov     %GB_ATTR,A
        sta     @P_ATTR
        call    @scan_dk                ; le decor sous ses cases : fondu dans ses motifs, comme pour
gs_k:   call    @put_pose               ; le prince (il y prend sa couleur : une case n'en a qu'une)
        call    @put_window
        call    @erase_old
        mov     R_COL,R_OC
        mov     R_ROW,R_OR
        mov     R_W,R_OW
        mov     R_H,R_OH
        mov     %ATTR,A
        sta     @P_ATTR
        call    @g_swap
        call    @g_hits
        mov     %1,A
        sta     @OT_EN
        rets
gd_n:   add     %1,RD
        adc     %0,RD-1
        lda     *RD
        rets
nx_e:   add     %1,RE
        adc     %0,RE-1
        lda     *RE
        rets

; --- g_flip : A = drapeaux du pas ; 1 : demi-tour ------------------------------
g_flip: btjz    %1,A,@gf_x
        lda     @GR_MIR
        xor     %$80,A
        sta     @GR_MIR
gf_x:   rets

; --- g_move : A = avance (signee) dans le sens du garde ; il reste dans la salle et ne
;     passe pas le prince
g_move: mov     A,B
        lda     @GR_MIR
        btjo    %$80,A,@gm_r
        inv     B
        inc     B
gm_r:   lda     @G_X
        add     R_B,A
        cmp     %62,A
        jhs     @gm_1
        mov     %62,A
gm_1:   cmp     %195,A
        jl      @gm_2
        mov     %194,A
gm_2:   sta     @G_X
        mov     A,B
        lda     @G_ON
        cmp     %1,A
        jne     @gm_x
        lda     @G_ETG
        cmp     R_ETG,A
        jne     @gm_x
        lda     @K_SIDE
        jne     @gm_s
        mov     B,A                     ; prince a gauche : le garde reste a sa droite
        cmp     R_X,A
        jhs     @gm_x
        mov     R_X,A
        sta     @G_X
        rets
gm_s:   mov     R_X,A                   ; prince a droite
        cmp     R_B,A
        jhs     @gm_x
        mov     R_X,A
        sta     @G_X
gm_x:   rets

; --- k_clamp : le prince ne passe pas le garde (meme etage) ------------------------
k_clamp:
        lda     @G_ON
        cmp     %1,A
        jne     @kc_x
        lda     @G_ETG
        cmp     R_ETG,A
        jne     @kc_x
        lda     @G_X
        mov     A,R_GD
        mov     R_X,A
        cmp     R_GD,A
        jhs     @kc_r
        mov     R_GD,A                  ; a gauche : l'ecart
        sub     R_X,A
        cmp     %30,A
        jl      @kc_l
        clr     A                       ; loin : c'est son cote
        sta     @K_SIDE
kc_x:   rets
kc_l:   lda     @K_SIDE
        jeq     @kc_x
        mov     R_GD,R_X                ; il etait a droite : il reste a droite
        rets
kc_r:   sub     R_GD,A                  ; a droite
        cmp     %30,A
        jl      @kc_q
        mov     %1,A
        sta     @K_SIDE
        rets
kc_q:   lda     @K_SIDE
        jne     @kc_x
        mov     R_GD,R_X                ; il etait a gauche
        rets

; --- distances, comme le jeu (char_opp_dist) : > 0 si l'autre est devant ; +13 face a face
gd_dist:                                ; du garde vers le prince
        lda     @G_X
        mov     A,R_GB
        lda     @GR_MIR
        mov     A,R_GC
        mov     R_X,R_GD
        mov     R_MIR,R_GE
        jmp     @odist
kd_dist:                                ; du prince vers le garde
        mov     R_X,R_GB
        mov     R_MIR,R_GC
        lda     @G_X
        mov     A,R_GD
        lda     @GR_MIR
        mov     A,R_GE
odist:  mov     R_GD,A                  ; R_GB, R_GC : x et sens de celui qui regarde ; R_GD, R_GE : l'autre
        cmp     R_GB,A
        jhs     @od_p
        mov     R_GB,A
        sub     R_GD,A
        cmp     %120,A
        jl      @od_n
        mov     %120,A
od_n:   inv     A
        inc     A
        jmp     @od_d
od_p:   sub     R_GB,A
        cmp     %120,A
        jl      @od_d
        mov     %120,A
od_d:   btjo    %$80,R_GC,@od_r
        inv     A
        inc     A
od_r:   btjo    %$80,A,@od_x            ; derriere
        mov     A,B
        mov     R_GC,A
        xor     R_GE,A
        btjz    %$80,A,@od_s
        mov     B,A
        add     %13,A
        rets
od_s:   mov     B,A
od_x:   rets

; --- rnd : A = un nombre au hasard (0-255) ------------------------------------------
rnd:    lda     @RND
        mov     A,B
        rl      A
        rl      A
        add     R_B,A
        add     %59,A
        sta     @RND
        rets

; --- g_ai : le garde decide, quand il est en garde (comme autocontrol_guard du jeu) ----
g_ai:   lda     @G_ON
        cmp     %1,A
        jne     @ga_x
        lda     @G_T
        jeq     @ga_t
        dec     A
        sta     @G_T
ga_t:   lda     @G_JB
        jeq     @ga_j
        dec     A
        sta     @G_JB
ga_j:   lda     @G_ETG
        cmp     R_ETG,A
        jne     @ga_x                   ; pas au meme etage : il attend
        lda     @G_RSH                  ; au repos : il se met en garde
        cmp     %(pj_alertstand+9)>>8,A
        jne     @ga_1
        lda     @G_RSL
        cmp     %(pj_alertstand+9)&$FF,A
        jne     @ga_1
        mov     %pj_ready>>8,A
        sta     @G_RSH
        mov     %pj_ready&$FF,A
        sta     @G_RSL
ga_x:   rets
ga_1:   lda     @G_RSH                  ; en garde, entre deux mouvements ?
        mov     A,RE-1
        lda     @G_RSL
        mov     A,RE
        call    @rdy_re
        jne     @ga_x
        lda     @HP
        jeq     @ga_x                   ; le prince est mort
        call    @gd_dist
        btjz    %$80,A,@ga_2
        lda     @GR_MIR                 ; le prince est derriere : demi-tour
        xor     %$80,A
        sta     @GR_MIR
        rets
ga_2:   mov     A,R_GD
        cmp     %35,A
        jl      @ga_2b                  ; loin : il avance
        br      @ga_adv
ga_2b:
        cmp     %12,A
        jhs     @ga_3
        mov     %pj_retreat>>8,A        ; trop pres : il recule
        sta     @G_RSH
        mov     %pj_retreat&$FF,A
        sta     @G_RSL
        rets
ga_3:   lda     @K_ARM
        jne     @ga_5
        lda     @G_T                    ; le prince sans epee : il frappe des qu'il peut
        jne     @ga_x
        mov     R_GD,A
        cmp     %29,A
        jl      @ga_str
        br      @ga_adv
ga_5:   mov     R_GD,A
        cmp     %29,A
        jl      @ga_6
        call    @rnd                    ; hors de portee : il avance (le plus souvent)
        mov     A,R_GC
        lda     @G_SKL
        mov     A,B
        lda     @p_adv(B)
        cmp     R_GC,A
        jhs     @ga_adv
        rets
ga_6:   lda     @K_TAG                  ; le coup du prince part (152, 162, 153) : parer ?
        cmp     %3,A
        jhs     @ga_6a
        jmp     @ga_7
ga_6a:
        call    @rnd
        mov     A,R_GC
        lda     @G_SKL
        mov     A,B
        lda     @G_JB
        jeq     @ga_6b
        lda     @p_imb(B)
        jmp     @ga_6c
ga_6b:  lda     @p_blk(B)
ga_6c:  cmp     R_GC,A
        jl      @ga_7
        movd    %pj_readyblock,RE
        lda     @K_TAG
        cmp     %4,A                    ; (deja l'image 153 : la parade commence a l'image 150)
        jne     @ga_6d
        add     %9,RE
        adc     %0,RE-1
ga_6d:  mov     RE-1,A
        sta     @G_RSH
        mov     RE,A
        sta     @G_RSL
        rets
ga_7:   lda     @G_T                    ; frapper ?
        jne     @ga_y
        call    @rnd
        mov     A,R_GC
        lda     @G_SKL
        mov     A,B
        lda     @G_JB
        jeq     @ga_7b
        lda     @p_rst(B)
        jmp     @ga_7c
ga_7b:  lda     @p_str(B)
ga_7c:  cmp     R_GC,A
        jl      @ga_y
ga_str: mov     %pj_strike>>8,A
        sta     @G_RSH
        mov     %pj_strike&$FF,A
        sta     @G_RSL
        rets
ga_adv: mov     %pj_advance>>8,A
        sta     @G_RSH
        mov     %pj_advance&$FF,A
        sta     @G_RSL
ga_y:   rets
p_str:  .byte   61,100,61,61            ; probabilites (sur 255) par niveau, comme le jeu : frapper,
p_rst:  .byte   0,0,0,5                 ; frapper juste apres avoir pare,
p_blk:  .byte   0,150,150,200           ; parer,
p_imb:  .byte   0,61,61,100             ; parer juste apres avoir pare,
p_adv:  .byte   255,200,200,200         ; avancer

; --- g_hits : les coups portes (image 154 : le coup ; 150, 161 : la parade) ----------
g_hits: lda     @G_ON
        cmp     %1,A
        jeq     @gh_a
gh_z:   br      @gh_x
gh_a:   lda     @G_ETG
        cmp     R_ETG,A
        jne     @gh_z
        lda     @HP
        jeq     @gh_z
        lda     @G_TAG                  ; le garde porte son coup (153 : pare ou non ; 154 : touche)
        cmp     %1,A
        jeq     @gh_g
        cmp     %4,A
        jne     @gh_k
gh_g:   call    @gd_dist
        btjo    %$80,A,@gh_k
        cmp     %29,A
        jhs     @gh_k
        mov     A,R_GD
        lda     @K_TAG
        cmp     %2,A
        jne     @gh_1
        mov     %pj_blockedstrike>>8,A  ; pare par le prince
        sta     @G_RSH
        mov     %pj_blockedstrike&$FF,A
        sta     @G_RSL
        mov     %sx_clash>>8,A
        mov     %sx_clash&$FF,B
        call    @snd
        jmp     @gh_k
gh_1:   lda     @G_TAG
        cmp     %1,A
        jne     @gh_k
        mov     %8,B                    ; portee : 8 sans epee, 12 avec
        lda     @K_ARM
        jeq     @gh_2
        mov     %12,B
gh_2:   mov     R_GD,A
        cmp     R_B,A
        jl      @gh_k
        lda     @K_ARM                  ; touche : sans epee, il meurt
        jeq     @gh_d
        lda     @HP
        dec     A
        sta     @HP
        jeq     @gh_d
        movd    %pj_stabbed,RS
        jmp     @gh_h
gh_d:   clr     A
        sta     @HP
        movd    %pj_dropdead,RS
gh_h:
        mov     %sx_hit>>8,A
        mov     %sx_hit&$FF,B
        call    @snd
        call    @hp_draw
        rets
gh_k:   lda     @K_TAG                  ; le prince porte son coup
        cmp     %1,A
        jeq     @gh_q
        cmp     %4,A
        jne     @gh_x
gh_q:   call    @kd_dist
        btjo    %$80,A,@gh_x
        cmp     %29,A
        jhs     @gh_x
        mov     A,R_GD
        lda     @G_TAG
        cmp     %2,A
        jne     @gh_3
        movd    %pj_blockedstrike,RS    ; pare par le garde
        mov     %4,A
        sta     @G_JB
        mov     %sx_clash>>8,A
        mov     %sx_clash&$FF,B
        call    @snd
        rets
gh_3:   lda     @K_TAG
        cmp     %1,A
        jne     @gh_x
        mov     R_GD,A
        cmp     %12,A
        jl      @gh_x
        mov     %G_REFR,A               ; touche
        sta     @G_T
        mov     %sx_hit>>8,A
        mov     %sx_hit&$FF,B
        call    @snd
        lda     @G_HP
        dec     A
        sta     @G_HP
        jeq     @gh_m
        mov     %pj_stabbed>>8,A
        sta     @G_RSH
        mov     %pj_stabbed&$FF,A
        sta     @G_RSL
        call    @hp_draw
gh_x:   rets
gh_m:   mov     %pj_dropdead>>8,A       ; il meurt, et le reste jusqu'a la reprise du niveau
        sta     @G_RSH
        mov     %pj_dropdead&$FF,A
        sta     @G_RSL
        mov     %2,A
        sta     @G_ON
        lda     @G_IDX
        mov     A,B
        movd    %LV_GARD,RD
        add     R_B,RD
        adc     %0,RD-1
        lda     *RD
        or      %$40,A
        call    @lv_poke
        br      @hp_draw

; --- k_engage : debout, l'epee, un garde vivant devant a moins de 70 : en garde -------
;     A <> 0 (et non Z) si le prince se met en garde
k_engage:
        lda     @SWORD
        jeq     @ke_n
        lda     @G_ON
        cmp     %1,A
        jne     @ke_n
        lda     @G_ETG
        cmp     R_ETG,A
        jne     @ke_n
        call    @kd_dist
        btjo    %$80,A,@ke_n
        cmp     %90,A                   ; (le jeu : moins de 90 points)
        jhs     @ke_n
        movd    %pj_engarde,RS
        mov     %1,A
        sta     @K_ARM
        mov     %1,A
        rets
ke_n:   clr     A
        rets

; --- rdy_re : Z si RE est le pas qui suit une image d'attente en garde (158, 170, 171)
rdy_re: cmp     %(pj_ready_loop+9)>>8,RE-1
        jne     @ry_2
        cmp     %(pj_ready_loop+9)&$FF,RE
        jeq     @ry_y
ry_2:   cmp     %(pj_ready+9)>>8,RE-1
        jne     @ry_3
        cmp     %(pj_ready+9)&$FF,RE
        jeq     @ry_y
ry_3:   cmp     %(pj_ready+18)>>8,RE-1
        jne     @ry_n
        cmp     %(pj_ready+18)&$FF,RE
        jeq     @ry_y
ry_n:   mov     %1,A
        rets
ry_y:   clr     A
        rets

; --- in_fight : en garde, les commandes : feu = frapper, haut = parer, avant, arriere,
;     bas = ranger l'epee
in_fight:
        btjo    %$10,R_IN,@if_f
        clr     A
        sta     @FIREL
        jmp     @if_1
if_f:   lda     @FIREL
        jne     @if_1
        mov     %1,A
        sta     @FIREL
        movd    %pj_strike,RS
        br      @loop
if_1:   btjz    %1,R_IN,@if_2
        movd    %pj_readyblock,RS
        lda     @G_TAG
        cmp     %4,A                    ; (le coup du garde en est a l'image 153 : on pare tout de suite)
        jne     @if_1b
        add     %9,RS
        adc     %0,RS-1
if_1b:  br      @loop
if_2:   btjz    %8,R_IN,@if_3
        movd    %pj_advance,RS
        br      @loop
if_3:   btjz    %4,R_IN,@if_4
        movd    %pj_retreat,RS
        br      @loop
if_4:   btjz    %2,R_IN,@if_x
        clr     A
        sta     @K_ARM
        movd    %pj_resheathe,RS
        br      @loop
if_x:   br      @in_x

; --- oc_get : la case (ligne R_GE, colonne R_GC) est-elle une case pleine du garde ?
;     A = son code (et non Z), ou 0 (Z)
oc_get: lda     @OT_EN
        jeq     @oc_n
        lda     @GR_ROW
        mov     A,B
        mov     R_GE,A
        sub     B,A
        mov     A,R_GD                  ; ligne dans sa fenetre
        lda     @GR_H
        mov     A,B
        mov     R_GD,A
        cmp     B,A
        jhs     @oc_n
        lda     @GR_COL
        mov     A,B
        mov     R_GC,A
        sub     B,A
        mov     A,R_GE                  ; colonne dans sa fenetre
        lda     @GR_W
        mov     A,B
        mov     R_GE,A
        cmp     B,A
        jhs     @oc_n
        lda     @GR_MIR
        btjz    %$80,A,@oc_m
        mov     B,A                     ; miroir : le plan se lit de droite a gauche
        dec     A
        sub     R_GE,A
        mov     A,R_GE
oc_m:   lda     @G_PLH
        mov     A,RE-1
        lda     @G_PLL
        mov     A,RE
oc_l:   cmp     %0,R_GD
        jeq     @oc_c
        add     R_B,RE
        adc     %0,RE-1
        dec     R_GD
        jmp     @oc_l
oc_c:   add     R_GE,RE
        adc     %0,RE-1
        lda     *RE
        jeq     @oc_n
        mov     A,B                     ; code : son jeu courant + n - 1
        lda     @GR_SET
        add     B,A
        dec     A
        rets
oc_n:   clr     A
        rets

; --- g_hp : les points de vie du garde, en bas a droite (pleins, puis vides) -----------
g_hp:   mov     %HP_ROW,A
        mov     %32,B
        call    @cell_addr
        movd    RV,TEMP1
        trap    8
        mov     %8,R_GE
gh_l:   movp    %G_ATTR,P46
        lda     @G_ON
        cmp     %1,A
        jne     @gh_0
        lda     @G_HPM
        cmp     R_GE,A
        jl      @gh_0
        lda     @G_HP
        cmp     R_GE,A
        jl      @gh_e
        movp    %1,P46
        jmp     @gh_n
gh_e:   movp    %2,P46
        jmp     @gh_n
gh_0:   movp    %0,P46
gh_n:   djnz    R_GE,@gh_l
        rets

; --- wall_fr : le mur arrete le personnage X_FRONT avant sa face : son corps reste alors
;     dans l'avant-derniere case. Pour grimper, s'il y a un mur juste devant lui, on fait comme
;     s'il etait dans la case qui touche le mur : R_Q4 = cette case, R_NX = la distance a son bord.
wall_fr:
        mov     R_X,A                   ; (on regarde jusqu'a 13 devant : selon la longueur du dernier pas,
        btjo    %$80,R_MIR,@wf_r        ; le mur arrete le personnage entre 5 et 13 points avant lui)
        sub     %13,A
        jmp     @wf_1
wf_r:   add     %13,A
wf_1:   call    @tcol
        cmp     %10,A
        jhs     @wf_x                   ; (mur dans la salle voisine : on laisse)
        mov     A,R_GC
        mov     A,R_TC
        mov     R_ETG,R_TE
        call    @tile_at
        cmp     %T_WALL,A
        jne     @wf_x
        mov     R_GC,B
        btjo    %$80,R_MIR,@wf_d
        cmp     %9,B                    ; face a gauche : la case a droite du mur
        jeq     @wf_x
        inc     B
        mov     B,R_Q2
        lda     @t_x14(B)               ; bord gauche de cette case + 10
        mov     A,B
        mov     R_WX,A
        sub     B,A
        add     %10,A                   ; distance du corps au bord gauche
        jmp     @wf_s
wf_d:   cmp     %0,B                    ; face a droite : la case a gauche du mur
        jeq     @wf_x
        dec     B
        mov     B,R_Q2
        inc     B
        lda     @t_x14(B)               ; bord gauche du mur + 10
        sub     %11,A
        sub     R_WX,A                  ; distance du corps au bord droit de la case
wf_s:   cmp     %21,A
        jhs     @wf_x                   ; (trop loin, ou deja dedans)
        mov     A,R_NX
        mov     R_Q2,R_Q4
wf_x:   rets

; --- wall_ahead : Z si un mur est juste devant le personnage (a son etage, a moins de 10 unites)
wall_ahead:
        mov     R_WX,A
        call    @tcol                   ; A = case, R_Q3 = place dans la case (0-13)
        mov     A,R_Q4
        mov     R_Q3,A
        btjz    %$80,R_MIR,@wa_l
        mov     %13,A                   ; face a droite : distance au bord droit
        sub     R_Q3,A
wa_l:   cmp     %10,A
        jhs     @wa_n
        mov     %1,A
        call    @col_a
        mov     R_ETG,R_TE              ; (meme etage)
        call    @tile_at
        cmp     %T_WALL,A
        rets
wa_n:   mov     %1,A                    ; non Z
        rets

; --- fall_out : en chute, le corps est dans un mur : il passe dans la case voisine libre
;     (celle du cote le plus proche d'abord), a 4 unites de son bord. Z : repousse ;
;     non Z : pas de case libre a cote (il se pose, comme avant).
fall_out:
        mov     R_WX,A
        call    @tcol                   ; A = case du mur, R_Q3 = place dans la case (0-13)
        mov     A,R_GC
        cmp     %10,A
        jhs     @fo_n                   ; (hors de la salle : rien)
        cmp     %7,R_Q3
        jhs     @fo_r
        call    @fo_left                ; plus pres du bord gauche : a gauche d'abord
        jeq     @fo_x
        jmp     @fo_right
fo_r:   call    @fo_right
        jeq     @fo_x
        jmp     @fo_left
fo_x:   rets
fo_left:
        cmp     %0,R_GC
        jeq     @fo_n
        mov     R_GC,A
        dec     A
        mov     A,R_TC
        mov     R_ETG,R_TE
        call    @tile_at
        call    @is_hole
        jne     @fo_n
        mov     R_GC,B
        lda     @t_x14(B)               ; bord gauche du mur + 10
        sub     %15,A                   ; -> 5 avant ce bord
        jmp     @fo_mv
fo_right:
        cmp     %9,R_GC
        jhs     @fo_n
        mov     R_GC,A
        inc     A
        mov     A,R_TC
        mov     R_ETG,R_TE
        call    @tile_at
        call    @is_hole
        jne     @fo_n
        mov     R_GC,B
        inc     B
        lda     @t_x14(B)               ; bord gauche de la case de droite + 10
        sub     %6,A                    ; -> 4 apres ce bord
fo_mv:  mov     A,B                     ; A = le nouveau poids du corps : R_X suit du meme ecart
        sub     R_WX,A
        add     R_A,R_X
        mov     B,R_WX
        mov     R_Q4,A                  ; et la colonne de l'image
        add     R_X,A
        mov     A,B
        lda     @pr_col(B)
        mov     A,R_COL
        clr     A                       ; Z
        rets
fo_n:   mov     %1,A                    ; non Z
        rets

; --- wall_hole : Z si le personnage, arrete par un mur, doit tomber dans le trou qui le precede
wall_hole:
        mov     R_X,A                   ; un trou contre un mur : le mur arrete le personnage avant que son corps
        btjo    %$80,R_MIR,@nf_w1       ; soit au-dessus du vide. S'il y a un mur a moins de R_GC devant lui et que
        sub     R_GC,A                  ; la case d'avant ce mur est un vide, il s'avance contre le mur et tombe.
        jmp     @nf_w2                  ; (R_GC : 8 a chaque pas, 14 quand le mur vient de l'arreter)
nf_w1:  add     R_GC,A
nf_w2:  call    @tcol
        mov     A,R_Q4                  ; la case du mur
        mov     A,R_TC
        mov     R_ETG,R_TE
        call    @tile_at
        cmp     %T_WALL,A
        jne     @wh_no
        mov     R_Q4,R_TC
        btjo    %$80,R_MIR,@nf_w3
        inc     R_TC
        jmp     @nf_w4
nf_w3:  dec     R_TC
nf_w4:  mov     R_ETG,R_TE
        call    @tile_at
        call    @is_hole
        jne     @wh_no
        mov     %X_LEFT,A               ; le bord gauche de la case du mur
        mov     R_Q4,B
        cmp     %$FF,B
        jne     @nf_w6
        sub     %14,A
        jmp     @nf_w7
nf_w6:  cmp     %0,B
        jeq     @nf_w7
nf_w8:  add     %14,A
        djnz    B,@nf_w8
nf_w7:  btjo    %$80,R_MIR,@nf_w5
        add     %17,A                   ; face a gauche : 4 apres son bord droit
        mov     A,R_X
        add     %10,A
        mov     A,R_WX
        clr     B                       ; Z : il tombe
        rets
nf_w5:  sub     %4,A                    ; face a droite : 4 avant son bord gauche
        mov     A,R_X
        sub     %10,A
        mov     A,R_WX
        clr     B
        rets
wh_no:  mov     %1,B
        rets

; --- pot_take : la potion dont le type est en RD est bue : la case redevient un sol
;     (meme table que les sols fragiles), et les points de vie changent selon sa nature.
pot_take:
        lda     *RD
        rl      A
        rl      A
        rl      A
        and     %7,A
        mov     A,R_GC                  ; sa nature
        mov     A,B                     ; son bruitage (1 : potion, 2 : grande potion, 3 : poison)
        dec     B
        cmp     %3,B
        jhs     @pt_s                   ; (0 : l'epee, son bruitage est a part)
        lda     @sx_pth(B)
        push    A
        lda     @sx_ptl(B)
        mov     A,B
        pop     A
        call    @snd
pt_s:
        lda     @LS_AH                  ; (ls_rows prend sa cle dans LS_AH:LS_AL)
        push    A
        lda     @LS_AL
        push    A
        mov     RD-1,A
        sta     @LS_AH
        mov     RD,A
        sta     @LS_AL
        mov     %1,A
        call    @lv_poke
        call    @ls_rows
        pop     A
        sta     @LS_AL
        pop     A
        sta     @LS_AH
        cmp     %1,R_GC
        jne     @pt_2
        lda     @HP                     ; 1 : un point de vie de plus
        mov     A,B
        lda     @HPMAX
        cmp     R_B,A
        jeq     @pt_x
        inc     B
        mov     B,A
        sta     @HP
        jmp     @pt_x
pt_2:   cmp     %2,R_GC
        jne     @pt_3
        lda     @HPMAX                  ; 2 : un point de plus au maximum (8 au plus), et tous rendus
        cmp     %8,A
        jeq     @pt_2a
        inc     A
        sta     @HPMAX
pt_2a:  sta     @HP
        jmp     @pt_x
pt_3:   cmp     %3,R_GC
        jne     @pt_x
        lda     @HP                     ; 3 : poison, un point de moins
        dec     A
        sta     @HP
        jmp     @pt_x
sx_pth: .byte   sx_pot>>8,sx_life>>8,sx_poison>>8
sx_ptl: .byte   sx_pot&$FF,sx_life&$FF,sx_poison&$FF
pt_x:   ; (suite dans hp_draw)
; --- hp_draw : les points de vie, en bas a gauche : triangles pleins, puis vides -----
hp_draw:
        mov     %HP_ROW,A
        mov     %1,B
        call    @cell_addr
        movd    RV,TEMP1
        trap    8
        mov     %1,R_GE
hd_l:   movp    %HP_ATTR,P46
        lda     @HP
        cmp     R_GE,A
        jhs     @hd_f
        lda     @HPMAX
        cmp     R_GE,A
        jhs     @hd_e
        movp    %0,P46
        jmp     @hd_n
hd_f:   movp    %1,P46
        jmp     @hd_n
hd_e:   movp    %2,P46
hd_n:   inc     R_GE
        cmp     %9,R_GE
        jne     @hd_l
        br      @g_hp
t_hp:   .byte   $00,$00, $FF,$FF, $7E,$42, $7E,$42, $3C,$24, $3C,$24, $18,$18, $18,$18, $00,$00, $00,$00

; --- ls_break : le sol fragile (LS_AH:LS_AL) tombe -----------------------------------
;     Son type devient "vide" ; son image et celle de sa voisine de droite changent,
;     d'apres la table LV_FRAG preparee par niveau2exl.py. La page est redessinee.
ls_break:
        lda     @LS_AH
        mov     A,RD-1
        lda     @LS_AL
        mov     A,RD
        clr     A
        call    @lv_poke
ls_rows:
        movd    %LV_FRAG,RN
lb_l:   lda     *RN
        jeq     @lb_x
        mov     A,R_Q2                  ; la case cle
        call    @nx_n
        mov     A,R_Q3
        call    @nx_n                   ; l'octet a changer
        mov     A,RD-1
        call    @nx_n
        mov     A,RD
        call    @nx_n                   ; le nouveau bloc
        mov     A,R_TC
        add     %1,RN
        adc     %0,RN-1
        lda     @LS_AH
        cmp     R_Q2,A
        jne     @lb_l
        lda     @LS_AL
        cmp     R_Q3,A
        jne     @lb_l
        mov     R_TC,A
        call    @lv_poke
        jmp     @lb_l
lb_x:   call    @ls_nb
        mov     %1,R_RDW
        rets
; --- ls_nb : apres la chute de LS_AH:LS_AL, si sa voisine de gauche est un vide, elle prend
;     l'image LV_VV (pas le bout de dalle d'une voisine deja tombee) ; si sa voisine de droite
;     est un vide (une fragile deja tombee), elle aussi. Dans la meme salle seulement.
ls_nb:  lda     @LV_VF
        jeq     @nb_x
        lda     @LS_AL                  ; la case : (adresse - $8550) mod 64 - 30, puis sa colonne
        sub     %$50,A
        and     %$3F,A
        sub     %30,A
nb_m:   cmp     %10,A
        jl      @nb_c
        sub     %10,A
        jmp     @nb_m
nb_c:   mov     A,R_Q2
        jeq     @nb_r                   ; (colonne 0 : la voisine est dans une autre salle)
        call    @nb_ad
        sub     %1,RD
        sbb     %0,RD-1
        call    @nb_v
        jne     @nb_r
        call    @nb_ad                  ; la gauche est un vide : la case tombee prend LV_VV
        call    @nb_p
nb_r:   cmp     %9,R_Q2
        jeq     @nb_x
        call    @nb_ad
        add     %1,RD
        adc     %0,RD-1
        call    @nb_v
        jne     @nb_x
        call    @nb_p                   ; la droite est un vide : elle prend LV_VV
nb_x:   rets
nb_ad:  lda     @LS_AH                  ; RD = l'adresse du type de la case tombee
        mov     A,RD-1
        lda     @LS_AL
        mov     A,RD
        rets
nb_v:   lda     *RD                     ; Z : le type en RD est un vide
        and     %$1F,A
        rets
nb_p:   sub     %30,RD                  ; RD : un type -> son bloc ; il prend LV_VV (note au journal)
        sbb     %0,RD-1
        lda     @LV_VV
        call    @lv_poke
        rets
nx_n:   add     %1,RN
        adc     %0,RN-1
        lda     *RN
        rets

; --- lv_poke : ecrit A a l'adresse RD du niveau (Exelmemoire), en notant l'ancienne
;     valeur dans le journal ; lv_undo : remet tout, dans l'ordre inverse.
lv_poke:
        mov     A,R_Q
        lda     @UNDO_N
        cmp     %UNDO_MAX,A
        jhs     @lvp_w                  ; journal plein : on ecrit quand meme
        mov     A,B
        movd    %UNDO_E,RE
        add     R_B,RE
        adc     %0,RE-1
        add     R_B,RE
        adc     %0,RE-1
        add     R_B,RE
        adc     %0,RE-1
        mov     RD-1,A
        sta     *RE
        add     %1,RE
        adc     %0,RE-1
        mov     RD,A
        sta     *RE
        add     %1,RE
        adc     %0,RE-1
        lda     *RD
        sta     *RE
        inc     B
        mov     B,A
        sta     @UNDO_N
lvp_w:  mov     R_Q,A
        sta     *RD
        rets
lv_undo:
        lda     @UNDO_N
        jeq     @lu_x
        cmp     %UNDO_MAX+1,A
        jhs     @lu_z                   ; (valeur impossible : memoire non initialisee)
        mov     A,R_Q
lu_l:   dec     R_Q
        mov     R_Q,B
        movd    %UNDO_E,RE
        add     R_B,RE
        adc     %0,RE-1
        add     R_B,RE
        adc     %0,RE-1
        add     R_B,RE
        adc     %0,RE-1
        lda     *RE
        mov     A,RD-1
        add     %1,RE
        adc     %0,RE-1
        lda     *RE
        mov     A,RD
        add     %1,RE
        adc     %0,RE-1
        lda     *RE
        sta     *RD
        cmp     %0,R_Q
        jne     @lu_l
lu_z:   clr     A
        sta     @UNDO_N
lu_x:   rets

; --- flags_a : A = drapeaux du pas (demi-tour, changement d'etage) -----------------
flags_a:
        mov     A,R_FL
        btjz    %1,R_FL,@fa_1
        xor     %$80,R_MIR
fa_1:   btjz    %4,R_FL,@fa_2           ; un etage plus haut
        dec     R_ETG
        btjz    %$80,R_ETG,@fa_2
        mov     %62,B                   ; ... dans la salle du dessus
        call    @nb_room
        cmp     %0,A
        jeq     @fa_a
        call    @set_room
        mov     %2,R_ETG
        mov     %1,R_RDW
        jmp     @fa_2
fa_a:   clr     R_ETG
fa_2:   btjz    %8,R_FL,@fa_x           ; un etage plus bas
        inc     R_ETG
        cmp     %3,R_ETG
        jl      @fa_x
        mov     %63,B
        call    @nb_room
        cmp     %0,A
        jeq     @fa_b
        call    @set_room
        clr     R_ETG
        mov     %1,R_RDW
        rets
fa_b:   mov     %2,R_ETG
fa_x:   rets

; --- move_a : avance de A (signe) dans le sens du personnage -----------------------
; Le deplacement est refuse si la case devant est un mur (ou s'il n'y a pas de salle
; de ce cote). 
move_a: btjz    %$80,R_FL,@mv_0         ; pas prudent : l'avance est limitee
        btjo    %$80,A,@mv_0            ; (un recul reste libre)
        mov     A,R_Q3
        lda     @LIMC
        cmp     R_Q3,A
        jhs     @mv_l
        mov     A,R_Q3                  ; on n'avance que de ce qui reste
mv_l:   sub     R_Q3,A
        sta     @LIMC
        mov     R_Q3,A
mv_0:   btjo    %$80,R_MIR,@mv_r
        inv     A
        inc     A
mv_r:   cmp     %0,A
        jeq     @mv_x
        mov     A,R_Q3                  ; deplacement, signe
        add     R_X,A
        mov     A,R_NX
        btjo    %$20,R_FL,@mv_f         ; (en grimpant, on passe devant le mur)
        btjo    %$80,R_Q3,@mv_n
        add     %X_FRONT,A              ; le point teste : devant, dans le sens du deplacement
        jmp     @mv_t
mv_n:   sub     %X_FRONT,A
mv_t:   mov     A,R_GD                  ; le point teste, puis ceux d'avant de 4 en 4 jusqu'au depart :
        mov     R_Q3,R_GC               ; les barreaux d'une grille ne font que 4 unites
        mov     R_Q3,A
        btjz    %$80,A,@mv_a
        inv     A
        inc     A
mv_a:   mov     A,R_GE
mv_t1:  mov     R_GD,A
        call    @tcol
        mov     A,R_TC
        mov     R_ETG,R_TE
        call    @tile_at
        cmp     %T_WALL,A
        jeq     @mv_wb
        cmp     %T_GATE,A
        jne     @mv_g
        lda     *RD
        cmp     %$80,A
        jhs     @mv_g                   ; ouverte aux 4/5 : on passe
        cmp     %10,R_Q3
        jhs     @mv_blk                 ; les barreaux : les 4 dernieres unites de la case
mv_g:   cmp     %5,R_GE
        jl      @mv_f
        sub     %4,R_GE
        btjo    %$80,R_GC,@mv_g1
        sub     %4,R_GD
        jmp     @mv_t1
mv_g1:  add     %4,R_GD
        jmp     @mv_t1
mv_f:   mov     R_NX,R_X                ; libre : on avance
mv_x:   rets
mv_blk: mov     %1,R_BUMP
        rets
mv_wb:  mov     %1,R_BUMP               ; un mur : on avance jusqu'a lui (le bord avant a X_FRONT), comme le
        cmp     %X_LEFT,R_GD            ; jeu, au lieu de s'arreter la ou le pas aurait mene trop loin
        jl      @mv_x                   ; (R_Q3 : la place du point teste dans sa case ; pas a gauche de la salle)
        mov     R_GD,A
        sub     R_Q3,A                  ; le bord gauche de la case du mur
        btjo    %$80,R_GC,@mv_wl
        sub     %X_FRONT+1,A            ; vers la droite : R_X = ce bord - X_FRONT - 1, si c'est plus loin
        cmp     R_X,A
        jl      @mv_x
        jeq     @mv_x
        mov     A,R_X
        rets
mv_wl:  add     %13+X_FRONT+1,A         ; vers la gauche : R_X = bord droit + X_FRONT + 1, si c'est plus loin
        cmp     R_X,A
        jhs     @mv_x
        mov     A,R_X
        rets

; --- under : A = type de la case sous les pieds ; is_hole : Z si A est un vide ------
under_r:                                ; ... la meme, FALL_T derriere le corps
        mov     R_WX,A
        btjo    %$80,R_MIR,@un_r
        add     %FALL_T,A
        jmp     @un_1
un_r:   sub     %FALL_T,A
        jmp     @un_1
under:  mov     R_WX,A
un_1:
        call    @tcol
        mov     A,R_TC
        mov     R_ETG,R_TE
        ; (suite dans tile_at)
; --- tile_at : R_TC = case (-1 a 10), R_TE = etage (-1 a 3) -> A = type de la case.
;     Passe dans les salles voisines ; pas de salle : c'est un mur.
tile_at:
        movd    RROOM,RD
        btjz    %$80,R_TE,@ta_1
        mov     %62,B                   ; etage -1 : la salle du dessus, son etage 2
        call    @nb_from
        jeq     @ta_w
        mov     %2,R_TE
        jmp     @ta_2
ta_1:   cmp     %3,R_TE
        jl      @ta_2
        mov     %63,B                   ; etage 3 : la salle du dessous, son etage 0
        call    @nb_from
        jeq     @ta_w
        clr     R_TE
ta_2:   btjz    %$80,R_TC,@ta_3
        mov     %60,B
        call    @nb_from
        jeq     @ta_w
        mov     %9,R_TC
        jmp     @ta_4
ta_3:   cmp     %10,R_TC
        jl      @ta_4
        mov     %61,B
        call    @nb_from
        jeq     @ta_w
        clr     R_TC
ta_4:   mov     R_TE,B
        lda     @t_e10(B)
        add     R_TC,A
        add     %30,A
        add     R_A,RD
        adc     %0,RD-1
        lda     *RD
        and     %$1F,A
        rets
ta_w:   mov     %T_WALL,A
        rets

is_hole:
        cmp     %0,A                    ; vide
        jeq     @ih_x
        cmp     %9,A                    ; haut de gros pilier
        jeq     @ih_x
        cmp     %12,A                   ; linteau
ih_x:   rets

; --- tcol : A = abscisse -> A = case (0-9 ; $FF a gauche ; 10 et plus a droite), R_Q3 = reste (0-13)
tcol:   cmp     %X_LEFT,A
        jhs     @tc_p
        mov     %$FF,A
        rets
tc_p:   sub     %X_LEFT,A
        clr     B
tc_l:   cmp     %14,A
        jl      @tc_x
        sub     %14,A
        inc     B
        jmp     @tc_l
tc_x:   mov     A,R_Q3
        mov     B,A
        rets

; --- nb_room : B = 60 gauche, 61 droite, 62 haut, 63 bas -> A = salle voisine (0 = aucune), RD = cette salle
nb_room:
        movd    RROOM,RD
nb_from:                                ; ... la meme, a partir de la salle RD ; Z si aucune
        movd    RD,RE
        add     R_B,RE
        adc     %0,RE-1
        lda     *RE
        jeq     @nr_x
        mov     A,B
        lda     @dc_roomh(B)
        mov     A,RD-1
        lda     @dc_rooml(B)
        mov     A,RD
        mov     B,A
nr_x:   rets

; --- set_room : A = salle -> R_ROOM, RROOM ----------------------------------------
set_room:
        mov     A,R_ROOM
        mov     A,B
        lda     @dc_roomh(B)
        mov     A,RROOM-1
        lda     @dc_rooml(B)
        mov     A,RROOM
        br      @g_load                 ; (et son garde)

; --- draw_room : la page entiere, 25 lignes ---------------------------------------
draw_room:
        movd    %SCREEN_BASE,RV         ; (case par case du bloc : une rangee de 4 caracteres trouvee une seule
        movd    RV,TEMP1                ; fois pour les 4, au lieu de map_at pour chaque caractere : 4 fois plus
        trap    8                       ; vite, le changement de salle ne fige plus le jeu)
        clr     R_T                     ; ligne
dr_ln:  mov     R_T,A
        sub     %ROOM_TOP,A
        cmp     %18,A
        jl      @dr_in
        cmp     %$FF,A                  ; la ligne juste au-dessus : le plafond
        jne     @dr_o
        br      @dr_cl
dr_o:   mov     %40,R_U                 ; hors de la salle : 40 cases vides
        mov     %$E8,A
        call    @attr_f
dr_e:   movp    A,P46
        movp    %0,P46
        djnz    R_U,@dr_e
        jmp     @dr_eol
dr_in:  mov     A,B
        lda     @t_s10(B)
        mov     A,R_Q                   ; etage x 10
        lda     @t_r4(B)
        clrc
        rrc     A
        clrc
        rrc     A
        mov     A,R_Q2                  ; ligne dans le bloc (0-5)
        clr     R_U                     ; case (0-9)
dr_t:   mov     R_U,A
        add     R_Q,A
        movd    RROOM,RD
        add     R_A,RD
        adc     %0,RD-1
        lda     *RD                     ; le numero du bloc
        mov     A,R_G2
        lda     @LV_WB                  ; murs generes : une case mur ne lit pas son bloc
        jeq     @dr_b
        add     %30,RD
        adc     %0,RD-1
        lda     *RD
        and     %$1F,A
        cmp     %T_WALL,A
        jne     @dr_b
        br      @dr_w
dr_b:   mov     R_G2,A
        call    @row_ad                 ; RD = sa rangee de 4 caracteres
        mov     %4,R_Q3
dr_c:   lda     *RD
        mov     A,R_G2
        mov     A,B
        call    @attr_b
        call    @attr_f
        movp    A,P46
        mov     R_G2,A
        jeq     @dr_z
        and     %$7F,A
dr_z:   movp    A,P46
        add     %1,RD
        adc     %0,RD-1
        djnz    R_Q3,@dr_c
dr_nx:  inc     R_U
        cmp     %10,R_U
        jne     @dr_t
dr_eol: movp    %MIXT_NEXT_TEXT|MBLACK,P46  ; controle : la ligne suivante est du texte
        movp    %0,P46
        inc     R_T
        cmp     %25,R_T
        jeq     @dr_ld
        br      @dr_ln
dr_ld:  br      @hp_draw                ; (toute la page vient d'etre ecrite : les points de vie avec)
dr_w:   mov     R_U,A                   ; une case mur generee : ses 4 caracteres par wall_ch
        add     R_Q,A
        sta     @WC_TI
        mov     R_Q2,A
        clrc
        rlc     A
        clrc
        rlc     A
        sta     @WC_RC
        mov     %4,R_Q3
dw_c:   call    @wall_ch
        mov     A,R_G2
        mov     A,B
        call    @attr_b
        call    @attr_f
        movp    A,P46
        mov     R_G2,A
        and     %$7F,A
        movp    A,P46
        lda     @WC_RC
        inc     A
        sta     @WC_RC
        djnz    R_Q3,@dw_c
        br      @dr_nx
dr_cl:  clr     R_U                     ; le plafond, comme dans le jeu : la derniere rangee (la dalle)
dc_t:   mov     R_U,A                   ; des blocs de l'etage 2 de la salle du dessus (ceil_ch)
        call    @ceil_ch
        mov     A,R_G2
        mov     A,B
        call    @attr_b
        call    @attr_f
        movp    A,P46
        mov     R_G2,A
        jeq     @dc_z
        and     %$7F,A
dc_z:   movp    A,P46
        inc     R_U
        cmp     %40,R_U
        jne     @dc_t
        br      @dr_eol

t_e10:  .byte   0,10,20                 ; etage -> premiere case de l'etage
t_erm:  .byte   ROOM_TOP                ; (tremblement du plafond : sa ligne, ROOM_TOP - 1, et celle d'en dessous)
t_erow: .byte   ROOM_TOP+5,ROOM_TOP+11,ROOM_TOP+17  ; etage -> ligne d'ecran de la dalle (6e ligne du bloc)
t_eoff: .byte   -6,0,6                  ; etage -> decalage en lignes (les poses sont donnees pour l'etage 1)
t_ctop: .byte   ROOM_TOP,ROOM_TOP+6,ROOM_TOP+12 ; etage -> sa 1re ligne de caracteres
t_s10:  .byte   0,0,0,0,0,0,10,10,10,10,10,10,20,20,20,20,20,20    ; ligne dans la salle -> etage x 10
t_r4:   .byte   0,4,8,12,16,20,0,4,8,12,16,20,0,4,8,12,16,20       ; -> (ligne dans le bloc) x 4

next_r: add     %1,RR                   ; octet suivant des regles
        adc     %0,RR-1
        lda     *RR
        rets
next_s: add     %1,RS                   ; octet suivant du pas
        adc     %0,RS-1
        lda     *RS
        rets
next_p: add     %1,RP                   ; octet suivant de la pose
        adc     %0,RP-1
        lda     *RP
        rets

; --- up_gen : 10 lignes de 128 octets de RD vers le generateur RV -----------------
up_gen: mov     %10,RL
ug_l:   movd    RV,TEMP1
        trap    8
        mov     %128,RC
ug_b:   lda     *RD
        movp    A,P46
        add     %1,RD
        adc     %0,RD-1
        djnz    RC,@ug_b
        add     %128,RV
        adc     %0,RV-1
        add     %DC_W-128,RD            ; (0 ou 128 : la part de l'autre generateur)
        adc     %0,RD-1
        djnz    RL,@ug_l
        rets

; --- map_at : A = ligne, B = colonne (0-39) -> A = caractere du decor (0 = rien),
;     R_TY = type de la case du jeu a cet endroit (0 hors de la salle)
;     La salle est faite de 30 blocs de 4 x 6 caracteres, a partir de la ligne ROOM_TOP.
map_at: sub     %ROOM_TOP,A
        cmp     %18,A
        jl      @ma_1
        cmp     %$FF,A                  ; la ligne du plafond
        jeq     @ma_up
        br      @ma_0                   ; au-dessus ou au-dessous de la salle
ma_up:  mov     B,A                     ; la dalle (6e rangee) du bloc de l'etage 2 de la salle du dessus
        call    @ceil_ch
        clr     R_TY                    ; (le personnage passe devant)
        tsta
        rets
ma_1:
        mov     B,R_G
        mov     A,B
        lda     @t_s10(B)
        mov     A,R_Q
        lda     @t_r4(B)
        mov     A,R_Q2
        mov     R_G,A
        and     %3,A
        add     R_A,R_Q2                ; place dans le bloc : ligne x 4 + colonne
        mov     R_G,A
        clrc
        rrc     A
        clrc
        rrc     A                       ; colonne / 4 : la case
        add     R_Q,A
        sta     @WC_TI                  ; (pour wall_ch)
        movd    RROOM,RD
        add     R_A,RD
        adc     %0,RD-1
        lda     *RD                     ; le numero du bloc
        mov     A,R_G
        add     %30,RD                  ; et le type de la case, 30 octets plus loin
        adc     %0,RD-1
        lda     *RD
        and     %$1F,A
        mov     A,R_TY
        cmp     %T_WALL,A               ; un mur genere : son caractere par wall_ch
        jne     @ma_k
        lda     @LV_WB
        jeq     @ma_k
        mov     R_Q2,A
        sta     @WC_RC
        br      @wall_ch
ma_k:   clr     RD-1                    ; le bloc : BLK0 + 7 x son numero (6 rangees + leurs 9es bits)
        mov     R_G,RD
        add     RD,RD
        adc     RD-1,RD-1
        add     RD,RD
        adc     RD-1,RD-1
        add     RD,RD
        adc     RD-1,RD-1
        sub     R_G,RD
        sbb     %0,RD-1
        add     %BLK0&$FF,RD
        adc     %BLK0>>8,RD-1
        mov     R_Q2,A                  ; sa rangee : ligne dans le bloc (R_Q2 = ligne x 4 + colonne)
        clrc
        rrc     A
        clrc
        rrc     A
        mov     A,R_Q
        add     %6,RD                   ; l'octet des 9es bits
        adc     %0,RD-1
        lda     *RD
        mov     A,R_G
        sub     %6,RD
        sbb     %0,RD-1
        mov     R_Q,A
        add     R_A,RD
        adc     %0,RD-1
        lda     *RD                     ; le numero de la rangee (8 bits du bas)
        mov     R_Q,B
ma_b:   cmp     %0,B                    ; son 9e bit : le bit (ligne) de R_G
        jeq     @ma_c
        clrc
        rrc     R_G
        dec     B
        jmp     @ma_b
ma_c:   mov     A,RD                    ; -> LV_ROWS + 4 x numero + colonne
        clr     RD-1
        btjz    %1,R_G,@ma_d
        inc     RD-1
ma_d:   add     RD,RD
        adc     RD-1,RD-1
        add     RD,RD
        adc     RD-1,RD-1
        lda     @LV_ROWS                ; (LDA efface la retenue : l'octet fort d'abord, dans B)
        mov     A,B
        lda     @LV_ROWS+1
        add     R_A,RD
        adc     R_B,RD-1
        mov     R_Q2,A
        and     %3,A
        add     R_A,RD
        adc     %0,RD-1
        lda     *RD
        rets
ma_0:   clr     R_TY
        clr     A
        rets


; --- wall_ch : murs generes (niveau2exl.py : ligne "murs") : le caractere d'une place d'une case mur,
;     comme wall_pattern dans le jeu : une graine par salle et par case. Chaque rangee de briques (2
;     lignes) a un joint dans l'une de ses 4 colonnes ; ailleurs, une brique pleine parmi 8 (4 joints).
;     WC_TI = case (etage x 10 + case), WC_RC = ligne x 4 + colonne dans le bloc -> A = code
wall_ch:
        lda     @WC_TI
        mov     A,B
        lda     @wc_t13(B)
        sta     @WC_X
        mov     R_ROOM,B
        lda     @wc_t29(B)
        mov     A,B
        lda     @WC_X
        add     B,A
        sta     @WC_X
        lda     @LV_WS                  ; + la graine du niveau
        mov     A,B
        lda     @WC_X
        add     B,A
        sta     @WC_X
        lda     @WC_RC
        mov     A,B
        lda     @wc_k71(B)              ; + la rangee de briques
        mov     A,B
        lda     @WC_X
        add     B,A
        mov     A,B
        lda     @wc_rnd(B)              ; x : le tirage de cette rangee de cette case
        sta     @WC_X
        and     %3,A                    ; la colonne du joint
        mov     A,B
        lda     @WC_RC
        and     %3,A
        cmp     B,A
        jne     @wc_p
        lda     @WC_X                   ; le joint : variante (x / 32) x 2 + haut/bas
        mov     A,B
        lda     @hi_tab(B)
        and     %$0E,A
        push    A
        lda     @WC_RC
        mov     A,B
        lda     @wc_pt(B)
        pop     B
        add     B,A
        jmp     @wc_c
wc_p:   lda     @WC_RC                  ; une brique pleine : l'une des 16 variantes
        mov     A,B
        lda     @wc_h2(B)
        mov     A,B
        lda     @WC_X
        add     B,A
        mov     A,B
        lda     @wc_rnd(B)
        and     %15,A
        push    A
        lda     @WC_RC
        mov     A,B
        lda     @wc_pb(B)
        pop     B
        add     B,A
wc_c:   or      %$C0,A                  ; la tuile : BAGC1 ($80), code 64 + n
        rets

wc_t29: ; salle x 29
        .byte   0,29,58,87,116,145,174,203,232,5,34,63,92,121,150,179
        .byte   208,237,10,39,68,97,126,155,184
wc_t13: ; case (etage x 10 + case) x 13
        .byte   0,13,26,39,52,65,78,91,104,117,130,143,156,169,182,195
        .byte   208,221,234,247,4,17,30,43,56,69,82,95,108,121
wc_k71: ; par place (ligne x 4 + colonne) : rangee de briques x 71
        .byte   0,0,0,0,0,0,0,0,71,71,71,71,71,71,71,71
        .byte   142,142,142,142,142,142,142,142
wc_pt:  ; ... haut (0) ou bas (1) de la brique
        .byte   0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1
        .byte   0,0,0,0,1,1,1,1
wc_pb:  ; ... premier caractere de brique pleine : 16 (haut) ou 32 (bas)
        .byte   16,16,16,16,32,32,32,32,16,16,16,16,32,32,32,32
        .byte   16,16,16,16,32,32,32,32
wc_h2:  ; ... melange pour la variante de brique pleine
        .byte   0,53,106,159,97,150,203,0,0,53,106,159,97,150,203,0
        .byte   0,53,106,159,97,150,203,0
wc_rnd: ; 256 octets pseudo-aleatoires (les memes que niveau2exl.py et l'atelier)
        .byte   41,139,100,201,24,130,221,7,111,151,141,200,219,228,191,73
        .byte   71,199,0,5,223,219,26,184,15,252,27,94,131,71,79,52
        .byte   40,22,64,180,41,7,188,157,243,246,206,232,48,253,194,211
        .byte   206,122,36,216,248,8,193,181,26,131,164,102,225,7,25,37
        .byte   56,241,172,112,75,220,42,2,134,164,158,216,150,102,84,44
        .byte   101,125,217,124,33,133,247,131,54,90,188,62,78,24,115,231
        .byte   87,28,169,252,124,1,40,56,41,163,254,152,11,31,118,86
        .byte   13,208,29,240,91,82,190,33,97,129,101,230,204,121,94,121
        .byte   134,151,53,88,189,118,183,62,221,242,239,40,144,40,41,80
        .byte   196,114,241,52,164,110,20,143,156,248,157,93,89,42,216,219
        .byte   198,98,81,132,15,59,213,20,160,145,111,135,38,129,107,26
        .byte   139,101,86,72,253,219,250,205,232,191,101,165,246,43,226,13
        .byte   21,125,254,128,112,80,132,186,115,128,127,183,203,41,62,180
        .byte   99,168,74,44,103,152,113,219,67,213,190,189,164,124,125,15
        .byte   116,232,58,76,226,181,194,48,87,191,32,183,128,34,160,30
        .byte   74,59,206,224,224,165,119,185,175,60,166,165,97,29,167,225

; --- hi_tab : le quartet fort de chaque octet (decodage des poses) -----------------
hi_tab: .byte   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte   1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
        .byte   2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
        .byte   3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
        .byte   4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
        .byte   5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
        .byte   6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6
        .byte   7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7
        .byte   8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
        .byte   9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9
        .byte   10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10
        .byte   11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11
        .byte   12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12
        .byte   13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13
        .byte   14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14
        .byte   15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15

; --- gnib : quartet suivant du flux de la pose (RP) -> A (0-15), Z si 0 ------------
gnib:   cmp     %0,R_T
        jeq     @gn_1
        clr     R_T
        mov     R_Q,A
        and     %$0F,A
        rets
gn_1:   lda     *RP
        mov     A,R_Q
        add     %1,RP
        adc     %0,RP-1
        mov     %1,R_T
        mov     A,B
        lda     @hi_tab(B)
        rets

; --- pil_fore : apres map_at, Z si cette case de l'ecran est le devant d'un pilier (pilier, gros
;     pilier) : comme dans le jeu (fore_id de tile_table, a 8 points du bord gauche), le personnage
;     passe derriere. Le pilier : colonnes 1 a 3 du bloc (fut, face de cote et sa dalle), sur toute
;     la hauteur ; la colonne 0 (le bord de la dalle, ou il s'agrippe) reste devant. A est garde.
pil_fore:
        push    A
        mov     R_TY,A
        cmp     %3,A
        jeq     @pf_1
        cmp     %8,A
        jeq     @pf_1
        cmp     %9,A
        jne     @pf_n
pf_1:   mov     R_Q2,A                  ; place dans le bloc : ligne x 4 + colonne
        and     %3,A
        jeq     @pf_n                   ; (colonne 0)
        pop     A
        mov     %0,B                    ; Z
        rets
pf_n:   pop     A
        mov     %1,B                    ; non Z
        rets

; --- ceil_ch : A = colonne de l'ecran (0-39) -> A = la tuile du plafond (0 : rien) : la 6e rangee
;     (la dalle) du bloc de cette case a l'etage 2 de la salle du dessus ; une case mur generee y
;     prend son caractere de wall_ch (calcule pour la salle du dessus). Ne touche pas R_U, R_Q3.
ceil_ch:
        sta     @CL_C
        movd    RROOM,RD
        add     %62,RD
        adc     %0,RD-1
        lda     *RD                     ; la salle du dessus
        jne     @cc_0
        rets                            ; (aucune : A = 0)
cc_0:   sta     @CL_R
        lda     @CL_C
        clrc
        rrc     A
        clrc
        rrc     A                       ; la case
        call    @ceil_blk               ; A = son bloc ; RD : sur ce bloc dans la salle du dessus
        push    A
        add     %30,RD                  ; son type
        adc     %0,RD-1
        lda     *RD
        and     %$1F,A
        mov     A,B
        lda     @LV_PLF                 ; plafond mince : d'apres le TYPE de la case du dessus (un vide :
        jeq     @cc_t                   ; rien ; sinon la tuile de sa colonne), pas son image (une case
        pop     A                       ; tombee garde le bout de la dalle de sa voisine)
        mov     B,A
        call    @is_hole
        jeq     @cc_z
        lda     @CL_C
        and     %3,A
        mov     A,B
        lda     @LV_PLR(B)
        rets
cc_t:   mov     B,A
        cmp     %T_WALL,A
        jne     @cc_b
        lda     @LV_WB
        jeq     @cc_b
        pop     A
        lda     @CL_C                   ; un mur genere : sa place (ligne 5 x 4 + colonne) et sa case
        and     %3,A
        add     %20,A
        sta     @WC_RC
        lda     @CL_C
        clrc
        rrc     A
        clrc
        rrc     A
        add     %20,A
        sta     @WC_TI
        mov     R_ROOM,A                ; wall_ch tire d'apres la salle : celle du dessus
        push    A
        lda     @CL_R
        mov     A,R_ROOM
        call    @wall_ch
        sta     @CL_R
        pop     A
        mov     A,R_ROOM
        lda     @CL_R
        jmp     @cc_s
cc_b:   pop     A
        tsta
        jeq     @cc_z
        mov     %5,R_Q2
        call    @row_ad
        lda     @CL_C
        and     %3,A
        add     R_A,RD
        adc     %0,RD-1
        lda     *RD
cc_s:   tsta                            ; une case non vide : avec une ligne "plafond", la tuile de sa
        jeq     @cc_r                   ; colonne dans la rangee du bloc du plafond (un plafond mince)
        mov     A,B
        lda     @LV_PLF
        jeq     @cc_o
        lda     @CL_C
        and     %3,A
        mov     A,B
        lda     @LV_PLR(B)
        rets
cc_o:   mov     B,A
cc_r:   rets
cc_z:   clr     A
        rets

; --- ceil_blk : A = case (0-9) -> A = bloc de cette case a l'etage 2 de la salle du dessus
;     (Z : pas de salle au-dessus, ou bloc vide). N'utilise que A, B et RD.
ceil_blk:
        push    A
        movd    RROOM,RD
        add     %62,RD
        adc     %0,RD-1
        lda     *RD                     ; la salle du dessus
        jeq     @cb_n
        mov     A,B
        lda     @dc_roomh(B)
        mov     A,RD-1
        lda     @dc_rooml(B)
        mov     A,RD
        pop     A
        add     %20,A                   ; son etage 2
        add     R_A,RD
        adc     %0,RD-1
        lda     *RD
        rets
cb_n:   pop     A
        clr     A
        rets

; --- row_ad : A = numero de bloc, R_Q2 = ligne dans le bloc (0-5) -> RD = sa rangee de
;     4 caracteres (le meme chemin que map_at)
row_ad: mov     A,R_G
        clr     RD-1                    ; BLK0 + 7 x numero
        mov     R_G,RD
        add     RD,RD
        adc     RD-1,RD-1
        add     RD,RD
        adc     RD-1,RD-1
        add     RD,RD
        adc     RD-1,RD-1
        sub     R_G,RD
        sbb     %0,RD-1
        add     %BLK0&$FF,RD
        adc     %BLK0>>8,RD-1
        add     %6,RD                   ; l'octet des 9es bits
        adc     %0,RD-1
        lda     *RD
        mov     A,R_G
        sub     %6,RD
        sbb     %0,RD-1
        mov     R_Q2,A
        add     R_A,RD
        adc     %0,RD-1
        lda     *RD                     ; le numero de la rangee (8 bits du bas)
        mov     R_Q2,B
ra_b:   cmp     %0,B
        jeq     @ra_c
        clrc
        rrc     R_G
        dec     B
        jmp     @ra_b
ra_c:   mov     A,RD
        clr     RD-1
        btjz    %1,R_G,@ra_d
        inc     RD-1
ra_d:   add     RD,RD
        adc     RD-1,RD-1
        add     RD,RD
        adc     RD-1,RD-1
        lda     @LV_ROWS                ; (LDA efface la retenue : l'octet fort d'abord, dans B)
        mov     A,B
        lda     @LV_ROWS+1
        add     R_A,RD
        adc     R_B,RD-1
        rets

; --- scan_dk : DK(n-1) = tuile du decor sous la n-ieme case pleine (0 hors ecran)
scan_dk:
        movd    RM,RN
        mov     R_H,RL
        mov     R_ROW,R_U
sd_l:   mov     R_COL,R_CC
        mov     R_W,RC
        btjz    %$80,R_MIR,@sd_c
        add     R_W,RM
        adc     %0,RM-1
sd_c:   btjz    %$80,R_MIR,@sd_d
        sub     %1,RM
        sbb     %0,RM-1
sd_d:   lda     *RM
        jeq     @sd_s                   ; case vide
        mov     A,R_G2
        clr     A
        cmp     %40,R_CC
        jhs     @sd_w
        mov     R_U,A
        mov     R_CC,B
        call    @map_at
sd_w:   mov     R_G2,B
        sta     @DK-1(B)
sd_s:   inc     R_CC
        btjo    %$80,R_MIR,@sd_f
        add     %1,RM
        adc     %0,RM-1
sd_f:   djnz    RC,@sd_c
        btjz    %$80,R_MIR,@sd_g
        add     R_W,RM
        adc     %0,RM-1
sd_g:   inc     R_U
        djnz    RL,@sd_l
        movd    RN,RM
        rets

; --- put_pose : RP = motifs ; 10 lignes de R_K octets dans le jeu R_SET ---------
;     Sur un caractere du decor : le decor est eteint sous le personnage et sur un
;     point tout autour de lui (dans la case), pour qu'il reste lisible devant un mur.
put_pose:
        cmp     %0,R_K
        jne     @pd_0
        rets
pd_0:   movd    %PBUF,RF                ; 1. decodage : case par case, 10 lignes chacune. Le flux se
        clr     R_G                     ;    lit par quartets (fort d'abord) : 0 n = n+1 octets nuls ;
        clr     R_T                     ;    1 a 14 = l'octet pr_ntab ; 15 h l = l'octet hl
        mov     R_K,RL                  ;    (R_G : nuls en attente ; R_T <> 0 : quartet faible de R_Q en attente)
pd_c:   mov     %10,RC
pd_b:   cmp     %0,R_G
        jne     @pd_y
        cmp     %0,R_T                  ; le quartet suivant (en ligne : c'est le cas courant)
        jne     @pd_f
        lda     *RP                     ; octet neuf : son quartet fort
        mov     A,R_Q
        add     %1,RP
        adc     %0,RP-1
        mov     %1,R_T
        mov     A,B
        lda     @hi_tab(B)              ; (son quartet fort, par table)
        jmp     @pd_q
pd_f:   clr     R_T                     ; le quartet faible en attente
        mov     R_Q,A
        and     %$0F,A
pd_q:   jeq     @pd_z
        cmp     %15,A
        jeq     @pd_l
        mov     A,B
        lda     @pr_ntab-1(B)
        jmp     @pd_s
pd_y:   dec     R_G
        clr     A
        jmp     @pd_s
pd_z:   call    @gnib                   ; une suite de nuls : celui-ci et n autres
        mov     A,R_G
        clr     A
        jmp     @pd_s
pd_l:   call    @gnib                   ; un octet en clair
        rl      A                       ; (quartet fort : 4 rotations, sans SWAP)
        rl      A
        rl      A
        rl      A
        push    A
        call    @gnib
        pop     B
        or      B,A
pd_s:   sta     *RF
        add     %1,RF
        adc     %0,RF-1
        djnz    RC,@pd_b
        djnz    RL,@pd_c

        movd    %FONT_BAGC3,RV          ; 2. ecriture, ligne par ligne du generateur (BAGC3 ; le garde :
        lda     @P_ATTR                 ;    BAGC1)
        cmp     %GB_ATTR,A
        jne     @pp_g
        movd    %FONT_B,RV
pp_g:   add     R_SET,RV
        adc     %0,RV-1
        movd    %dc_font,RD             ; RD + n : le caractere n du decor, ligne courante
        lda     @LV_WF                  ; WL + tuile : celui d'une brique ($C0 + n)
        mov     A,B                     ; (lda et sta effacent la retenue : le fort dans B)
        lda     @LV_WF+1
        sub     %$C0,A
        sbb     %0,B
        sta     @WL_L
        mov     B,A
        sta     @WL_H
        clr     R_Q4                    ; ligne
pp_l:   movd    RV,TEMP1
        trap    8
        movd    %PBUF,RF
        add     R_Q4,RF
        adc     %0,RF-1
        clr     R_G2                    ; numero de la case pleine
pp_b:   lda     *RF
        btjz    %$80,R_MIR,@pp_n
        mov     A,B                     ; miroir : les 8 points de l'octet a l'envers
        lda     @rev_tab(B)
pp_n:   mov     A,R_T
        mov     R_G2,B
        lda     @DK(B)
        jeq     @pp_w                   ; pas de decor dessous
        btjo    %$80,A,@pp_k
        movd    RD,RE
        add     R_A,RE
        adc     %0,RE-1
pp_e:   lda     *RE
        mov     A,R_G                   ; le decor
        lda     *RF                     ; le detourage : le motif et ses lignes voisines dans la case...
        mov     A,R_Q
        cmp     %0,R_Q4
        jeq     @pp_u                   ; (ligne du bas : rien dessous)
        sub     %1,RF
        sbb     %0,RF-1
        lda     *RF
        or      R_A,R_Q
        add     %1,RF
        adc     %0,RF-1
pp_u:   cmp     %9,R_Q4
        jeq     @pp_v                   ; (ligne du haut : rien dessus)
        add     %1,RF
        adc     %0,RF-1
        lda     *RF
        or      R_A,R_Q
        sub     %1,RF
        sbb     %0,RF-1
pp_v:   mov     R_Q,B
        btjz    %$80,R_MIR,@pp_m
        lda     @rev_tab(B)
        mov     A,B
pp_m:   lda     @nd_tab(B)              ; ... elargis d'un point de chaque cote, eteignent le decor
        and     R_G,A
        or      R_T,A
        jmp     @pp_o
pp_k:   mov     A,B                     ; une brique : WL + tuile
        lda     @WL_L
        mov     A,RE
        lda     @WL_H
        mov     A,RE-1
        add     R_B,RE
        adc     %0,RE-1
        jmp     @pp_e
pp_w:   mov     R_T,A
pp_o:   movp    A,P46
        add     %10,RF
        adc     %0,RF-1
        inc     R_G2
        cmp     R_K,R_G2
        jeq     @pp_y
        br      @pp_b
pp_y:
        add     %128,RV
        adc     %0,RV-1
        add     %DC_W&$FF,RD
        adc     %DC_W>>8,RD-1
        lda     @WL_H
        mov     A,B
        lda     @WL_L
        add     %48,A
        adc     %0,B
        sta     @WL_L
        mov     B,A
        sta     @WL_H
        inc     R_Q4
        cmp     %10,R_Q4
        jeq     @pp_x
        br      @pp_l
pp_x:   rets

; --- attr_b : B = caractere du decor -> A = son attribut (sa couleur de LV_COL, sinon blanc ; BAGC2 ou BAGC1)
attr_b: mov     B,A                     ; un caractere de LV_COL : son attribut (sa couleur)
        sta     @AB_C
        push    B
        clr     A
ab_l:   sta     @AB_I
        mov     A,B
        lda     @LV_COL(B)
        jeq     @ab_n
        mov     A,B
        lda     @AB_C
        cmp     B,A
        jeq     @ab_y
        lda     @AB_I
        add     %2,A
        jmp     @ab_l
ab_y:   lda     @AB_I
        inc     A
        mov     A,B
        lda     @LV_COL(B)
        pop     B
        rets
ab_n:   pop     B                       ; sinon blanc (BAGC2 ; BAGC1 pour les codes de $80 et plus)
        mov     %$E8,A
        btjz    %$80,B,@ab_x
        mov     %$F0,A
ab_x:   rets

; --- cell_addr : RV = adresse de la case (ligne A, colonne B) ------------------
cell_addr:
        movd    %SCREEN_BASE,RV
        tsta
        jeq     @ca_c
ca_r:   add     %LINE_LEN,RV
        adc     %0,RV-1
        djnz    A,@ca_r
ca_c:   add     R_B,RV
        adc     %0,RV-1
        add     R_B,RV
        adc     %0,RV-1
        rets

; --- put_window : la fenetre en (R_ROW, R_COL), d'apres le plan RM --------------
;     plan : 0 = case vide (code 0), n = n-ieme case pleine (code R_SET + n - 1)
put_window:
        mov     R_H,RL
        mov     R_ROW,R_U               ; ligne ecran courante
pw_l:   mov     R_COL,R_CC              ; colonne ecran courante
        clr     R_F
        mov     R_W,RC
        btjz    %$80,R_MIR,@pw_c
        add     R_W,RM                  ; miroir : la ligne du plan se lit de droite
        adc     %0,RM-1                 ; a gauche (RM = sa fin)
pw_c:   btjz    %$80,R_MIR,@pw_d
        sub     %1,RM
        sbb     %0,RM-1
pw_d:   cmp     %40,R_CC                ; hors de l'ecran (ou colonne negative) : case sautee
        jhs     @pw_s
        cmp     %0,R_F
        jne     @pw_a
        mov     R_U,A                   ; premiere case visible de la ligne : son adresse
        mov     R_CC,B
        call    @cell_addr
        movd    RV,TEMP1
        trap    8
        inc     R_F
pw_a:   mov     R_U,A                   ; la tuile du decor a cet endroit
        mov     R_CC,B
        call    @map_at
        mov     A,R_G2
        lda     @CLIPR                  ; au-dessus du plafond (saut sous un sol) : le decor
        cmp     R_U,A
        jeq     @pw_k
        jhs     @pw_v
pw_k:   lda     *RM
        jeq     @pw_v
        cmp     %T_WALL,R_TY            ; sur la face d'un mur : le personnage passe DERRIERE, comme
        jeq     @pw_v                   ; dans le jeu (on ne voit que le mur)
        call    @pil_fore               ; ... et derriere le fut d'un pilier
        jeq     @pw_v
        mov     A,B
        add     R_SET,A                 ; case pleine : un caractere de la pose (BAGC3 : le prince,
        dec     A                       ; BAGC1 : le garde), dans sa couleur
        mov     A,R_T
pw_a2:  lda     @P_ATTR
        jmp     @pw_e
pw_v:   clr     R_T                     ; case vide : le garde s'il y est (sauf sur un mur), sinon la tuile
        cmp     %T_WALL,R_TY
        jeq     @pw_v1
        call    @pil_fore
        jeq     @pw_v1
        mov     R_U,R_GE
        mov     R_CC,R_GC
        call    @oc_get
        jeq     @pw_v1
        mov     A,R_T
        mov     %GB_ATTR,A
        jmp     @pw_e
pw_v1:  mov     R_G2,A
        jeq     @pw_z
        and     %$7F,A
        mov     A,R_T
pw_z:   mov     R_G2,B
        call    @attr_b
pw_e:   movp    A,P46
        mov     R_T,A
        movp    A,P46
pw_s:   inc     R_CC
        btjo    %$80,R_MIR,@pw_f
        add     %1,RM
        adc     %0,RM-1
pw_f:   dec     RC
        jeq     @pw_f0
        br      @pw_c
pw_f0:
        btjz    %$80,R_MIR,@pw_g
        add     R_W,RM                  ; miroir : ligne suivante du plan
        adc     %0,RM-1
pw_g:   inc     R_U
        dec     RL
        jeq     @pw_x
        br      @pw_l
pw_x:   rets

; --- erase_old : rend au decor les cases de l'ancienne fenetre hors de la nouvelle
erase_old:
        cmp     %0,R_OH
        jeq     @eo_x
        clr     RL                      ; ligne dans l'ancienne fenetre
eo_l:   clr     RC                      ; colonne
eo_c:   mov     R_OR,R_T                ; R_T = ligne ecran, R_U = colonne ecran
        add     RL,R_T
        mov     R_OC,R_U
        add     RC,R_U
        cmp     %40,R_U                 ; hors de l'ecran : rien a rendre
        jhs     @eo_n
        mov     R_T,A                   ; dans la nouvelle fenetre ?
        sub     R_ROW,A
        cmp     R_H,A                   ; (non signe : < R_H = dedans)
        jhs     @eo_w
        mov     R_U,A
        sub     R_COL,A
        cmp     R_W,A
        jl      @eo_n                   ; dedans : on la laisse
eo_w:   mov     R_T,A
        mov     R_U,B
        call    @cell_addr
        movd    RV,TEMP1
        trap    8
        mov     R_T,A                   ; on remet le decor (ou le garde)
        mov     R_U,B
        call    @map_at
        mov     A,R_G2
        cmp     %T_WALL,R_TY
        jeq     @eo_d
        call    @pil_fore
        jeq     @eo_d
        mov     R_T,R_GE
        mov     R_U,R_GC
        call    @oc_get
        jeq     @eo_d
        push    A
        movp    %GB_ATTR,P46
        pop     A
        movp    A,P46
        jmp     @eo_n
eo_d:   mov     R_G2,B
        call    @attr_b
        movp    A,P46
        mov     R_G2,A
        jeq     @eo_z
        and     %$7F,A
eo_z:   movp    A,P46
eo_n:   inc     RC
        cmp     R_OW,RC
        jne     @eo_c
        inc     RL
        cmp     R_OH,RL
        jne     @eo_l
eo_x:   rets

; --- rev_tab : l'octet aux 8 points inverses (pour le miroir) --------------------
rev_tab:
        .byte   $00,$80,$40,$C0,$20,$A0,$60,$E0,$10,$90,$50,$D0,$30,$B0,$70,$F0
        .byte   $08,$88,$48,$C8,$28,$A8,$68,$E8,$18,$98,$58,$D8,$38,$B8,$78,$F8
        .byte   $04,$84,$44,$C4,$24,$A4,$64,$E4,$14,$94,$54,$D4,$34,$B4,$74,$F4
        .byte   $0C,$8C,$4C,$CC,$2C,$AC,$6C,$EC,$1C,$9C,$5C,$DC,$3C,$BC,$7C,$FC
        .byte   $02,$82,$42,$C2,$22,$A2,$62,$E2,$12,$92,$52,$D2,$32,$B2,$72,$F2
        .byte   $0A,$8A,$4A,$CA,$2A,$AA,$6A,$EA,$1A,$9A,$5A,$DA,$3A,$BA,$7A,$FA
        .byte   $06,$86,$46,$C6,$26,$A6,$66,$E6,$16,$96,$56,$D6,$36,$B6,$76,$F6
        .byte   $0E,$8E,$4E,$CE,$2E,$AE,$6E,$EE,$1E,$9E,$5E,$DE,$3E,$BE,$7E,$FE
        .byte   $01,$81,$41,$C1,$21,$A1,$61,$E1,$11,$91,$51,$D1,$31,$B1,$71,$F1
        .byte   $09,$89,$49,$C9,$29,$A9,$69,$E9,$19,$99,$59,$D9,$39,$B9,$79,$F9
        .byte   $05,$85,$45,$C5,$25,$A5,$65,$E5,$15,$95,$55,$D5,$35,$B5,$75,$F5
        .byte   $0D,$8D,$4D,$CD,$2D,$AD,$6D,$ED,$1D,$9D,$5D,$DD,$3D,$BD,$7D,$FD
        .byte   $03,$83,$43,$C3,$23,$A3,$63,$E3,$13,$93,$53,$D3,$33,$B3,$73,$F3
        .byte   $0B,$8B,$4B,$CB,$2B,$AB,$6B,$EB,$1B,$9B,$5B,$DB,$3B,$BB,$7B,$FB
        .byte   $07,$87,$47,$C7,$27,$A7,$67,$E7,$17,$97,$57,$D7,$37,$B7,$77,$F7
        .byte   $0F,$8F,$4F,$CF,$2F,$AF,$6F,$EF,$1F,$9F,$5F,$DF,$3F,$BF,$7F,$FF

; --- nd_tab : NON (motif elargi d'un point de chaque cote), pour detourer le personnage
nd_tab:
        .byte   $FF,$FC,$F8,$F8,$F1,$F0,$F0,$F0,$E3,$E0,$E0,$E0,$E1,$E0,$E0,$E0
        .byte   $C7,$C4,$C0,$C0,$C1,$C0,$C0,$C0,$C3,$C0,$C0,$C0,$C1,$C0,$C0,$C0
        .byte   $8F,$8C,$88,$88,$81,$80,$80,$80,$83,$80,$80,$80,$81,$80,$80,$80
        .byte   $87,$84,$80,$80,$81,$80,$80,$80,$83,$80,$80,$80,$81,$80,$80,$80
        .byte   $1F,$1C,$18,$18,$11,$10,$10,$10,$03,$00,$00,$00,$01,$00,$00,$00
        .byte   $07,$04,$00,$00,$01,$00,$00,$00,$03,$00,$00,$00,$01,$00,$00,$00
        .byte   $0F,$0C,$08,$08,$01,$00,$00,$00,$03,$00,$00,$00,$01,$00,$00,$00
        .byte   $07,$04,$00,$00,$01,$00,$00,$00,$03,$00,$00,$00,$01,$00,$00,$00
        .byte   $3F,$3C,$38,$38,$31,$30,$30,$30,$23,$20,$20,$20,$21,$20,$20,$20
        .byte   $07,$04,$00,$00,$01,$00,$00,$00,$03,$00,$00,$00,$01,$00,$00,$00
        .byte   $0F,$0C,$08,$08,$01,$00,$00,$00,$03,$00,$00,$00,$01,$00,$00,$00
        .byte   $07,$04,$00,$00,$01,$00,$00,$00,$03,$00,$00,$00,$01,$00,$00,$00
        .byte   $1F,$1C,$18,$18,$11,$10,$10,$10,$03,$00,$00,$00,$01,$00,$00,$00
        .byte   $07,$04,$00,$00,$01,$00,$00,$00,$03,$00,$00,$00,$01,$00,$00,$00
        .byte   $0F,$0C,$08,$08,$01,$00,$00,$00,$03,$00,$00,$00,$01,$00,$00,$00
        .byte   $07,$04,$00,$00,$01,$00,$00,$00,$03,$00,$00,$00,$01,$00,$00,$00



; ============================================================================
; INTRO -- l'ecran titre (prince_intro.asm, fait par intro2exl.py) et un air au
; buzzer (comme Exeltris : la minuterie bat chaque demi-periode), jusqu'a ce
; qu'on appuie sur une fleche, ESPACE ou la manette (puis qu'on la relache).
; ============================================================================
IN_ROW0         .equ    2               ; premiere ligne de l'image (20 lignes de 40 cases)
SN_PH           .equ    $C7D0           ; son : adresse de la note suivante
SN_PL           .equ    $C7D1
SN_CH           .equ    $C7D2           ; ... battements restants de la note
SN_CL           .equ    $C7D3
SN_F            .equ    $C7D4           ; ... <> 0 : la note sonne (0 : silence)
SN_G            .equ    $C7D5           ; ... silence entre deux notes, en battements (0 : notes liees)
SN_RH           .equ    $C7D6           ; ... debut de l'air pour recommencer (0 : un bruitage, on s'arrete)
SN_RL           .equ    $C7D7
SN_B6           .equ    $C7D8           ; ... bit du buzzer au repos
TM_H            .equ    $C7DA           ; temps ecoule depuis le debut du pas, en unites de 3/307200 s (9,8 us)
TM_L            .equ    $C7DB
SN_DT           .equ    $C7DC           ; recharge de la minuterie en cours (pour compter le temps)
SN_ON           .equ    $C7DD           ; <> 0 : un son joue (0 : la minuterie ne fait que compter le temps)
RIPF            .equ    $C7D9           ; <> 0 : "feu" appuye pendant le debut de la parade (riposte)
MU_VEC          .equ    $C004           ; BRTIME : vecteur de la minuterie (le moniteur l'appelle)

intro:  call    @pg_clr                 ; la page en noir, avant de changer les generateurs
        mov     %IN_N,A
        jne     @it_g0
        br      @it_mus                 ; (pas d'image : la musique seule)
it_g0:
; 1. les motifs : le motif k dans BAGC2 (k < 126) ou BAGC3, code (k mod 126) + 1, 32 saute
;    (BAGC1, comme BAGC0, est un generateur alphanumerique : pas de couleur de fond)
        movd    %in_glyf,RD
        clr     R_Q
it_g:   mov     R_Q,A
        call    @in_gc                  ; A = code, B = generateur (0 : BAGC2, 1 : BAGC3)
        mov     A,RV
        lda     @in_gbh(B)
        mov     A,RV-1
        mov     %10,RL
it_l:   movd    RV,TEMP1                ; une ligne du motif (la ligne du bas d'abord)
        trap    8
        lda     *RD
        movp    A,P46
        add     %1,RD
        adc     %0,RD-1
        add     %128,RV
        adc     %0,RV-1
        djnz    RL,@it_l
        inc     R_Q
        cmp     %IN_N,R_Q
        jne     @it_g
; 2. l'ecran : un octet de commande par case (voir intro2exl.py)
        movd    %SCREEN_BASE+(IN_ROW0*LINE_LEN),RV  ; (TASM : de gauche a droite)
        movd    RV,TEMP1
        trap    8
        movd    %in_scr,RD
        clr     R_T                     ; prochain nouveau motif
        clr     R_U                     ; repetitions de la case precedente restantes
        mov     %20,RL
it_r:   clr     R_CC
it_c:   mov     R_U,A
        jeq     @it_rd
        dec     R_U                     ; encore la case precedente
        jmp     @it_o
it_rd:  lda     *RD
        add     %1,RD
        adc     %0,RD-1
        mov     A,R_G
        and     %$3F,A
        btjo    %$80,R_G,@it_h
        mov     A,R_Q3                  ; 00 / 01 : les couleurs (forme, fond)
        btjo    %$40,R_G,@it_k
        mov     R_T,R_Q                 ; 00 : le motif suivant
        inc     R_T
        jmp     @it_o
it_k:   lda     *RD                     ; 01 : le motif donne
        add     %1,RD
        adc     %0,RD-1
        mov     A,R_Q
        jmp     @it_o
it_h:   btjo    %$40,R_G,@it_u
        mov     A,R_U                   ; 10 : la case precedente, n + 1 fois (celle-ci comprise)
        jmp     @it_o
it_u:   mov     A,R_Q3                  ; 11 : le motif de la case du dessus
        mov     R_CC,B
        lda     @DK(B)
        mov     A,R_Q
it_o:   mov     R_CC,B                  ; (DK : le motif de chaque colonne, pour la ligne suivante)
        mov     R_Q,A
        sta     @DK(B)
        call    @in_gc
        mov     A,R_G2                  ; code
        lda     @in_gat(B)
        mov     A,R_G                   ; generateur
        mov     R_Q3,A
        and     %$38,A                  ; forme : bits 5-3 -> 7-5
        rl      A
        rl      A
        or      R_G,A
        mov     A,R_G
        mov     R_Q3,A
        and     %7,A                    ; fond
        or      R_G,A
        movp    A,P46
        mov     R_G2,A
        movp    A,P46
        inc     R_CC
        cmp     %40,R_CC
        jne     @it_c
        movp    %MIXT_NEXT_TEXT|MBLACK,P46
        movp    %0,P46
        djnz    RL,@it_r
; 3. la musique, jusqu'a une touche
it_mus: call    @snd_init
        mov     %1,A                    ; l'air recommence a la fin
        sta     @SN_RH
        mov     %mu_air>>8,A
        mov     %mu_air&$FF,B
        call    @sn_go
it_w:   lda     @joy_state0
        jeq     @it_w
it_w2:  lda     @joy_state0             ; (relachee : elle ne compte pas dans le jeu)
        jne     @it_w2
        call    @snd_off
        br      @pg_clr                 ; la page en noir pendant qu'on charge le decor

; in_gc : A = numero du motif -> A = code (1-127 sans 32), B = generateur (0 : BAGC2, 1 : BAGC3)
in_gc:  clr     B
gc_1:   cmp     %126,A
        jl      @gc_2
        sub     %126,A
        inc     B
        jmp     @gc_1
gc_2:   inc     A
        cmp     %32,A
        jl      @gc_3
        inc     A
gc_3:   rets
in_gbh: .byte   FONT_A>>8,FONT_BAGC3>>8
in_gat: .byte   $08,$18

; pg_clr : toute la page en noir (noir sur noir), lignes de controle comprises
pg_clr: movd    %SCREEN_BASE,RV
        movd    RV,TEMP1
        trap    8
        mov     %25,RL
pc_l:   mov     %40,RC
pc_c:   movp    %$08,P46
        movp    %1,P46
        djnz    RC,@pc_c
        movp    %MIXT_NEXT_TEXT|MBLACK,P46
        movp    %0,P46
        djnz    RL,@pc_l
        rets

; ============================================================================
; SON -- la minuterie bat au double de la frequence de la note (prediviseur p :
; F = 307200 / ((p + 1) (r + 1))) et mu_isr inverse le buzzer a chaque battement.
; Une table de son : silence entre deux notes (battements), prediviseur, puis par
; note : recharge r (0 : silence), nombre de battements (fort, faible) ; 0,0,0 : fin.
; L'air de l'intro recommence a la fin, un bruitage s'arrete.
; ============================================================================

; snd_init : la minuterie appellera mu_isr (une fois pour toutes, avant l'intro)
snd_init:
        dint
        mov     %mu_isr>>8,A
        sta     @MU_VEC
        mov     %mu_isr&$FF,A
        sta     @MU_VEC+1
        movp    P6,A
        and     %8,A
        sta     @SN_B6
        clr     A
        sta     @SN_F
        eint
        rets

; snd : joue le bruitage dont la table est en A (fort) B (faible) ; il remplace celui
; qui sonne, sauf si celui-ci est plus important (l'octet avant la table : sa priorite,
; petite = importante, comme sound_prio_table de SDLPoP). A et B ne changent pas.
snd:    push    A
        push    B
        push    RD-1
        push    RD
        mov     A,RD-1
        mov     B,RD
        sub     %1,RD
        sbb     %0,RD-1
        lda     *RD                     ; sa priorite, juste avant la table (petite : important)
        mov     A,B
        pop     RD
        pop     RD-1
        lda     @SN_ON
        jeq     @sp_ok
        lda     @SN_PR                  ; un bruitage plus important sonne encore : on n'y touche pas
        cmp     B,A
        jhs     @sp_ok
        pop     B
        pop     A
        rets
sp_ok:  mov     B,A
        sta     @SN_PR
        pop     B
        pop     A
        push    A
        clr     A
        sta     @SN_RH
        pop     A
; sn_go : meme chose ; SN_RH <> 0 : l'air recommence a la fin
sn_go:  dint
        push    RD-1
        push    RD
        mov     A,RD-1
        mov     B,RD
        lda     *RD                     ; silence entre deux notes
        sta     @SN_G
        add     %1,RD
        adc     %0,RD-1
        lda     *RD                     ; prediviseur
        or      %$80,A                  ; (+ marche)
        push    A
        add     %1,RD
        adc     %0,RD-1
        mov     RD-1,A
        sta     @SN_PH
        mov     RD,A
        sta     @SN_PL
        lda     @SN_RH
        jeq     @sg_1
        mov     RD-1,A
        sta     @SN_RH
        mov     RD,A
        sta     @SN_RL
sg_1:   clr     A
        sta     @SN_F
        sta     @SN_CH
        inc     A
        sta     @SN_CL                  ; la 1re note au 1er battement
        call    @sn_rep
        movp    %100,P2
        mov     %100,A
        sta     @SN_DT
        mov     %1,A
        sta     @SN_ON
        pop     A
        movp    A,P3
        movp    P0,A
        and     %$D5,A                  ; (sans effacer INT1 / INT3 en attente)
        or      %$0C,A                  ; INT2 permise, son drapeau efface
        movp    A,P0
        pop     RD
        pop     RD-1
        eint
        rets

; fr_wait : attend que FRAME_U unites de temps se soient ecoulees depuis le dernier appel
; (si le pas a pris plus longtemps, on n'attend pas), puis repart de zero
fr_wait:
        dint
        lda     @TM_H
        cmp     %FRAME_U>>8,A
        jl      @fw_n
        jne     @fw_y
        lda     @TM_L
        cmp     %FRAME_U&$FF,A
        jhs     @fw_y
fw_n:   eint
        jmp     @fr_wait
fw_y:   push    RD-1                    ; on garde l'avance (la minuterie bat par 2,5 ms) : TM -= FRAME_U,
        push    RD                      ; et si le pas a dure plus de deux pas, on repart de zero
        lda     @TM_H
        mov     A,RD-1
        lda     @TM_L
        mov     A,RD
        sub     %FRAME_U&$FF,RD
        sbb     %FRAME_U>>8,RD-1
        cmp     %FRAME_U>>8,RD-1
        jl      @fw_k
        clr     RD-1
        clr     RD
fw_k:   mov     RD-1,A
        sta     @TM_H
        mov     RD,A
        sta     @TM_L
        pop     RD
        pop     RD-1
        eint
        rets

; snd_off : plus de son
snd_off:
        dint
        call    @sn_end
        eint
        rets
sn_end: movp    %255,P2                 ; plus de son : la minuterie bat lentement (400 fois par seconde)
        mov     %255,A                  ; et ne fait plus que compter le temps (fr_wait)
        sta     @SN_DT
        movp    %$82,P3
        clr     A
        sta     @SN_F
        sta     @SN_ON
; sn_rep : le buzzer au repos
sn_rep: movp    P6,A
        and     %$F7,A
        mov     A,B
        lda     @SN_B6
        or      B,A
        movp    A,P6
        rets

; mu_isr : un battement (le moniteur a sauve A et B). D'abord le temps : TM += recharge + 1
mu_isr: lda     @TM_H                   ; (sans deborder : au-dela de 600 ms, on ne compte plus)
        cmp     %$F0,A
        jhs     @mi_ts
        push    RD-1
        push    RD
        mov     A,RD-1
        lda     @TM_L
        mov     A,RD
        lda     @SN_DT
        mov     A,B
        add     R_B,RD
        adc     %0,RD-1
        add     %1,RD
        adc     %0,RD-1
        mov     RD-1,A
        sta     @TM_H
        mov     RD,A
        sta     @TM_L
        pop     RD
        pop     RD-1
mi_ts:  lda     @SN_ON
        jne     @mi_0
        rets
mi_0:   lda     @SN_F
        jeq     @mi_s
        xorp    %8,P6                   ; bit 3 du port : le buzzer
mi_s:   lda     @SN_CL
        dec     A
        sta     @SN_CL
        cmp     %$FF,A
        jne     @mi_z
        lda     @SN_CH
        dec     A
        sta     @SN_CH
mi_z:   lda     @SN_CH
        mov     A,B
        lda     @SN_CL
        or      B,A
        jeq     @mi_e
        rets
mi_e:   lda     @SN_F                   ; fin d'une note : un court silence avant la suivante ?
        jeq     @mi_n
        lda     @SN_G
        jeq     @mi_n                   ; (0 : notes liees)
        sta     @SN_CL                  ; (SN_CH est deja a 0)
        clr     A
        sta     @SN_F
        movp    %101,P2
        mov     %101,A
        sta     @SN_DT
        br      @sn_rep
mi_n:   push    RD-1                    ; note suivante
        push    RD
        lda     @SN_PH
        mov     A,RD-1
        lda     @SN_PL
        mov     A,RD
        lda     *RD                     ; recharge (0 : silence)
        sta     @SN_F
        jne     @mi_t
        mov     %101,A
mi_t:   movp    A,P2
        sta     @SN_DT
        add     %1,RD
        adc     %0,RD-1
        lda     *RD
        sta     @SN_CH
        add     %1,RD
        adc     %0,RD-1
        lda     *RD
        sta     @SN_CL
        add     %1,RD
        adc     %0,RD-1
        mov     RD-1,A
        sta     @SN_PH
        mov     RD,A
        sta     @SN_PL
        pop     RD
        pop     RD-1
        lda     @SN_CH
        mov     A,B
        lda     @SN_CL
        or      B,A
        jeq     @mi_f
        br      @sn_rep
mi_f:   lda     @SN_RH                  ; fin de la table
        jne     @mi_l
        br      @sn_end                 ; un bruitage : c'est fini
mi_l:
        sta     @SN_PH                  ; l'air : on recommence
        lda     @SN_RL
        sta     @SN_PL
        mov     %1,A
        sta     @SN_CL
        clr     A
        sta     @SN_F
mi_x:   rets

; les bruitages (prediviseur 3 : 102400 / (r + 1) battements par seconde ; silence a 1 kHz)
        .byte   48                      ; (priorite)
sx_tick:    .byte   0,2; une grille bouge d'un cran
        .byte   170,0,5, 0,0,6, 232,0,4, 0,0,0
        .byte   48                      ; (priorite)
sx_slam:    .byte   0,2; la grille retombe
        .byte   196,0,8, 255,0,10, 0,0,10, 255,0,8, 0,0,0
        .byte   102                      ; (priorite)
sx_click:   .byte   0,2; un bouton s'enfonce
        .byte   48,0,13, 0,0,10, 64,0,9, 0,0,0
        .byte   130                      ; (priorite)
sx_sword:   .byte   0,2; l'epee prise
        .byte   130,0,27, 97,0,37, 77,0,46, 64,0,55, 48,0,73, 0,0,15, 48,0,167, 0,0,0
        .byte   125                      ; (priorite)
sx_pot:     .byte   0,2; potion : un point de vie
        .byte   154,0,20, 0,0,20, 137,0,22, 0,0,20, 122,0,25, 0,0,40, 64,0,63, 48,0,125, 0,0,0
        .byte   125                      ; (priorite)
sx_life:    .byte   0,2; grande potion : un point de plus
        .byte   194,0,24, 154,0,30, 130,0,35, 97,0,47, 77,0,59, 64,0,71, 48,0,188, 0,0,0
        .byte   125                      ; (priorite)
sx_poison:  .byte   0,2; poison
        .byte   84,0,48, 101,0,40, 121,0,34, 145,0,28, 176,0,23, 212,0,19, 255,0,24, 0,0,0
        .byte   10                      ; (priorite)
sx_clash:   .byte   0,2; epees qui se croisent (parade)
        .byte   38,0,21, 51,0,16, 32,0,25, 43,0,19, 36,0,28, 48,0,25, 38,0,37, 0,0,0
        .byte   1                      ; (priorite)
sx_fin:     .byte   0,2; le niveau est fini
        .byte   97,0,125, 77,0,158, 64,0,189, 48,0,251, 0,0,60, 64,0,189, 48,3,0, 0,0,0
        .byte   11                      ; (priorite)
sx_hit:     .byte   0,2; touche
        .byte   72,0,21, 113,0,18, 170,0,15, 232,0,18, 0,0,0
        .byte   26                      ; (priorite)
sx_crash:   .byte   0,2; une dalle fragile se brise en touchant le sol (bruit qui decroit)
        .byte   112,0,4, 68,0,6, 131,0,3, 196,0,2, 42,0,10, 48,0,8, 240,0,2, 167,0,2, 54,0,7, 123,0,3
        .byte   179,0,2, 44,0,9, 159,0,3, 84,0,5, 39,0,10, 52,0,8, 0,0,4, 91,0,4, 0,0,9, 45,0,9
        .byte   61,0,7, 191,0,2, 45,0,11, 131,0,4, 0,0,6, 41,0,12, 64,0,8, 0,0,5, 168,0,3, 0,0,7
        .byte   173,0,3, 76,0,7, 0,0,6, 125,0,4, 0,0,4, 174,0,3, 0,0,6, 157,0,3, 139,0,4, 149,0,3
        .byte   0,0,10, 122,0,4, 0,0,5, 208,0,2, 0,0,0
        .byte   11                      ; (priorite)
sx_crhit:   .byte   0,2; une dalle fragile se brise sur le prince : la dalle, puis touche
        .byte   112,0,4, 68,0,6, 131,0,3, 196,0,2, 42,0,10, 48,0,8, 240,0,2, 167,0,2, 54,0,7, 123,0,3
        .byte   179,0,2, 44,0,9, 159,0,3, 84,0,5, 39,0,10, 52,0,8, 0,0,20
        .byte   72,0,21, 113,0,18, 170,0,15, 232,0,18, 0,0,0
        .byte   15                      ; (priorite)
sx_impale:  .byte   0,2; empale sur les pics : un choc metallique aigu, puis un rale qui descend
        .byte   28,0,30, 0,0,4, 34,0,24, 0,0,4, 30,0,20, 0,0,12, 120,0,20, 135,0,18, 150,0,16, 165,0,15
        .byte   180,0,14, 195,0,13, 210,0,12, 225,0,11, 240,0,10, 255,0,20, 0,0,0
        .byte   20                      ; (priorite)
sx_splat:   .byte   0,2; chute de trois etages : il s'ecrase
        .byte   160,0,4, 223,0,3, 188,0,4, 217,0,3, 213,0,3, 193,0,4, 243,0,3, 207,0,3, 186,0,4, 227,0,3
        .byte   159,0,4, 165,0,4, 215,0,3, 203,0,4, 171,0,4, 246,0,3, 193,0,4, 169,0,4, 203,0,4, 0,0,5
        .byte   247,0,3, 251,0,3, 190,0,4, 0,0,9, 226,0,3, 252,0,3, 161,0,4, 210,0,3, 158,0,5, 0,0,8
        .byte   232,0,3, 255,0,24, 0,0,0
        .byte   25                      ; (priorite)
sx_medland: .byte   0,2; reception dure (deux etages)
        .byte   255,0,8, 0,0,4, 220,0,6, 255,0,6, 0,0,6, 240,0,4, 0,0,0
        .byte   28                      ; (priorite)
sx_softland: .byte  0,2; reception souple (un etage)
        .byte   255,0,4, 0,0,3, 250,0,3, 0,0,0
        .byte   30                      ; (priorite)
sx_fall:    .byte   0,2; il tombe de plus d'un etage (son qui descend)
        .byte   45,0,78, 56,0,63, 67,0,53, 78,0,45, 89,0,40, 100,0,35, 111,0,32, 122,0,29, 133,0,27, 144,0,25
        .byte   155,0,23, 166,0,21, 177,0,20, 188,0,19, 199,0,18, 210,0,17, 0,0,0
        .byte   75                      ; (priorite)
sx_bump:    .byte   0,2; il se cogne contre un mur
        .byte   255,0,5, 0,0,3, 255,0,3, 0,0,0
        .byte   75                      ; (priorite)
sx_bumpup:  .byte   0,2; la tete cogne le plafond
        .byte   200,0,6, 0,0,3, 240,0,4, 0,0,0
        .byte   60                      ; (priorite)
sx_spike:   .byte   0,2; des pics sortent : clac metallique sec
        .byte   24,0,20, 0,0,3, 40,0,10, 0,0,0
        .byte   70                      ; (priorite)
sx_grab:    .byte   0,2; il se rattrape au rebord
        .byte   150,0,4, 0,0,2, 190,0,3, 0,0,0
        .byte   160                     ; (priorite)
sx_step:    .byte   0,2; un pas : le pied se pose
        .byte   230,0,2, 0,0,0

; l'air (mu_air) et les musiques de la mort (sx_mort, sx_mortc) sont dans prince_intro.asm, ecrit par
; intro2exl.py : ceux de SDLPoP
; (sa version haut-parleur PC) ou un air original, au format des tables de son ci-dessus.

#include "joyexl.asm"
#include "prince_jeu_data.asm"
#include "prince_intro.asm"

        .end
