# Adamatovy nepříjemné skripty

*(Sorry, no english version)*

Všechno jsou to totální bastly, které vznikly pro mou jednorázovou potřebu a až
později jsem je začal trochu zušlechťovat, aby je mohl použít i někdo další. Ne
všude se to zatím povedlo a jen málo co je konfigurovatelné jinak, než změnou
zdrojáku, nebo robustní s ohledem na pracovní adresář atd.

## 1. Stáhněte výsledky MOSSu

`crawl.sh` – v hlavičce změňte číselný identifikátor. Stahuje do pracovního
adresáře. Chvíli trvá (žádná paralelisace).

## 2. Sepište zjištění

V kořeni repositáře vyrobte soubor `findings.tex` podle následujícího mustru:

```tex
%HW A
%GROUP 445763 445225

Řešení jsou až na pojmenování proměnných totožná a~dosahují \moss{97}.

%GROUP 445763-Adam_Matousek-hw.hs 123456-whatever
Důležité je, aby řetězce za \texttt{\%GROUP} začínaly učem; zbytek se ignoruje.

%HW B
%GROUP 8793098 22389

Značka úlohy za \texttt{\%HW} může být libovolný řetězec z~písmen, ale v~\TeX
u se s~ním pak na několika místech pracuje lépe, pokud je jednopísmenná.

Více odstavců je lze.
```

## 3. Vyexportujte seznam lidí

Stačí použít v ISu export seznamu studentů, v němž zaškrtnete pouze sloupec
„pohlaví“. Zvolte export do formátu s dvojtečkami v kódování UTF-8 (mělo by být
výchozí). Mezi zvolením sloupců a exportem je zapotřebí „znovu vypsat seznam“.

Získaný soubor uložte jako `lidi.csv` do kořene.

## 4. Vygenerujte základ podnětů

Se soubory `zjisteni.tex` a `lidi.csv` v pracovním adresáři spusťte skript
`generate.pl`. V adresáři `_generated/` se vyrobí pro každého člověka uvedeného
v některé `%GROUP` stručný TeXový soubor.

## 5. Upravte si šablonu

Projděte si obsah adresáře `tex/` a upravte znění úvodu, závěru a označení úloh.
Mělo by stačit měnit `podani_defs.tex` a `podani_basic.tex`.

## 6. Vysázejte podněty

`make singles`.

Při úpravách jednotlivých podnětů můžete zkusit jednoduchý skript `retry.sh`.

## 7. Vyrobte pro každé podání přílohu

Oporou může být skript `prilohy.pl`, v němž bude potřeba nastavit správné cesty
k originálním zdrojákům. Ten potom zplodí skript `prilohy.sh`, jímž pro každý
podnět vyrobíte archiv se všemi zdrojovými kódy z příslušných `%GROUP`
