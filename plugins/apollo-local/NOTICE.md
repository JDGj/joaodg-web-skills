# Proveniência e licença

Este plugin **não contém** o OpenJarvis. Contém a configuração, a persona e as
instruções que fazem o OpenJarvis correr como **Apollo**, o assistente do
HeavenlyCo Group.

## Obra de origem

**OpenJarvis** - <https://github.com/open-jarvis/OpenJarvis>
Licenciado sob a **Apache License, Version 2.0**. A cópia integral da licença
está em [`LICENSE-Apache-2.0.txt`](LICENSE-Apache-2.0.txt).

O projeto de origem não distribui ficheiro `NOTICE`, por isso não há avisos de
terceiros a propagar (Apache 2.0, secção 4(d)).

## Ficheiros derivados, e o que foi alterado

A Apache 2.0, secção 4(b), obriga a marcar os ficheiros modificados. Neste
plugin há dois:

| Ficheiro aqui | Origem | Alterações |
|---|---|---|
| `skills/apollo-motor-local/references/config-apollo.toml` | `configs/openjarvis/examples/morning-digest-linux.toml` | persona, honorific, fuso, secções, fontes e agendamento trocados para o âmbito do HeavenlyCo Group; comentários reescritos em português |
| `skills/apollo-motor-local/references/config-apollo-mac.toml` | `configs/openjarvis/examples/morning-digest-mac.toml` e `chat-simple.toml` | motor "cloud" com um modelo Claude em vez do Ollama; persona, tratamento, fuso, secções, fontes, voz e ferramentas trocados; comentários reescritos |

O aviso de modificação vai também no cabeçalho do próprio ficheiro, onde quem o
copia o vê.

**Escrito de raiz, não derivado:** `references/persona-apollo.md` (a persona do
Apollo) e as duas skills. A persona do OpenJarvis (`jarvis.md`) serviu para
perceber o *formato* que o carregador espera - não foi copiada nem adaptada.

## Marcas

"OpenJarvis" e "Jarvis" são nomes do projeto de origem. Aqui aparecem só para
dizer de onde vem o motor, que é o uso que a secção 6 da Apache 2.0 permite.
Nada neste plugin se chama Jarvis: o assistente é o **Apollo**, e o plugin é o
`apollo-local`.
