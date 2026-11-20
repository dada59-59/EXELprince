; prince_jeu_data.asm -- produit par pop2exl.py --jeu a partir de VOTRE exemplaire de SDLPoP.
; Ce fichier derive des images du jeu : ne le diffusez pas.
; 236 poses, 57 sequences, 428 pas, 13775 octets, mode lum
PR_SET          .equ    22              ; taille d'un jeu de codes (la plus grande pose)
PR_CRAM         .equ    10527              ; octets de poses dans l'Exelmemoire (prince_poses.bin)
PR_CRAMP        .equ    $91A0           ; ... a partir d'ici (en-tete "PO" et empreinte, puis les poses)
PR_CHASH        .equ    $197C           ; ... et leur empreinte (le moteur la verifie au demarrage)
pr_p3 .equ $B296                     ; pose dans l'Exelmemoire
pr_p4 .equ $B5D0                     ; pose dans l'Exelmemoire
pr_p5 .equ $A993                     ; pose dans l'Exelmemoire
pr_p6 .equ $B942                     ; pose dans l'Exelmemoire
pr_p7 .equ $B044                     ; pose dans l'Exelmemoire
pr_p8 .equ $A879                     ; pose dans l'Exelmemoire
pr_p9 .equ $A57E                     ; pose dans l'Exelmemoire
pr_p10 .equ $B488                     ; pose dans l'Exelmemoire
pr_p11 .equ $AA4D                     ; pose dans l'Exelmemoire
pr_p12 .equ $A45B                     ; pose dans l'Exelmemoire
pr_p13 .equ $AAA9                     ; pose dans l'Exelmemoire
pr_p28 .equ $AB05                     ; pose dans l'Exelmemoire
pr_p29 .equ $AD26                     ; pose dans l'Exelmemoire
pr_p30 .equ $9CB4                     ; pose dans l'Exelmemoire
pr_p31 .equ $9AFE                     ; pose dans l'Exelmemoire
pr_p32 .equ $B621                     ; pose dans l'Exelmemoire
pr_p33 .equ $9ECC                     ; pose dans l'Exelmemoire
pr_p34 .equ $9DF8                     ; pose dans l'Exelmemoire
pr_p35 .equ $A0D8                     ; pose dans l'Exelmemoire
pr_p36 .equ $A207                     ; pose dans l'Exelmemoire
pr_p37 .equ $A333                     ; pose dans l'Exelmemoire
pr_p38 .equ $B98F                     ; pose dans l'Exelmemoire
pr_p39 .equ $A69E                     ; pose dans l'Exelmemoire
pr_p40 .equ $AD7F                     ; pose dans l'Exelmemoire
pr_p41 .equ $A396                     ; pose dans l'Exelmemoire
pr_p42 .equ $B2E9                     ; pose dans l'Exelmemoire
pr_p43 .equ $B4DA                     ; pose dans l'Exelmemoire
pr_p44 .equ $ADD8                     ; pose dans l'Exelmemoire
pr_p45 .equ $AB61                     ; pose dans l'Exelmemoire
pr_p46 .equ $A5DE                     ; pose dans l'Exelmemoire
pr_p47 .equ $A13D                     ; pose dans l'Exelmemoire
pr_p48 .equ $9D20                     ; pose dans l'Exelmemoire
pr_p49 .equ $A4BC                     ; pose dans l'Exelmemoire
pr_p50 .equ $A9F0                     ; pose dans l'Exelmemoire
pr_p51 .equ $A6FD                     ; pose dans l'Exelmemoire
pr_p52 .equ $B0F0                     ; pose dans l'Exelmemoire
pr_p68 .equ $B8F4                     ; pose dans l'Exelmemoire
pr_p69 .equ $B52C                     ; pose dans l'Exelmemoire
pr_p70 .equ $B57E                     ; pose dans l'Exelmemoire
pr_p82 .equ $B9DC                     ; pose dans l'Exelmemoire
pr_p83 .equ $A51D                     ; pose dans l'Exelmemoire
pr_p84 .equ $A26B                     ; pose dans l'Exelmemoire
pr_p85 .equ $9F35                     ; pose dans l'Exelmemoire
pr_p86 .equ $B33C                     ; pose dans l'Exelmemoire
pr_p89 .equ $BA29                     ; pose dans l'Exelmemoire
pr_p90 .equ $B672                     ; pose dans l'Exelmemoire
pr_p97 .equ $AE31                     ; pose dans l'Exelmemoire
pr_p99 .equ $9530                     ; pose dans l'Exelmemoire
pr_p113 .equ $A3F9                     ; pose dans l'Exelmemoire
pr_p115 .equ $A75C                     ; pose dans l'Exelmemoire
pr_p117 .equ $AE8A                     ; pose dans l'Exelmemoire
pr_p119 .equ $9F9E                     ; pose dans l'Exelmemoire
pr_p121 .equ $9BDA                     ; pose dans l'Exelmemoire
pr_p123 .equ $9707                     ; pose dans l'Exelmemoire
pr_p125 .equ $94B8                     ; pose dans l'Exelmemoire
pr_p127 .equ $9C47                     ; pose dans l'Exelmemoire
pr_p129 .equ $91A4                     ; pose dans l'Exelmemoire
pr_p131 .equ $9344                     ; pose dans l'Exelmemoire
pr_p133 .equ $A2CF                     ; pose dans l'Exelmemoire
pr_p135 .equ $A070                     ; pose dans l'Exelmemoire
pr_p137 .equ $961D                     ; pose dans l'Exelmemoire
pr_p139 .equ $92C1                     ; pose dans l'Exelmemoire
pr_p141 .equ $9779                     ; pose dans l'Exelmemoire
pr_p143 .equ $9692                     ; pose dans l'Exelmemoire
pr_p145 .equ $9A20                     ; pose dans l'Exelmemoire
pr_p147 .equ $99B0                     ; pose dans l'Exelmemoire
pr_p149 .equ $9D8C                     ; pose dans l'Exelmemoire
pr_p151 .equ $9239                     ; pose dans l'Exelmemoire
pr_p153 .equ $9A8F                     ; pose dans l'Exelmemoire
pr_p155 .equ $95A7                     ; pose dans l'Exelmemoire
pr_p158 .equ $A007                     ; pose dans l'Exelmemoire
pr_p159 .equ $985D                     ; pose dans l'Exelmemoire
pr_p160 .equ $98CE                     ; pose dans l'Exelmemoire
pr_p161 .equ $93C3                     ; pose dans l'Exelmemoire
pr_p162 .equ $943E                     ; pose dans l'Exelmemoire
pr_p163 .equ $9E62                     ; pose dans l'Exelmemoire
pr_p164 .equ $993F                     ; pose dans l'Exelmemoire
pr_p165 .equ $97EB                     ; pose dans l'Exelmemoire
pr_p166 .equ $9B6C                     ; pose dans l'Exelmemoire
pr_p167 .equ $AEE3                     ; pose dans l'Exelmemoire
pr_p168 .equ $AC72                     ; pose dans l'Exelmemoire
pr_p174 .equ $B6C3                     ; pose dans l'Exelmemoire
pr_p175 .equ $AF3C                     ; pose dans l'Exelmemoire
pr_p176 .equ $ACCC                     ; pose dans l'Exelmemoire
pr_p179 .equ $AFED                     ; pose dans l'Exelmemoire
pr_p183 .equ $B38F                     ; pose dans l'Exelmemoire
pr_p184 .equ $B19A                     ; pose dans l'Exelmemoire
pr_p185 .equ $B3E2                     ; pose dans l'Exelmemoire
pr_p186 .equ $BA76                     ; pose dans l'Exelmemoire
pr_p187 .equ $AF95                     ; pose dans l'Exelmemoire
pr_p188 .equ $B1EE                     ; pose dans l'Exelmemoire
pr_p194 .equ $B765                     ; pose dans l'Exelmemoire
pr_p199 .equ $B145                     ; pose dans l'Exelmemoire
pr_p200 .equ $B242                     ; pose dans l'Exelmemoire
pr_p201 .equ $B8A5                     ; pose dans l'Exelmemoire
pr_p202 .equ $A8D7                     ; pose dans l'Exelmemoire
pr_p203 .equ $A7BB                     ; pose dans l'Exelmemoire
pr_p204 .equ $A935                     ; pose dans l'Exelmemoire
pr_p205 .equ $A1A2                     ; pose dans l'Exelmemoire
pr_p206 .equ $ABBC                     ; pose dans l'Exelmemoire
pr_p207 .equ $A63E                     ; pose dans l'Exelmemoire
pr_p208 .equ $A81A                     ; pose dans l'Exelmemoire
pr_p211 .equ $B7B5                     ; pose dans l'Exelmemoire
pr_p212 .equ $B805                     ; pose dans l'Exelmemoire
pr_p213 .equ $B855                     ; pose dans l'Exelmemoire
pr_p215 .equ $AC17                     ; pose dans l'Exelmemoire
pr_p216 .equ $B714                     ; pose dans l'Exelmemoire
pr_p220 .equ $B435                     ; pose dans l'Exelmemoire
pr_p222 .equ $B09A                     ; pose dans l'Exelmemoire
PR_FLOOR        .equ    14              ; ligne de cases du sol (son haut : la ou marche le personnage)
PR_X0           .equ    78              ; abscisse de depart (unites du jeu)
PR_XMIN         .equ    37              ; sortie a gauche (colonne -6)
PR_XMAX         .equ    219              ; sortie a droite (colonne 46)
PR_TOUR         .equ    161              ; 46 cases : on rentre par l'autre cote
; pas : pose (fort, faible), drapeaux, avance, decalage de l'image, poids du corps, ligne (+ $80 : le sol est ebranle ; + $40 : course ou saut, mortel sur des pics), regles (fort, faible ; 0,n = aucune, n : escrime, 1 coup porte, 2 parade, 3 coup qui part, 4 coup qui arrive)
; drapeaux : 1 demi-tour, 2 il faut un sol sous les pieds, 4 un etage plus haut, 8 plus bas, 16 chute libre, 32 les murs n'arretent pas, 64 mort, 128 pas prudent
; fin : 0, demi-tour, avance, sequence suivante (fort, faible)
pr_start:                               ; la premiere sequence
pj_stand:
        .byte   pr_p0>>8,pr_p0&$FF,2,0,0,253,9,pj_r15>>8,pj_r15&$FF        ; image 15
        .byte   0,0,0,pj_stand>>8,pj_stand&$FF        ; -> stand
pj_startrun:
        .byte   pr_p1>>8,pr_p1&$FF,2,0,1,253,9,0,0        ; image 1
        .byte   pr_p2>>8,pr_p2&$FF,2,0,1,253,9,0,0        ; image 2
        .byte   pr_p3>>8,pr_p3&$FF,2,0,3,252,9,0,0        ; image 3
        .byte   pr_p4>>8,pr_p4&$FF,2,0,4,252,10,0,0        ; image 4
        .byte   pr_p5>>8,pr_p5&$FF,2,8,0,250,10,0,0        ; image 5
        .byte   pr_p6>>8,pr_p6&$FF,2,3,0,247,10,0,0        ; image 6
        .byte   pr_p7>>8,pr_p7&$FF,2,3,0,246,74,pj_r7>>8,pj_r7&$FF        ; image 7
        .byte   pr_p8>>8,pr_p8&$FF,2,5,0,251,74,pj_r8>>8,pj_r8&$FF        ; image 8
        .byte   pr_p9>>8,pr_p9&$FF,2,1,0,252,74,pj_r9>>8,pj_r9&$FF        ; image 9
pj_f1:
        .byte   pr_p10>>8,pr_p10&$FF,2,2,0,249,74,pj_r10>>8,pj_r10&$FF        ; image 10
        .byte   pr_p11>>8,pr_p11&$FF,2,4,0,245,74,pj_r11>>8,pj_r11&$FF        ; image 11
        .byte   pr_p12>>8,pr_p12&$FF,2,5,0,253,74,pj_r12>>8,pj_r12&$FF        ; image 12
        .byte   pr_p13>>8,pr_p13&$FF,2,2,0,253,74,pj_r13>>8,pj_r13&$FF        ; image 13
pj_f2:
        .byte   pr_p14>>8,pr_p14&$FF,2,3,0,249,74,pj_r14>>8,pj_r14&$FF        ; image 14
        .byte   0,0,4,pj_runcyc1>>8,pj_runcyc1&$FF        ; -> runcyc1
pj_runcyc1:
        .byte   pr_p7>>8,pr_p7&$FF,2,0,0,246,74,pj_r7>>8,pj_r7&$FF        ; image 7
        .byte   pr_p8>>8,pr_p8&$FF,2,5,0,251,74,pj_r8>>8,pj_r8&$FF        ; image 8
        .byte   pr_p9>>8,pr_p9&$FF,2,1,0,252,74,pj_r9>>8,pj_r9&$FF        ; image 9
pj_f3:
        .byte   pr_p10>>8,pr_p10&$FF,2,2,0,249,74,pj_r10>>8,pj_r10&$FF        ; image 10
        .byte   pr_p11>>8,pr_p11&$FF,2,4,0,245,74,pj_r11>>8,pj_r11&$FF        ; image 11
        .byte   pr_p12>>8,pr_p12&$FF,2,5,0,253,74,pj_r12>>8,pj_r12&$FF        ; image 12
        .byte   pr_p13>>8,pr_p13&$FF,2,2,0,253,74,pj_r13>>8,pj_r13&$FF        ; image 13
pj_f4:
        .byte   pr_p14>>8,pr_p14&$FF,2,3,0,249,74,pj_r14>>8,pj_r14&$FF        ; image 14
        .byte   0,0,4,pj_runcyc1>>8,pj_runcyc1&$FF        ; -> runcyc1
pj_rdiveroll:
        .byte   pr_p15>>8,pr_p15&$FF,2,1,0,252,11,0,0        ; image 107
        .byte   pr_p16>>8,pr_p16&$FF,2,4,0,251,11,0,0        ; image 108
pj_rp1:
        .byte   pr_p17>>8,pr_p17&$FF,2,2,0,250,12,pj_r109>>8,pj_r109&$FF        ; image 109
        .byte   0,$40,2,pj_rp1>>8,pj_rp1&$FF        ; -> 2 fois de plus
        .byte   0,0,0,pj_rdiveroll_crouch>>8,pj_rdiveroll_crouch&$FF        ; -> rdiveroll_crouch
pj_rdiveroll_crouch:
        .byte   pr_p17>>8,pr_p17&$FF,2,0,0,250,12,pj_r109>>8,pj_r109&$FF        ; image 109
        .byte   0,0,0,pj_rdiveroll_crouch>>8,pj_rdiveroll_crouch&$FF        ; -> rdiveroll_crouch
pj_standup:
        .byte   pr_p18>>8,pr_p18&$FF,2,1,0,249,12,0,0        ; image 110
        .byte   pr_p19>>8,pr_p19&$FF,2,0,0,249,11,0,0        ; image 111
        .byte   pr_p20>>8,pr_p20&$FF,2,2,0,247,11,0,0        ; image 112
        .byte   pr_p21>>8,pr_p21&$FF,2,0,0,248,11,0,0        ; image 113
        .byte   pr_p22>>8,pr_p22&$FF,2,1,0,247,11,0,0        ; image 114
        .byte   pr_p23>>8,pr_p23&$FF,2,0,0,247,11,0,0        ; image 115
        .byte   pr_p24>>8,pr_p24&$FF,2,0,0,251,10,0,0        ; image 116
        .byte   pr_p25>>8,pr_p25&$FF,2,252,2,253,10,0,0        ; image 117
        .byte   pr_p26>>8,pr_p26&$FF,2,0,2,253,10,0,0        ; image 118
        .byte   pr_p27>>8,pr_p27&$FF,2,0,0,253,10,0,0        ; image 119
        .byte   0,0,0,pj_stand>>8,pj_stand&$FF        ; -> stand
pj_runjump:
        .byte   pr_p28>>8,pr_p28&$FF,2,0,0,253,74,0,0        ; image 34
pj_f5:
        .byte   pr_p29>>8,pr_p29&$FF,2,5,0,248,74,0,0        ; image 35
        .byte   pr_p30>>8,pr_p30&$FF,2,6,0,242,74,0,0        ; image 36
        .byte   pr_p31>>8,pr_p31&$FF,2,3,0,255,74,0,0        ; image 37
        .byte   pr_p32>>8,pr_p32&$FF,2,5,0,251,73,0,0        ; image 38
pj_f6:
        .byte   pr_p33>>8,pr_p33&$FF,0,7,0,242,73,0,0        ; image 39
        .byte   pr_p34>>8,pr_p34&$FF,0,12,0,245,9,0,0        ; image 40
        .byte   pr_p35>>8,pr_p35&$FF,0,8,0,245,9,0,0        ; image 41
        .byte   pr_p36>>8,pr_p36&$FF,0,8,0,246,9,0,0        ; image 42
        .byte   pr_p37>>8,pr_p37&$FF,0,4,0,255,74,0,0        ; image 43
        .byte   pr_p38>>8,pr_p38&$FF,2,4,0,252,10|$80,0,0        ; image 44
pj_rj44:
pj_f7:
        .byte   0,0,5,pj_runcyc1>>8,pj_runcyc1&$FF        ; -> runcyc1
pj_runturn:
        .byte   pr_p39>>8,pr_p39&$FF,2,1,0,254,9,0,0        ; image 53
        .byte   pr_p40>>8,pr_p40&$FF,2,1,0,255,10,0,0        ; image 54
pj_f8:
        .byte   pr_p41>>8,pr_p41&$FF,2,8,0,254,10,0,0        ; image 55
        .byte   pr_p42>>8,pr_p42&$FF,0,0,0,0,10,0,0        ; image 56
pj_f9:
        .byte   pr_p43>>8,pr_p43&$FF,0,7,0,0,10,0,0        ; image 57
        .byte   pr_p44>>8,pr_p44&$FF,0,3,0,0,10,0,0        ; image 58
        .byte   pr_p45>>8,pr_p45&$FF,0,1,0,0,10,0,0        ; image 59
        .byte   pr_p46>>8,pr_p46&$FF,0,0,0,0,10,0,0        ; image 60
        .byte   pr_p47>>8,pr_p47&$FF,0,2,0,0,10,0,0        ; image 61
        .byte   pr_p48>>8,pr_p48&$FF,0,255,0,0,10,0,0        ; image 62
        .byte   pr_p49>>8,pr_p49&$FF,0,0,0,0,10,0,0        ; image 63
        .byte   pr_p50>>8,pr_p50&$FF,0,0,0,0,10,0,0        ; image 64
        .byte   pr_p51>>8,pr_p51&$FF,0,255,0,0,10,0,0        ; image 65
        .byte   0,1,14,pj_runcyc7>>8,pj_runcyc7&$FF        ; -> runcyc7
pj_runcyc7:
        .byte   pr_p13>>8,pr_p13&$FF,2,0,0,253,74,pj_r13>>8,pj_r13&$FF        ; image 13
pj_f10:
        .byte   pr_p14>>8,pr_p14&$FF,2,3,0,249,74,pj_r14>>8,pj_r14&$FF        ; image 14
        .byte   0,0,4,pj_runcyc1>>8,pj_runcyc1&$FF        ; -> runcyc1
pj_runstop:
        .byte   pr_p39>>8,pr_p39&$FF,2,0,0,254,9,0,0        ; image 53
        .byte   pr_p40>>8,pr_p40&$FF,2,2,0,255,10,0,0        ; image 54
pj_f11:
        .byte   pr_p41>>8,pr_p41&$FF,2,7,0,254,10,0,0        ; image 55
        .byte   pr_p42>>8,pr_p42&$FF,0,0,0,0,10,0,0        ; image 56
pj_f12:
        .byte   pr_p52>>8,pr_p52&$FF,2,2,0,250,10,0,0        ; image 49
        .byte   pr_p53>>8,pr_p53&$FF,2,254,4,253,10,0,0        ; image 50
        .byte   pr_p54>>8,pr_p54&$FF,2,0,3,253,10,0,0        ; image 51
        .byte   pr_p55>>8,pr_p55&$FF,2,0,1,253,10,0,0        ; image 52
        .byte   0,0,0,pj_stand>>8,pj_stand&$FF        ; -> stand
pj_stoop:
        .byte   pr_p15>>8,pr_p15&$FF,2,1,0,252,11,0,0        ; image 107
        .byte   pr_p16>>8,pr_p16&$FF,2,2,0,251,11,0,0        ; image 108
        .byte   pr_p17>>8,pr_p17&$FF,2,0,0,250,12,pj_r109>>8,pj_r109&$FF        ; image 109
        .byte   0,0,0,pj_stoop_crouch>>8,pj_stoop_crouch&$FF        ; -> stoop_crouch
pj_stoop_crouch:
        .byte   pr_p17>>8,pr_p17&$FF,2,0,0,250,12,pj_r109>>8,pj_r109&$FF        ; image 109
        .byte   0,0,0,pj_stoop_crouch>>8,pj_stoop_crouch&$FF        ; -> stoop_crouch
