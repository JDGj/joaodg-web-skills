---
name: apollo-motor-local
description: Instalar, configurar e operar o motor local do Apollo - o OpenJarvis (Apache 2.0) a correr como Apollo, com persona própria, briefing falado e modelos em casa. Carregar quando se falar do Apollo local, do OpenJarvis, do briefing por voz, do digest, do ficheiro config.toml do Apollo, ou de pôr o assistente a correr sem depender de uma API de terceiros. Cobre a persona (que é um ficheiro de prompt), o preset de configuração, as armadilhas reais do motor (persona em falta falha em silêncio, o andaime do prompt é inglês, limite fixo de 200 palavras) e a fronteira de acesso que o motor local herda do ADR-001.
---

# Apollo: o motor local

O **OpenJarvis** (<https://github.com/open-jarvis/OpenJarvis>, Apache 2.0) é um
assistente local-first: modelos por Ollama ou vLLM, conectores para Gmail,
Calendar e companhia, e um *morning digest* falado. Aqui não se usa como
"Jarvis" - usa-se como **motor**, e quem fala é o Apollo.

Proveniência, licença e ficheiros derivados: ver `NOTICE.md` na raiz do plugin.

## Porquê

**Build to own.** O briefing matinal é a coisa mais regular que o grupo faz e
hoje depende inteiramente de uma API de terceiros. Um motor local tira essa
dependência do caminho crítico e mantém dentro de casa o que ele lê - caixa de
correio, agenda, números do negócio.

O que este plugin acrescenta ao motor é a única coisa que interessa: **fazê-lo
falar como o Apollo em vez de como o Jarvis.**

## O ponto onde isto se torna nosso: a persona é um ficheiro

`morning_digest.py` carrega a persona por nome, de um ficheiro `.md`:

```python
search_paths = [
    Path("configs/openjarvis/prompts/personas") / f"{persona_name}.md",
    get_config_dir() / "prompts" / "personas" / f"{persona_name}.md",
]
```

Ou seja: `persona = "apollo"` no `config.toml` mais um `apollo.md` no sítio
certo, e o assistente passa a ser o nosso. Não é preciso fazer fork nem tocar
no código do motor - e é por isso que este plugin é configuração, não um clone
de 2133 ficheiros.

A persona está em [`references/persona-apollo.md`](references/persona-apollo.md).
O preset de configuração em [`references/config-apollo.toml`](references/config-apollo.toml).

## Instalar

Corre no **Mac do João** ou no servidor onde o motor vive - nunca numa sessão
remota do Claude, que não tem SSH nem GPU. `$OPENJARVIS_HOME` manda; sem ele, a
raiz é `~/.openjarvis`.

**Primeiro o motor.** O projeto não publica pacote no PyPI: o caminho documentado
é um instalador que trata do uv, do venv, do Ollama e de um modelo inicial
(`pyproject.toml` pede Python >= 3.10 e < 3.14).

```bash
curl -fsSL https://open-jarvis.github.io/OpenJarvis/install.sh -o /tmp/openjarvis-install.sh && \
less /tmp/openjarvis-install.sh
```

O `curl | bash` da documentação deles faz o mesmo numa linha. Aqui separa-se em
duas de propósito: um script de terceiros que instala software na máquina onde
está o trabalho todo lê-se antes de correr, e depois corre-se com
`bash /tmp/openjarvis-install.sh`. Não é desconfiança do projeto - é que a
alternativa é executar o que quer que esteja naquele URL no momento em que se
carrega no Enter.

**Depois o Apollo por cima.**

```bash
JARVIS_HOME="${OPENJARVIS_HOME:-$HOME/.openjarvis}" && \
RAW="https://raw.githubusercontent.com/JDGj/joaodg-web-skills/main/plugins/apollo-local/skills/apollo-motor-local/references" && \
mkdir -p "$JARVIS_HOME/prompts/personas" && \
{ [ ! -f "$JARVIS_HOME/config.toml" ] || cp "$JARVIS_HOME/config.toml" "$JARVIS_HOME/config.toml.bak-$(date +%F)"; } && \
curl -fsSL "$RAW/persona-apollo.md" -o "$JARVIS_HOME/prompts/personas/apollo.md" && \
curl -fsSL "$RAW/config-apollo.toml" -o "$JARVIS_HOME/config.toml" && \
test -s "$JARVIS_HOME/prompts/personas/apollo.md" && echo "persona instalada" && \
jarvis digest --text-only --fresh
```

Três coisas neste bloco não são enfeite:

- **`curl -f`** falha no 404 e o `&&` pára a corrente. Sem ele, um caminho errado
  grava a página de erro do GitHub como se fosse a persona.
- **A cópia de segurança do `config.toml`** existente. O preset substitui o
  ficheiro inteiro; se já lá havia configuração, perdia-se sem aviso.
- **`test -s`** na persona. Sem ele, uma cópia falhada passa despercebida, e a
  primeira armadilha abaixo explica porquê isso é grave.

O `RAW` aponta para `main`. Enquanto este plugin estiver só no ramo de trabalho,
trocar `main` pelo nome do ramo - ou o `curl` traz um 404 e a corrente pára, que
é o comportamento certo mas não é óbvio.

Agendar (o motor tem agendador próprio, não precisa de cron):

```bash
jarvis digest --schedule "0 7 * * *"
```

## Armadilhas do motor - as que já custaram tempo

### 1. Persona em falta falha em silêncio

`_load_persona()` devolve `""` quando não encontra o ficheiro, e o campo
`persona` no `config.toml` é uma string livre, sem validação. Uma gralha em
`persona = "apolo"` não dá erro nenhum: o briefing sai sem persona nenhuma,
educado e anónimo, e ninguém repara durante semanas.

**É exatamente o que a regra da casa proíbe**, e o motor não a segue. A defesa é
nossa: confirmar o ficheiro depois de cada instalação ou atualização.

```bash
test -s "${OPENJARVIS_HOME:-$HOME/.openjarvis}/prompts/personas/apollo.md" && echo ok || echo "PERSONA EM FALTA"
```

Sinal no output: um briefing sem a leitura do dia e sem tratamento pelo nome é
quase sempre isto, não é o modelo a portar-se mal.

### 2. O andaime à volta da persona é inglês, e é fixo

A persona é **prepended** a um bloco em inglês, escrito em código
(`_build_system_prompt`), que traz as secções (`MESSAGES`, `CALENDAR`, ...) e as
regras absolutas. Não se configura.

Consequência prática: **a persona tem de declarar a língua**, senão o modelo
segue o andaime e responde em inglês. A `persona-apollo.md` abre com isso, e não
é estilo - é o que faz o briefing sair em português.

### 3. Limite fixo de 200 palavras

A última linha do andaime é `STRICT LIMIT: 200 words`. Também não se configura.

O briefing escrito da skill `briefing-matinal` é "no máximo uma página". Não
cabe em 200 palavras faladas, e forçá-lo transforma a leitura do dia num resumo.
**São duas coisas diferentes, e é assim que se devem tratar:** o digest local é
a versão falada, curta; o briefing escrito continua a ser o que vale.

### 4. O tratamento por omissão é "sir"

`honorific` entra no prompt como *"The user's preferred honorific is: X"* e vem
`"sir"` de fábrica. No preset vai `honorific = "João"` - em português o espaço
do tratamento cerimonioso é ocupado pelo nome, e resolve-se sem artifício.

### 5. A voz por omissão manda o briefing para fora de casa

O exemplo de origem traz `tts_backend = "openai"`. Quer dizer que o texto do
briefing - o que veio do correio e da agenda - sai da máquina para ser lido em
voz alta. Isso anula a razão de existir de um motor local, e não é óbvio a olhar
para a linha.

O preset fica em **`kokoro`**, que corre na máquina. O que se paga por isso: o
Kokoro só tem **português do Brasil** (prefixo de voz `p`), não tem europeu.
Enquanto o modelo escreve em português europeu - a persona garante isso - quem
ouve ouve sotaque brasileiro.

**A escolha é dele, não minha:** sotaque errado com os dados em casa, ou voz
certa com o correio a passar por um terceiro. O preset assume a primeira, que é
a que segue a razão de se ter feito isto. Trocar é uma linha.

Armadilha dentro da armadilha: o idioma é decidido pelo **prefixo** do
`voice_id`. Um nome de voz sem prefixo reconhecido cai em `af_heart` - inglês
americano - sem um aviso.

## O que o motor local ainda não consegue ler

O briefing do grupo assenta em cinco fontes. O motor traz conectores para duas:

| Fonte do briefing | Conector no motor |
|---|---|
| Google Calendar | `gcalendar` |
| Gmail | `gmail` |
| Painel `app.joaodg.pt` | **não existe** |
| Stripe (3 contas) | **não existe** |
| Cloudflare | **não existe** |

Dizer isto com todas as letras importa: um digest local que fale de "tudo" está
a falar de 2 das 5 fontes, e quem o ouve não tem como saber.

**O caminho certo não são três conectores.** O snapshot diário do ADR-003 já
tem as cinco fontes tratadas e o estado de cada uma (`ok`, `parcial`,
`indisponivel`). Um conector único que leia
`apps/painel/data/snapshots/AAAA-MM-DD.json` traz as três em falta de uma vez, e
mantém a regra de que existe **uma** recolha e não duas - duas recolhas dão dois
números diferentes para a mesma coisa, e é a partir daí que ninguém acredita em
nenhum. Trabalho por fazer, e não se deve fingir que está feito.

## Fronteira de acesso

O motor local é mais um cliente da mesma fronteira, não uma excepção a ela. Vale
o ADR-001 inteiro (skill `fronteira-de-acesso` do plugin `apollo`):

- **leitura livre, escrita caso a caso**;
- as credenciais que se lhe dão são **de leitura**, e uma por serviço - um motor
  que corre modelos locais e executa ferramentas (`shell_exec`,
  `code_interpreter` estão na lista de `tools` do exemplo de origem) não deve
  ter na mão um token que escreve;
- **`shell_exec` fica fora** do nosso preset. Um assistente que lê correio de
  estranhos e sabe correr comandos é a definição do problema.

## Relação com o plugin `apollo`

| Onde | O quê |
|---|---|
| plugin `apollo` | quem o Apollo é: identidade, âmbito, regras invioláveis, o formato do briefing, a fronteira |
| plugin `apollo-local` (este) | onde ele corre: motor, persona, configuração, agendamento |

A persona local é uma **destilação** do `apollo-identidade`, não uma segunda
versão dele. Quando a identidade mudar lá, a persona daqui muda a seguir - e o
sítio certo para a discussão continua a ser o `apollo-identidade`.
