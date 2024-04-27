*** Settings ***
# robot framework with requests 
# Bibliotecas e configuracoes
Library    RequestsLibrary   #precisa incluir um `tab` entre a library


*** Variables ***
# Objetos, atributos e variaveis
${url}    https://petstore.swagger.io/v2/pet

${id}    3457890                     # $ sinaliza uma variavel simples
${name}    Duna
&{category}    id=1    name=dog      # & sinaliza uma lista com campos determinados (ex. so tem um id e um name, seria {} da swagger)
@{photoUrls}                         # @ sinaliza uma lista com varios registros (ex. varios enderecos de photos, seria [] da swagger) 
&{tag}    id=1    name=vacinado
@{tags}    ${tag}                    # Fez uma lista de outra lista
${status}    available

*** Test Cases *** 
# Descritivo de Negocio + Passos de Automacao 
Post pet
    #montar a mensagem/body
    ${body}    Create Dictionary    id=${id}    category=${category}    name=${name}    
    ...                             photoUrls=${photoUrls}    tags=${tags}    status=${status}
    
    #executar
    ${response}    POST    url=${url}    json=${body}

    #validar
    ${response_body}    Set Variable    ${response.json()}   # recebe o conteudo da outra variavel
    Log To Console    ${response_body}            #imprimir o retorno da API no terminal / console

    Status Should Be    200
    Should Be Equal    ${response_body}[id]    ${{int($id)}}
    Should Be Equal    ${response_body}[name]    ${name}
    Should Be Equal    ${response_body}[tags][0][id]    ${{int(${tag}[id])}}
    Should Be Equal    ${response_body}[tags][0][name]    ${tag}[name]
    Should Be Equal    ${response_body}[status]    ${status}


Get pet
    #executa    
    ${response}    GET    ${{$url + '/' + $id}}

    #valida
    ${response_body}    Set Variable    ${response.json()}
    Log To Console    ${response_body}
    
    Status Should Be    200
    Should Be Equal    ${response_body}[id]    ${{int($id)}}
    Should Be Equal    ${response_body}[name]    ${name}
    Should Be Equal    ${response_body}[category][id]    ${{int(${category}[id])}}
    Should Be Equal    ${response_body}[category][name]    ${category}[name]


Put pet
    #montar a mensagem - body com a mudanca
    ${body}    Evaluate    json.loads(open('./fixtures/json/pet2.json').read())

    #executar
    ${response}    PUT    url=${url}    json=${body}

    #Valida
    ${response_body}    Set Variable    ${response.json()}
    Log To Console    ${response_body}
    Status Should Be    200
    Should Be Equal    ${response_body}[id]    ${{int($id)}}
    Should Be Equal    ${response_body}[category][id]    ${{int(${category}[id])}}
    Should Be Equal    ${response_body}[category][name]    ${category}[name]
    Should Be Equal    ${response_body}[name]    ${name}
    Should Be Equal    ${response_body}[tags][0][id]    ${{int(${tag}[id])}}
    Should Be Equal    ${response_body}[tags][0][name]    ${tag}[name]
    Should Be Equal    ${response_body}[status]    sold
    Should Be Equal    ${response_body}[status]    ${body}[status]
    

Delete pet
    #Executar
    ${response}    DELETE    ${{$url + '/' + $id}}

    #Valida
    ${response_body}    Set Variable    ${response.json()}
    Log To Console    ${response_body}

    Status Should Be    200
    Should Be Equal    ${response_body}[code]    ${{int(200)}}
    Should Be Equal    ${response_body}[type]    unknown
    Should Be Equal    ${response_body}[message]    ${id}



*** Keywords ***
# Descritivo de Negocio (se estruturar separadamente)
# DSL = Domain Specific Languages 