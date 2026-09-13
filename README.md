# joaodg-web-skills

Marketplace de plugins Claude do estúdio JoaoDG. Um repositório, três plugins:

| Plugin | Origem | O que traz |
|---|---|---|
| `joaodg-web` | este repo (`./plugins/joaodg-web`) | skills próprias |
| `apple-design` | `emilkowalski/skills`, subpasta `skills/apple-design` | design e movimento fluido Apple, traduzido para a web |
| `ponytail` | `DietrichGebert/ponytail` | modo "senior preguiçoso": YAGNI, stdlib primeiro, menos código (6 skills) |

As duas skills externas **não estão copiadas** para aqui. O `marketplace.json` aponta para os
repositórios originais, por isso ficam sempre na versão do autor e a atualização é automática
quando ele publica. Também evita redistribuir trabalho de terceiros.

## Instalar

### Claude (web, Desktop, Cowork) — planos pagos

1. `Customize` → separador `Plugins`.
2. Em `Personal plugins`, botão `+` → `Add marketplace` → `Add from a repository`.
3. Colar `https://github.com/JDGj/joaodg-web-skills`.
4. Instalar os plugins que quiseres a partir da listagem.

### Claude Code

```
/plugin marketplace add JDGj/joaodg-web-skills
/plugin install joaodg-web@joaodg-web-skills
/plugin install apple-design@joaodg-web-skills
/plugin install ponytail@joaodg-web-skills
```

Um comando por mensagem. Depois `/reload-plugins` se for pedido.

Quem abrir uma sessão Claude Code dentro deste repo e confiar na pasta recebe o marketplace
automaticamente via `.claude/settings.json` — não precisa de correr nada.

## Atualização dinâmica

Nenhum manifesto aqui declara `version`. **É deliberado.** Com `version` definido, o plugin fica
preso a essa string e ninguém recebe alterações até haver bump; sem `version`, em fontes git a
versão é o SHA do commit, por isso qualquer push passa a ser uma atualização.

Se um dia quiseres releases estáveis, acrescenta `version` ao `plugin.json` e passa a fazer bump
em cada release — mas aí perdes o comportamento "push = update".

O catálogo em si (`marketplace.json`) não é lido a cada mensagem: o cliente sincroniza-o. Em
Claude Code, `/plugin marketplace update joaodg-web-skills`. Na app, `re-sync` no cartão do
marketplace.

## Adicionar uma skill própria

```
plugins/joaodg-web/skills/<nome>/SKILL.md
```

Nome da pasta igual ao `name` do frontmatter, kebab-case. Ver `skills/exemplo-skill/` como molde.
Commit, push, sync. Não é preciso mexer no `marketplace.json` — as skills são descobertas sozinhas.

Para adicionar um **plugin** novo (conjunto de skills com identidade própria), cria
`plugins/<nome>/` com o seu `.claude-plugin/plugin.json` e regista-o no array `plugins` do
`marketplace.json`.

## Validar antes de publicar

```
claude plugin validate .
claude plugin validate ./plugins/joaodg-web
claude plugin validate ./plugins/joaodg-web/skills
```

O GitHub Action em `.github/workflows/validate.yml` corre isto a cada push. Vale a pena: um
`marketplace.json` inválido falha o sync do lado do servidor com uma mensagem genérica, e o
erro real só aparece nos logs locais.

## Requisitos e limites

- O repositório tem de ser **público**. O sync do lado do Claude é anónimo; repositórios privados
  falham por esta via (só funcionam via Organization settings, em planos Team/Enterprise).
- Plugins exigem plano pago (Pro, Max, Team, Enterprise).
- Skills funcionam no chat web, no Desktop e no Cowork. Hooks e sub-agentes só correm no Cowork —
  o `ponytail` tem dois hooks Node.js para ativação automática; no chat, as skills continuam a
  funcionar, só não se auto-ativam.
- Se a app rejeitar a entrada `git-subdir` do `apple-design`, o plano B é copiar a pasta
  `skills/apple-design` para `plugins/apple-design/` e trocar a `source` por
  `"./plugins/apple-design"`. Nesse caso passas a redistribuir trabalho do autor: mantém a
  atribuição e confirma a licença no repo dele primeiro.

## Atribuição

- `apple-design` — Emil Kowalski, <https://github.com/emilkowalski/skills>
- `ponytail` — Dietrich Gebert, MIT, <https://github.com/DietrichGebert/ponytail>