pj_highjump:
        .byte   pr_p56>>8,pr_p56&$FF,2,0,254,253,10,0,0        ; image 67
        .byte   pr_p57>>8,pr_p57&$FF,2,0,254,253,10,0,0        ; image 68
        .byte   pr_p58>>8,pr_p58&$FF,2,0,255,253,10,0,0        ; image 69
        .byte   pr_p59>>8,pr_p59&$FF,2,0,254,252,10,0,0        ; image 70
        .byte   pr_p60>>8,pr_p60&$FF,2,0,254,253,10,0,0        ; image 71
        .byte   pr_p61>>8,pr_p61&$FF,2,0,254,253,10,0,0        ; image 72
        .byte   pr_p62>>8,pr_p62&$FF,2,0,254,253,10,0,0        ; image 73
        .byte   pr_p63>>8,pr_p63&$FF,0,0,255,248,10,0,0        ; image 74
        .byte   pr_p64>>8,pr_p64&$FF,0,0,255,250,10,0,0        ; image 75
        .byte   pr_p65>>8,pr_p65&$FF,0,0,2,251,10,0,0        ; image 76
        .byte   pr_p66>>8,pr_p66&$FF,0,0,2,251,10,0,0        ; image 77
        .byte   pr_p67>>8,pr_p67&$FF,0,0,2,2,9,0,0        ; image 78
        .byte   pr_p68>>8,pr_p68&$FF,0,0,2,2,8,0,0        ; image 79
        .byte   pr_p69>>8,pr_p69&$FF,0,0,2,2,7,0,0        ; image 79
pj_rp2:
        .byte   pr_p70>>8,pr_p70&$FF,0,0,2,2,7,0,0        ; image 79
        .byte   0,$40,1,pj_rp2>>8,pj_rp2&$FF        ; -> 1 fois de plus
        .byte   pr_p69>>8,pr_p69&$FF,0,0,2,2,7,0,0        ; image 79
        .byte   0,0,0,pj_hangdrop>>8,pj_hangdrop&$FF        ; -> hangdrop
pj_hangdrop:
        .byte   pr_p71>>8,pr_p71&$FF,2,0,3,0,8,0,0        ; image 81
        .byte   pr_p72>>8,pr_p72&$FF,2,0,3,0,9,0,0        ; image 82
        .byte   pr_p73>>8,pr_p73&$FF,2,0,3,0,9,0,0        ; image 83
        .byte   pr_p74>>8,pr_p74&$FF,2,0,3,0,10|$80,0,0        ; image 84
        .byte   pr_p75>>8,pr_p75&$FF,2,0,4,1,10,0,0        ; image 85
        .byte   0,0,3,pj_stand>>8,pj_stand&$FF        ; -> stand
pj_standjump:
        .byte   pr_p76>>8,pr_p76&$FF,2,0,0,253,9,0,0        ; image 16
        .byte   pr_p77>>8,pr_p77&$FF,2,0,0,252,10,0,0        ; image 17
        .byte   pr_p78>>8,pr_p78&$FF,2,2,0,250,10,0,0        ; image 18
        .byte   pr_p79>>8,pr_p79&$FF,2,2,0,248,10,0,0        ; image 19
        .byte   pr_p80>>8,pr_p80&$FF,0,2,0,247,10,0,0        ; image 20
        .byte   pr_p81>>8,pr_p81&$FF,0,2,0,245,10,0,0        ; image 21
        .byte   pr_p82>>8,pr_p82&$FF,0,2,0,245,10,0,0        ; image 22
        .byte   pr_p83>>8,pr_p83&$FF,0,7,0,239,10,0,0        ; image 23
        .byte   pr_p84>>8,pr_p84&$FF,0,9,0,249,10,0,0        ; image 24
        .byte   pr_p85>>8,pr_p85&$FF,0,5,0,251,10,0,0        ; image 25
        .byte   pr_p86>>8,pr_p86&$FF,2,1,0,255,75,0,0        ; image 26
pj_sj26:
        .byte   pr_p87>>8,pr_p87&$FF,2,4,0,250,11|$80,0,0        ; image 27
pj_f13:
        .byte   pr_p88>>8,pr_p88&$FF,2,253,0,253,11,0,0        ; image 28
        .byte   pr_p89>>8,pr_p89&$FF,2,5,0,248,11,0,0        ; image 29
        .byte   pr_p90>>8,pr_p90&$FF,2,0,0,254,10,0,0        ; image 30
pj_f14:
        .byte   pr_p91>>8,pr_p91&$FF,2,0,0,254,10,0,0        ; image 31
        .byte   pr_p92>>8,pr_p92&$FF,2,0,0,254,10,0,0        ; image 32
        .byte   pr_p93>>8,pr_p93&$FF,2,0,0,254,10,0,0        ; image 33
        .byte   0,0,1,pj_stand>>8,pj_stand&$FF        ; -> stand
pj_turn:
        .byte   pr_p94>>8,pr_p94&$FF,3,6,0,253,10,0,0        ; image 45
        .byte   pr_p95>>8,pr_p95&$FF,2,1,0,253,10,0,0        ; image 46
        .byte   pr_p96>>8,pr_p96&$FF,0,2,0,251,10,0,0        ; image 47
        .byte   pr_p97>>8,pr_p97&$FF,0,255,0,252,10,0,0        ; image 48
        .byte   pr_p52>>8,pr_p52&$FF,2,1,0,250,10,0,0        ; image 49
        .byte   pr_p53>>8,pr_p53&$FF,2,254,4,253,10,0,0        ; image 50
        .byte   pr_p54>>8,pr_p54&$FF,2,0,3,253,10,0,0        ; image 51
        .byte   pr_p55>>8,pr_p55&$FF,2,0,1,253,10,0,0        ; image 52
        .byte   0,0,0,pj_stand>>8,pj_stand&$FF        ; -> stand
pj_alertstand:
        .byte   pr_p98>>8,pr_p98&$FF,2,0,0,253,9,0,0        ; image 166
        .byte   0,0,0,pj_alertstand>>8,pj_alertstand&$FF        ; -> alertstand
pj_dropdead:
        .byte   pr_p100>>8,pr_p100&$FF,2,0,0,252,10,0,0        ; image 179
        .byte   pr_p102>>8,pr_p102&$FF,2,0,0,252,10,0,0        ; image 180
        .byte   pr_p104>>8,pr_p104&$FF,2,0,0,252,11,0,0        ; image 181
        .byte   pr_p106>>8,pr_p106&$FF,2,0,0,249,11,0,0        ; image 182
        .byte   pr_p108>>8,pr_p108&$FF,2,1,0,245,13,0,0        ; image 183
        .byte   pr_p110>>8,pr_p110&$FF,66,252,4,251,13,0,0        ; image 185
        .byte   0,0,0,pj_dropdead_dead>>8,pj_dropdead_dead&$FF        ; -> dropdead_dead
pj_dropdead_dead:
        .byte   pr_p110>>8,pr_p110&$FF,66,0,4,251,13,0,0        ; image 185
        .byte   0,0,0,pj_dropdead_dead>>8,pj_dropdead_dead&$FF        ; -> dropdead_dead
pj_stabbed:
        .byte   pr_p112>>8,pr_p112&$FF,2,0,0,250,10,0,0        ; image 172
        .byte   pr_p114>>8,pr_p114&$FF,2,255,0,250,10,0,0        ; image 173
        .byte   pr_p116>>8,pr_p116&$FF,2,255,0,251,10,0,0        ; image 174
        .byte   0,0,248,pj_guy8>>8,pj_guy8&$FF        ; -> guy8
pj_guy8:
        .byte   pr_p118>>8,pr_p118&$FF,0,0,4,4,10,0,0        ; image 156
        .byte   pr_p120>>8,pr_p120&$FF,2,0,7,242,10,0,0        ; image 157
        .byte   0,0,0,pj_ready>>8,pj_ready&$FF        ; -> ready
pj_ready:
        .byte   pr_p122>>8,pr_p122&$FF,2,0,12,243,10,0,0        ; image 158
        .byte   pr_p124>>8,pr_p124&$FF,2,0,12,243,10,0,0        ; image 170
        .byte   pr_p126>>8,pr_p126&$FF,2,0,12,243,10,0,0        ; image 171
        .byte   0,0,0,pj_ready_loop>>8,pj_ready_loop&$FF        ; -> ready_loop
pj_ready_loop:
        .byte   pr_p126>>8,pr_p126&$FF,2,0,12,243,10,0,0        ; image 171
        .byte   0,0,0,pj_ready_loop>>8,pj_ready_loop&$FF        ; -> ready_loop
pj_blockedstrike:
        .byte   pr_p128>>8,pr_p128&$FF,0,0,16,7,10,0,0        ; image 167
        .byte   0,0,0,pj_guy7>>8,pj_guy7&$FF        ; -> guy7
pj_guy7:
        .byte   pr_p130>>8,pr_p130&$FF,0,0,10,7,10,0,0        ; image 155
        .byte   pr_p118>>8,pr_p118&$FF,0,0,4,4,10,0,0        ; image 156
        .byte   pr_p120>>8,pr_p120&$FF,2,0,7,242,10,0,0        ; image 157
        .byte   0,0,0,pj_ready>>8,pj_ready&$FF        ; -> ready
pj_blocktostrike:
        .byte   pr_p132>>8,pr_p132&$FF,0,0,0,0,9,0,3        ; image 162
        .byte   0,0,0,pj_guy4>>8,pj_guy4&$FF        ; -> guy4
pj_guy4:
        .byte   pr_p134>>8,pr_p134&$FF,0,0,3,3,10,0,3        ; image 152
        .byte   pr_p136>>8,pr_p136&$FF,2,0,17,3,10,0,4        ; image 153
        .byte   pr_p138>>8,pr_p138&$FF,0,0,19,10,11,0,1        ; image 154
        .byte   pr_p130>>8,pr_p130&$FF,0,0,10,7,10,0,0        ; image 155
        .byte   pr_p118>>8,pr_p118&$FF,0,0,4,4,10,0,0        ; image 156
        .byte   pr_p120>>8,pr_p120&$FF,2,0,7,242,10,0,0        ; image 157
        .byte   0,0,0,pj_ready>>8,pj_ready&$FF        ; -> ready
pj_readyblock:
        .byte   pr_p140>>8,pr_p140&$FF,0,0,6,0,10,0,0        ; image 169
        .byte   pr_p142>>8,pr_p142&$FF,0,0,6,0,9,0,2        ; image 150
        .byte   0,0,0,pj_ready>>8,pj_ready&$FF        ; -> ready
pj_strike:
        .byte   pr_p144>>8,pr_p144&$FF,0,0,11,1,10,0,0        ; image 168
        .byte   pr_p146>>8,pr_p146&$FF,0,0,3,0,10,0,0        ; image 151
        .byte   pr_p134>>8,pr_p134&$FF,0,0,3,3,10,0,3        ; image 152
        .byte   pr_p136>>8,pr_p136&$FF,2,0,17,3,10,0,4        ; image 153
        .byte   pr_p138>>8,pr_p138&$FF,0,0,19,10,11,0,1        ; image 154
        .byte   pr_p130>>8,pr_p130&$FF,0,0,10,7,10,0,0        ; image 155
        .byte   pr_p118>>8,pr_p118&$FF,0,0,4,4,10,0,0        ; image 156
        .byte   pr_p120>>8,pr_p120&$FF,2,0,7,242,10,0,0        ; image 157
        .byte   0,0,0,pj_ready>>8,pj_ready&$FF        ; -> ready
pj_retreat:
        .byte   pr_p148>>8,pr_p148&$FF,0,253,8,3,10,0,0        ; image 160
        .byte   pr_p120>>8,pr_p120&$FF,2,254,7,242,10,0,0        ; image 157
        .byte   0,0,0,pj_ready>>8,pj_ready&$FF        ; -> ready
pj_advance:
        .byte   pr_p150>>8,pr_p150&$FF,0,2,11,0,10,0,0        ; image 163
        .byte   pr_p152>>8,pr_p152&$FF,0,4,8,0,10,0,0        ; image 164
        .byte   pr_p154>>8,pr_p154&$FF,2,0,11,255,10,0,0        ; image 165
        .byte   0,0,0,pj_ready>>8,pj_ready&$FF        ; -> ready
pj_engarde:
        .byte   pr_p156>>8,pr_p156&$FF,2,2,0,250,10,0,0        ; image 207
        .byte   pr_p157>>8,pr_p157&$FF,2,0,0,250,10,0,0        ; image 208
        .byte   pr_p158>>8,pr_p158&$FF,2,2,0,248,10,0,0        ; image 209
        .byte   pr_p159>>8,pr_p159&$FF,2,2,0,246,9,0,0        ; image 210
        .byte   pr_p122>>8,pr_p122&$FF,2,3,12,243,10,0,0        ; image 158
        .byte   pr_p124>>8,pr_p124&$FF,2,0,12,243,10,0,0        ; image 170
        .byte   pr_p126>>8,pr_p126&$FF,2,0,12,243,10,0,0        ; image 171
        .byte   0,0,0,pj_ready_loop>>8,pj_ready_loop&$FF        ; -> ready_loop
pj_pickupsword:
pj_rp3:
        .byte   pr_p160>>8,pr_p160&$FF,2,0,4,254,9,0,0        ; image 229
        .byte   0,$40,5,pj_rp3>>8,pj_rp3&$FF        ; -> 5 fois de plus
pj_rp4:
        .byte   pr_p161>>8,pr_p161&$FF,2,0,6,247,9,0,0        ; image 230
        .byte   0,$40,1,pj_rp4>>8,pj_rp4&$FF        ; -> 1 fois de plus
        .byte   pr_p162>>8,pr_p162&$FF,2,0,6,247,9,0,0        ; image 232
        .byte   0,0,0,pj_resheathe>>8,pj_resheathe&$FF        ; -> resheathe
pj_resheathe:
        .byte   pr_p163>>8,pr_p163&$FF,2,251,12,253,10,0,0        ; image 233
        .byte   pr_p163>>8,pr_p163&$FF,2,0,12,253,10,0,0        ; image 233
pj_rp5:
        .byte   pr_p164>>8,pr_p164&$FF,2,0,10,254,10,0,0        ; image 235
        .byte   0,$40,1,pj_rp5>>8,pj_rp5&$FF        ; -> 1 fois de plus
pj_rp6:
        .byte   pr_p165>>8,pr_p165&$FF,2,0,4,254,10,0,0        ; image 237
        .byte   0,$40,1,pj_rp6>>8,pj_rp6&$FF        ; -> 1 fois de plus
pj_rp7:
        .byte   pr_p166>>8,pr_p166&$FF,2,0,1,254,10,0,0        ; image 239
        .byte   0,$40,1,pj_rp7>>8,pj_rp7&$FF        ; -> 1 fois de plus
pj_rp8:
        .byte   pr_p167>>8,pr_p167&$FF,2,0,0,255,10,0,0        ; image 133
        .byte   0,$40,1,pj_rp8>>8,pj_rp8&$FF        ; -> 1 fois de plus
pj_rp9:
        .byte   pr_p168>>8,pr_p168&$FF,2,0,0,249,10,0,0        ; image 134
        .byte   0,$40,3,pj_rp9>>8,pj_rp9&$FF        ; -> 3 fois de plus
        .byte   pr_p52>>8,pr_p52&$FF,2,1,0,250,10,0,0        ; image 49
        .byte   pr_p52>>8,pr_p52&$FF,2,254,0,250,10,0,0        ; image 49
pj_rp10:
        .byte   pr_p54>>8,pr_p54&$FF,2,0,3,253,10,0,0        ; image 51
        .byte   0,$40,1,pj_rp10>>8,pj_rp10&$FF        ; -> 1 fois de plus
        .byte   0,0,0,pj_stand>>8,pj_stand&$FF        ; -> stand
pj_drinkpotion:
        .byte   pr_p169>>8,pr_p169&$FF,0,4,0,0,12,0,0        ; image 191
        .byte   pr_p169>>8,pr_p169&$FF,0,0,0,0,12,0,0        ; image 191
pj_rp11:
        .byte   pr_p170>>8,pr_p170&$FF,0,0,0,0,11,0,0        ; image 193
        .byte   0,$40,1,pj_rp11>>8,pj_rp11&$FF        ; -> 1 fois de plus
pj_rp12:
        .byte   pr_p171>>8,pr_p171&$FF,0,0,255,255,10,0,0        ; image 195
        .byte   0,$40,1,pj_rp12>>8,pj_rp12&$FF        ; -> 1 fois de plus
pj_rp13:
        .byte   pr_p172>>8,pr_p172&$FF,0,0,255,255,9,0,0        ; image 197
        .byte   0,$40,1,pj_rp13>>8,pj_rp13&$FF        ; -> 1 fois de plus
pj_rp14:
        .byte   pr_p173>>8,pr_p173&$FF,0,0,252,252,9,0,0        ; image 199
        .byte   0,$40,1,pj_rp14>>8,pj_rp14&$FF        ; -> 1 fois de plus
pj_rp15:
        .byte   pr_p174>>8,pr_p174&$FF,0,0,252,252,9,0,0        ; image 201
        .byte   0,$40,1,pj_rp15>>8,pj_rp15&$FF        ; -> 1 fois de plus
pj_rp16:
        .byte   pr_p175>>8,pr_p175&$FF,0,0,252,252,9,0,0        ; image 203
        .byte   0,$40,1,pj_rp16>>8,pj_rp16&$FF        ; -> 1 fois de plus
pj_rp17:
        .byte   pr_p176>>8,pr_p176&$FF,0,0,251,251,9,0,0        ; image 205
        .byte   0,$40,5,pj_rp17>>8,pj_rp17&$FF        ; -> 5 fois de plus
        .byte   pr_p177>>8,pr_p177&$FF,0,0,252,252,9,0,0        ; image 198
        .byte   0,0,252,pj_stand>>8,pj_stand&$FF        ; -> stand
pj_impale:
        .byte   pr_p178>>8,pr_p178&$FF,64,4,0,246,11|$80,0,0        ; image 177
        .byte   pr_p178>>8,pr_p178&$FF,64,0,0,246,11,0,0        ; image 177
        .byte   0,0,0,pj_impale_dead>>8,pj_impale_dead&$FF        ; -> impale_dead
pj_impale_dead:
        .byte   pr_p178>>8,pr_p178&$FF,64,0,0,246,11,0,0        ; image 177
        .byte   0,0,0,pj_impale_dead>>8,pj_impale_dead&$FF        ; -> impale_dead
pj_testfoot:
        .byte   pr_p180>>8,pr_p180&$FF,130,0,0,253,10,0,0        ; image 121
        .byte   pr_p181>>8,pr_p181&$FF,130,1,0,252,10,0,0        ; image 122
        .byte   pr_p182>>8,pr_p182&$FF,130,0,0,251,10,0,0        ; image 123
        .byte   pr_p183>>8,pr_p183&$FF,130,2,0,248,10,0,0        ; image 124
        .byte   pr_p184>>8,pr_p184&$FF,130,4,0,244,10,0,0        ; image 125
        .byte   pr_p185>>8,pr_p185&$FF,130,3,0,241,10,0,0        ; image 126
        .byte   pr_p186>>8,pr_p186&$FF,128,252,0,0,11,0,0        ; image 86
        .byte   pr_p24>>8,pr_p24&$FF,130,252,0,251,10|$80,0,0        ; image 116
pj_f15:
        .byte   pr_p25>>8,pr_p25&$FF,130,254,2,253,10,0,0        ; image 117
        .byte   pr_p26>>8,pr_p26&$FF,130,0,2,253,10,0,0        ; image 118
        .byte   pr_p27>>8,pr_p27&$FF,130,0,0,253,10,0,0        ; image 119
        .byte   0,0,0,pj_stand>>8,pj_stand&$FF        ; -> stand
pj_climbdown:
        .byte   pr_p187>>8,pr_p187&$FF,34,0,5,252,10,0,0        ; image 148
        .byte   pr_p188>>8,pr_p188&$FF,34,0,5,252,11,0,0        ; image 145
        .byte   pr_p189>>8,pr_p189&$FF,34,0,4,252,12,0,0        ; image 144
        .byte   pr_p190>>8,pr_p190&$FF,34,0,4,251,12,0,0        ; image 143
        .byte   pr_p191>>8,pr_p191&$FF,34,0,4,0,12,0,0        ; image 142
        .byte   pr_p192>>8,pr_p192&$FF,34,0,2,0,12,0,0        ; image 141
        .byte   pr_p193>>8,pr_p193&$FF,40,251,7,5,6,0,0        ; image 140
        .byte   pr_p194>>8,pr_p194&$FF,32,0,4,4,6,0,0        ; image 138
        .byte   pr_p195>>8,pr_p195&$FF,32,0,0,0,7,0,0        ; image 136
        .byte   pr_p196>>8,pr_p196&$FF,32,0,2,2,7,0,0        ; image 91
        .byte   0,32,0,pj_hang1>>8,pj_hang1&$FF        ; -> hang1
