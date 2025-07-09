# Baza Podataka za Ritmičku Videoigru

Verzija ovog dokumenta na engleskom jeziku dostupna je [ovdje](./README.md).

## O Projektu

[cite_start]Ovaj projekt je seminarski rad iz kolegija "Moderni Sustavi Baza Podataka" [cite: 5] [cite_start]na Fakultetu primijenjene matematike i informatike u Osijeku[cite: 2]. [cite_start]Cilj rada bio je modelirati i implementirati bazu podataka koja bi služila kao okosnica za funkcionalnu online ritmičku videoigru[cite: 13, 14].

[cite_start]Ritmičke videoigre u pozadini skrivaju ogromne baze podataka koje pamte svaki pogodak i promašaj igrača[cite: 11]. [cite_start]Ovaj, iako pojednostavljen, model prikazuje logiku i osnovne principe na kojima se temelje takvi sustavi, a implementiran je u PostgreSQL sustavu za upravljanje bazama podataka[cite: 14].

Cjelokupni seminarski rad s detaljnim opisom i ER dijagramom dostupan je u datoteci: [`/seminar/MSBP Projekt - Ritmicka videoigra, Tibor M..pdf`](./seminar/MSBP%20Projekt%20-%20Ritmi%C4%8Dka%20videoigra,%20Tibor%20M..pdf).

## Struktura Baze Podataka

[cite_start]Baza se sastoji od sljedećih ključnih entiteta[cite: 17]:
* [cite_start]**USER**: Središnji entitet koji predstavlja registriranog igrača[cite: 19].
* [cite_start]**PROFILE**: Proširenje `USER` entiteta koje pohranjuje kumulativne statistike igrača (rang, level, ukupni score...)[cite: 20].
* [cite_start]**BEATMAP**: Predstavlja pojedinu "mapu" ili pjesmu koju igrač igra[cite: 23].
* **SCORE**: Zapis o jednom ostvarenom rezultatu na određenoj mapi. [cite_start]Ovo je najčešće korišteni entitet u bazi[cite: 26, 27].
* [cite_start]**REPLAY**: Opcionalni entitet koji sadrži podatke za ponovno gledanje odigrane partije[cite: 29].
* [cite_start]**FRIENDS**: Asocijativna tablica koja rješava N:N vezu prijateljstva između korisnika[cite: 99].

## Implementirane Značajke

-   [cite_start]**Složeni upiti:** Upiti nad više tablica [cite: 296][cite_start], s agregirajućim funkcijama [cite: 336] [cite_start]i podupitima [cite: 374] za generiranje ljestvica i statistika.
-   [cite_start]**Uvjeti (Constraints):** `CHECK` uvjeti koji osiguravaju integritet podataka (npr. da `accuracy` mora biti između 0 i 100)[cite: 421, 423].
-   [cite_start]**Zadane vrijednosti (Defaults):** Postavljanje zadanih vrijednosti za stupce poput `level` (DEFAULT 1) ili `status` prijateljstva (DEFAULT 'Pending')[cite: 409].
-   [cite_start]**Indeksi:** Kreiranje B-tree indeksa na stupcima koji se često koriste u pretragama (`username`, `status` itd.) radi ubrzanja dohvaćanja podataka[cite: 438].
-   **Procedure:**
    -   [cite_start]`add_new_user`: Automatizira i pojednostavljuje registraciju novog korisnika[cite: 445].
    -   [cite_start]`accept_friend_request`: Upravlja društvenom komponentom igre tako što omogućuje prihvaćanje zahtjeva za prijateljstvo[cite: 463, 464].
-   **Okidači (Triggers):**
    -   [cite_start]`trig_effective_score`: Prije unosa novog rezultata, okidač provjerava je li korišten modifikator 'DT' (Double Time) te automatski računa i sprema efektivni BPM i težinu mape[cite: 530, 531].
    -   [cite_start]`trg_before_score_insert_improvement`: Sprječava unos rezultata koji nije bolji od osobnog rekorda igrača na istoj mapi, čime se baza ne zatrpava nepotrebnim podacima[cite: 568, 569].

## Pokretanje i Korištenje

1.  **Kreirajte novu PostgreSQL bazu podataka.**

2.  **Kreirajte shemu i unesite podatke:** Pokrenite skriptu `01_schema_and_inserts.sql`. Ona će kreirati sve tablice i popuniti ih početnim podacima za testiranje.
    ```bash
    psql -U vaše_korisničko_ime -d ime_baze -f sql_scripts/01_schema_and_inserts.sql
    ```
3.  **Dodajte naprednu logiku:** Pokrenite dijelove skripte `02_features_and_queries.sql` (koraci 9-14) kako biste dodali indekse, uvjete, procedure i okidače.

4.  **Istražite upite:** Datoteka `02_features_and_queries.sql` (koraci 5-8) sadrži brojne primjere upita koji demonstriraju funkcionalnost baze.

## Autor

* [cite_start]**Tibor Milković** [cite: 6]
