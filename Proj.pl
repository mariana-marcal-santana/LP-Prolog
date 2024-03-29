% ist1106992 - Mariana Isabel Marcal Santana
:- set_prolog_flag(answer_write_options,[max_depth(0)]).
:- ['dados.pl'], ['keywords.pl'].

%Qualidade dos Dados

%eventosSemSalas

eventosSemSalas(EventosSemSala):-
    findall(Id,evento(Id,_,_,_,'semSala'),EventosSemSala).
    %cria uma lista com os IDs dos eventos sem sala

/*
eventosSemSalas/1
Unifica a variavel EventosSemSala com uma lista ordenada e
sem repeticoes, dos IDs de eventos sem sala.
*/

%eventosSemSalasDiaSemana

eventosSemSalasDiaSemana(DiaSemana,EventosSemSala):-
    findall(Id,(evento(Id,_,_,_,'semSala'),horario(Id,DiaSemana,_,_,_,_)),EventosSemSala).
    %cria uma lista com os IDs dos eventos sem sala no DiaSemana

/*
eventosSemSalasDiaSemana/2
Unifica a variavel EventosSemSala com uma lista ordenada e sem repeticoes, 
dos IDs de eventos sem sala que decorrem no dia mencionado no argumento DiaSemana.
*/

%eventosSemSalasPeriodo

eventosSemSalasPeriodo(ListaPeriodos,EventosSemSala):- 
    eventosSemSalasPeriodo(ListaPeriodos,EventosSemSala,[]).
    %criacao de uma variavel auxiliar para realizar iteracao

%factos que fazem corresponder periodos a semestres
periodos(p1,p1_2).
periodos(p2,p1_2).
periodos(p3,p3_4).
periodos(p4,p3_4).

eventosSemSalasPeriodo([],ESSala_Aux,ESSala_Aux):-!.

eventosSemSalasPeriodo([Periodo|RListaPeriodos],EventosSemSala,ESSala_Aux):-
    periodos(Periodo,Semestre),
    findall(Id,(evento(Id,_,_,_,'semSala'),
        (horario(Id,_,_,_,_,Periodo);horario(Id,_,_,_,_,Semestre))),ESSala_Aux1),
    %lista temporaria com os IDs dos eventos sem sala de 1 periodo da lista
    append(ESSala_Aux,ESSala_Aux1,ESSala_Aux2),sort(ESSala_Aux2,ESSala_Aux2_sorted),
    %juncao e ordenacao dessa lista com a da variavel auxiliar
    eventosSemSalasPeriodo(RListaPeriodos,EventosSemSala,ESSala_Aux2_sorted).

/*
eventosSemSalasPeriodo/2
Unifica a variavel EventosSemSala com uma lista, ordenada e sem repeticoes, 
dos IDs de eventos sem sala nos periodos do argumento ListaPeriodos.
*/

%Pesquisas Simples

%organizaEventos

organizaEventos(L,P,L2):-sort(L,L1),organizaEventos2(L1,P,L2).
%ordenacao da lista passada como argumento para realizacao da recursao

organizaEventos2([],_,[]):-!.

organizaEventos2([Id|RListaIds],Periodo,[Id|EventosPeriodo]):-
    %caso o evento pertenca ao periodo, adiciona a lista
    periodos(Periodo,Semestre),
    (horario(Id,_,_,_,_,Periodo);horario(Id,_,_,_,_,Semestre)),
    organizaEventos2(RListaIds,Periodo,EventosPeriodo).

organizaEventos2([Id|RListaIds],Periodo,EventosPeriodo):-
    %caso nao pertenca ao periodo, nao adiciona
    horario(Id,_,_,_,_,Pe),Pe\==Periodo,
    organizaEventos2(RListaIds,Periodo,EventosPeriodo).

/*
organizaEventos/3
Unifica a variavel EventosNoPeriodo com a lista ordenada e sem repeticoes, 
dos IDs dos eventos do argumento ListaEventos que ocorrem no argumento Periodo.
*/

%eventosMenoresQue

eventosMenoresQue(Duracao,ListaEventosMenoresQue):-
    findall(Id,(horario(Id,_,_,_,D,_),D=<Duracao),ListaEventosMenoresQue).
    %compara a duracao do evento com o argumento Duracao

/*
eventosMenoresQue/2
Unifica a variavel ListaEventosMenoresQue com uma lista ordenada e sem repeticoes
dos IDs dos eventos com duracao menor ou igual ao argumento Duracao.
*/

%eventosMenoresQueBool

eventosMenoresQueBool(Id,Duracao):-
    horario(Id,_,_,_,Tempo,_),Tempo=<Duracao.
    %compara a duracao do evento com o argumento Duracao

/*
eventosMenoresQueBool/2
Devolve true se o evento correspondente ao ID tiver duracao igual ou menor a Duracao,
caso contrario devolve false.
*/

