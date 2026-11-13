# Izračun porazdelitve temperature v 2D prerezih (NROR) – 1. faza

Program v MATLAB-u prebere mrežo, izriše vhodne podatke, sestavi redko matriko **A** in vektor **b**, izračuna `T = A\b` ter A in b zapiše v binarno datoteko.

## Mape
- `matlab/Faza1NROR.m` – program (branje, izris, A in b, binarni izvoz in preverjanje)
- `podatki/` – `lopatica_mreza.txt`,`lopatica_mreza_r1.txt`, `lopatica_mreza_r2.txt`, `lopatica_mreza_r3.txt`  (inženirski primeri), `primer_predloga_projekt.txt` (zgled)
- `binarno/` – zapis sistema za vse primere
- `porocilo/` – poročilo (`porocilo.pdf`)

## Zagon
V skripti nastavi ime datoteke in prevodnost:
- lopatica: `lopatica_mreza.txt`, `k = 22`
- zgled: `primer_predloga_projekt.txt`, `k = 1`

Datoteka z mrežo mora biti v isti mapi kot skripta. Skripto zaženi od vrha.

## Format binarne datoteke (little-endian)
| vsebina | tip | število |
|---|---|---|
| oznaka `NROS` | char | 4 |
| verzija (1), N, n (neničelni elementi) | int32 | 3 |
| vrstice (0-osnovno) | int32 | n |
| stolpci (0-osnovno) | int32 | n |
| vrednosti | double | n |
| desna stran b | double | N |

Velikost: 16 + 16·n + 8·N bajtov.