pj_hang1:
        .byte   pr_p197>>8,pr_p197&$FF,32,0,3,3,7,pj_rhang>>8,pj_rhang&$FF        ; image 90
        .byte   pr_p198>>8,pr_p198&$FF,32,0,4,4,7,pj_rhang>>8,pj_rhang&$FF        ; image 89
        .byte   pr_p199>>8,pr_p199&$FF,32,0,7,7,7,pj_rhang>>8,pj_rhang&$FF        ; image 88
pj_rp18:
        .byte   pr_p200>>8,pr_p200&$FF,32,0,7,7,7,pj_rhang>>8,pj_rhang&$FF        ; image 87
        .byte   0,$40,2,pj_rp18>>8,pj_rp18&$FF        ; -> 2 fois de plus
        .byte   pr_p199>>8,pr_p199&$FF,32,0,7,7,7,pj_rhang>>8,pj_rhang&$FF        ; image 88
        .byte   pr_p198>>8,pr_p198&$FF,32,0,4,4,7,pj_rhang>>8,pj_rhang&$FF        ; image 89
        .byte   pr_p197>>8,pr_p197&$FF,32,0,3,3,7,pj_rhang>>8,pj_rhang&$FF        ; image 90
        .byte   pr_p196>>8,pr_p196&$FF,32,0,2,2,7,pj_rhang>>8,pj_rhang&$FF        ; image 91
        .byte   pr_p201>>8,pr_p201&$FF,32,0,1,1,7,pj_rhang>>8,pj_rhang&$FF        ; image 92
        .byte   pr_p202>>8,pr_p202&$FF,32,0,0,0,7,pj_rhang>>8,pj_rhang&$FF        ; image 93
        .byte   pr_p203>>8,pr_p203&$FF,32,0,255,255,7,pj_rhang>>8,pj_rhang&$FF        ; image 94
        .byte   pr_p204>>8,pr_p204&$FF,32,0,255,255,7,pj_rhang>>8,pj_rhang&$FF        ; image 95
        .byte   pr_p205>>8,pr_p205&$FF,32,0,255,255,7,pj_rhang>>8,pj_rhang&$FF        ; image 96
        .byte   pr_p206>>8,pr_p206&$FF,32,0,255,255,7,pj_rhang>>8,pj_rhang&$FF        ; image 97
        .byte   pr_p207>>8,pr_p207&$FF,32,0,255,255,7,pj_rhang>>8,pj_rhang&$FF        ; image 98
        .byte   pr_p208>>8,pr_p208&$FF,32,0,0,0,7,pj_rhang>>8,pj_rhang&$FF        ; image 99
        .byte   pr_p206>>8,pr_p206&$FF,32,0,255,255,7,pj_rhang>>8,pj_rhang&$FF        ; image 97
        .byte   pr_p205>>8,pr_p205&$FF,32,0,255,255,7,pj_rhang>>8,pj_rhang&$FF        ; image 96
        .byte   pr_p204>>8,pr_p204&$FF,32,0,255,255,7,pj_rhang>>8,pj_rhang&$FF        ; image 95
        .byte   pr_p203>>8,pr_p203&$FF,32,0,255,255,7,pj_rhang>>8,pj_rhang&$FF        ; image 94
        .byte   pr_p202>>8,pr_p202&$FF,32,0,0,0,7,pj_rhang>>8,pj_rhang&$FF        ; image 93
        .byte   pr_p201>>8,pr_p201&$FF,32,0,1,1,7,pj_rhang>>8,pj_rhang&$FF        ; image 92
        .byte   pr_p196>>8,pr_p196&$FF,32,0,2,2,7,pj_rhang>>8,pj_rhang&$FF        ; image 91
        .byte   pr_p197>>8,pr_p197&$FF,32,0,3,3,7,pj_rhang>>8,pj_rhang&$FF        ; image 90
        .byte   pr_p198>>8,pr_p198&$FF,32,0,4,4,7,pj_rhang>>8,pj_rhang&$FF        ; image 89
        .byte   pr_p199>>8,pr_p199&$FF,32,0,7,7,7,pj_rhang>>8,pj_rhang&$FF        ; image 88
        .byte   pr_p200>>8,pr_p200&$FF,32,0,7,7,7,pj_rhang>>8,pj_rhang&$FF        ; image 87
        .byte   pr_p199>>8,pr_p199&$FF,32,0,7,7,7,pj_rhang>>8,pj_rhang&$FF        ; image 88
        .byte   pr_p198>>8,pr_p198&$FF,32,0,4,4,7,pj_rhang>>8,pj_rhang&$FF        ; image 89
        .byte   pr_p197>>8,pr_p197&$FF,32,0,3,3,7,pj_rhang>>8,pj_rhang&$FF        ; image 90
        .byte   pr_p196>>8,pr_p196&$FF,32,0,2,2,7,pj_rhang>>8,pj_rhang&$FF        ; image 91
        .byte   pr_p201>>8,pr_p201&$FF,32,0,1,1,7,pj_rhang>>8,pj_rhang&$FF        ; image 92
        .byte   pr_p202>>8,pr_p202&$FF,32,0,0,0,7,pj_rhang>>8,pj_rhang&$FF        ; image 93
        .byte   pr_p203>>8,pr_p203&$FF,32,0,255,255,7,pj_rhang>>8,pj_rhang&$FF        ; image 94
        .byte   pr_p204>>8,pr_p204&$FF,32,0,255,255,7,pj_rhang>>8,pj_rhang&$FF        ; image 95
        .byte   pr_p205>>8,pr_p205&$FF,32,0,255,255,7,pj_rhang>>8,pj_rhang&$FF        ; image 96
        .byte   pr_p204>>8,pr_p204&$FF,32,0,255,255,7,pj_rhang>>8,pj_rhang&$FF        ; image 95
        .byte   pr_p203>>8,pr_p203&$FF,32,0,255,255,7,pj_rhang>>8,pj_rhang&$FF        ; image 94
        .byte   pr_p202>>8,pr_p202&$FF,32,0,0,0,7,pj_rhang>>8,pj_rhang&$FF        ; image 93
        .byte   pr_p201>>8,pr_p201&$FF,32,0,1,1,7,pj_rhang>>8,pj_rhang&$FF        ; image 92
        .byte   0,32,0,pj_hangdrop>>8,pj_hangdrop&$FF        ; -> hangdrop
pj_climbup:
        .byte   pr_p209>>8,pr_p209&$FF,32,0,0,255,7,0,0        ; image 135
        .byte   pr_p195>>8,pr_p195&$FF,32,0,0,0,7,0,0        ; image 136
        .byte   pr_p210>>8,pr_p210&$FF,32,0,1,1,7,0,0        ; image 137
        .byte   pr_p194>>8,pr_p194&$FF,32,0,4,4,6,0,0        ; image 138
        .byte   pr_p211>>8,pr_p211&$FF,32,0,6,5,6,0,0        ; image 139
        .byte   pr_p193>>8,pr_p193&$FF,32,0,7,5,6,0,0        ; image 140
        .byte   pr_p192>>8,pr_p192&$FF,38,5,2,0,12,0,0        ; image 141
        .byte   pr_p191>>8,pr_p191&$FF,34,0,4,0,12,0,0        ; image 142
        .byte   pr_p190>>8,pr_p190&$FF,34,0,4,251,12,0,0        ; image 143
        .byte   pr_p189>>8,pr_p189&$FF,34,0,4,252,12,0,0        ; image 144
        .byte   pr_p188>>8,pr_p188&$FF,34,0,5,252,11,0,0        ; image 145
        .byte   pr_p212>>8,pr_p212&$FF,34,0,5,252,11,0,0        ; image 146
        .byte   pr_p213>>8,pr_p213&$FF,34,0,5,253,11,0,0        ; image 147
        .byte   pr_p187>>8,pr_p187&$FF,34,0,5,252,10,0,0        ; image 148
        .byte   pr_p214>>8,pr_p214&$FF,34,0,5,252,10,0,0        ; image 149
        .byte   pr_p26>>8,pr_p26&$FF,34,0,2,253,10,0,0        ; image 118
        .byte   pr_p27>>8,pr_p27&$FF,34,0,0,253,10,0,0        ; image 119
        .byte   0,32,1,pj_stand>>8,pj_stand&$FF        ; -> stand
pj_rjumpfall:
        .byte   pr_p215>>8,pr_p215&$FF,2,1,0,250,10,0,0        ; image 102
        .byte   pr_p216>>8,pr_p216&$FF,2,3,0,250,11,0,0        ; image 103
        .byte   pr_p217>>8,pr_p217&$FF,2,2,0,251,12,0,0        ; image 104
        .byte   pr_p218>>8,pr_p218&$FF,2,3,0,251,13,0,0        ; image 105
        .byte   0,0,0,pj_freefall_p30>>8,pj_freefall_p30&$FF        ; -> freefall
pj_freefall_p30:
        .byte   pr_p219>>8,pr_p219&$FF,18,0,0,254,13,0,0        ; image 106
        .byte   0,0,0,pj_freefall_loop_p30>>8,pj_freefall_loop_p30&$FF        ; -> freefall_loop
pj_freefall_loop_p30:
        .byte   pr_p219>>8,pr_p219&$FF,18,0,0,254,13,0,0        ; image 106
        .byte   0,0,0,pj_freefall_loop_p30>>8,pj_freefall_loop_p30&$FF        ; -> freefall_loop
pj_jumpfall:
        .byte   pr_p215>>8,pr_p215&$FF,2,1,0,250,10,0,0        ; image 102
        .byte   pr_p216>>8,pr_p216&$FF,2,2,0,250,11,0,0        ; image 103
        .byte   pr_p217>>8,pr_p217&$FF,2,1,0,251,12,0,0        ; image 104
        .byte   pr_p218>>8,pr_p218&$FF,2,2,0,251,13,0,0        ; image 105
        .byte   0,0,0,pj_freefall_p30>>8,pj_freefall_p30&$FF        ; -> freefall
pj_fallhang:
        .byte   pr_p220>>8,pr_p220&$FF,32,0,2,2,7,0,0        ; image 80
        .byte   0,32,0,pj_hang1>>8,pj_hang1&$FF        ; -> hang
pj_jumpup:
        .byte   pr_p56>>8,pr_p56&$FF,2,0,254,253,42,0,0        ; image 67
        .byte   pr_p57>>8,pr_p57&$FF,2,0,254,253,42,0,0        ; image 68
        .byte   pr_p58>>8,pr_p58&$FF,2,0,255,253,42,0,0        ; image 69
        .byte   pr_p59>>8,pr_p59&$FF,2,0,254,252,42,0,0        ; image 70
        .byte   pr_p60>>8,pr_p60&$FF,2,0,254,253,42,0,0        ; image 71
        .byte   pr_p61>>8,pr_p61&$FF,2,0,254,253,42,0,0        ; image 72
        .byte   pr_p62>>8,pr_p62&$FF,2,0,254,253,42,0,0        ; image 73
        .byte   pr_p63>>8,pr_p63&$FF,0,0,255,248,42,0,0        ; image 74
        .byte   pr_p64>>8,pr_p64&$FF,0,0,255,250,42,0,0        ; image 75
        .byte   pr_p65>>8,pr_p65&$FF,0,0,2,251,42,0,0        ; image 76
        .byte   pr_p66>>8,pr_p66&$FF,0,0,2,251,42,0,0        ; image 77
        .byte   pr_p67>>8,pr_p67&$FF,0,0,2,2,41,0,0        ; image 78
        .byte   pr_p68>>8,pr_p68&$FF,0,0,2,2,40,0,0        ; image 79
pj_kup:
        .byte   0,0,0,pj_hangdrop_c>>8,pj_hangdrop_c&$FF        ; -> hangdrop
pj_hangdrop_c:
        .byte   pr_p71>>8,pr_p71&$FF,2,0,3,0,40,0,0        ; image 81
        .byte   pr_p72>>8,pr_p72&$FF,2,0,3,0,41,0,0        ; image 82
        .byte   pr_p73>>8,pr_p73&$FF,2,0,3,0,41,0,0        ; image 83
        .byte   pr_p74>>8,pr_p74&$FF,2,0,3,0,42|$80,0,0        ; image 84
        .byte   pr_p75>>8,pr_p75&$FF,2,0,4,1,42,0,0        ; image 85
        .byte   0,0,3,pj_stand>>8,pj_stand&$FF        ; -> stand
pj_step11:
        .byte   pr_p180>>8,pr_p180&$FF,130,0,0,253,10,0,0        ; image 121
        .byte   pr_p181>>8,pr_p181&$FF,130,1,0,252,10,0,0        ; image 122
        .byte   pr_p182>>8,pr_p182&$FF,130,1,0,251,10,0,0        ; image 123
        .byte   pr_p183>>8,pr_p183&$FF,130,3,0,248,10,0,0        ; image 124
        .byte   pr_p184>>8,pr_p184&$FF,130,4,0,244,10,0,0        ; image 125
        .byte   pr_p185>>8,pr_p185&$FF,130,3,0,241,10,0,0        ; image 126
        .byte   pr_p221>>8,pr_p221&$FF,130,255,0,253,10,0,0        ; image 127
        .byte   pr_p222>>8,pr_p222&$FF,130,0,0,253,10,0,0        ; image 128
        .byte   pr_p223>>8,pr_p223&$FF,130,0,0,253,10,0,0        ; image 129
        .byte   pr_p224>>8,pr_p224&$FF,130,0,0,253,10,0,0        ; image 130
        .byte   pr_p225>>8,pr_p225&$FF,130,0,0,252,10,0,0        ; image 131
        .byte   pr_p226>>8,pr_p226&$FF,130,0,0,252,9,0,0        ; image 132
        .byte   0,0,0,pj_stand>>8,pj_stand&$FF        ; -> stand
pj_jumphangMed:
        .byte   pr_p56>>8,pr_p56&$FF,34,0,254,253,10,0,0        ; image 67
        .byte   pr_p57>>8,pr_p57&$FF,34,0,254,253,10,0,0        ; image 68
        .byte   pr_p58>>8,pr_p58&$FF,34,0,255,253,10,0,0        ; image 69
        .byte   pr_p59>>8,pr_p59&$FF,34,0,254,252,10,0,0        ; image 70
        .byte   pr_p60>>8,pr_p60&$FF,34,0,254,253,10,0,0        ; image 71
        .byte   pr_p61>>8,pr_p61&$FF,34,0,254,253,10,0,0        ; image 72
        .byte   pr_p62>>8,pr_p62&$FF,34,0,254,253,10,0,0        ; image 73
        .byte   pr_p63>>8,pr_p63&$FF,32,0,255,248,10,0,0        ; image 74
        .byte   pr_p64>>8,pr_p64&$FF,32,0,255,250,10,0,0        ; image 75
        .byte   pr_p65>>8,pr_p65&$FF,32,0,2,251,10,0,0        ; image 76
        .byte   pr_p66>>8,pr_p66&$FF,32,0,2,251,10,0,0        ; image 77
        .byte   pr_p67>>8,pr_p67&$FF,32,0,2,2,9,0,0        ; image 78
        .byte   pr_p68>>8,pr_p68&$FF,32,0,2,2,8,0,0        ; image 79
        .byte   pr_p220>>8,pr_p220&$FF,32,0,2,2,7,0,0        ; image 80
        .byte   0,32,0,pj_hang1>>8,pj_hang1&$FF        ; -> hang
pj_jumphangLong:
        .byte   pr_p56>>8,pr_p56&$FF,34,0,254,253,10,0,0        ; image 67
        .byte   pr_p57>>8,pr_p57&$FF,34,0,254,253,10,0,0        ; image 68
        .byte   pr_p58>>8,pr_p58&$FF,34,0,255,253,10,0,0        ; image 69
        .byte   pr_p59>>8,pr_p59&$FF,34,0,254,252,10,0,0        ; image 70
        .byte   pr_p60>>8,pr_p60&$FF,34,0,254,253,10,0,0        ; image 71
        .byte   pr_p61>>8,pr_p61&$FF,34,0,254,253,10,0,0        ; image 72
        .byte   pr_p62>>8,pr_p62&$FF,34,0,254,253,10,0,0        ; image 73
        .byte   pr_p63>>8,pr_p63&$FF,32,0,255,248,10,0,0        ; image 74
        .byte   pr_p64>>8,pr_p64&$FF,32,0,255,250,10,0,0        ; image 75
        .byte   pr_p65>>8,pr_p65&$FF,32,0,2,251,10,0,0        ; image 76
        .byte   pr_p66>>8,pr_p66&$FF,32,0,2,251,10,0,0        ; image 77
        .byte   pr_p67>>8,pr_p67&$FF,32,1,2,2,9,0,0        ; image 78
        .byte   pr_p68>>8,pr_p68&$FF,32,2,2,2,8,0,0        ; image 79
        .byte   pr_p220>>8,pr_p220&$FF,32,1,2,2,7,0,0        ; image 80
        .byte   0,32,0,pj_hang1>>8,pj_hang1&$FF        ; -> hang
pj_hardland:
        .byte   pr_p227>>8,pr_p227&$FF,66,3,4,251,12|$80,0,0        ; image 185
        .byte   pr_p227>>8,pr_p227&$FF,66,0,4,251,12,0,0        ; image 185
        .byte   0,0,0,pj_hardland_dead_m2>>8,pj_hardland_dead_m2&$FF        ; -> hardland_dead
pj_hardland_dead_m2:
        .byte   pr_p227>>8,pr_p227&$FF,66,0,4,251,12,0,0        ; image 185
        .byte   0,0,0,pj_hardland_dead_m2>>8,pj_hardland_dead_m2&$FF        ; -> hardland_dead
pj_medland:
        .byte   pr_p229>>8,pr_p229&$FF,2,3,0,251,11|$80,0,0        ; image 108
pj_rp19:
        .byte   pr_p230>>8,pr_p230&$FF,2,0,0,250,11,pj_r109>>8,pj_r109&$FF        ; image 109
        .byte   0,$40,28,pj_rp19>>8,pj_rp19&$FF        ; -> 28 fois de plus
        .byte   pr_p231>>8,pr_p231&$FF,2,1,0,249,11,0,0        ; image 110
pj_rp20:
        .byte   pr_p231>>8,pr_p231&$FF,2,0,0,249,11,0,0        ; image 110
        .byte   0,$40,1,pj_rp20>>8,pj_rp20&$FF        ; -> 1 fois de plus
        .byte   pr_p232>>8,pr_p232&$FF,2,0,0,249,11,0,0        ; image 111
        .byte   pr_p233>>8,pr_p233&$FF,2,2,0,247,11,0,0        ; image 112
        .byte   pr_p234>>8,pr_p234&$FF,2,0,0,248,11,0,0        ; image 113
        .byte   pr_p235>>8,pr_p235&$FF,2,1,0,247,11,0,0        ; image 114
        .byte   pr_p23>>8,pr_p23&$FF,2,0,0,247,11,0,0        ; image 115
        .byte   pr_p24>>8,pr_p24&$FF,2,0,0,251,10,0,0        ; image 116
        .byte   pr_p25>>8,pr_p25&$FF,2,252,2,253,10,0,0        ; image 117
        .byte   pr_p26>>8,pr_p26&$FF,2,0,2,253,10,0,0        ; image 118
        .byte   pr_p27>>8,pr_p27&$FF,2,0,0,253,10,0,0        ; image 119
        .byte   0,0,0,pj_stand>>8,pj_stand&$FF        ; -> stand
pj_softland:
        .byte   pr_p15>>8,pr_p15&$FF,2,1,0,252,11|$80,0,0        ; image 107
        .byte   pr_p16>>8,pr_p16&$FF,2,2,0,251,11,0,0        ; image 108
        .byte   pr_p17>>8,pr_p17&$FF,2,0,0,250,12,pj_r109>>8,pj_r109&$FF        ; image 109
        .byte   0,0,0,pj_softland_crouch>>8,pj_softland_crouch&$FF        ; -> softland_crouch
pj_softland_crouch:
        .byte   pr_p17>>8,pr_p17&$FF,2,0,0,250,12,pj_r109>>8,pj_r109&$FF        ; image 109
        .byte   0,0,0,pj_softland_crouch>>8,pj_softland_crouch&$FF        ; -> softland_crouch
pj_stepfall:
        .byte   pr_p215>>8,pr_p215&$FF,2,1,0,250,10,0,0        ; image 102
        .byte   pr_p216>>8,pr_p216&$FF,2,2,0,250,11,0,0        ; image 103
        .byte   pr_p217>>8,pr_p217&$FF,2,255,0,251,12,0,0        ; image 104
        .byte   pr_p218>>8,pr_p218&$FF,2,0,0,251,13,0,0        ; image 105
        .byte   0,0,254,pj_freefall_p30>>8,pj_freefall_p30&$FF        ; -> freefall
