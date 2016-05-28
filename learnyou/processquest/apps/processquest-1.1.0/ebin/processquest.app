{application, processquest,
 [{description, "Game inspired by the Progress Quest game (http://progressquest.com)"},
  {vsn, "1.1.0"},
  {mod, {processquest, []}},
  {registered, [pq_supersup]},
  {modules, [processquest, pq_stats, pq_enemy, pq_events, pq_player, pq_quest]},
  {applications, [stdlib, kernel, regis, crypto]}]}.
