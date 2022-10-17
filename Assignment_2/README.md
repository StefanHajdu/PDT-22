### Úloha 1:

Query:

```SQL
select * from authors where username = 'mfa_russia';
```

Explain:
![u1](images/u1.png)

Plánovač vybral paralelný sekvenčný scan. Dôvodom je to, že úloha je svojou charakteristikou paralelizovateľná, pretože môžeme pole autorov rozdeliť do menších častí, ktoré sa prehľadajú samostatne. Tiež máme v konfiguráku nastavený počet workerov na 2, čiže Postres má dovolené spawnovať workerov, ak potrebuje.

### Úloha 2:

Na selecte pracovali 2 workery (podľa hodnoty nastavenej v konfiguráku). Ich úlohou je prehľadať rôzne časti tabuľky (teraz sa tabuľka rozdelí na 2 nezávislé časti, každý worker prehľadá jednu)

| ![u2.jpg](images/u2-0.png) |
| :------------------------: |
|       Sekvenčný scan       |
| ![u2.jpg](images/u2-1.png) |
|          1 worker          |
| ![u2.jpg](images/u2-2.png) |
|         2 workers          |
| ![u2.jpg](images/u2-3.png) |
|         3 workers          |
| ![u2.jpg](images/u2-4.png) |
|         4 workers          |
| ![u2.jpg](images/u2-6.png) |
|         6 workers          |

Čas na vykonanie selectu klesal do momentu kým sa nám neminuli voľné CPU (máme 4). Od nastavenia počtu workerov na 4, sa nám nezmenil počet spustených workerov. Počet workerov sme nastavovali pomocou:

```SQL
set max_parallel_workers_per_gather to desired_number;
```

### Úloha 3:

Query:

```SQL
create index idx_authors_username on authors using BTREE (username);
select * from authors where username = 'mfa_russia';
```

Explain Analyze:
![u3](images/u3.png)

Nebolo použitých viac workerov. Zrýlechenie vyplýva z toho, že vytvorením indexu sa zmenila dátová štruktúra, v ktorej sa vyhľadáva. Teraz sa používa stromová štruktúra BTREE, ktorá má logaritmickú zložitosť, na rozdiel od scanu, ktorý je lineárny.

| ![u2.jpg](images/u3-b.png) |
| :------------------------: |
|         3 workers          |
| ![u2.jpg](images/u3-a.png) |
|        BTREE INDEX         |

Použitím indexu sme vylepšili čas približne o polovicu v porovnaní s sekvenčným scanom s 3 workermi.

### Úloha 4:

Query:

```SQL
select * from authors where followers_count between 100 and 200;
select * from authors where followers_count between 100 and 120;
```

Explain Analyze:
| ![u4.jpg](images/u4-200.png) |
| :--------------------------: |
| between 100 and 200 |
| ![u4.jpg](images/u4-120.png) |
| between 100 and 120X |

Ako vidíme rozdiel je v tom, že ak hľadáme vačší interval, tak sa plánovač uprednostní obyčajný sekvenčný namiesto paralelného. Toto môže byť zapríčinené tým, že ako sa zvyšuje interval, tým sa zvyšuje aj cena gather operácie. Pretože paralelizácia nie je len o tom, že viac workerov => menší čas. Pri paralelizácií dochádza aj k rozdeleniu úlohy medzi workerov a komunikácie výsledkov do master procesu.

### Úloha 5:

Query:

```SQL
select * from authors where followers_count between 100 and 200;
select * from authors where followers_count between 100 and 120;
```

Index:

```SQL
create index idx_follow_interval on authors using BTREE (followers_count) where (followers_count >= 100) and (followers_count <= 200);
```

Explain Analyze:
| ![u5.jpg](images/u5-200.png) |
| :--------------------------: |
| between 100 and 200 |
| ![u5.jpg](images/u5-120.png) |
| between 100 and 120X |

### Úloha 6:

Query:

```SQL
insert into authors values (456168618, 'StefanHajdu', 'stevexo', 'james bond fan', 1212, 1516, 22, 565);
```

Index:

```SQL
create index idx_authors_name on authors using BTREE (name);
create index idx_authors_follow_cnt on authors using BTREE (followers_count);
create index idx_authors_desc on authors using BTREE (description);

drop index idx_follow_interval;
drop index idx_authors_name;
drop index idx_authors_follow_cnt;
drop index idx_authors_desc;
```