; bruits de pas (snd(SND_FOOTSTEP) du jeu) : les pas apres lesquels le moteur fait "toc" ; 0 = fin
; la flamme des torches : 9 images de 18 lignes (gauche, droite), data/PRINCE res151-159
pj_fln: .byte   9
pj_flam:
        .byte   $02,$00,$03,$00,$07,$00,$06,$00,$02,$40,$00,$40
        .byte   $08,$C0,$1D,$E0,$1F,$E0,$0F,$E0,$07,$E0,$03,$E0
        .byte   $03,$E0,$07,$C0,$07,$C0,$07,$80,$03,$80,$03,$80
        .byte   $00,$00,$06,$00,$07,$00,$03,$60,$07,$E0,$0F,$C0
        .byte   $0F,$C0,$0F,$80,$07,$A0,$07,$E0,$07,$E0,$0F,$E0
        .byte   $0F,$C0,$07,$C0,$03,$C0,$03,$80,$03,$80,$03,$80
        .byte   $00,$00,$0C,$00,$1E,$00,$0E,$00,$04,$00,$00,$C0
        .byte   $01,$C0,$01,$80,$07,$80,$0F,$C0,$0F,$C0,$0F,$E0
        .byte   $07,$E0,$07,$E0,$07,$C0,$03,$C0,$03,$80,$03,$80
        .byte   $01,$00,$03,$C0,$03,$80,$07,$80,$07,$E0,$07,$C0
        .byte   $03,$80,$03,$80,$07,$C0,$0F,$E0,$0F,$E0,$0F,$C0
        .byte   $07,$C0,$07,$C0,$07,$E0,$03,$E0,$03,$C0,$03,$80
        .byte   $00,$00,$04,$60,$06,$C0,$02,$00,$00,$80,$00,$C0
        .byte   $01,$E0,$01,$E0,$03,$C0,$07,$C0,$07,$E0,$07,$C0
        .byte   $07,$80,$03,$80,$03,$C0,$03,$C0,$03,$C0,$03,$80
        .byte   $01,$00,$03,$00,$07,$C0,$07,$E0,$03,$E0,$01,$C0
        .byte   $01,$C0,$03,$C0,$03,$E0,$07,$E0,$07,$E0,$07,$C0
        .byte   $07,$C0,$03,$80,$03,$80,$03,$80,$03,$80,$03,$80
        .byte   $00,$00,$00,$40,$00,$C0,$00,$E0,$04,$E0,$06,$60
        .byte   $07,$40,$0F,$C0,$0F,$C0,$0F,$E0,$0F,$E0,$0F,$C0
        .byte   $07,$80,$07,$80,$07,$C0,$03,$C0,$03,$80,$03,$80
        .byte   $00,$00,$00,$00,$00,$00,$00,$00,$0E,$00,$07,$60
        .byte   $07,$F0,$03,$F0,$03,$F0,$07,$E0,$07,$E0,$07,$E0
        .byte   $07,$E0,$07,$E0,$03,$C0,$03,$C0,$03,$C0,$03,$80
        .byte   $00,$00,$00,$40,$06,$E0,$0F,$E0,$0F,$E0,$07,$C0
        .byte   $07,$80,$0F,$E0,$0F,$E0,$07,$C0,$03,$80,$03,$80
        .byte   $03,$C0,$03,$C0,$07,$C0,$07,$80,$03,$80,$03,$80
; les bulles des potions : 7 images d'un caractere (le haut d'abord), data/PRINCE res166-172
pj_bln: .byte   7
pj_bul:
        .byte   $00,$00,$02,$00,$04,$00,$08,$00,$00,$10
        .byte   $00,$00,$00,$04,$00,$10,$00,$00,$10,$00
        .byte   $00,$00,$02,$00,$10,$00,$00,$10,$00,$10
        .byte   $00,$02,$00,$20,$00,$00,$04,$00,$08,$00
        .byte   $00,$00,$20,$00,$00,$04,$00,$10,$00,$08
        .byte   $00,$00,$00,$00,$04,$00,$08,$00,$10,$00
        .byte   $00,$00,$00,$04,$00,$04,$00,$08,$00,$00
pj_fst:
        .byte   pj_f1>>8,pj_f1&$FF
        .byte   pj_f2>>8,pj_f2&$FF
        .byte   pj_f3>>8,pj_f3&$FF
        .byte   pj_f4>>8,pj_f4&$FF
        .byte   pj_f5>>8,pj_f5&$FF
        .byte   pj_f6>>8,pj_f6&$FF
        .byte   pj_f7>>8,pj_f7&$FF
        .byte   pj_f8>>8,pj_f8&$FF
        .byte   pj_f9>>8,pj_f9&$FF
        .byte   pj_f10>>8,pj_f10&$FF
        .byte   pj_f11>>8,pj_f11&$FF
        .byte   pj_f12>>8,pj_f12&$FF
        .byte   pj_f13>>8,pj_f13&$FF
        .byte   pj_f14>>8,pj_f14&$FF
        .byte   pj_f15>>8,pj_f15&$FF
        .byte   0
; regles : masque, valeur, sequence (fort, faible) ; $FF = fin
; bits : 0 haut, 1 bas, 2 arriere, 3 avant, 4 feu, 5 touche B
pj_rhang:                               ; pendu : le moteur decide (haut, feu, ou rien)
        .byte   $FF
pj_r7:
        .byte   $04,$04,pj_runturn>>8,pj_runturn&$FF        ; arriere -> runturn
        .byte   $01,$01,pj_runjump>>8,pj_runjump&$FF        ; haut -> runjump
        .byte   $02,$02,pj_rdiveroll>>8,pj_rdiveroll&$FF        ; bas -> rdiveroll
        .byte   $08,$00,pj_runstop>>8,pj_runstop&$FF        ; !avant -> runstop
        .byte   $FF
pj_r8:
        .byte   $04,$04,pj_runturn>>8,pj_runturn&$FF        ; arriere -> runturn
        .byte   $01,$01,pj_runjump>>8,pj_runjump&$FF        ; haut -> runjump
        .byte   $02,$02,pj_rdiveroll>>8,pj_rdiveroll&$FF        ; bas -> rdiveroll
        .byte   $FF
pj_r9:
        .byte   $04,$04,pj_runturn>>8,pj_runturn&$FF        ; arriere -> runturn
        .byte   $01,$01,pj_runjump>>8,pj_runjump&$FF        ; haut -> runjump
        .byte   $02,$02,pj_rdiveroll>>8,pj_rdiveroll&$FF        ; bas -> rdiveroll
        .byte   $FF
pj_r10:
        .byte   $04,$04,pj_runturn>>8,pj_runturn&$FF        ; arriere -> runturn
        .byte   $01,$01,pj_runjump>>8,pj_runjump&$FF        ; haut -> runjump
        .byte   $02,$02,pj_rdiveroll>>8,pj_rdiveroll&$FF        ; bas -> rdiveroll
        .byte   $FF
pj_r11:
        .byte   $04,$04,pj_runturn>>8,pj_runturn&$FF        ; arriere -> runturn
        .byte   $01,$01,pj_runjump>>8,pj_runjump&$FF        ; haut -> runjump
        .byte   $02,$02,pj_rdiveroll>>8,pj_rdiveroll&$FF        ; bas -> rdiveroll
        .byte   $08,$00,pj_runstop>>8,pj_runstop&$FF        ; !avant -> runstop
        .byte   $FF
pj_r12:
        .byte   $04,$04,pj_runturn>>8,pj_runturn&$FF        ; arriere -> runturn
        .byte   $01,$01,pj_runjump>>8,pj_runjump&$FF        ; haut -> runjump
        .byte   $02,$02,pj_rdiveroll>>8,pj_rdiveroll&$FF        ; bas -> rdiveroll
        .byte   $FF
pj_r13:
        .byte   $04,$04,pj_runturn>>8,pj_runturn&$FF        ; arriere -> runturn
        .byte   $01,$01,pj_runjump>>8,pj_runjump&$FF        ; haut -> runjump
        .byte   $02,$02,pj_rdiveroll>>8,pj_rdiveroll&$FF        ; bas -> rdiveroll
        .byte   $FF
pj_r14:
        .byte   $04,$04,pj_runturn>>8,pj_runturn&$FF        ; arriere -> runturn
        .byte   $01,$01,pj_runjump>>8,pj_runjump&$FF        ; haut -> runjump
        .byte   $02,$02,pj_rdiveroll>>8,pj_rdiveroll&$FF        ; bas -> rdiveroll
        .byte   $FF
pj_r15:
        .byte   $04,$04,pj_turn>>8,pj_turn&$FF        ; arriere -> turn
        .byte   $09,$09,pj_standjump>>8,pj_standjump&$FF        ; haut+avant -> standjump
        .byte   $01,$01,pj_highjump>>8,pj_highjump&$FF        ; haut -> highjump
        .byte   $02,$02,pj_stoop>>8,pj_stoop&$FF        ; bas -> stoop
        .byte   $08,$08,pj_startrun>>8,pj_startrun&$FF        ; avant -> startrun
        .byte   $FF
pj_r109:
        .byte   $02,$00,pj_standup>>8,pj_standup&$FF        ; !bas -> standup
        .byte   $FF
pr_gflag:                               ; 1 : le garde a ses images (4 octets avant les poses du prince)
        .byte   1
pr_cflag:                               ; 1 : des poses sont dans l'Exelmemoire
        .byte   1
pr_ntab:                                ; compression par quartets : l'octet des quartets 1 a 14
        .byte   $FF,$80,$C0,$1F,$E0,$0F,$07,$F0,$3F,$01,$03,$F8,$7F,$FC
pr_col:                                 ; abscisse du jeu -> colonne de l'ancrage (signee)
        .byte   $EF,$F0,$F0,$F0,$F1,$F1,$F1,$F1,$F2,$F2,$F2,$F3,$F3,$F3,$F3,$F4
        .byte   $F4,$F4,$F5,$F5,$F5,$F5,$F6,$F6,$F6,$F7,$F7,$F7,$F7,$F8,$F8,$F8
        .byte   $F9,$F9,$F9,$F9,$FA,$FA,$FA,$FB,$FB,$FB,$FB,$FC,$FC,$FC,$FD,$FD
        .byte   $FD,$FD,$FE,$FE,$FE,$FF,$FF,$FF,$FF,$00,$00,$00,$01,$01,$01,$01
        .byte   $02,$02,$02,$03,$03,$03,$03,$04,$04,$04,$05,$05,$05,$05,$06,$06
        .byte   $06,$07,$07,$07,$07,$08,$08,$08,$09,$09,$09,$09,$0A,$0A,$0A,$0B
        .byte   $0B,$0B,$0B,$0C,$0C,$0C,$0D,$0D,$0D,$0D,$0E,$0E,$0E,$0F,$0F,$0F
        .byte   $0F,$10,$10,$10,$11,$11,$11,$11,$12,$12,$12,$13,$13,$13,$13,$14
        .byte   $14,$14,$15,$15,$15,$15,$16,$16,$16,$17,$17,$17,$17,$18,$18,$18
        .byte   $19,$19,$19,$19,$1A,$1A,$1A,$1B,$1B,$1B,$1B,$1C,$1C,$1C,$1D,$1D
        .byte   $1D,$1D,$1E,$1E,$1E,$1F,$1F,$1F,$1F,$20,$20,$20,$21,$21,$21,$21
        .byte   $22,$22,$22,$23,$23,$23,$23,$24,$24,$24,$25,$25,$25,$25,$26,$26
        .byte   $26,$27,$27,$27,$27,$28,$28,$28,$29,$29,$29,$29,$2A,$2A,$2A,$2B
        .byte   $2B,$2B,$2B,$2C,$2C,$2C,$2D,$2D,$2D,$2D,$2E,$2E,$2E,$2F,$2F,$2F
        .byte   $2F,$30,$30,$30,$31,$31,$31,$31,$32,$32,$32,$33,$33,$33,$33,$34
        .byte   $34,$34,$35,$35,$35,$35,$36,$36,$36,$37,$37,$37,$37,$38,$38,$38
pr_p0:                                 ; pose 15 du jeu, decalage 0,9
        .byte   $02,$05,$0A,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$40,$82,$08
        .byte   $67,$77,$44,$9F,$0E,$F1,$9F,$27,$55,$32,$00,$F4,$03,$33,$34,$49
        .byte   $99,$44,$46,$65,$55,$55,$55,$55,$56,$64,$44,$44,$44,$45,$55,$33
        .byte   $35,$55,$56,$BA,$AA,$AB,$77,$65,$53,$33,$58,$88,$50
pr_p1:                                 ; pose 1 du jeu, decalage 0,8
        .byte   $02,$05,$0A,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$F4,$F9,$07
        .byte   $20,$84,$66,$66,$F3,$EF,$3E,$DF,$1D,$F3,$35,$53,$20,$12,$22,$24
        .byte   $99,$99,$44,$44,$45,$53,$35,$55,$55,$54,$44,$44,$44,$44,$45,$55
        .byte   $55,$58,$88,$87,$A0,$3B,$76,$68,$88,$55,$88,$88,$50
pr_p2:                                 ; pose 2 du jeu, decalage 0,8
        .byte   $02,$05,$0A,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$F4,$F9,$07
        .byte   $20,$86,$66,$66,$F3,$EF,$3E,$DF,$1D,$F3,$35,$53,$20,$12,$22,$24
        .byte   $66,$44,$44,$44,$4C,$88,$85,$55,$55,$54,$44,$44,$66,$69,$9C,$88
        .byte   $8C,$CC,$CC,$CA,$04,$AB,$76,$EF,$7C,$F3,$CF,$1C,$F1,$CF,$7C,$EE
        .byte   $EC
pr_p14:                                 ; pose 14 du jeu, decalage 0,1
        .byte   $03,$04,$0B,$01,$02,$00,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$64
        .byte   $F7,$CF,$7D,$1F,$3B,$F6,$7F,$9F,$F7,$E0,$03,$20,$8A,$F7,$3D,$D7
        .byte   $66,$66,$D1,$11,$1F,$FE,$EC,$85,$22,$20,$64,$44,$66,$7B,$A0,$1E
        .byte   $CC,$EF,$FE,$11,$11,$D0,$62,$22,$07,$B6,$00,$6B,$B7,$F0,$EF,$3E
        .byte   $FF,$E1,$10,$05,$52,$F0,$8F,$08,$F1,$8F,$38,$CC
pr_p15:                                 ; pose 107 du jeu, decalage 0,1
        .byte   $03,$03,$07,$01,$02,$00,$03,$04,$05,$06,$07,$00,$01,$77,$6B,$F0
        .byte   $6F,$09,$70,$0F,$FE,$EC,$FD,$08,$FB,$0F,$70,$85,$00,$47,$A0,$1F
        .byte   $0C,$60,$2F,$FE,$11,$19,$91,$1D,$D0,$02,$33,$33,$32,$01,$A0,$2A
        .byte   $76,$44,$43,$8F,$78,$F7,$05,$55,$33,$80
pr_p16:                                 ; pose 108 du jeu, decalage 0,7
        .byte   $03,$03,$08,$01,$02,$00,$03,$04,$05,$06,$07,$08,$F0,$CF,$13,$60
        .byte   $65,$53,$06,$7B,$BB,$BB,$66,$47,$11,$11,$11,$FF,$EC,$5F,$60,$55
        .byte   $55,$32,$06,$F3,$09,$94,$66,$7F,$10,$F1,$8F,$0C,$F0,$EF,$DE,$C8
        .byte   $11,$10,$62,$35
pr_p17:                                 ; pose 109 du jeu, decalage 0,1
        .byte   $03,$02,$06,$01,$02,$03,$04,$05,$06,$77,$44,$9F,$0E,$F1,$9F,$27
        .byte   $40,$01,$11,$FF,$E3,$33,$32,$00,$85,$20,$6F,$70,$F3,$8F,$1C,$46
        .byte   $67,$77,$7F,$1C,$77,$11,$11,$11,$10,$12,$22,$58,$88,$80
pr_p18:                                 ; pose 110 du jeu, decalage 0,0
        .byte   $03,$02,$06,$01,$02,$03,$04,$05,$06,$77,$79,$9D,$F1,$DF,$33,$F4
        .byte   $F9,$11,$11,$11,$E2,$20,$0C,$CC,$85,$20,$3F,$1C,$F0,$CF,$0C,$F0
        .byte   $EF,$0E,$F0,$EF,$06,$77,$70,$0B,$AF,$79,$11,$11,$11,$01,$23,$52
        .byte   $25,$8C
pr_p19:                                 ; pose 111 du jeu, decalage 0,8
        .byte   $03,$03,$08,$01,$02,$00,$03,$04,$05,$06,$07,$08,$F4,$F9,$07,$20
        .byte   $87,$77,$77,$99,$DF,$1D,$F3,$31,$11,$11,$11,$1C,$28,$CC,$CC,$83
        .byte   $02,$F1,$CF,$0C,$F0,$CF,$0C,$F0,$EF,$0E,$66,$77,$00,$A0,$1F,$0E
        .byte   $91,$FF,$E1,$10,$02,$35,$F7,$08,$20,$02,$50
pr_p20:                                 ; pose 112 du jeu, decalage 0,6
        .byte   $03,$03,$09,$01,$02,$03,$04,$05,$06,$07,$08,$09,$F1,$9F,$27,$40
        .byte   $6F,$E7,$32,$06,$50,$8A,$AA,$AA,$A4,$49,$F0,$EF,$9F,$F9,$FF,$8F
        .byte   $F8,$71,$11,$11,$18,$CE,$EF,$FE,$11,$1F,$FE,$E0,$2A,$AA,$AA,$AA
        .byte   $02,$2F,$87,$F8,$FF,$8F,$F9,$FF,$9F,$F9,$FF,$18,$F0,$CF,$0E,$6F
        .byte   $8F,$EF,$FE,$EC,$80
pr_p21:                                 ; pose 113 du jeu, decalage 0,4
        .byte   $03,$03,$09,$01,$02,$03,$04,$05,$06,$07,$08,$09,$F3,$ED,$F1,$DF
        .byte   $33,$F4,$F9,$03,$11,$C2,$20,$43,$08,$AA,$AA,$AA,$AB,$B9,$11,$FD
        .byte   $FF,$CF,$FC,$7F,$CF,$FD,$F1,$11,$8C,$EF,$FE,$FF,$EF,$FE,$FF,$EE
        .byte   $C8,$03,$AA,$AA,$AA,$03,$F8,$7F,$8F,$F9,$FF,$BF,$FB,$F1,$F2,$0F
        .byte   $30,$F1,$8F,$1C,$FF,$EE,$CE,$C8
pr_p22:                                 ; pose 114 du jeu, decalage 0,1
        .byte   $04,$03,$08,$01,$02,$03,$00,$00,$04,$05,$00,$00,$06,$07,$08,$AB
        .byte   $9F,$3E,$DF,$1D,$F3,$3F,$4F,$90,$01,$11,$1C,$22,$20,$1E,$C5,$20
        .byte   $5F,$FE,$1D,$99,$99,$9D,$1C,$C8,$8C,$EF,$FE,$FF,$EF,$FE,$FF,$EF
        .byte   $0C,$F0,$6B,$B6,$99,$DF,$7E,$FF,$E0,$1F,$8E,$F8,$3B,$74,$9F,$7E
        .byte   $F7,$C0,$33,$20,$30
pr_p23:                                 ; pose 115 du jeu, decalage 0,0
        .byte   $04,$03,$08,$01,$02,$03,$00,$00,$04,$05,$00,$00,$06,$07,$08,$00
        .byte   $AB,$9F,$3E,$DF,$1D,$F3,$3F,$4F,$9D,$11,$11,$E2,$22,$00,$C8,$53
        .byte   $05,$DD,$D9,$94,$66,$49,$F7,$EE,$C8,$CE,$EE,$EE,$F6,$0F,$38,$F1
        .byte   $EF,$0E,$F0,$CF,$7C,$F7,$CF,$7C,$F7,$EF,$7E,$03,$F0,$4B,$BB,$49
        .byte   $05,$23,$20,$00
pr_p24:                                 ; pose 116 du jeu, decalage 0,7
        .byte   $04,$04,$0A,$01,$02,$00,$00,$03,$04,$05,$00,$00,$06,$07,$00,$00
        .byte   $08,$09,$0A,$F1,$9F,$27,$40,$63,$32,$0A,$AA,$44,$9F,$0E,$49,$D1
        .byte   $11,$EF,$40,$33,$EC,$85,$20,$4D,$D9,$94,$46,$77,$6E,$83,$35,$8C
        .byte   $EE,$EF,$78,$F1,$EF,$0E,$F0,$EF,$1E,$99,$DF,$7E,$D0,$37,$BB,$BD
        .byte   $E0,$42,$33,$01
pr_p25:                                 ; pose 117 du jeu, decalage 0,5
        .byte   $03,$04,$0A,$01,$00,$00,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$1F
        .byte   $3B,$F6,$7F,$9F,$F7,$E0,$5A,$B7,$64,$44,$DF,$7D,$11,$11,$FF,$EE
        .byte   $C8,$30,$03,$32,$06,$AA,$A0,$61,$1F,$FE,$EF,$FE,$F7,$ED,$D9,$D2
        .byte   $05,$23,$3B,$A0,$4A,$AA,$38,$8F,$70,$FF,$18,$88,$FF,$31,$03,$25
        .byte   $C8,$33
