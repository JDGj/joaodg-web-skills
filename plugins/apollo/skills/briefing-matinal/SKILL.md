---
name: briefing-matinal
description: Produz o briefing matinal do HeavenlyCo Group e escreve o snapshot diário que alimenta o painel. Carregar quando for pedido o briefing do dia, o ponto de situação do grupo, ou quando a tarefa agendada "Apollo - briefing matinal HeavenlyCo" disparar. Cobre a recolha nas cinco fontes (Calendar, Gmail, painel app.joaodg.pt, Stripe, Cloudflare), o filtro de âmbito que exclui o Passion Group, o formato de entrega de uma página, e o contrato do snapshot.
---

# Briefing matinal

Carregar primeiro `apollo-identidade` (âmbito, tom, regras invioláveis) e
`fronteira-de-acesso` (o que se pode escrever). Esta skill diz **como** se faz o
briefing do dia.

## 1. Recolher

As cinco fontes, **em paralelo**. Se uma falhar, regista-se o falhanço e
continua-se com as outras - o briefing sai na mesma, a dizer o que faltou.

1. **Google Calendar** - eventos de hoje e amanhã. Conflitos, e o que exige
   preparação antes da hora.
2. **Gmail** - só o que exige decisão ou resposta. A caixa dele é sobretudo
   ruído automático: alertas de segurança da Google, confirmações de login,
   extratos bancários, newsletters. Filtrar agressivamente e **não listar o
   ruído**. Em quatro dias de observação, praticamente nada exigia resposta:
   se num dia não houver nada, a secção desaparece.
3. **Sistemas** - o painel `app.joaodg.pt`, em `/dashboard/lojas`,
   `/dashboard/diagnosticos` e `/dashboard/backups`. Procurar certificados a
   expirar, produção bloqueada e endereços temporários (`stg-*`). **Aplicar o
   filtro de âmbito** - ver `references/app-joaodg.md`.
4. **Stripe** - três contas, **sempre separadas por marca**: JoaoDG
   (`acct_1TX0T3IdK2WEOkOo`), ImoBuddy (`acct_1U4KQsIqBjOdiZCJ`), HookForge
   (`acct_1UD2yBIU5IgB56ai`). Cobranças falhadas, subscrições canceladas ou em
   risco, MRR. Nunca somar sem dizer que é soma.
5. **Cloudflare** - anomalias de tráfego e erros 5xx.

## 2. Escrever o snapshot

Antes de redigir, escrever `apps/painel/data/snapshots/AAAA-MM-DD.json` no repo
`JDGj/heavenlyco-group` e commitá-lo. É a única escrita com aprovação
permanente (ver `fronteira-de-acesso`), e é o que faz o painel existir.

O contrato está em `schema/snapshot.schema.json` desse repo. As regras que mais
custam a acertar:

- **Campo sem fonte é `null`, nunca `0`.** Zero é um valor real; `null` é
  ausência de resposta.
- **`fontes` regista o estado de cada origem** (`ok`, `parcial`,
  `indisponivel`) com a razão por extenso.
- **O filtro de âmbito aplica-se na escrita.** O painel não deve sequer saber
  que o Passion Group existe.
- **Snapshots não se reescrevem.** Corrigir ontem faz-se escrevendo hoje.

Validar antes de commitar: `npm run validar-snapshots` na raiz do repo. Um
ficheiro que não valida nunca deve chegar ao painel - aparece no ecrã como dado
em falta, e dado em falta lê-se como negócio parado.

## 3. Entregar

**Máximo uma página.** Por esta ordem, e as secções vazias desaparecem:

- **Abertura** - uma frase: o que define o dia.
- **Hoje** - calendário.
- **Email** - só o que exige decisão.
- **Sistemas** - só desvios.
- **Negócio** - Stripe primeiro, depois pipeline e follow-ups parados.
- **Leitura do dia**.

### A leitura do dia

É a **única secção que justifica o Apollo existir**. Uma - só uma - observação
de conselheiro: um padrão entre dias, um risco que ele ainda não viu, uma
decisão a desviar-se do que foi combinado.

Um resumo do que aconteceu não é uma leitura do dia. A pergunta a responder é
"o que é que isto quer dizer, que ele ainda não reparou". Se num dia não houver
substância, diz-se isso numa linha, em vez de inventar profundidade.

Onde o prejuízo for assimétrico - onde perder custa muito mais do que ganhar
rende - desafiar, mesmo que seja uma decisão que ele já tomou.

## 4. Fechar

**Terminar sempre com uma linha a dizer que fontes falharam**, se alguma
falhou. Um briefing que não menciona uma fonte em baixo lê-se como um briefing
completo, e é assim que um problema passa despercebido duas semanas.

## Contexto a confirmar, não a repetir como novo

Isto era verdade a 2026-09-13. Verificar antes de usar; se mudou, é notícia, e
se não mudou, não se repete como se fosse.

- MRR JoaoDG 205,00 EUR, seis assinaturas ativas. **Um único cliente vale
  105 EUR - 51,2% do total.** É o risco em aberto mais caro do grupo.
- ImoBuddy e HookForge sem assinaturas.
- Uma assinatura de 20 EUR sem método de pagamento próprio definido.
- `franciscasoares-celebrantes.pt` em página de manutenção, sendo o caso de
  estudo em destaque no `joaodg.pt`; o `www` dá 503.
- Três obras paradas em endereço temporário `stg-*`: Naturalmente Mulher,
  Cláudia Valentim Semijoias, Tanoaria.
- `app.heavenlyco-group.com`: loja criada, DNS a apontar para o j01, código no
  GitHub, **deploy por fazer** - continua a servir a página por defeito.
