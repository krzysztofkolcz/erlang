{application, mysockserv,
 [{description, "Socket server to communicate via tcp"},
  {vsn, "1.0.0"},
  {mod, {mysockserv, []}},
  {registered, [mysockserv_sup]},
  {modules, [mysockserv, mysockserv_sup, mysockserv_serv]},
  {applications, [stdlib, kernel]},
  {env,
    [{port, 8082}]}
 ]}.
