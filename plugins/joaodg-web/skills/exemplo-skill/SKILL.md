---
name: exemplo-skill
description: Template de skill do JoaoDG. Substituir por uma skill real ou apagar a pasta. Usar quando o utilizador pedir explicitamente "exemplo-skill" ou quiser ver o formato de uma skill deste plugin.
---

# Exemplo

Esta pasta existe para que o plugin `joaodg-web` carregue com pelo menos uma skill valida
e para servir de molde. Apaga-a assim que tiveres skills a serio.

## Como adicionar uma skill

1. Cria `plugins/joaodg-web/skills/<nome>/SKILL.md`.
2. O nome da pasta e o campo `name` do frontmatter devem coincidir (kebab-case).
3. O campo `description` e o unico texto que o Claude ve antes de decidir abrir a skill:
   diz o que faz **e** quando deve ser usada, com as palavras que o utilizador usaria.
4. Ficheiros de apoio (referencias, scripts, templates) ficam na mesma pasta e sao
   carregados apenas quando a skill e invocada.
5. Commit e push. Na app, faz sync/re-sync do marketplace.

## Limites

O corpo da skill e instrucoes para o modelo, nao documentacao para humanos.
Curto, imperativo, sem preambulo.