pr_p26:                                 ; pose 118 du jeu, decalage 0,2
        .byte   $02,$04,$08,$01,$02,$03,$04,$05,$06,$07,$08,$74,$49,$F0,$EF,$19
        .byte   $F2,$74,$01,$53,$F4,$03,$33,$32,$02,$AA,$B7,$77,$66,$71,$1F,$FE
        .byte   $FF,$EE,$CC,$88,$80,$0A,$AA,$A0,$4E,$EE,$FF,$EF,$FE,$FF,$EF,$FE
        .byte   $11,$1B,$08,$CC,$F7,$0F,$78,$F7,$8F,$7C,$FF,$EF,$FE,$FF,$EE
pr_p27:                                 ; pose 119 du jeu, decalage 0,1
        .byte   $02,$04,$07,$01,$00,$02,$03,$04,$05,$06,$07,$9F,$1E,$F7,$EF,$7D
        .byte   $1F,$3B,$F6,$7F,$9F,$F7,$E0,$04,$44,$99,$99,$99,$95,$33,$33,$32
        .byte   $22,$24,$44,$44,$49,$94,$43,$32,$33,$55,$55,$59,$67,$77,$66,$64
        .byte   $42,$20,$12,$23,$33,$30
pr_p53:                                 ; pose 50 du jeu, decalage 0,3
        .byte   $03,$04,$08,$00,$01,$00,$02,$03,$04,$00,$05,$06,$00,$07,$08,$F7
        .byte   $CF,$7D,$1F,$3B,$F6,$7F,$9F,$F7,$E0,$2F,$1C,$4A,$06,$41,$19,$99
        .byte   $99,$44,$55,$55,$33,$32,$20,$01,$11,$DD,$94,$44,$40,$02,$23,$35
        .byte   $55,$55,$7A,$AA,$B6,$49,$DF,$FE,$55,$33,$22,$20,$20
pr_p54:                                 ; pose 51 du jeu, decalage 0,2
        .byte   $03,$04,$0B,$01,$02,$00,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$00
        .byte   $BB,$7A,$BF,$04,$B0,$1F,$78,$5F,$E8,$CF,$D8,$F3,$8C,$80,$1F,$1C
        .byte   $6B,$06,$11,$11,$11,$FF,$EF,$FE,$FF,$EF,$7C,$22,$20,$6A,$A0,$4A
        .byte   $A0,$0E,$FF,$EF,$FE,$11,$DD,$11,$10,$42,$22,$22,$08,$A4,$7B,$B7
        .byte   $49,$F7,$EE,$E2,$22,$06
pr_p55:                                 ; pose 52 du jeu, decalage 0,1
        .byte   $02,$04,$08,$01,$02,$03,$04,$05,$06,$07,$08,$77,$44,$9F,$0E,$F1
        .byte   $9F,$27,$40,$03,$20,$0F,$40,$33,$33,$20,$0D,$96,$66,$66,$66,$6C
        .byte   $CC,$C8,$88,$55,$54,$44,$44,$46,$66,$F6,$F3,$22,$35,$88,$CC,$CB
        .byte   $03,$AB,$76,$6E,$EF,$38,$F3,$8F,$78,$C8,$55,$30
pr_p56:                                 ; pose 67 du jeu, decalage 0,0
        .byte   $02,$04,$08,$01,$02,$03,$04,$05,$06,$07,$08,$F1,$EF,$1C,$F1,$CF
        .byte   $3E,$DD,$D4,$9F,$1E,$04,$22,$20,$19,$99,$99,$99,$99,$93,$33,$32
        .byte   $22,$02,$DD,$D9,$9D,$D9,$99,$00,$22,$33,$55,$55,$5D,$46,$76,$9D
        .byte   $DD,$D0,$02,$20,$12,$22,$20,$00
pr_p57:                                 ; pose 68 du jeu, decalage 0,0
        .byte   $02,$04,$08,$01,$02,$03,$04,$05,$06,$07,$08,$4F,$1E,$F1,$CF,$3E
        .byte   $DD,$D4,$9F,$1E,$04,$22,$20,$14,$49,$99,$99,$44,$45,$55,$33,$33
        .byte   $22,$00,$99,$94,$99,$94,$44,$00,$22,$33,$55,$55,$59,$67,$B6,$44
        .byte   $99,$90,$03,$32,$23,$33,$20,$00
pr_p58:                                 ; pose 69 du jeu, decalage 0,0
        .byte   $02,$04,$08,$01,$02,$03,$04,$05,$06,$07,$08,$77,$B7,$66,$6B,$7B
        .byte   $32,$23,$58,$88,$53,$44,$46,$66,$66,$66,$CC,$CC,$88,$85,$55,$66
        .byte   $66,$66,$66,$66,$53,$35,$58,$88,$CC,$47,$BA,$AA,$77,$66,$38,$85
        .byte   $58,$88,$85
pr_p59:                                 ; pose 70 du jeu, decalage 0,0
        .byte   $02,$04,$08,$01,$02,$03,$04,$05,$06,$07,$08,$6F,$0E,$49,$99,$64
        .byte   $60,$32,$33,$32,$01,$44,$99,$99,$94,$44,$C8,$88,$53,$33,$22,$99
        .byte   $44,$44,$44,$44,$23,$33,$55,$EE,$EC,$D4,$67,$76,$44,$49,$00,$33
        .byte   $22,$33,$33,$20
pr_p60:                                 ; pose 71 du jeu, decalage 0,0
        .byte   $03,$04,$0A,$01,$02,$00,$03,$04,$05,$06,$07,$08,$09,$0A,$00,$F1
        .byte   $EF,$1C,$F3,$ED,$DD,$49,$F1,$E0,$42,$22,$02,$44,$49,$99,$99,$99
        .byte   $FF,$3F,$E7,$FE,$EE,$C8,$53,$20,$02,$08,$99,$99,$44,$46,$66,$22
        .byte   $33,$55,$88,$8F,$F1,$07,$33,$D4,$67,$76,$44,$49,$00,$22,$03,$22
        .byte   $20
pr_p61:                                 ; pose 72 du jeu, decalage 0,0
        .byte   $03,$04,$09,$01,$02,$00,$03,$04,$05,$06,$07,$00,$08,$09,$00,$44
        .byte   $F3,$ED,$DD,$49,$F1,$E0,$08,$20,$12,$22,$02,$64,$44,$49,$99,$94
        .byte   $C8,$8F,$E1,$FE,$3F,$C6,$FD,$C1,$1E,$02,$22,$F3,$08,$30,$14,$44
        .byte   $44,$66,$66,$65,$55,$58,$88,$CC,$C9,$67,$BB,$77,$66,$42,$33,$22
        .byte   $23,$55,$50
pr_p62:                                 ; pose 73 du jeu, decalage 0,1
        .byte   $03,$04,$09,$01,$02,$00,$03,$04,$05,$06,$07,$00,$08,$09,$00,$4F
        .byte   $3E,$DD,$D4,$9F,$1E,$04,$22,$20,$36,$64,$44,$49,$99,$98,$85,$55
        .byte   $3F,$C7,$11,$10,$3F,$30,$83,$00,$CC,$46,$66,$67,$77,$66,$55,$88
        .byte   $8C,$CC,$C8,$47,$BA,$A7,$66,$44,$35,$53,$35,$55,$55
pr_p63:                                 ; pose 74 du jeu, decalage 0,2
        .byte   $03,$04,$09,$01,$02,$00,$03,$04,$05,$06,$07,$00,$08,$09,$00,$49
        .byte   $99,$64,$60,$32,$33,$32,$03,$BB,$77,$64,$44,$46,$FF,$EF,$FE,$EC
        .byte   $FF,$1F,$E3,$11,$E0,$2F,$60,$53,$28,$80,$17,$7B,$BB,$AA,$AA,$A5
        .byte   $8C,$CE,$FF,$EF,$FE,$11,$1B,$03,$AB,$B7,$7C,$EF,$7C,$F3,$8F,$7C
        .byte   $EC,$C8,$50
pr_p64:                                 ; pose 75 du jeu, decalage 0,4
        .byte   $03,$04,$09,$01,$02,$00,$03,$04,$00,$05,$06,$07,$08,$09,$00,$99
        .byte   $64,$60,$43,$33,$20,$5B,$76,$64,$44,$44,$91,$FF,$EE,$C8,$53,$01
        .byte   $26,$7B,$AA,$03,$A5,$8C,$FF,$EF,$FE,$11,$11,$10,$52,$22,$2A,$03
        .byte   $AB,$76,$6E,$F7,$EF,$3E,$F3,$CE,$EE,$C8,$50
pr_p65:                                 ; pose 76 du jeu, decalage 0,5
        .byte   $03,$04,$0A,$01,$02,$00,$03,$04,$05,$06,$07,$08,$00,$09,$0A,$B0
        .byte   $0A,$06,$EE,$C8,$05,$DE,$30,$3A,$BB,$FE,$F1,$DD,$9F,$7E,$F7,$C8
        .byte   $CE,$85,$32,$0E,$71,$D9,$46,$77,$76,$FC,$F0,$02,$35,$8C,$CC,$CC
        .byte   $7B,$AA,$64,$9D,$1F,$FE,$23,$53,$22,$22,$01
pr_p66:                                 ; pose 77 du jeu, decalage 0,2
        .byte   $03,$04,$09,$01,$02,$00,$03,$04,$05,$00,$06,$07,$00,$08,$09,$F1
        .byte   $DF,$19,$F1,$9F,$18,$F1,$8F,$18,$F0,$CF,$0C,$01,$EF,$FE,$FF,$EF
        .byte   $7E,$EF,$78,$0A,$B7,$64,$99,$9D,$DF,$FE,$FF,$EE,$C5,$33,$22,$04
        .byte   $EF,$FE,$1D,$DD,$99,$44,$02,$22,$35,$55,$57,$BB,$BB,$64,$9D,$FF
        .byte   $E0,$02,$35,$32,$22,$01
pr_p67:                                 ; pose 78 du jeu, decalage 0,0
        .byte   $02,$05,$09,$01,$02,$03,$04,$05,$06,$07,$08,$00,$09,$9D,$F6,$FF
        .byte   $6F,$F6,$CF,$6E,$F7,$6F,$77,$F3,$3F,$33,$33,$20,$69,$99,$44,$66
        .byte   $44,$93,$33,$32,$01,$23,$36,$66,$44,$44,$44,$48,$85,$55,$53,$33
        .byte   $3A,$BB,$B7,$77,$76,$6E,$EE,$CC,$CC,$88,$80,$2F,$18,$F7,$CF,$3E
        .byte   $94,$F1,$EF,$78
pr_p71:                                 ; pose 81 du jeu, decalage 0,4
        .byte   $02,$06,$0A,$01,$00,$02,$03,$04,$05,$06,$07,$08,$09,$00,$0A,$BB
        .byte   $BB,$BB,$03,$76,$B7,$F0,$B7,$BB,$BB,$FD,$08,$FB,$0F,$70,$85,$03
        .byte   $DD,$D9,$94,$46,$77,$55,$55,$88,$88,$83,$66,$64,$44,$44,$11,$88
        .byte   $88,$88,$88,$55,$AA,$BB,$BB,$B7,$77,$CC,$CC,$C8,$88,$88,$01,$3F
        .byte   $60,$F7,$0F,$38,$F3,$CF,$38,$F7,$8C
pr_p72:                                 ; pose 82 du jeu, decalage 0,2
        .byte   $02,$05,$0A,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$F3,$BF,$4F
        .byte   $9F,$0C,$F0,$CF,$0C,$F0,$CF,$0C,$01,$22,$07,$DD,$D9,$96,$F3,$EF
        .byte   $3E,$DF,$1D,$23,$33,$32,$00,$22,$29,$99,$99,$11,$11,$15,$55,$55
        .byte   $53,$32,$26,$44,$44,$49,$99,$95,$53,$33,$33,$33,$30,$07,$BA,$AA
        .byte   $76,$66,$01,$55,$33,$35,$55
pr_p73:                                 ; pose 83 du jeu, decalage 0,9
        .byte   $02,$05,$09,$01,$00,$02,$03,$04,$05,$06,$07,$08,$09,$B0,$8B,$B6
        .byte   $64,$76,$F1,$36,$B5,$32,$FA,$05,$F6,$05,$53,$00,$66,$4D,$94,$46
        .byte   $67,$88,$55,$88,$88,$88,$44,$44,$66,$66,$66,$33,$55,$55,$88,$88
        .byte   $7A,$00,$AB,$76,$44,$4C,$C8,$55,$53,$22,$30
pr_p74:                                 ; pose 84 du jeu, decalage 0,2
        .byte   $02,$04,$08,$01,$02,$03,$04,$05,$06,$07,$08,$44,$9F,$0E,$F1,$9F
        .byte   $27,$40,$3F,$40,$33,$33,$20,$24,$99,$44,$46,$67,$73,$33,$33,$33
        .byte   $33,$21,$11,$DD,$D9,$99,$40,$02,$22,$33,$55,$53,$6A,$A7,$64,$9D
        .byte   $11,$88,$55,$55,$32,$01
pr_p75:                                 ; pose 85 du jeu, decalage 0,0
        .byte   $02,$04,$08,$01,$02,$03,$04,$05,$06,$07,$08,$7B,$B6,$64,$7F,$0C
        .byte   $F1,$36,$53,$22,$FA,$05,$F6,$05,$53,$66,$66,$66,$66,$67,$C8,$88
        .byte   $55,$55,$55,$44,$44,$44,$66,$99,$55,$55,$58,$8C,$CC,$7A,$02,$AB
        .byte   $76,$6C,$CF,$70,$F7,$0F,$70,$CC,$C8,$80
pr_p76:                                 ; pose 16 du jeu, decalage 0,9
        .byte   $02,$05,$09,$01,$00,$02,$03,$04,$05,$06,$07,$08,$09,$90,$87,$77
        .byte   $6F,$3E,$F3,$ED,$F1,$DF,$33,$F4,$F5,$33,$20,$02,$22,$22,$67,$77
        .byte   $66,$66,$66,$CC,$CC,$85,$55,$55,$66,$66,$66,$67,$76,$55,$33,$55
        .byte   $88,$CC,$6B,$A0,$2B,$77,$65,$55,$55,$58,$88,$80
pr_p77:                                 ; pose 17 du jeu, decalage 0,0
        .byte   $02,$04,$08,$01,$02,$03,$04,$05,$06,$07,$08,$66,$4F,$7C,$F7,$D1
        .byte   $F3,$BF,$67,$F9,$FF,$7E,$53,$20,$67,$BA,$AB,$B7,$76,$6E,$EE,$EC
        .byte   $CC,$88,$57,$77,$77,$7B,$BB,$78,$88,$88,$CC,$EE,$E7,$A0,$3A,$BB
        .byte   $7C,$CF,$78,$F3,$8F,$38,$CC,$CC,$C0
pr_p78:                                 ; pose 18 du jeu, decalage 0,1
        .byte   $03,$04,$09,$01,$02,$00,$03,$04,$05,$00,$06,$07,$00,$08,$09,$64
        .byte   $F7,$CF,$7D,$1F,$3B,$F6,$7F,$9F,$F7,$E0,$08,$30,$BA,$B7,$66,$64
        .byte   $49,$11,$11,$FF,$EE,$E5,$88,$53,$32,$02,$11,$11,$DD,$99,$94,$03
        .byte   $22,$23,$35,$FF,$E9,$46,$66,$49,$DD,$00,$22,$02,$22,$22
pr_p79:                                 ; pose 19 du jeu, decalage 0,7
        .byte   $04,$04,$0A,$01,$02,$00,$00,$03,$04,$05,$06,$00,$07,$08,$00,$00
        .byte   $09,$0A,$00,$F1,$9F,$27,$40,$63,$32,$0C,$44,$9F,$0E,$01,$A7,$49
        .byte   $1D,$1F,$DF,$11,$11,$11,$EC,$52,$02,$33,$04,$BB,$BB,$AA,$A0,$2E
        .byte   $EE,$EF,$FE,$FF,$EF,$FE,$FF,$E1,$DB,$06,$AB,$CF,$FE,$F7,$EF,$3C
        .byte   $F3,$CF,$3C,$F7,$EF,$FE,$FF,$EF,$FE
pr_p80:                                 ; pose 20 du jeu, decalage 0,9
        .byte   $04,$04,$09,$01,$00,$00,$00,$02,$03,$04,$05,$00,$00,$06,$07,$00
        .byte   $00,$08,$09,$90,$C9,$9D,$F1,$DF,$33,$F4,$F0,$1F,$78,$11,$11,$22
        .byte   $2D,$DD,$11,$E2,$02,$22,$28,$20,$41,$11,$11,$DD,$D9,$90,$62,$22
        .byte   $FF,$E9,$46,$6F,$1E,$9D,$D1,$00,$22,$02,$22,$22
pr_p81:                                 ; pose 21 du jeu, decalage 0,9
        .byte   $04,$04,$0B,$01,$00,$00,$00,$02,$03,$04,$05,$00,$06,$07,$08,$00
        .byte   $09,$0A,$0B,$F7,$E0,$AA,$BD,$D1,$F3,$BF,$67,$F9,$F4,$11,$11,$FF
        .byte   $E3,$02,$11,$1E,$50,$42,$20,$7A,$AA,$05,$B1,$FF,$EF,$FE,$FF,$EF
        .byte   $FE,$1D,$D1,$10,$33,$30,$02,$22,$08,$A6,$BA,$A6,$9D,$11,$12,$35
        .byte   $32,$00,$22,$20,$00
pr_p87:                                 ; pose 27 du jeu, decalage 0,4
        .byte   $05,$03,$0B,$01,$02,$03,$00,$00,$04,$05,$06,$07,$00,$00,$08,$09
        .byte   $0A,$0B,$F0,$AF,$0D,$F0,$E7,$7B,$03,$11,$1C,$83,$03,$1F,$FE,$80
        .byte   $FA,$67,$BA,$03,$BF,$E7,$11,$11,$1D,$91,$11,$FF,$EF,$FE,$CC,$CC
        .byte   $88,$53,$47,$BB,$77,$66,$66,$00,$22,$00,$4F,$BF,$FB,$F1,$11,$01
        .byte   $7B,$F8,$3F,$F7,$11,$25,$03,$22,$22,$01
pr_p88:                                 ; pose 28 du jeu, decalage 0,5
        .byte   $03,$03,$08,$01,$02,$00,$03,$04,$05,$06,$07,$08,$DF,$1D,$F3,$3F
        .byte   $4F,$90,$4C,$22,$20,$56,$6B,$02,$AB,$9F,$3E,$11,$1D,$11,$11,$1F
        .byte   $FE,$8C,$CC,$CC,$85,$20,$06,$BA,$A7,$77,$66,$65,$85,$35,$FC,$3F
        .byte   $C3,$F8,$6F,$86,$FF,$D0,$83
pr_p91:                                 ; pose 31 du jeu, decalage 0,4
        .byte   $03,$04,$0B,$01,$02,$00,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$AB
        .byte   $00,$AF,$02,$A0,$3F,$F4,$EF,$EC,$F9,$CF,$7C,$C0,$CA,$DD,$D1,$11
        .byte   $1F,$7E,$F7,$88,$33,$33,$22,$03,$44,$66,$44,$7B,$A0,$0E,$CC,$FF
        .byte   $E1,$11,$11,$10,$42,$23,$33,$D4,$67,$76,$66,$44,$02,$BA,$F8,$1F
        .byte   $81,$F8,$FF,$BF,$10,$32,$35,$30,$10
pr_p92:                                 ; pose 32 du jeu, decalage 0,1
        .byte   $03,$04,$0A,$01,$02,$00,$03,$04,$05,$06,$07,$08,$09,$0A,$00,$03
        .byte   $A0,$1A,$01,$F3,$EF,$3C,$CF,$FA,$FF,$EF,$76,$FC,$EF,$3E,$E0,$07
        .byte   $B0,$71,$11,$D9,$9D,$DD,$F7,$E2,$22,$22,$22,$02,$66,$67,$7B,$AA
        .byte   $F1,$8F,$1E,$55,$58,$EF,$FE,$11,$11,$07,$22,$96,$7B,$B7,$76,$66
        .byte   $01,$F7,$0F,$3C,$F1,$CF,$38,$F7,$8F,$78,$88
pr_p93:                                 ; pose 33 du jeu, decalage 0,0
        .byte   $02,$04,$08,$01,$02,$03,$04,$05,$06,$07,$08,$A0,$1A,$AB,$00,$AF
        .byte   $02,$AE,$CF,$78,$8F,$F4,$EF,$EC,$F9,$CF,$7C,$CF,$33,$96,$BA,$A0
        .byte   $0A,$AA,$EE,$CC,$EE,$EE,$EE,$44,$44,$66,$67,$7B,$32,$23,$58,$CC
        .byte   $EE,$96,$7B,$B7,$76,$64,$22,$22,$22,$23,$33
