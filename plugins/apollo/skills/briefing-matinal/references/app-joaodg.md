# O painel `app.joaodg.pt` como fonte de dados

Não confundir com `app.heavenlyco-group.com`. São dois painéis diferentes:

| Painel | O que é | Papel |
|---|---|---|
| `app.joaodg.pt` | O admin do estúdio. Lojas, clientes, diagnósticos, backups, acessos. | **Fonte** que o Apollo lê. |
| `app.heavenlyco-group.com` | O painel do grupo. | **Destino**: lê o snapshot que o Apollo escreve. Não lê fontes. |

## Onde olhar

- `/dashboard/lojas` - estado de cada loja, servidor, cliente, tipo de projeto.
- `/dashboard/diagnosticos` - certificados a expirar, produção bloqueada,
  limites de espaço.
- `/dashboard/backups` - o que correu e o que ficou por correr.

## O filtro de âmbito - aplicar sempre, na leitura

**Os sites do Passion Group vivem dentro deste painel.** O filtro não acontece
sozinho. Excluir, sem excepção:

- o grupo de servidor `WEB - Passion Group | JoaoDG`;
- qualquer loja com cliente `André Paixão` - incluindo `app.passiongroup.pt`,
  que está no Servidor Externo;
- os domínios `*.passiongroup.pt`, `*.maxfinancepassion.pt`, `passion-group.pt`.

À data de 2026-09-13 sobravam 21 lojas dentro do âmbito. Confirmar o número em
vez de o repetir: a lista cresce.

## O que se lê aqui e não se adivinha

- **Cada loja diz em que servidor está.** Não inferir pelo domínio.
- **Um certificado a expirar num site do Passion Group não é do âmbito**, mas
  alguém tem de o tratar: o servidor é deles e pagam subscrição mensal. Diz-se
  ao João à parte, fora do briefing do grupo.
- **`ERR:` numa loja** quer dizer que o caminho em `/var/www` não existe - loja
  registada sem código publicado, que é diferente de site em baixo.

## O que este painel não sabe

Não sabe de dinheiro. MRR, cobranças falhadas e subscrições vêm do Stripe, nas
três contas separadas, nunca deste painel.