Porovnanie času:
| ![u6.jpg](images/u6-index.png) |
| :--------------------------: |
| insert do tabuľky so 4 indexami |
| ![u6.jpg](images/u6-noindex.png) |
| insert do tabuľky bez indexov |

### Úloha 7:

Index:

```SQL
create index idx_conv_content on conversations using BTREE (content);
create index idx_conv_retweet on conversations using BTREE (retweet_count);
```

Porovnanie času:
| ![u7.jpg](images/u7-retweet.png) |
| :--------------------------: |
| vytvorenie indexu pre retweet_count |
| ![u7.jpg](images/u7-content.png) |
| vytvorenie indexu pre content |

### Úloha 8

Query:

```SQL
create extension pgstattuple;
create extension pageinspect;

select * from pgstatindex('idx_conv_content');
select * from pgstatindex('idx_conv_retweet');
select * from pgstatindex('idx_authors_name'
select * from pgstatindex('idx_authors_follow_cnt');
```

### Úloha 9

Query:

```SQL
create index idx_conv_content on conversations using BTREE (content);
select * from conversations where content like '%Gates%';
```

Explain Analyze:

| ![u9.jpg](images/u9-noindex.png) |
| :------------------------------: |
|    Hľadaj 'Gates' bez indexu     |
|  ![u9.jpg](images/u9-index.png)  |
|  Hľadaj 'Gates' s BTREE indexom  |

### Úloha 10

Query:

```SQL
select * from conversations where content like 'There are no excuses%' and possibly_sensitive=true;
```

Explain Analyze:
![u9.jpg](images/u10.png)

Vytvorený BTREE index sa nepoužil. Pretože plánovač zvažuje BTREE index, keď sa má vykonať porovnanie (=, <, >, <=, =>). Nie keď chceme vyhľadávať reťazce podľa obsahu.

Ak bolo query nasledovné:

```SQL
select * from conversations where content='There are no excuses' and possibly_sensitive=true;
```

Explain Analyze:
![u9.jpg](images/u10-index.png)

Tak by sa použil index scan, ale takto sa text vyhľadávať nedá.

Zefektívniť query môžeme použitím indexu, ktoré podporujú vyhľadávanie podľa obsahu GiST a GIN.

### Úloha 11

Query:

```SQL
create index idx_conv_content_url on conversations using BTREE (lower(right(content, length('https://t.co/pkFwLXZlEm'))));
select * from conversations where lower(right(content, length('https://t.co/pkFwLXZlEm'))) = lower('https://t.co/pkFwLXZlEm');
```

Explain Analyze:
![u9.jpg](images/u11-index.png)

BTREE sa aktivuje ak hľadáme podľa porovnania, preto budeme vyhľadávať také záznamy, ktorých posledných N (N je dĺžka reťazca 'https://t.co/pkFwLXZlEm') znakov **je rovnakých** ako 'https://t.co/pkFwLXZlEm'. Ak chceme aby výsledok nebol závislý od veľkosti znakov vstupu prevedieme vstup na lowercase.

Použité funkcie:

- lower(): zmena vstupu na lowercase, podmienka nezávislosti vstupu
- right(): extrahovanie posledných N znakov z textu
- length(): vráti dĺžku reťazca

Výsledok:
![u9.jpg](images/u11-result.png)

### Úloha 12

Query:

```SQL
select * from conversations where reply_count > 150 and retweet_count >= 5000
order by quote_count desc;

create index idx_conv_reply_cnt on conversations using BTREE (reply_count);
create index idx_conv_retweet_cnt on conversations using BTREE (retweet_count);
create index idx_conv_quote_cnt on conversations using BTREE (quote_count);

drop index idx_conv_reply_cnt;
drop index idx_conv_retweet_cnt;
drop index idx_conv_quote_cnt;
```

Explain Analyze:

| ![u9.jpg](images/u12-noindex.png)  |
| :--------------------------------: |
|            Bez indexov             |
| ![u9.jpg](images/u12-3indexes.png) |
|             S indexami             |

Ukázalo sa, že sa používa jediný index scan, a to nad stĺpcom reply_count. Indexy nad stĺpcami retweet_count a quote_count sa nepoužijú. Ani ak sú vytvorené samostatne.