pr_p94:                                 ; pose 45 du jeu, decalage 0,1
        .byte   $02,$04,$08,$01,$02,$03,$04,$05,$06,$07,$08,$67,$BF,$0B,$6F,$0D
        .byte   $F0,$E6,$70,$02,$25,$58,$3F,$60,$F9,$05,$00,$DD,$D9,$99,$99,$44
        .byte   $33,$33,$33,$33,$33,$64,$49,$99,$DD,$DD,$55,$55,$88,$53,$33,$9F
        .byte   $3E,$F3,$CF,$1C,$F1,$C4,$44,$66,$20,$42,$33,$50
pr_p95:                                 ; pose 46 du jeu, decalage 0,1
        .byte   $02,$04,$08,$01,$02,$03,$04,$05,$06,$07,$08,$94,$BB,$7A,$BF,$04
        .byte   $B0,$0C,$55,$FE,$8C,$FD,$8F,$38,$C8,$00,$99,$99,$99,$99,$99,$CC
        .byte   $CC,$CC,$CC,$CC,$AB,$B7,$76,$44,$99,$CC,$CC,$88,$88,$88,$B4,$4F
        .byte   $0E,$F0,$66,$77,$7B,$30,$33,$35,$8C
pr_p96:                                 ; pose 47 du jeu, decalage 0,0
        .byte   $03,$04,$0A,$01,$02,$03,$04,$05,$06,$00,$07,$08,$00,$09,$0A,$AA
        .byte   $A0,$61,$11,$44,$9F,$0E,$F1,$9F,$27,$4C,$85,$00,$F4,$03,$33,$32
        .byte   $04,$AA,$AA,$A1,$DD,$D1,$11,$11,$13,$35,$CC,$CC,$CC,$C1,$11,$11
        .byte   $11,$11,$13,$33,$33,$33,$33,$3F,$78,$8C,$F7,$8F,$3C,$F3,$CF,$7E
        .byte   $DD,$D0,$72,$20
        .byte   pr_p99>>8,pr_p99&$FF,0,4        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p98:                                 ; pose 166 du jeu, decalage 0,9
        .byte   $02,$05,$0A,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$40,$82,$08
        .byte   $67,$77,$44,$9F,$0E,$F1,$9F,$27,$55,$32,$00,$F4,$03,$33,$34,$49
        .byte   $99,$44,$46,$65,$55,$55,$55,$55,$56,$64,$44,$44,$44,$45,$55,$33
        .byte   $35,$55,$56,$BA,$AA,$AB,$77,$65,$53,$33,$58,$88,$50
        .byte   pr_p101>>8,pr_p101&$FF,0,254        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p100:                                 ; pose 179 du jeu, decalage 0,3
        .byte   $02,$05,$09,$01,$00,$02,$03,$04,$05,$06,$07,$08,$09,$F7,$CF,$7D
        .byte   $1F,$3B,$F6,$7F,$9F,$F7,$E0,$24,$44,$44,$44,$44,$48,$88,$55,$53
        .byte   $22,$00,$44,$44,$99,$44,$44,$35,$8C,$CC,$C8,$CC,$A0,$07,$66,$44
        .byte   $99,$48,$55,$55,$32,$22,$30,$87,$08,$80
pr_p101:                                 ; pose 1179 du jeu, decalage 0,1
        .byte   $02,$05,$0A,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$D9,$D9,$9D
        .byte   $11,$90,$23,$8C,$CC,$83,$00,$44,$44,$99,$99,$46,$85,$55,$88,$55
        .byte   $32,$66,$77,$66,$64,$44,$EE,$EE,$EE,$EC,$C8,$B0,$0A,$77,$44,$44
        .byte   $6C,$88,$EE,$EC,$CC,$C0,$8A,$08,$C0
        .byte   pr_p103>>8,pr_p103&$FF,0,254        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p102:                                 ; pose 180 du jeu, decalage 0,8
        .byte   $02,$05,$09,$01,$00,$02,$03,$04,$05,$06,$07,$08,$09,$F9,$FF,$7E
        .byte   $07,$44,$44,$4D,$F7,$D1,$F3,$BF,$67,$85,$53,$30,$49,$94,$44,$44
        .byte   $44,$4C,$CE,$EC,$CE,$C8,$8B,$A4,$D1,$DD,$99,$48,$55,$53,$22,$35
        .byte   $80,$86,$08,$80
pr_p103:                                 ; pose 1180 du jeu, decalage 0,6
        .byte   $03,$05,$0B,$01,$02,$00,$03,$04,$00,$05,$06,$00,$07,$08,$09,$0A
        .byte   $0B,$00,$D1,$19,$05,$CC,$83,$05,$49,$94,$6D,$9D,$99,$88,$85,$30
        .byte   $13,$8C,$66,$66,$66,$44,$44,$FF,$EF,$FE,$FF,$EE,$EC,$CC,$88,$BB
        .byte   $64,$9D,$DD,$94,$C8,$55,$FE,$3F,$CF,$11,$1F,$FE,$03,$23,$50,$B7
        .byte   $08,$C0
        .byte   pr_p105>>8,pr_p105&$FF,255,254        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p104:                                 ; pose 181 du jeu, decalage 0,1
        .byte   $03,$04,$09,$01,$02,$00,$03,$04,$05,$06,$07,$08,$09,$00,$00,$77
        .byte   $44,$9F,$0E,$F1,$9F,$27,$40,$08,$53,$F6,$05,$53,$32,$00,$AF,$73
        .byte   $D4,$77,$77,$77,$11,$11,$1F,$FE,$EE,$EC,$01,$22,$05,$44,$46,$66
        .byte   $7A,$AA,$FF,$EF,$FE,$EF,$FE,$11,$11,$11,$05,$22,$22,$08,$70
pr_p105:                                 ; pose 1181 du jeu, decalage 0,9
        .byte   $03,$05,$0C,$01,$02,$00,$03,$04,$00,$05,$06,$07,$08,$09,$0A,$0B
        .byte   $0C,$00,$40,$85,$08,$66,$94,$94,$49,$DD,$85,$22,$5C,$EE,$EC,$BF
        .byte   $73,$D9,$66,$66,$64,$11,$FF,$EE,$EE,$EE,$EC,$22,$07,$66,$67,$7B
        .byte   $BA,$BB,$EC,$CF,$FE,$11,$11,$11,$03,$23,$8C,$C5,$08,$70,$82
        .byte   pr_p107>>8,pr_p107&$FF,1,254        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p106:                                 ; pose 182 du jeu, decalage 0,9
        .byte   $03,$04,$09,$01,$00,$00,$02,$03,$04,$05,$06,$07,$08,$09,$00,$F1
        .byte   $E0,$A7,$76,$BF,$06,$F0,$97,$41,$D1,$FD,$EE,$FB,$8F,$70,$85,$00
        .byte   $22,$07,$46,$7B,$02,$AA,$A1,$11,$11,$D1,$11,$15,$88,$CC,$88,$55
        .byte   $30,$86,$08,$10
pr_p107:                                 ; pose 1182 du jeu, decalage 0,0
        .byte   $03,$03,$09,$01,$02,$03,$04,$05,$06,$07,$08,$09,$00,$67,$67,$76
        .byte   $4D,$F6,$7D,$1F,$FE,$CF,$FE,$11,$1F,$FE,$C2,$08,$99,$60,$1A,$AA
        .byte   $A0,$01,$11,$11,$11,$11,$18,$8C,$CC,$88,$33,$20,$79,$90,$71,$10
        .byte   $85
        .byte   pr_p109>>8,pr_p109&$FF,255,254        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p108:                                 ; pose 183 du jeu, decalage 0,0
        .byte   $04,$02,$07,$00,$01,$02,$03,$04,$05,$06,$07,$64,$99,$9A,$AA,$01
        .byte   $11,$1F,$FE,$FF,$E1,$11,$80,$08,$CF,$BC,$F1,$CF,$0E,$F8,$6F,$86
        .byte   $BB,$B0,$34,$4A,$05,$B1,$11,$46,$60,$28,$EE,$11,$11,$05,$22,$23
pr_p109:                                 ; pose 1183 du jeu, decalage 0,3
        .byte   $04,$03,$0B,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$00
        .byte   $AB,$74,$F1,$EF,$1C,$02,$FF,$98,$53,$05,$EC,$07,$FB,$F9,$6F,$FB
        .byte   $50,$41,$11,$1D,$A0,$31,$11,$11,$1D,$99,$D8,$CC,$CE,$EF,$FE,$FF
        .byte   $EF,$FE,$FF,$E0,$79,$10,$71,$10,$71,$10,$73,$80
        .byte   pr_p111>>8,pr_p111&$FF,0,255        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p110:                                 ; pose 185 du jeu, decalage 0,1
        .byte   $05,$02,$09,$01,$02,$03,$04,$00,$05,$06,$07,$08,$09,$B0,$8D,$DF
        .byte   $FE,$11,$9A,$02,$19,$66,$F8,$7F,$C3,$FC,$3B,$01,$22,$22,$22,$20
        .byte   $64,$DF,$78,$F3,$CF,$1E,$70,$27,$FE,$FF,$EF,$FF,$7D,$99,$02,$31
        .byte   $11,$EF,$FE,$10,$33,$8E,$47,$A0,$73,$30
