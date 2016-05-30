dodane pliki:
  ▾ mytcp/
    ▾ apps/
      ▾ mysockserv-1.0.0/
        ▾ ebin/
            mysockserv.app
        ▾ src/
            mysockserv.erl
            mysockserv_serv.erl
            mysockserv_sup.erl
          Emakefile
    ▾ rel/
      mytcp-1.0.0.config

korzystam z reltool

erl
{ok, Conf} = file:consult("mytcp-1.0.0.config"). 
{ok, Spec} = reltool:get_target_spec(Conf). 
reltool:eval_target_spec(Spec, code:root_dir(), "rel").

{ok, Conf} = file:consult("mytcp-1.0.0.config"), {ok, Spec} = reltool:get_target_spec(Conf), reltool:eval_target_spec(Spec, code:root_dir(), "rel").

w drugiej konsolce:
./rel/bin/erl -mysockserv 
mysockserv_serv:ping().


Problem - nie startowały wątki nasłuchujące
Rozwiązanie - wszedłem do katalogu src, odpaliłem konsolkę erl, zacząłem kompilować każdy skrypt osobno:
c(mysockserv_sup).
c(mysockserv_serv).
problem był w mysockserv_serv. Pytanie, czemu erl -make tego nie wykrył???
