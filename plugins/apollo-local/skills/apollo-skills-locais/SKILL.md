---
name: apollo-skills-locais
description: Levar as skills do estúdio JoaoDG para dentro do motor local do Apollo (OpenJarvis). Carregar quando se falar de importar skills para o motor local, de jarvis skill install ou jarvis skill sync, de compatibilidade entre as nossas skills e o formato agentskills.io, ou quando uma importação falhar. Traz a medição real de quantas passam, a razão pela qual as seis do prefixo ckm falham, porque NÃO se resolve renomeando-as, e a regra de nunca importar scripts sem os ler.
---

# As nossas skills no motor local

O motor lê skills no formato **agentskills.io**: uma pasta com `SKILL.md` e
frontmatter `name` + `description`. É o mesmo formato das nossas, por isso a
maior parte entra sem tocar em nada.

## O que o motor exige

Do `openjarvis/skills/parser.py`:

| Campo | Regra |
|---|---|
| `name` | 1 a 64 caracteres, `^[a-z0-9](?:[a-z0-9]\|-(?!-))*[a-z0-9]$` - minúsculas, dígitos e hífenes simples; sem `:`, sem `_`, sem hífen duplo, sem começar nem acabar em hífen |
| `description` | 1 a 1024 caracteres |

O descobridor do GitHub (`GitHubResolver`) faz uma travessia recursiva à procura
de `SKILL.md` em **qualquer** repositório - não é preciso o repo ter estrutura
especial.

## Medição, não estimativa

Correndo estas regras contra `joaodg-skills/` do repo `JDGj/joaodg`
(26 skills, a 2026-09-14):

**Passam 20. Falham 6.** Todas as seis pela mesma razão, e só por essa: o `name`
tem dois pontos.

```
ckm:banner-design   ckm:brand          ckm:design
ckm:design-system   ckm:slides         ckm:ui-styling
```

Quando isto for corrido outra vez, vale a pena medir em vez de acreditar no
número acima - a pasta cresce:

```bash
python3 - <<'PY'
import re, pathlib
NOME = re.compile(r"^[a-z0-9](?:[a-z0-9]|-(?!-))*[a-z0-9]$|^[a-z0-9]$")
for p in sorted(pathlib.Path(".").glob("*/SKILL.md")):
    fm = re.match(r"^---\n(.*?)\n---", p.read_text(encoding="utf-8"), re.S)
    n = re.search(r"^name:\s*(.+)$", fm.group(1), re.M) if fm else None
    nome = n.group(1).strip().strip("\"'") if n else ""
    if not NOME.match(nome or ""):
        print("falha:", p.parent.name, "->", nome or "(sem name)")
PY
```

## Porque NÃO se resolve renomeando

A correção óbvia - tirar o `ckm:` - parte as skills por dentro. O prefixo não é
decoração: **é invocado como comando dentro do corpo das próprias skills.** Em
`design/SKILL.md`, linha 228:

```
4. **Design** - `/ckm:brand` -> `/ckm:design-system` -> ...
```

Renomear `ckm:brand` para `ckm-brand` deixa aquela linha a apontar para um
comando que já não existe. E, ao contrário da persona em falta, isto não parte
com estrondo: a skill corre, chega àquele passo, não encontra nada, e segue.
Fica pior do que estava.

**O sítio certo da correção é a importação, não as skills.** Quem importa é que
tem de traduzir - `ckm:design` vira `ckm-design` no `name`, e as referências
`/ckm:x` dentro do corpo são reescritas na mesma passagem. Um resolvedor nosso à
frente do `GitHubResolver` faz isso; seis renomeações à mão não fazem, porque
partem o lado de cá.

Até isso existir, **as seis não se importam** e as vinte que passam chegam bem
para o que o motor local faz. Não é dívida escondida: está escrita aqui.

## Importar

Uma:

```bash
jarvis skill install github:criar-loja --url https://github.com/JDGj/joaodg
```

O `--url` é obrigatório com a fonte `github`. O nome da consulta é o `name` do
frontmatter, não o nome da pasta.

Todas as de um repositório:

```bash
jarvis skill sync github --url https://github.com/JDGj/joaodg
```

**Ler o resultado do `sync` até ao fim.** Uma importação que falha diz-o e sai
com código 1 quando é uma só; num `sync` de 26, as seis falhas passam a seis
linhas vermelhas no meio de vinte verdes, e é fácil dar por importado o que não
foi. Contar o que ficou instalado, não confiar no ecrã:

```bash
ls "${OPENJARVIS_HOME:-$HOME/.openjarvis}/skills" | wc -l
```

## Scripts: nunca por omissão

O `--with-scripts` importa a pasta `scripts/` da skill, e o `--yes-dangerous`
aceita skills que pedem shell, escrita no disco ou porta à escuta.

**Nenhum dos dois entra sem alguém ter lido o que está lá dentro.** Vale a
fronteira do ADR-001 (skill `fronteira-de-acesso` do plugin `apollo`): o motor
local corre na máquina onde está o trabalho todo, e uma skill importada é código
de fora a correr lá dentro. Se o script for preciso, lê-se primeiro; se não for
preciso, não se importa.

## Skills que não fazem sentido no motor local

Nem tudo o que existe em `joaodg-skills/` serve aqui. As de desenho e vídeo
(`canva-joaodg`, `capcut-joaodg`) dependem de aplicações de interface gráfica e
de MCP que o motor local não tem. Importá-las não dá erro - dá uma skill que
promete o que não consegue cumprir, que é pior. Importar por necessidade, não
por completude.