pr_p111:                                 ; pose 1185 du jeu, decalage 0,4
        .byte   $06,$02,$0C,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$7A
        .byte   $07,$1F,$C7,$A0,$61,$11,$94,$70,$31,$11,$11,$FF,$E0,$31,$11,$FF
        .byte   $EF,$78,$04,$22,$0D,$F1,$94,$47,$05,$11,$11,$05,$51,$11,$05,$91
        .byte   $11,$05,$F1,$C1,$11,$07,$22
        .byte   pr_p113>>8,pr_p113&$FF,0,6        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p112:                                 ; pose 172 du jeu, decalage 0,5
        .byte   $04,$04,$0C,$01,$02,$00,$00,$03,$04,$05,$00,$06,$07,$08,$00,$09
        .byte   $0A,$0B,$0C,$B0,$0A,$F0,$2A,$04,$EF,$EC,$F9,$CF,$7C,$C0,$89,$1F
        .byte   $C1,$00,$AA,$49,$99,$1F,$FE,$FF,$EF,$3C,$CF,$F4,$32,$20,$6B,$BA
        .byte   $A0,$5F,$F1,$11,$11,$D9,$46,$4E,$CC,$88,$88,$55,$30,$6A,$BB,$00
        .byte   $F3,$0F,$18,$F1,$CF,$1E,$F1,$CC,$EC,$FF,$90,$3B,$B6,$D1,$EF,$10
        .byte   $F1,$0F,$30,$F3,$08,$83,$20,$10
        .byte   pr_p115>>8,pr_p115&$FF,0,6        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p114:                                 ; pose 173 du jeu, decalage 0,5
        .byte   $04,$05,$0A,$00,$01,$02,$00,$03,$04,$05,$00,$00,$06,$07,$00,$00
        .byte   $08,$09,$0A,$00,$00,$00,$00,$9F,$0E,$F1,$9F,$27,$40,$43,$33,$32
        .byte   $07,$31,$70,$3A,$BB,$71,$1D,$74,$4E,$EC,$C8,$85,$52,$F4,$09,$94
        .byte   $66,$7B,$BA,$AC,$CE,$EF,$FE,$FF,$EF,$FE,$FF,$EF,$FE,$FF,$EF,$0E
        .byte   $77,$77,$64,$99,$90,$12,$00,$7F,$BF,$1F,$FE,$EC,$00,$F4,$0F,$60
        .byte   $F6,$08,$83,$02
        .byte   pr_p117>>8,pr_p117&$FF,0,3        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p116:                                 ; pose 174 du jeu, decalage 0,6
        .byte   $03,$05,$0B,$01,$02,$00,$03,$04,$05,$06,$07,$08,$00,$09,$0A,$00
        .byte   $0B,$00,$A0,$8F,$DF,$1F,$FE,$F7,$80,$92,$C4,$B0,$0A,$F7,$1F,$1B
        .byte   $77,$66,$F9,$F1,$DF,$BF,$EE,$CC,$88,$55,$33,$04,$3F,$30,$F0,$CB
        .byte   $A9,$94,$46,$7B,$AA,$FC,$12,$35,$8C,$EE,$EE,$EF,$38,$F1,$E6,$6F
        .byte   $06,$49,$99,$9F,$60,$F3,$0F,$38,$F3,$CF,$38,$85,$53,$30,$8F,$70
        .byte   pr_p119>>8,pr_p119&$FF,0,0        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p118:                                 ; pose 156 du jeu, decalage 0,5
        .byte   $05,$05,$11,$00,$01,$02,$00,$00,$00,$03,$04,$05,$00,$06,$07,$08
        .byte   $09,$00,$0A,$0B,$0C,$0D,$0E,$0F,$00,$00,$10,$11,$47,$F0,$CF,$13
        .byte   $60,$45,$F6,$05,$53,$05,$AA,$BB,$BB,$B6,$61,$11,$1F,$FE,$EC,$C5
        .byte   $FA,$02,$22,$06,$BA,$07,$FB,$FF,$DF,$FE,$FF,$77,$F3,$B4,$67,$01
        .byte   $11,$11,$11,$1F,$FE,$FF,$E1,$22,$20,$69,$DB,$BB,$AF,$21,$F1,$0F
        .byte   $08,$F0,$60,$12,$58,$8C,$EF,$FE,$D0,$4A,$B6,$49,$AA,$B4,$DF,$FE
        .byte   $E8,$32,$55,$50,$FF,$0E,$07,$BA,$07,$33
        .byte   pr_p121>>8,pr_p121&$FF,0,0        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p120:                                 ; pose 157 du jeu, decalage 0,5
        .byte   $06,$05,$11,$00,$00,$01,$02,$00,$00,$00,$00,$03,$04,$05,$00,$06
        .byte   $07,$08,$09,$0A,$00,$00,$00,$0B,$0C,$0D,$0E,$00,$00,$0F,$00,$10
        .byte   $11,$6B,$F0,$6F,$09,$70,$48,$FB,$0F,$70,$85,$04,$47,$BB,$BB,$BA
        .byte   $77,$11,$11,$11,$1F,$FE,$EF,$D0,$35,$53,$20,$AF,$78,$70,$82,$F7
        .byte   $E7,$DD,$44,$7A,$02,$EF,$8F,$11,$11,$1D,$DD,$D3,$33,$33,$33,$20
        .byte   $02,$94,$F0,$EF,$0C,$F3,$CF,$3E,$F3,$EF,$7E,$F7,$EF,$7E,$04,$AB
        .byte   $77,$6B,$AA,$4D,$FF,$EE,$C3,$33,$33,$0F,$E0,$77,$B0,$83
        .byte   pr_p123>>8,pr_p123&$FF,0,251        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p122:                                 ; pose 158 du jeu, decalage 0,6
        .byte   $07,$05,$12,$00,$00,$00,$00,$01,$02,$00,$03,$04,$05,$06,$07,$08
        .byte   $09,$00,$00,$00,$00,$0A,$0B,$0C,$00,$00,$00,$00,$0D,$0E,$0F,$00
        .byte   $00,$00,$10,$11,$00,$12,$F1,$DF,$33,$F4,$F9,$05,$22,$20,$8B,$08
        .byte   $10,$81,$07,$FE,$F1,$F3,$00,$5A,$11,$94,$46,$9F,$3E,$D1,$11,$11
        .byte   $11,$EC,$22,$35,$53,$20,$3D,$94,$67,$BA,$02,$F9,$FF,$DF,$11,$11
        .byte   $11,$11,$33,$55,$55,$33,$32,$F7,$CF,$18,$F3,$CF,$3E,$F3,$EF,$3E
        .byte   $F7,$ED,$DD,$03,$AB,$76,$44,$F0,$6F,$1E,$F7,$EE,$EC,$85,$33,$08
        .byte   $B0,$8E,$07,$46
        .byte   pr_p125>>8,pr_p125&$FF,0,251        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p124:                                 ; pose 170 du jeu, decalage 0,6
        .byte   $07,$05,$12,$00,$00,$00,$00,$01,$02,$00,$03,$04,$05,$06,$07,$08
        .byte   $09,$00,$00,$00,$00,$0A,$0B,$0C,$00,$00,$00,$00,$0D,$0E,$0F,$00
        .byte   $00,$00,$10,$11,$00,$12,$F1,$DF,$33,$F4,$F9,$05,$22,$20,$8B,$08
        .byte   $10,$81,$07,$FE,$F1,$F3,$00,$5A,$11,$94,$46,$9F,$3E,$D1,$11,$11
        .byte   $11,$EC,$22,$35,$53,$20,$3D,$94,$67,$BA,$02,$F9,$FF,$DF,$11,$11
        .byte   $11,$11,$33,$55,$55,$33,$32,$F7,$CF,$18,$F3,$CF,$3E,$F3,$EF,$3E
        .byte   $F7,$ED,$DD,$03,$AB,$76,$44,$F0,$6F,$1E,$F7,$EE,$EC,$85,$33,$08
        .byte   $B0,$8E,$07,$46
        .byte   pr_p127>>8,pr_p127&$FF,0,251        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p126:                                 ; pose 171 du jeu, decalage 0,6
        .byte   $07,$05,$12,$00,$00,$00,$00,$01,$02,$00,$03,$04,$05,$06,$07,$08
        .byte   $09,$00,$00,$00,$00,$0A,$0B,$0C,$00,$00,$00,$00,$0D,$0E,$0F,$00
        .byte   $00,$00,$10,$11,$00,$12,$F1,$DF,$33,$F4,$F9,$05,$22,$20,$8B,$08
        .byte   $10,$81,$07,$FE,$F1,$F3,$00,$5A,$11,$94,$46,$9F,$3E,$D1,$11,$11
        .byte   $11,$EC,$22,$35,$53,$20,$3D,$94,$67,$BA,$02,$F9,$FF,$DF,$11,$11
        .byte   $11,$11,$33,$55,$55,$33,$32,$F7,$CF,$18,$F3,$CF,$3E,$F3,$EF,$3E
        .byte   $F7,$ED,$DD,$03,$AB,$76,$44,$F0,$6F,$1E,$F7,$EE,$EC,$85,$33,$08
        .byte   $B0,$8E,$07,$46
        .byte   pr_p129>>8,pr_p129&$FF,255,253        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p128:                                 ; pose 167 du jeu, decalage 0,8
        .byte   $08,$05,$16,$00,$00,$00,$00,$01,$02,$03,$04,$00,$05,$06,$07,$08
        .byte   $09,$0A,$0B,$0C,$0D,$00,$00,$0E,$0F,$10,$00,$00,$00,$00,$00,$11
        .byte   $00,$12,$13,$00,$00,$00,$14,$15,$00,$00,$16,$F2,$74,$07,$52,$07
        .byte   $D0,$83,$08,$70,$88,$77,$07,$31,$40,$6A,$11,$D4,$49,$F0,$EF,$19
        .byte   $11,$11,$FF,$EF,$FE,$F7,$E1,$FC,$7F,$E1,$32,$05,$31,$08,$30,$6F
        .byte   $78,$70,$82,$F7,$E9,$99,$6B,$05,$3C,$11,$19,$99,$DF,$7E,$FF,$EE
        .byte   $EE,$CC,$C8,$5C,$F3,$0F,$30,$F3,$8F,$7C,$F7,$EF,$7E,$F7,$EF,$7E
        .byte   $F3,$E0,$2B,$64,$49,$F3,$EF,$7E,$F1,$EF,$1E,$FF,$68,$85,$30,$B7
        .byte   $08,$C0,$7F,$3C,$F1,$E0
        .byte   pr_p131>>8,pr_p131&$FF,0,0        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p130:                                 ; pose 155 du jeu, decalage 0,8
        .byte   $07,$05,$13,$00,$00,$01,$00,$00,$00,$00,$00,$00,$02,$03,$04,$00
        .byte   $00,$05,$06,$07,$08,$09,$00,$00,$00,$0A,$0B,$0C,$0D,$0E,$0F,$00
        .byte   $10,$11,$00,$00,$12,$13,$F9,$FF,$7E,$07,$77,$77,$4D,$F7,$D1,$F3
        .byte   $BF,$67,$11,$1E,$83,$03,$53,$08,$F7,$87,$08,$2F,$7E,$70,$41,$94
        .byte   $71,$44,$AA,$A1,$11,$11,$11,$11,$1C,$C8,$88,$5F,$DC,$F9,$CF,$3C
        .byte   $87,$AA,$AA,$AA,$A0,$13,$33,$58,$CC,$C1,$10,$6A,$AF,$E3,$01,$A4
        .byte   $9D,$1E,$CC,$B7,$11,$83,$03,$22,$22,$0E,$90,$83,$07,$BB,$08,$20
        .byte   pr_p133>>8,pr_p133&$FF,1,2        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p132:                                 ; pose 162 du jeu, decalage 0,3
        .byte   $04,$06,$0F,$01,$00,$00,$00,$02,$03,$04,$00,$00,$05,$06,$00,$07
        .byte   $08,$09,$00,$0A,$0B,$0C,$0D,$00,$00,$0E,$0F,$F0,$4F,$08,$F1,$0F
        .byte   $10,$F2,$0F,$40,$F4,$00,$6A,$BB,$7F,$06,$F0,$49,$DF,$71,$FE,$3F
        .byte   $C4,$F8,$32,$02,$FE,$8C,$FD,$8F,$38,$C8,$03,$44,$46,$49,$96,$64
        .byte   $88,$8C,$CE,$EE,$EC,$9D,$D1,$19,$6B,$03,$AF,$C1,$11,$11,$19,$EE
        .byte   $EE,$CC,$CC,$CC,$67,$BB,$B7,$64,$49,$00,$35,$52,$22,$22,$20,$27
        .byte   $64,$9D,$DF,$FE,$88,$82,$22,$20,$AA,$08,$35
        .byte   pr_p135>>8,pr_p135&$FF,0,1        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p134:                                 ; pose 152 du jeu, decalage 0,4
        .byte   $05,$05,$11,$00,$01,$02,$00,$00,$03,$04,$05,$06,$00,$07,$08,$09
        .byte   $0A,$00,$0B,$0C,$0D,$0E,$0F,$00,$00,$00,$10,$11,$F4,$1B,$00,$AF
        .byte   $02,$A0,$3F,$F4,$FF,$EF,$EE,$F9,$CF,$7C,$C0,$8A,$4F,$1E,$7A,$04
        .byte   $11,$70,$0F,$81,$DD,$11,$11,$11,$D1,$22,$22,$23,$33,$88,$AA,$07
        .byte   $8C,$11,$19,$7A,$01,$77,$61,$11,$11,$1D,$88,$55,$55,$33,$33,$C9
        .byte   $46,$7B,$BB,$BA,$05,$38,$88,$06,$AB,$BA,$AA,$64,$DF,$FE,$EC,$85
        .byte   $55,$22,$0C,$BA,$07,$35
        .byte   pr_p137>>8,pr_p137&$FF,0,249        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p136:                                 ; pose 153 du jeu, decalage 0,7
        .byte   $08,$05,$16,$00,$00,$00,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09
        .byte   $0A,$0B,$0C,$00,$00,$00,$00,$0D,$0E,$0F,$00,$00,$00,$00,$00,$10
        .byte   $11,$12,$13,$00,$00,$00,$14,$15,$00,$00,$16,$F1,$36,$07,$58,$80
        .byte   $69,$08,$50,$99,$08,$10,$8F,$FB,$F1,$B0,$75,$16,$06,$A1,$19,$66
        .byte   $47,$F0,$C1,$11,$1F,$FE,$FF,$EF,$BE,$1F,$63,$53,$32,$03,$25,$10
        .byte   $85,$44,$47,$A0,$45,$C1,$11,$D9,$99,$DF,$7E,$FF,$EE,$EE,$CC,$C8
        .byte   $5F,$7C,$F1,$8F,$18,$F3,$EF,$3E,$99,$94,$40,$82,$02,$A7,$44,$99
        .byte   $F7,$E6,$6D,$CC,$53,$20,$AB,$08,$E0,$7F,$1E,$60
        .byte   pr_p139>>8,pr_p139&$FF,255,254        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p138:                                 ; pose 154 du jeu, decalage 0,1
        .byte   $09,$04,$13,$01,$02,$03,$04,$05,$06,$07,$08,$00,$00,$00,$00,$00
        .byte   $09,$0A,$0B,$0C,$00,$00,$00,$00,$00,$0D,$0E,$0F,$10,$11,$00,$00
        .byte   $00,$00,$12,$00,$00,$00,$13,$90,$81,$08,$14,$07,$21,$60,$6A,$11
        .byte   $64,$7F,$2C,$F3,$B6,$00,$11,$1F,$BF,$1F,$70,$85,$30,$05,$55,$11
        .byte   $A0,$73,$CF,$38,$02,$66,$A0,$61,$11,$4B,$B7,$69,$11,$11,$11,$1F
        .byte   $FE,$EC,$83,$22,$06,$4F,$06,$F0,$26,$66,$66,$66,$03,$22,$33,$31
        .byte   $04,$A7,$64,$10,$17,$D1,$FF,$EC,$85,$3F,$1C,$F3,$CE,$E2,$0D,$10
        .byte   $7F,$18,$F1,$C0
        .byte   pr_p141>>8,pr_p141&$FF,0,1        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p140:                                 ; pose 169 du jeu, decalage 0,5
        .byte   $06,$05,$13,$01,$00,$02,$03,$00,$00,$04,$05,$06,$07,$08,$00,$00
        .byte   $00,$09,$0A,$0B,$00,$00,$00,$0C,$0D,$0E,$0F,$00,$00,$10,$11,$12
        .byte   $13,$7F,$1C,$F7,$00,$6A,$01,$A0,$5F,$FE,$F7,$6F,$CE,$F3,$EE,$0D
        .byte   $A0,$4B,$BF,$0A,$F7,$85,$03,$91,$1A,$01,$49,$9D,$11,$11,$1F,$FB
        .byte   $CC,$C8,$85,$55,$53,$46,$7B,$A0,$4F,$E1,$FF,$1F,$F9,$11,$1D,$94
        .byte   $6E,$EE,$EE,$EE,$EE,$E6,$BB,$76,$64,$44,$43,$22,$23,$33,$33,$3A
        .byte   $B7,$44,$9D,$F7,$EF,$FE,$FF,$E3,$33,$33,$20,$C9,$08,$30,$77,$B0
        .byte   $72,$30
        .byte   pr_p143>>8,pr_p143&$FF,1,0        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p142:                                 ; pose 150 du jeu, decalage 0,9
        .byte   $06,$06,$13,$01,$00,$00,$00,$00,$00,$02,$03,$04,$05,$06,$00,$00
        .byte   $00,$07,$08,$09,$00,$00,$00,$0A,$0B,$0C,$00,$00,$00,$0D,$0E,$0F
        .byte   $10,$00,$00,$11,$00,$12,$13,$30,$FB,$F0,$CF,$30,$01,$AB,$F0,$EF
        .byte   $30,$30,$24,$F7,$C8,$30,$5F,$9F,$9F,$0E,$F1,$9F,$27,$40,$3F,$40
        .byte   $33,$33,$20,$BA,$79,$9D,$DD,$99,$D1,$18,$88,$88,$88,$88,$8D,$D9
        .byte   $46,$7B,$A0,$1B,$F8,$7F,$C7,$FF,$71,$11,$11,$DC,$CC,$CC,$88,$88
        .byte   $84,$67,$66,$49,$9D,$D2,$20,$12,$2F,$81,$AB,$BB,$76,$9D,$1F,$FE
        .byte   $EC,$C2,$00,$22,$20,$DF,$7C,$07,$67,$08,$20
        .byte   pr_p145>>8,pr_p145&$FF,0,2        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p144:                                 ; pose 168 du jeu, decalage 0,7
        .byte   $07,$05,$13,$00,$00,$00,$01,$02,$00,$00,$03,$04,$05,$06,$07,$08
        .byte   $00,$00,$00,$09,$0A,$0B,$0C,$00,$00,$00,$00,$0D,$0E,$0F,$10,$00
        .byte   $00,$00,$11,$00,$12,$13,$00,$A0,$7F,$CE,$F3,$EE,$08,$40,$6A,$D5
        .byte   $06,$1F,$83,$07,$C1,$6B,$A0,$2A,$00,$91,$11,$19,$1F,$FA,$FF,$EF
        .byte   $76,$1F,$FE,$EC,$C8,$20,$B7,$66,$BA,$04,$2F,$FB,$11,$11,$94,$64
        .byte   $4C,$CE,$EE,$EE,$EF,$FE,$1F,$3E,$F0,$EF,$06,$64,$44,$44,$40,$32
        .byte   $2F,$81,$F8,$1F,$83,$FE,$3B,$A6,$4F,$7E,$FF,$EE,$C8,$83,$32,$0F
        .byte   $FF,$E0,$77,$70,$73,$30
        .byte   pr_p147>>8,pr_p147&$FF,0,0        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p146:                                 ; pose 151 du jeu, decalage 0,8
        .byte   $05,$05,$10,$00,$01,$02,$00,$00,$03,$04,$05,$06,$00,$00,$07,$08
        .byte   $09,$00,$00,$0A,$0B,$0C,$0D,$00,$0E,$00,$0F,$10,$F0,$2A,$07,$F7
        .byte   $CC,$0C,$6E,$04,$6D,$DF,$E1,$AB,$00,$AD,$11,$11,$1F,$F7,$EF,$EC
        .byte   $F9,$C3,$88,$33,$22,$02,$DD,$47,$A0,$4F,$DF,$11,$11,$D9,$99,$D3
        .byte   $35,$55,$53,$33,$3F,$1E,$F0,$CF,$1C,$F1,$EF,$1E,$F3,$EF,$3E,$F3
        .byte   $EF,$7E,$D0,$3A,$B7,$76,$6A,$49,$FF,$EE,$C5,$33,$32,$0F,$01,$FF
        .byte   $E0,$77,$A0,$73,$30
        .byte   pr_p149>>8,pr_p149&$FF,0,255        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p148:                                 ; pose 160 du jeu, decalage 0,5
        .byte   $06,$05,$11,$00,$00,$00,$01,$02,$00,$00,$00,$03,$04,$05,$00,$06
        .byte   $07,$08,$09,$0A,$00,$00,$00,$0B,$0C,$0D,$0E,$00,$00,$0F,$00,$10
        .byte   $11,$DF,$1D,$FB,$3F,$CF,$90,$42,$22,$20,$5F,$1B,$F3,$00,$7F,$E7
        .byte   $19,$66,$66,$69,$F3,$EE,$CE,$FF,$EF,$FE,$EC,$C5,$20,$5F,$7C,$70
        .byte   $85,$F3,$EB,$BA,$05,$F1,$8F,$FB,$FF,$D1,$1D,$94,$67,$BF,$83,$EE
        .byte   $EF,$FE,$FF,$EF,$FE,$FF,$EF,$FE,$EE,$BA,$00,$AA,$AA,$BB,$B5,$53
        .byte   $58,$CC,$CC,$FF,$D7,$76,$49,$DF,$7E,$FF,$EE,$E0,$02,$22,$0E,$60
        .byte   $74,$60,$72,$20
        .byte   pr_p151>>8,pr_p151&$FF,255,248        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p150:                                 ; pose 163 du jeu, decalage 0,6
        .byte   $08,$05,$15,$00,$00,$00,$00,$01,$02,$00,$00,$03,$04,$05,$06,$07
        .byte   $08,$09,$00,$00,$00,$00,$0A,$0B,$0C,$0D,$00,$00,$00,$00,$0E,$0F
        .byte   $10,$11,$00,$00,$00,$00,$12,$13,$00,$14,$15,$F0,$EF,$19,$F2,$74
        .byte   $05,$33,$32,$07,$B0,$81,$08,$10,$7F,$E7,$FF,$7F,$30,$05,$BF,$F3
        .byte   $19,$66,$74,$49,$11,$11,$11,$1E,$F7,$C3,$00,$33,$22,$04,$BA,$07
        .byte   $E1,$1D,$96,$7A,$AA,$9D,$11,$11,$11,$11,$22,$22,$22,$03,$A0,$3A
        .byte   $AA,$BB,$88,$F6,$05,$88,$85,$8C,$02,$AB,$76,$64,$97,$F1,$CF,$7E
        .byte   $EC,$83,$33,$30,$8B,$08,$30,$77,$70,$72,$20
        .byte   pr_p153>>8,pr_p153&$FF,0,251        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p152:                                 ; pose 164 du jeu, decalage 0,6
        .byte   $08,$05,$13,$00,$00,$00,$00,$01,$02,$00,$00,$03,$04,$05,$06,$07
        .byte   $08,$00,$00,$00,$00,$00,$09,$0A,$0B,$0C,$00,$00,$00,$00,$0D,$0E
        .byte   $0F,$10,$11,$00,$00,$00,$00,$00,$00,$12,$13,$F0,$EF,$19,$F2,$74
        .byte   $05,$33,$32,$07,$B0,$81,$08,$10,$75,$FF,$7F,$37,$05,$7B,$11,$77
        .byte   $74,$49,$EE,$EE,$EC,$C8,$F4,$03,$66,$66,$70,$43,$C1,$11,$D7,$00
        .byte   $A7,$44,$11,$11,$11,$FF,$EF,$FE,$53,$33,$22,$06,$14,$F0,$66,$66
        .byte   $60,$62,$22,$03,$AB,$77,$66,$B6,$D1,$FF,$EE,$88,$55,$20,$F0,$0B
        .byte   $B0,$73,$30
        .byte   pr_p155>>8,pr_p155&$FF,0,251        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p154:                                 ; pose 165 du jeu, decalage 0,6
        .byte   $08,$05,$16,$00,$00,$00,$00,$01,$02,$00,$00,$03,$04,$05,$06,$07
        .byte   $08,$09,$00,$00,$00,$00,$0A,$0B,$0C,$0D,$00,$00,$00,$00,$0E,$0F
        .byte   $10,$11,$12,$00,$00,$00,$13,$14,$00,$15,$16,$F1,$9F,$27,$40,$63
        .byte   $32,$08,$B0,$81,$08,$10,$7F,$E7,$FF,$7F,$30,$05,$B1,$16,$67,$44
        .byte   $9F,$0E,$11,$11,$11,$EF,$78,$33,$58,$83,$30,$4A,$08,$11,$D4,$6B
        .byte   $A0,$1A,$11,$11,$11,$11,$11,$33,$22,$03,$23,$A0,$1A,$AA,$AA,$AA
        .byte   $8F,$60,$F6,$08,$88,$CC,$E1,$03,$B7,$66,$44,$AA,$F1,$D1,$1F,$FE
        .byte   $C8,$53,$33,$55,$50,$D6,$08,$80,$8A,$08,$20
pr_p156:                                 ; pose 207 du jeu, decalage 0,2
        .byte   $02,$05,$09,$01,$02,$03,$04,$05,$06,$07,$08,$00,$09,$A7,$76,$BF
        .byte   $06,$F0,$97,$01,$55,$88,$FB,$0F,$70,$85,$01,$74,$F3,$BF,$73,$F7
        .byte   $B9,$94,$47,$FF,$E1,$11,$11,$11,$1F,$FE,$AB,$BB,$BB,$BB,$BB,$EC
        .byte   $CE,$EE,$FF,$EF,$FE,$FF,$EF,$FE,$06,$AA,$A9,$6F,$1E,$F3,$EF,$3E
        .byte   $F7,$EF,$FE,$EE,$E0,$8F,$3C
pr_p157:                                 ; pose 208 du jeu, decalage 0,3
        .byte   $02,$05,$09,$01,$02,$03,$04,$05,$06,$07,$08,$00,$09,$66,$47,$F0
        .byte   $CF,$13,$60,$25,$FA,$05,$F6,$05,$53,$02,$B7,$76,$11,$D9,$47,$EF
        .byte   $FE,$FF,$EF,$FE,$FF,$EF,$FE,$FF,$EF,$FE,$FF,$EC,$77,$77,$BB,$BB
        .byte   $BB,$CC,$EE,$EE,$FF,$EF,$FE,$FF,$EE,$04,$AB,$77,$7D,$DF,$3E,$F7
        .byte   $EF,$FE,$FF,$EE,$EC,$C0,$8F,$3C
pr_p169:                                 ; pose 191 du jeu, decalage 0,0
        .byte   $04,$02,$08,$01,$02,$03,$04,$05,$06,$07,$08,$02,$7F,$2B,$F3,$7F
        .byte   $3B,$44,$6F,$EF,$DD,$FB,$F1,$11,$1F,$C7,$00,$11,$11,$11,$11,$C0
        .byte   $03,$58,$85,$32,$04,$F3,$CF,$7E,$F7,$EF,$3C,$F1,$E9,$F7,$3F,$30
        .byte   $01,$BA,$01,$B7,$FC,$FF,$CF,$F3,$CF,$0E,$F8,$EE,$EE,$EE,$E1,$08
        .byte   $20
pr_p170:                                 ; pose 193 du jeu, decalage 0,2
        .byte   $04,$03,$09,$01,$02,$03,$00,$04,$05,$06,$07,$00,$08,$09,$00,$B6
        .byte   $F5,$7F,$6F,$F7,$79,$9F,$1E,$01,$FC,$FD,$11,$1F,$9F,$20,$21,$1F
        .byte   $FE,$E8,$30,$86,$44,$67,$99,$99,$47,$F8,$3F,$81,$00,$F8,$35,$35
        .byte   $CE,$FF,$E1,$11,$10,$62,$22,$01,$F0,$C6,$BB,$66,$44,$8F,$7C,$F7
        .byte   $CC,$88,$88,$55
pr_p171:                                 ; pose 195 du jeu, decalage 0,4
        .byte   $03,$04,$09,$01,$02,$00,$03,$04,$05,$00,$06,$07,$00,$08,$09,$7B
        .byte   $7A,$6B,$03,$1F,$FE,$88,$55,$07,$F7,$0C,$CF,$FE,$9F,$3B,$77,$76
        .byte   $44,$99,$11,$CC,$CC,$C8,$55,$32,$DD,$DD,$96,$44,$67,$03,$23,$58
        .byte   $CC,$7A,$96,$66,$49,$99,$38,$55,$55,$33,$22
pr_p172:                                 ; pose 197 du jeu, decalage 0,8
        .byte   $03,$05,$0C,$01,$02,$03,$04,$05,$06,$00,$07,$08,$00,$09,$0A,$00
        .byte   $0B,$0C,$F1,$E0,$8F,$27,$F1,$C0,$72,$0C,$AB,$B4,$99,$44,$91,$FE
        .byte   $FF,$BE,$FB,$FF,$3D,$F0,$DF,$1B,$55,$53,$00,$22,$23,$34,$44,$99
        .byte   $99,$99,$95,$53,$55,$88,$88,$89,$DD,$DD,$D9,$99,$92,$04,$22,$35
        .byte   $A0,$0F,$3E,$77,$76,$49,$98,$85,$53,$33,$33,$20
pr_p173:                                 ; pose 199 du jeu, decalage 0,6
        .byte   $02,$05,$0A,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$F3,$8F,$7C
        .byte   $F7,$CF,$38,$05,$FB,$0F,$60,$07,$46,$77,$6F,$0D,$4F,$1B,$F0,$BF
        .byte   $0C,$88,$85,$FD,$0C,$FD,$CF,$EC,$F5,$CF,$58,$44,$4D,$DD,$D9,$94
        .byte   $23,$58,$EE,$EE,$CC,$44,$44,$44,$44,$99,$20,$22,$22,$32,$20,$17
        .byte   $B7,$76,$64,$4C,$F3,$88,$88,$55,$33,$20
pr_p177:                                 ; pose 198 du jeu, decalage 0,6
        .byte   $02,$05,$0A,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$F7,$BF,$FB
        .byte   $CF,$70,$05,$F7,$03,$07,$44,$66,$64,$9F,$37,$F3,$7F,$39,$88,$55
        .byte   $3F,$A0,$8F,$B0,$FB,$8C,$44,$44,$99,$99,$44,$53,$35,$8C,$EE,$CC
        .byte   $64,$44,$44,$44,$44,$32,$22,$23,$33,$55,$01,$67,$AA,$B7,$66,$F7
        .byte   $8F,$7C,$FB,$CC,$CC,$C8,$85
        .byte   pr_p179>>8,pr_p179&$FF,0,0        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p178:                                 ; pose 177 du jeu, decalage 0,6
        .byte   $06,$04,$0E,$00,$00,$01,$02,$00,$00,$00,$03,$04,$05,$06,$00,$07
        .byte   $08,$09,$0A,$0B,$0C,$00,$00,$00,$0D,$0E,$00,$1D,$47,$05,$EE,$C8
        .byte   $0C,$AA,$A1,$F3,$EF,$38,$F3,$A9,$9F,$DF,$11,$11,$DD,$DD,$11,$11
        .byte   $FF,$E3,$33,$32,$20,$3B,$76,$07,$23,$FB,$8D,$D9,$46,$B0,$1F,$60
        .byte   $F6,$0F,$30,$82,$FC,$3F,$F3,$17,$7F,$6F,$1D,$D1,$11,$1F,$F4,$FE
        .byte   $4F,$8E,$FC,$EF,$DD,$FD,$3F,$C7,$FC,$63,$30,$32,$20,$BA,$B0,$65
        .byte   $8C
pr_p180:                                 ; pose 121 du jeu, decalage 0,0
        .byte   $02,$04,$08,$01,$02,$03,$04,$05,$06,$07,$08,$67,$74,$49,$F0,$EF
        .byte   $19,$F2,$74,$53,$20,$0F,$40,$33,$33,$24,$44,$44,$44,$44,$65,$55
        .byte   $55,$55,$55,$57,$66,$64,$44,$44,$48,$55,$33,$33,$55,$57,$A0,$2A
        .byte   $AB,$B7,$58,$F7,$0F,$70,$F7,$8C,$CC,$88