%procuraDisciplinas

procuraDisciplinas(Curso,ListaDisciplinas):-
    findall(Disciplina,(turno(Id,Curso,_,_),evento(Id,Disciplina,_,_,_)),ListaD),
    %cria lista com as disciplinas do argumento Curso
    sort(ListaD,ListaDisciplinas). %ordena alfabeticamente

/*
procuraDisciplinas/2
Unifica a variavel ListaDisciplinas com uma a lista ordenada das disciplinas 
do argumento Curso.
*/

%organizaDisciplinas

verificaDisciplinas([],_):-!.

verificaDisciplinas([Disciplina|RListaDisciplinas],Curso):-
    procuraDisciplinas(Curso,ListaProcuraDisciplinas),
    %gera a lista das disciplinas do Curso
    member(Disciplina,ListaProcuraDisciplinas),
    %verifica se a Disciplina pertence ao Curso
    verificaDisciplinas(RListaDisciplinas,Curso).

organizaDisciplinas_aux([],[],[]):-!.

organizaDisciplinas_aux([Disciplina|RListaDisciplinas],[Disciplina|ListaSemestre1],ListaSemestre2):-
    evento(Id,Disciplina,_,_,_),horario(Id,_,_,_,_,P),member(P,[p1_2,p1,p2]),!,
    %caso a disciplina seja do semestre 1
    organizaDisciplinas_aux(RListaDisciplinas,ListaSemestre1,ListaSemestre2).

organizaDisciplinas_aux([Disciplina|RListaDisciplinas],ListaSemestre1,[Disciplina|ListaSemestre2]):-
    %caso a disciplina seja do semestre 2 (e nao do semestre 1)
    organizaDisciplinas_aux(RListaDisciplinas,ListaSemestre1,ListaSemestre2).

organizaDisciplinas(ListaDisciplinas,Curso,Semestres):-
    verificaDisciplinas(ListaDisciplinas,Curso),
    %verifica se as disciplinas da ListaDisciplinas sao do Curso, devolve false caso nao sejam
    organizaDisciplinas_aux(ListaDisciplinas,ListaSemestre1,ListaSemestre2),
    %separa as disciplinas pelos 2 semestres
    append([ListaSemestre1],[ListaSemestre2],Semestres).

/*
organizaDisciplinas/3
Unifica a variavel Semestres com uma lista de duas listas ordenadas e sem repeticoes;
cada uma com as disciplinas do primeiro e segundo semestres (respetivamente) presentes na
ListaDisciplinas; O predicado verifica se as disciplinas do argumento ListaDisciplinas
pertencem ao Curso. 
*/

%horasCurso

horasCurso(Periodo,Curso,Ano,TotalHoras):-
    periodos(Periodo,Semestre),
    findall(Id,(turno(Id,Curso,Ano,_),(horario(Id,_,_,_,_,Periodo);
        horario(Id,_,_,_,_,Semestre))),ListaId),
    %cria uma lista com IDs dos eventos do Curso, no Ano e Periodo
    sort(ListaId,ListaIdsort), %retira IDs repetidos
    findall(Horas,(member(Id,ListaIdsort),horario(Id,_,_,_,Horas,_)),ListaHoras),
    %atribui a cada ID a duracao desse evento
    sumlist(ListaHoras,TotalHoras).
    %soma o numero de horas

/*
horasCurso/4
Unifica a variavel TotalHoras com o numero de horas dos eventos 
do Curso, no Ano e Periodo passados como argumentos.
*/

%evolucaoHorasCurso

evolucaoHorasCurso_aux(Curso,Ano,ListaAno):-
    horasCurso('p1',Curso,Ano,TotalHoras1),horasCurso('p2',Curso,Ano,TotalHoras2),
    horasCurso('p3',Curso,Ano,TotalHoras3),horasCurso('p4',Curso,Ano,TotalHoras4),
    %calcula as horas de cada periodo
    append([(Ano,'p1',TotalHoras1)],[(Ano,'p2',TotalHoras2)],TotalHoras1_2),
    append([(Ano,'p3',TotalHoras3)],[(Ano,'p4',TotalHoras4)],TotalHoras3_4),
    append(TotalHoras1_2,TotalHoras3_4,ListaAno).
    %junta os resultados numa lista de 4 tuplos (1 por periodo)

evolucaoHorasCurso(Curso,Evolucao):-
    evolucaoHorasCurso_aux(Curso,1,ListaAno1),
    evolucaoHorasCurso_aux(Curso,2,ListaAno2),
    evolucaoHorasCurso_aux(Curso,3,ListaAno3),
    %faz uma lista para cada ano com os 4 periodos e as horas dos mesmos 
    append(ListaAno1,ListaAno2,ListaAno1_2),
    append(ListaAno1_2,ListaAno3,Evolucao).
    %junta as 3 listas numa nova lista Evolucao