pr_p181:                                 ; pose 122 du jeu, decalage 0,1
        .byte   $02,$04,$08,$01,$02,$03,$04,$05,$06,$07,$08,$BB,$66,$47,$F0,$CF
        .byte   $13,$60,$05,$32,$FA,$05,$F6,$05,$53,$00,$44,$44,$46,$66,$77,$55
        .byte   $55,$55,$55,$55,$99,$99,$99,$99,$94,$22,$22,$23,$35,$55,$B0,$2B
        .byte   $76,$64,$92,$5F,$78,$F7,$88,$85,$53,$30
pr_p182:                                 ; pose 123 du jeu, decalage 0,1
        .byte   $02,$04,$08,$01,$02,$03,$04,$05,$06,$07,$08,$BB,$66,$47,$F0,$CF
        .byte   $13,$60,$05,$32,$FA,$05,$F6,$05,$53,$00,$96,$66,$66,$66,$77,$88
        .byte   $58,$88,$88,$88,$DD,$D9,$94,$46,$69,$22,$33,$55,$88,$88,$F0,$E7
        .byte   $BA,$64,$49,$9D,$00,$25,$88,$85,$53,$30
pr_p189:                                 ; pose 144 du jeu, decalage 0,0
        .byte   $04,$03,$09,$01,$02,$03,$04,$05,$06,$07,$08,$00,$00,$00,$09,$FD
        .byte   $7F,$DF,$FE,$F1,$1F,$7E,$03,$99,$FB,$F1,$11,$19,$6B,$FF,$E1,$11
        .byte   $11,$11,$11,$02,$22,$22,$22,$09,$F4,$40,$05,$F6,$1F,$61,$F6,$3F
        .byte   $33,$F3,$6F,$36,$F3,$D9,$00,$FC,$8F,$CD,$F8,$F6,$F3,$EF,$7E,$EE
        .byte   $FF,$EF,$3C,$C5,$32,$0A,$F1,$0F,$18,$F1,$8F,$1C
pr_p190:                                 ; pose 143 du jeu, decalage 0,5
        .byte   $04,$03,$09,$01,$02,$03,$04,$05,$06,$07,$08,$00,$00,$00,$09,$F7
        .byte   $7D,$D9,$05,$11,$19,$40,$41,$11,$11,$04,$35,$53,$0C,$F2,$2F,$6B
        .byte   $F6,$FF,$60,$F3,$1F,$19,$F1,$CF,$0E,$7B,$BF,$87,$FD,$F1,$11,$EF
        .byte   $FD,$D1,$11,$1F,$FE,$FF,$EF,$60,$F7,$0C,$53,$20,$02,$05,$F0,$2F
        .byte   $02,$F0,$6F,$0E
pr_p191:                                 ; pose 142 du jeu, decalage 0,7
        .byte   $04,$03,$09,$01,$02,$03,$00,$04,$05,$06,$07,$00,$00,$08,$09,$1F
        .byte   $7E,$07,$1D,$40,$61,$FF,$EE,$0B,$F4,$4F,$D7,$FD,$FF,$EF,$1F,$7C
        .byte   $47,$BB,$76,$F9,$F1,$1B,$7F,$CF,$11,$11,$11,$18,$55,$33,$33,$33
        .byte   $20,$8A,$00,$F1,$8F,$0C,$F0,$CF,$0E,$F0,$EF,$38,$F7,$CE,$C0
pr_p192:                                 ; pose 141 du jeu, decalage 0,9
        .byte   $03,$04,$0A,$01,$02,$03,$04,$05,$06,$07,$08,$09,$00,$00,$0A,$F7
        .byte   $E0,$8D,$08,$50,$86,$A0,$1F,$44,$FD,$7F,$DF,$FE,$F1,$1F,$E1,$19
        .byte   $49,$D1,$1D,$1E,$EE,$FF,$EF,$FE,$FF,$EF,$FE,$FF,$EE,$C0,$8F,$0C
        .byte   $03,$AA,$AA,$AA,$EC,$CC,$88,$88,$CC,$03,$8F,$3C,$F1,$CF,$18,$F3
        .byte   $8F,$7C
pr_p193:                                 ; pose 140 du jeu, decalage 0,6
        .byte   $04,$04,$0B,$01,$02,$03,$00,$04,$05,$06,$07,$00,$00,$08,$09,$00
        .byte   $00,$0A,$0B,$F7,$7D,$D9,$05,$1F,$BE,$30,$62,$0B,$B0,$2F,$22,$F6
        .byte   $BF,$6F,$01,$AF,$FD,$D4,$49,$FB,$F1,$D1,$11,$FF,$EF,$FE,$EC,$53
        .byte   $22,$07,$F3,$EF,$3E,$F3,$CF,$7E,$DD,$DD,$DD,$06,$22,$20,$1F,$1E
        .byte   $7B,$64,$49,$F3,$E0,$22,$20,$40
pr_p195:                                 ; pose 136 du jeu, decalage 0,5
        .byte   $02,$05,$0A,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$F3,$7F,$3C
        .byte   $F3,$39,$F7,$00,$4F,$60,$55,$30,$56,$66,$99,$9F,$37,$99,$98,$88
        .byte   $88,$85,$2F,$A0,$59,$99,$44,$44,$46,$62,$22,$33,$35,$55,$54,$44
        .byte   $99,$99,$99,$92,$22,$20,$32,$20,$0F,$0C,$F0,$67,$77,$77,$64,$03
        .byte   $22,$02,$20
pr_p196:                                 ; pose 91 du jeu, decalage 0,3
        .byte   $02,$06,$0B,$01,$00,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$F0
        .byte   $6F,$06,$F0,$6F,$06,$F0,$E0,$46,$B7,$67,$77,$77,$F0,$68,$FB,$08
        .byte   $85,$04,$99,$99,$44,$6B,$77,$33,$58,$88,$85,$5F,$D0,$DD,$DD,$99
        .byte   $99,$99,$33,$33,$35,$55,$33,$99,$99,$9D,$DD,$DD,$22,$22,$23,$33
        .byte   $33,$F1,$8F,$1C,$F1,$E6,$66,$44,$44,$03,$22,$01,$22
pr_p197:                                 ; pose 90 du jeu, decalage 0,5
        .byte   $02,$06,$0B,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$00,$03
        .byte   $A0,$43,$33,$33,$04,$BB,$00,$A0,$5E,$EE,$C8,$33,$33,$39,$44,$46
        .byte   $77,$BA,$B5,$8C,$CC,$CC,$88,$C1,$11,$11,$DD,$DD,$D2,$33,$35,$55
        .byte   $55,$5F,$3E,$F3,$EF,$3E,$DD,$D1,$11,$10,$52,$22,$2F,$60,$F7,$0F
        .byte   $78,$F3,$CF,$3E,$F3,$EF,$3E,$F3,$EF,$3E,$F3,$E0
pr_p198:                                 ; pose 89 du jeu, decalage 0,5
        .byte   $02,$06,$09,$00,$01,$00,$02,$03,$04,$05,$06,$07,$08,$09,$00,$F1
        .byte   $8F,$18,$F1,$8F,$18,$F3,$80,$4F,$FE,$11,$9F,$7E,$F3,$CF,$18,$F1
        .byte   $8F,$18,$F1,$86,$67,$7B,$AA,$A0,$18,$CE,$FF,$EF,$FE,$FF,$EF,$FE
        .byte   $FF,$EE,$F7,$C9,$99,$99,$44,$44,$43,$33,$35,$88,$88,$89,$99,$99
        .byte   $DD,$DD,$D0,$62,$22,$01,$38,$F7,$EF,$3E,$F1,$E9,$99
pr_p209:                                 ; pose 135 du jeu, decalage 0,5
        .byte   $02,$06,$0A,$01,$00,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$00,$F3
        .byte   $0F,$30,$F3,$0F,$30,$F7,$00,$4F,$1E,$44,$99,$9F,$30,$F3,$0F,$30
        .byte   $F3,$02,$22,$22,$04,$99,$99,$99,$44,$44,$22,$22,$22,$22,$20,$09
        .byte   $99,$99,$99,$99,$92,$22,$22,$22,$22,$24,$44,$44,$99,$99,$90,$52
        .byte   $22,$20,$2F,$0C,$F0,$CF,$06,$77,$F0,$EF,$0E
pr_p210:                                 ; pose 137 du jeu, decalage 0,0
        .byte   $02,$05,$0A,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$77,$77,$19
        .byte   $67,$6B,$CC,$85,$55,$F7,$08,$85,$66,$66,$66,$66,$66,$CC,$CC,$CC
        .byte   $CC,$CC,$77,$77,$77,$77,$66,$55,$55,$58,$88,$8C,$01,$AA,$BB,$77
        .byte   $77,$85,$38,$88,$88,$88,$05,$BA,$A0,$72,$35
pr_p214:                                 ; pose 149 du jeu, decalage 0,6
        .byte   $03,$04,$09,$01,$02,$00,$03,$04,$05,$00,$06,$07,$00,$08,$09,$F1
        .byte   $9F,$27,$40,$63,$32,$0B,$A4,$49,$F0,$EF,$3B,$9D,$D1,$11,$13,$31
        .byte   $1F,$FE,$FF,$EE,$C5,$02,$BB,$64,$4F,$1B,$F1,$BF,$19,$F1,$9F,$19
        .byte   $88,$CC,$EF,$FE,$FF,$E1,$11,$07,$AA,$F6,$0F,$38,$F1,$EF,$1E,$F1
        .byte   $CF,$38,$CC,$C8
pr_p217:                                 ; pose 104 du jeu, decalage 0,3
        .byte   $03,$04,$0A,$01,$02,$03,$04,$05,$06,$00,$07,$08,$00,$09,$0A,$B0
        .byte   $0A,$A0,$51,$DF,$BF,$FD,$F1,$FF,$EF,$78,$02,$53,$30,$D2,$C4,$AA
        .byte   $AA,$B7,$76,$6F,$9F,$EE,$EE,$EC,$C8,$85,$99,$99,$94,$46,$7B,$53
        .byte   $32,$35,$8C,$EE,$01,$F7,$0F,$38,$F1,$E6,$6F,$06,$49,$02,$F6,$0F
        .byte   $30,$F3,$8F,$3C,$F3,$88,$50
pr_p218:                                 ; pose 105 du jeu, decalage 0,2
        .byte   $03,$04,$09,$01,$02,$03,$00,$04,$05,$00,$06,$07,$00,$08,$09,$00
        .byte   $DF,$70,$02,$AB,$01,$11,$91,$1F,$7E,$52,$01,$52,$07,$A0,$1A,$BB
        .byte   $77,$66,$FF,$EF,$FE,$FF,$EF,$FE,$FF,$EF,$FE,$EE,$C8,$44,$66,$66
        .byte   $77,$BB,$33,$23,$8C,$EE,$FF,$EF,$FE,$00,$F6,$0F,$3C,$46,$F0,$E4
        .byte   $44,$40,$62,$22
pr_p219:                                 ; pose 106 du jeu, decalage 0,4
        .byte   $03,$04,$0A,$01,$02,$00,$03,$04,$05,$06,$07,$08,$09,$0A,$00,$76
        .byte   $49,$9F,$63,$03,$EE,$C8,$85,$0A,$AB,$7D,$DD,$DD,$11,$11,$FF,$E2
        .byte   $23,$33,$32,$02,$77,$BB,$BA,$A0,$28,$88,$CE,$FF,$E1,$1D,$D0,$72
        .byte   $2F,$0E,$7B,$BA,$AB,$B7,$70,$13,$32,$23,$58,$80
pr_p221:                                 ; pose 127 du jeu, decalage 0,2
        .byte   $04,$04,$0B,$00,$00,$01,$02,$00,$03,$04,$00,$05,$06,$07,$00,$08
        .byte   $09,$0A,$0B,$F1,$EF,$3E,$F3,$ED,$F1,$DF,$33,$F4,$F9,$03,$22,$22
        .byte   $20,$3B,$B0,$6E,$1D,$DD,$DD,$99,$4A,$A0,$7E,$11,$D9,$46,$7B,$AC
        .byte   $CC,$CC,$CC,$CE,$EF,$1C,$F7,$CF,$FE,$67,$77,$7B,$B0,$33,$35,$55
        .byte   $80,$07,$AA,$74,$9D,$F7,$EE,$00,$25,$32,$32,$02
pr_p223:                                 ; pose 129 du jeu, decalage 0,2
        .byte   $03,$04,$0A,$00,$01,$02,$00,$03,$04,$05,$06,$07,$08,$09,$0A,$6F
        .byte   $3E,$F3,$ED,$F1,$DF,$33,$F4,$F9,$03,$22,$22,$20,$2D,$1F,$DF,$44
        .byte   $44,$44,$62,$33,$33,$33,$22,$24,$46,$67,$BA,$02,$FF,$EF,$FE,$FF
        .byte   $EF,$FE,$11,$11,$1D,$05,$22,$22,$D4,$77,$66,$44,$44,$03,$2F,$81
        .byte   $F8,$7F,$9F,$FB,$FF,$BF,$01,$F0,$4F,$06,$71,$EC,$52
pr_p224:                                 ; pose 130 du jeu, decalage 0,1
        .byte   $03,$04,$09,$00,$01,$00,$02,$03,$04,$05,$06,$00,$07,$08,$09,$4F
        .byte   $1E,$F7,$CF,$7D,$1F,$3B,$F6,$7F,$9F,$F7,$E0,$2A,$A0,$51,$FF,$E1
        .byte   $FB,$F9,$DD,$D9,$90,$12,$22,$22,$20,$14,$44,$66,$77,$BB,$AF,$FE
        .byte   $EC,$8C,$EE,$FF,$EF,$FE,$19,$6B,$B7,$66,$44,$42,$20,$0A,$33,$3F
        .byte   $8F,$FB,$FD,$02,$23,$55,$32,$00
pr_p225:                                 ; pose 131 du jeu, decalage 0,0
        .byte   $02,$04,$08,$01,$02,$03,$04,$05,$06,$07,$08,$02,$AA,$B0,$0A,$F0
        .byte   $2A,$EF,$7C,$F7,$88,$FF,$4E,$FE,$CF,$9C,$F7,$CC,$77,$BB,$BB,$BA
        .byte   $A0,$0E,$EE,$CE,$EE,$EE,$E4,$44,$66,$77,$BB,$B3,$35,$8C,$CE,$EE
        .byte   $E6,$BA,$AB,$77,$66,$45,$53,$35,$55,$53,$20
pr_p226:                                 ; pose 132 du jeu, decalage 0,9
        .byte   $02,$05,$0A,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$B0,$88,$08
        .byte   $AA,$01,$BB,$7A,$BF,$04,$CC,$88,$5F,$E8,$CF,$D8,$F3,$8C,$77,$77
        .byte   $77,$7B,$BB,$CC,$C8,$CC,$CC,$CC,$66,$66,$66,$77,$77,$35,$58,$8C
        .byte   $CC,$CC,$4B,$01,$BB,$77,$66,$88,$55,$55,$55,$53
        .byte   pr_p228>>8,pr_p228&$FF,1,255        ; le garde : sa pose, ecarts de ligne et de decalage
pr_p227:                                 ; pose 185 du jeu, decalage 0,9
        .byte   $05,$03,$09,$00,$00,$00,$00,$00,$01,$02,$03,$04,$05,$06,$07,$08
        .byte   $09,$00,$F1,$E7,$B0,$69,$9D,$DF,$FE,$11,$9A,$00,$FF,$E1,$19,$66
        .byte   $F8,$7F,$C3,$FC,$3B,$7A,$22,$22,$22,$20,$03,$30,$D4,$DF,$78,$F3
        .byte   $C0,$47,$FE,$FF,$EF,$FF,$7D,$04,$31,$11,$E0,$53,$8E,$40
pr_p228:                                 ; pose 1185 du jeu, decalage 0,2
        .byte   $06,$02,$0B,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$00,$47
        .byte   $7A,$05,$11,$1F,$C7,$A0,$41,$11,$11,$94,$70,$11,$11,$11,$11,$FF
        .byte   $E0,$11,$11,$11,$FF,$EF,$78,$02,$22,$22,$0D,$F1,$94,$07,$11,$07
        .byte   $51,$07,$91,$07,$F1,$C1
pr_p229:                                 ; pose 108 du jeu, decalage 0,5
        .byte   $03,$03,$08,$01,$02,$00,$03,$04,$05,$06,$07,$08,$47,$F0,$CF,$13
        .byte   $60,$45,$F6,$05,$53,$04,$67,$7B,$BB,$BB,$66,$11,$11,$11,$11,$FF
        .byte   $EC,$35,$55,$55,$32,$06,$F3,$09,$94,$60,$1F,$10,$F1,$8F,$0C,$F0
        .byte   $EF,$DE,$C8,$10,$82
pr_p230:                                 ; pose 109 du jeu, decalage 0,9
        .byte   $03,$03,$08,$01,$02,$00,$03,$04,$05,$06,$07,$08,$40,$82,$08,$77
        .byte   $77,$44,$9F,$0E,$F1,$9F,$27,$11,$11,$1F,$FE,$33,$33,$88,$85,$20
        .byte   $6F,$70,$F3,$8F,$1C,$46,$67,$70,$1F,$1C,$77,$11,$11,$10,$32,$22
        .byte   $58,$80
pr_p231:                                 ; pose 110 du jeu, decalage 0,8
        .byte   $03,$03,$08,$01,$02,$00,$03,$04,$05,$06,$07,$08,$F4,$F9,$07,$20
        .byte   $87,$77,$77,$99,$DF,$1D,$F3,$31,$11,$11,$11,$1E,$28,$CC,$CC,$85
        .byte   $20,$3F,$1C,$F0,$CF,$0C,$F0,$EF,$0E,$F0,$EF,$06,$70,$2B,$AF,$79
        .byte   $11,$11,$03,$23,$52,$25
pr_p232:                                 ; pose 111 du jeu, decalage 0,6
        .byte   $03,$03,$08,$01,$02,$00,$03,$04,$05,$06,$07,$08,$F1,$DF,$33,$F4
        .byte   $F9,$05,$C2,$20,$67,$77,$77,$77,$99,$D1,$11,$11,$11,$11,$12,$58
        .byte   $CC,$CC,$83,$02,$F1,$CF,$0C,$F0,$CF,$0C,$F0,$EF,$0E,$66,$02,$A0
        .byte   $1F,$0E,$91,$FF,$E0,$22,$35,$F7,$08,$20,$00
pr_p233:                                 ; pose 112 du jeu, decalage 0,4
        .byte   $03,$03,$09,$01,$02,$03,$04,$05,$06,$07,$08,$09,$9F,$0E,$F1,$9F
        .byte   $27,$40,$41,$1F,$E7,$32,$04,$FF,$EE,$50,$6A,$AA,$AA,$AA,$A4,$4F
        .byte   $9F,$F9,$FF,$9F,$F9,$FF,$8F,$F8,$71,$11,$1C,$88,$CE,$EF,$FE,$11
        .byte   $10,$4A,$AA,$AA,$04,$2F,$87,$F8,$FF,$8F,$F9,$F0,$1F,$18,$F0,$CF
        .byte   $0E,$6F,$8F,$EF,$FE,$E0
pr_p234:                                 ; pose 113 du jeu, decalage 0,2
        .byte   $03,$03,$09,$01,$02,$03,$04,$05,$06,$07,$08,$09,$B9,$F3,$ED,$F1
        .byte   $DF,$33,$F4,$F9,$01,$11,$11,$C2,$20,$2C,$83,$06,$AA,$AA,$AA,$AA
        .byte   $AB,$FB,$F1,$11,$FD,$FF,$CF,$FC,$7F,$CF,$FD,$F1,$C8,$8C,$EF,$FE
        .byte   $FF,$EF,$FE,$FF,$EE,$05,$AA,$AA,$05,$F8,$7F,$8F,$F9,$FF,$BF,$01
        .byte   $F2,$0F,$30,$F1,$8F,$1C,$FF,$EE,$CE
pr_p235:                                 ; pose 114 du jeu, decalage 0,0
        .byte   $04,$03,$08,$01,$02,$03,$00,$00,$04,$05,$00,$00,$06,$07,$08,$00
        .byte   $AB,$9F,$3E,$DF,$1D,$F3,$3F,$4F,$91,$11,$11,$C2,$22,$00,$FF,$EE
        .byte   $C5,$20,$4F,$FE,$FF,$E1,$D9,$99,$99,$DF,$7C,$CC,$88,$CE,$FF,$EF
        .byte   $FE,$FF,$E0,$0F,$0C,$F0,$6B,$B6,$99,$DF,$7E,$02,$F8,$EF,$83,$B7
        .byte   $49,$F7,$E0,$43,$20,$20