/*
evolucaoHorasCurso/3
Unifica a variavel Evolucao com uma lista ordenada de tuplos ((Ano, Periodo, NumHoras)),
nos quais NumHoras e o total de horas associadas ao Curso, no Ano e Periodo respetivos.
*/

%Ocupacoes Criticas das Salas

%ocupaSlot

ocupaSlot(HID,HFD,HIE,HFE,Horas):-
    HID=<HIE,HFD>=HFE,HFE-HIE>0,!, Horas is HFE-HIE.

ocupaSlot(HID,HFD,HIE,HFE,Horas):-
    HIE=<HID,HFE>=HFD,HFD-HID>0,!, Horas is HFD-HID.

ocupaSlot(HID,HFD,HIE,HFE,Horas):-
    HID=<HIE,HFD=<HFE,HFD-HIE>0,!, Horas is HFD-HIE.

ocupaSlot(HID,HFD,HIE,HFE,Horas):-
    HID>=HIE,HFD>=HFE,HFE-HID>0, Horas is HFE-HID.
%compara HID com HIE e HFD com HFE e verifica se o calculo Horas e maior que 0

/*
ocupaSlot/5
Unifica a variavel Horas com o numero de horas sobrepostas entre o evento e o slot;
caso nao haja sobreposicao, devolve false.
*/

%numHorasOcupadas

ocupaSlot2(HID,HFD,HIE,HFE,Horas):-
    ocupaSlot(HID,HFD,HIE,HFE,Horas),!;
    %caso o evento e o slot se sobreponham, calcula a sobreposicao
    Horas is 0.
    %caso contrario, devolve 0

numHorasOcupadas(Periodo,TipoSala,DiaSemana,HoraInicio,HoraFim,SomaHoras):-
    periodos(Periodo,Semestre),salas(TipoSala,ListaSalas),
    findall(Id,((horario(Id,DiaSemana,_,_,_,Periodo);horario(Id,DiaSemana,_,_,_,Semestre)),
        member(Sala,ListaSalas),evento(Id,_,_,_,Sala)),ListaId),
    %cria uma lista com IDs de eventos do DiaSemana, Periodo e TipoSala passados como argumentos
    findall(HoraInicioEvento,(member(Id,ListaId),horario(Id,_,HoraInicioEvento,_,_,_)),ListaHIE),
    findall(HoraFimEvento,(member(Id,ListaId),horario(Id,_,_,HoraFimEvento,_,_)),ListaHFE),
    maplist(ocupaSlot2(HoraInicio,HoraFim),ListaHIE,ListaHFE,ListaHoras),
    %o maplist associa os argumentos HoraInicio e Hora Fim, a pares de HIE e HFE
    %se houver sobreposicao entre o evento e o slot, adiciona a duracao da sobreposicao a ListaHoras
    %caso contrario, adiciona 0 a ListaHoras
    sumlist(ListaHoras,SomaHoras).

/*
numHorasOcupadas/6
Unifica a variavel SomaHoras com o numero de horas ocupadas nas salas do TipoSala,
entre HoraInicio e HoraFim, no DiaSemana, e no Periodo passados como argumentos.
*/

%ocupacaoMax

ocupacaoMax(TipoSala,HoraInicio,HoraFim,Max):-
    salas(TipoSala,ListaSalas),
    length(ListaSalas,NSalas), %calcula o numero de salas do tipo
    Max is NSalas*(HoraFim-HoraInicio).
    %calcula o numeros de horas que as salas do TipoSala podem estar ocupadas
    %entre HoraInicio e HoraFim

/*
ocupacaoMax/4
Unifica a variavel Max com o numero maximo de horas ocupadas em salas do TipoSala,
entre HoraInicio e HoraFim.
*/

%percentagem

percentagem(SomaHoras,Max,Percentagem):-
    Percentagem is SomaHoras/Max*100.
    %calcula o quociente entre SomaHoras e Max multiplicado por 100

/*
percentagem/3
Unifica a variavel Percentagem com o quociente entre SomaHoras e Max, 
multiplicado por 100.
*/

%ocupacaoCritica

ocupacaoCritica(HoraInicio,HoraFim,Threshold,Resultados):-
    findall(TipoSala,salas(TipoSala,_),ListaTipoSalas),
    %cria uma lista com todos os tipos de salas
    findall(DiaSemana,horario(_,DiaSemana,_,_,_,_),ListaDiasSemana),
    %cria uma lista com os dias da semana
    findall(casosCriticos(DiaSemana,TipoSala,P),(member(TipoSala,ListaTipoSalas),
        member(Periodo,['p1','p2','p3','p4']),member(DiaSemana,ListaDiasSemana),
        numHorasOcupadas(Periodo,TipoSala,DiaSemana,HoraInicio,HoraFim,SomaHoras),
        ocupacaoMax(TipoSala,HoraInicio,HoraFim,Max),percentagem(SomaHoras,Max,Percentagem),
        Percentagem>Threshold,P is ceiling(Percentagem)),Result),
    %calcula a percentagem referente a DiaSemana e TipoSala e Periodo e compara com Threshold
    %adiciona a lista Resultados casosCriticos (Percentagem superior a Threshold)
    sort(Result,Resultados). %ordena a lista Resultados

/*
ocupacaoCritica/4
Unifica a variavel Resultados com uma lista ordenada de tuplos (casosCriticos(DiaSemana, 
TipoSala,Percentagem)) em que Percentagem e a percentagem de ocupacao, entre HoraInicio 
e HoraFim, e esta acima do Threshold passado como argumento.
*/

%And now for something completely different...

%assegura que a pessoa N tem um lugar na mesa
lugar(N,[[N,_,_],[_,_],[_,_,_]]).
lugar(N,[[_,N,_],[_,_],[_,_,_]]).
lugar(N,[[_,_,N],[_,_],[_,_,_]]).
lugar(N,[[_,_,_],[N,_],[_,_,_]]).
lugar(N,[[_,_,_],[_,N],[_,_,_]]).
lugar(N,[[_,_,_],[_,_],[N,_,_]]).
lugar(N,[[_,_,_],[_,_],[_,N,_]]).
lugar(N,[[_,_,_],[_,_],[_,_,N]]).

%assegura que a pessoa N esta na cabeceira
cab1(N,[[_,_,_],[N,_],[_,_,_]]).
cab2(N,[[_,_,_],[_,N],[_,_,_]]).

%assegura que a pessoa M esta num lugar de honra
%em relacao a pessoa N 
honra(N,M,[[_,_,_],[N,_],[M,_,_]]).
honra(N,M,[[_,_,M],[_,N],[_,_,_]]).

%assegura que as pessoas N e M estao ao lado na mesa
lado(N,M,[[N,M,_],[_,_],[_,_,_]]).
lado(N,M,[[_,N,M],[_,_],[_,_,_]]).
lado(N,M,[[_,_,_],[_,_],[N,M,_]]).
lado(N,M,[[_,_,_],[_,_],[_,N,M]]).
lado(N,M,[[M,N,_],[_,_],[_,_,_]]).
lado(N,M,[[_,M,N],[_,_],[_,_,_]]).
lado(N,M,[[_,_,_],[_,_],[M,N,_]]).
lado(N,M,[[_,_,_],[_,_],[_,M,N]]).

%assegura que as pessoas N e M nao estao ao lado na mesa
naoLado(N,M,OcupacaoMesa):-
    \+lado(N,M,OcupacaoMesa).

%assegura que as pessoas N e M estao a frente na mesa
frente(N,M,[[N,_,_],[_,_],[M,_,_]]).
frente(N,M,[[_,N,_],[_,_],[_,M,_]]).
frente(N,M,[[_,_,N],[_,_],[_,_,M]]).
frente(N,M,[[M,_,_],[_,_],[N,_,_]]).
frente(N,M,[[_,M,_],[_,_],[_,N,_]]).
frente(N,M,[[_,_,M],[_,_],[_,_,N]]).

%assegura que as pessoas N e M nao estao a frente na mesa
naoFrente(N,M,OcupacaoMesa):-
    \+frente(N,M,OcupacaoMesa),
    N\==M. %N e M sao pessoas diferentes

aplicaLugar(Pessoa,lugar(Pessoa)).

ocupacaoMesa_aux([],[[_,_,_],[_,_],[_,_,_]]):-!.

ocupacaoMesa_aux([Condicao|RListaCondicoes],OcupacaoMesa):-
    call(Condicao,OcupacaoMesa), 
    %chama as condicoes recursivamente para sentar as pessoas de acordo com as mesmas
    ocupacaoMesa_aux(RListaCondicoes,OcupacaoMesa).

ocupacaoMesa(ListaPessoas,ListaRestricoes,OcupacaoMesa):-
    maplist(aplicaLugar,ListaPessoas,ListaPessoas2),
    %asegura que todas as pessoas da ListaPessoas vao ser sentadas
    append(ListaPessoas2,ListaRestricoes,ListaCondicoes),
    %junta as condicoes lugar(Pessoa) com as restricoes passadas como argumento
    ocupacaoMesa_aux(ListaCondicoes,OcupacaoMesa).

/*
ocupacaoMesa/3
Unifica a variavel OcupacaoMesa com uma lista com 3 listas, de modo a que as pessoas 
de ListaPessoas estejam posicionadas de acordo com as restricoes de ListaRestricoes.
*/
