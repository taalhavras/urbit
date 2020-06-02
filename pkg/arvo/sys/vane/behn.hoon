::  %behn, just a timer
!:
!?  164
::
=,  behn
|=  pit=vase
=>  |%
    +$  move  [p=duct q=(wite note gift:able)]
    +$  note                                            ::  out request $->
      $~  [%b %wait *@da]                               ::
      $%  $:  %b                                        ::   to self
              $>(%wait task:able)                       ::  set timer
          ==                                            ::
          $:  %d                                        ::    to %dill
              $>(%flog task:able:dill)                  ::  log output
      ==  ==                                            ::
    +$  sign
      $~  [%b %wake ~]
      $%  [%b $>(%wake gift:able)]
      ==
    ::
    +$  behn-state
      $:  %2
          timers=(tree [key=@da val=(qeu duct)])
          unix-duct=duct
          next-wake=(unit @da)
          drips=drip-manager
      ==
    ::
    ++  timer-map  ((ordered-map ,@da ,(qeu duct)) lte)
    ::
    +$  drip-manager
      $:  count=@ud
          movs=(map @ud vase)
      ==
    ::
    +$  timer  [date=@da =duct]
    --
::
=>
~%  %behn  ..is  ~
|%
++  per-event
  =|  moves=(list move)
  |=  [[our=ship now=@da =duct] state=behn-state]
  ::
  |%
  ::  %entry-points
  ::
  ::  +born: urbit restarted; refresh :next-wake and store wakeup timer duct
  ::
  ++  born  set-unix-wake(next-wake.state ~, unix-duct.state duct)
  ::  +crud: handle failure of previous arvo event
  ::
  ++  crud
    |=  [tag=@tas error=tang]
    ^+  [moves state]
    ::  behn must get activated before other vanes in a %wake
    ::
    ?.  =(%wake tag)
      ~&  %behn-crud-not-wake^tag
      [[duct %slip %d %flog %crud tag error]~ state]
    ::
    ?:  =(~ timers.state)
      ~|(%behn-crud-no-timer^tag^error !!)
    ::
    (wake `error)
  ::  +rest: cancel the timer at :date, then adjust unix wakeup
  ::  +wait: set a new timer at :date, then adjust unix wakeup
  ::
  ++  rest  |=(date=@da set-unix-wake(timers.state (unset-timer [date duct])))
  ++  wait  |=(date=@da set-unix-wake(timers.state (set-timer [date duct])))
  ::  +huck: give back immediately
  ::
  ::    Useful if you want to continue working after other moves finish.
  ::
  ++  huck
    |=  mov=vase
    =<  [moves state]
    event-core(moves [duct %give %meta mov]~)
  ::  +drip:  XX
  ::
  ++  drip
    |=  mov=vase
    =<  [moves state]
    ^+  event-core
    =.  moves
      [duct %pass /drip/(scot %ud count.drips.state) %b %wait +(now)]~
    =.  movs.drips.state
      (~(put by movs.drips.state) count.drips.state mov)
    =.  count.drips.state  +(count.drips.state)
    event-core
  ::  +take-drip:  XX
  ::
  ++  take-drip
    |=  [num=@ud error=(unit tang)]
    =<  [moves state]
    ^+  event-core
    =/  drip  (~(got by movs.drips.state) num)
    =.  movs.drips.state  (~(del by movs.drips.state) num)
    =/  =move
      =/  card  [%give %meta drip]
      ?~  error
        [duct card]
      =/  =tang
        (weld u.error `tang`[leaf/"drip failed" ~])
      ::  XX should be
      ::  [duct %hurl fail/tang card]
      ::
      [duct %pass /drip-slog %d %flog %crud %drip-fail tang]
    event-core(moves [move moves])
  ::  +trim: in response to memory pressue
  ::
  ++  trim  [moves state]
  ::  +vega: learn of a kernel upgrade
  ::
  ++  vega  [moves state]
  ::  +wake: unix says wake up; process the elapsed timer and set :next-wake
  ::
  ++  wake
    |=  error=(unit tang)
    ^+  [moves state]
    ::  no-op on spurious but innocuous unix wakeups
    ::
    ?:  =(~ timers.state)
      ~?  ?=(^ error)  %behn-wake-no-timer^u.error
      [moves state]
    ::  if we errored, pop the timer and notify the client vane of the error
    ::
    ?^  error
      =<  set-unix-wake
      =^  =timer  timers.state  pop-timer
      (emit-vane-wake duct.timer error)
    ::  if unix woke us too early, retry by resetting the unix wakeup timer
    ::
    =/  [=timer later-timers=_timers.state]  pop-timer
    ?:  (gth date.timer now)
      set-unix-wake(next-wake.state ~)
    ::  pop first timer, tell vane it has elapsed, and adjust next unix wakeup
    ::
    =<  set-unix-wake
    (emit-vane-wake(timers.state later-timers) duct.timer ~)
  ::  +wegh: produce memory usage report for |mass
  ::
  ++  wegh
    ^+  [moves state]
    :_  state  :_  ~
    :^  duct  %give  %mass
    :+  %behn  %|
    :~  timers+&+timers.state
        dot+&+state
    ==
  ::  %utilities
  ::
  ::+|
  ::
  ++  event-core  .
  ::  +emit-vane-wake: produce a move to wake a vane; assumes no prior moves
  ::
  ++  emit-vane-wake
    |=  [=^duct error=(unit tang)]
    event-core(moves [duct %give %wake error]~)
  ::  +emit-doze: set new unix wakeup timer in state and emit move to unix
  ::
  ::    We prepend the unix %doze event so that it is handled first. Arvo must
  ::    handle this first because the moves %behn emits will get handled in
  ::    depth-first order. If we're handling a %wake which causes a move to a
  ::    different vane and a %doze event to send to unix, Arvo needs to process
  ::    the %doze first because otherwise if the move to the other vane calls
  ::    back into %behn and emits a second %doze, the second %doze would be
  ::    handled by unix first which is incorrect.
  ::
  ++  emit-doze
    |=  =date=(unit @da)
    ^+  event-core
    ::  no-op if .unix-duct has not yet been set
    ::
    ?~  unix-duct.state
      event-core
    ::  make sure we don't try to wake up in the past
    ::
    =?  date-unit  ?=(^ date-unit)  `(max now u.date-unit)
    ::
    %_  event-core
      next-wake.state  date-unit
      moves            [[unix-duct.state %give %doze date-unit] moves]
    ==
  ::  +set-unix-wake: set or unset next unix wakeup timer based on :i.timers
  ::
  ++  set-unix-wake
    =<  [moves state]
    ~%  %set-unix-wake  ..is  ~  |-
    ^+  event-core
    ::
    =*  next-wake  next-wake.state
    =*  timers     timers.state
    ::  if no timers, cancel existing wakeup timer or no-op
    ::
    =/  first=(unit [date=@da *])  (peek:timer-map timers.state)
    ?~  first
      ?~  next-wake
        event-core
      (emit-doze ~)
    ::  if :next-wake is in the past or not soon enough, reset it
    ::
    ?^  next-wake
      ?:  &((gte date.u.first u.next-wake) (lte now u.next-wake))
        event-core
      (emit-doze `date.u.first)
    ::  there was no unix wakeup timer; set one
    ::
    (emit-doze `date.u.first)
  ::  +pop-timer: dequeue and produce earliest timer
  ::
  ++  pop-timer
    ^+  [*timer timers.state]
    =^  [date=@da dux=(qeu ^duct)]  timers.state  (pop:timer-map timers.state)
    =^  dut  dux  ~(get to dux)
    :-  [date dut]
    ?:  =(~ dux)
      timers.state
    (put:timer-map timers.state date dux)
  ::  +set-timer: set a timer, maintaining order
  ::
  ++  set-timer
    ~%  %set-timer  ..is  ~
    |=  t=timer
    ^+  timers.state
    =/  found  (find-ducts date.t)
    (put:timer-map timers.state date.t (~(put to found) duct.t))
  ::  +find-ducts: get timers at date
  ::
  ::    TODO: move to +ordered-map
  ::
  ++  find-ducts
    |=  date=@da
    ^-  (qeu ^duct)
    ?~  timers.state  ~
    ?:  =(date key.n.timers.state)
      val.n.timers.state
    ?:  (lte date key.n.timers.state)
      $(timers.state l.timers.state)
    $(timers.state r.timers.state)
  ::  +unset-timer: cancel a timer; if it already expired, no-op
  ::
  ++  unset-timer
    |=  t=timer
    ^+  timers.state
    =/  [found=? dux=(qeu ^duct)]
      =/  dux  (find-ducts date.t)
      |-  ^-  [found=? dux=(qeu ^duct)]
      ?~  dux  |+~
      ?:  =(duct.t n.dux)  &+~(nip to `(qeu ^duct)`dux)
      =^  found-left=?  l.dux  $(dux l.dux)
      ?:  found-left  &+dux
      =^  found-rite=?  r.dux  $(dux r.dux)
      [found-rite dux]
    ?.  found  timers.state
    ?:  =(~ dux)
      +:(del:timer-map timers.state date.t)
    (put:timer-map timers.state date.t dux)
  --
--
::
=|  behn-state
=*  state  -
|=  [our=ship now=@da eny=@uvJ ski=sley]
=*  behn-gate  .
^?
|%
::  +call: handle a +task:able:behn request
::
++  call
  ~%  %behn-call  ..is  ~
  |=  $:  hen=duct
          dud=(unit goof)
          type=*
          wrapped-task=(hobo task:able)
      ==
  ^-  [(list move) _behn-gate]
  ::
  =/  =task:able  ((harden task:able) wrapped-task)
  ::
  ::  error notifications "downcast" to %crud
  ::
  =?  task  ?=(^ dud)
    ~|  %crud-in-crud
    ?<  ?=(%crud -.task)
    [%crud -.task tang.u.dud]
  ::
  =/  event-core  (per-event [our now hen] state)
  ::
  =^  moves  state
    ?-  -.task
      %born  born:event-core
      %crud  (crud:event-core [p q]:task)
      %rest  (rest:event-core date=p.task)
      %drip  (drip:event-core move=p.task)
      %huck  (huck:event-core move=p.task)
      %trim  trim:event-core
      %vega  vega:event-core
      %wait  (wait:event-core date=p.task)
      %wake  (wake:event-core error=~)
      %wegh  wegh:event-core
    ==
  [moves behn-gate]
::  +load: migrate an old state to a new behn version
::
++  load
  |^
  |=  old=state
  ^+  behn-gate
  =?  old  ?=(^ -.old)
    (ket-to-1 old)
  =?  old  ?=(~ -.old)
    (load-0-to-1 old)
  =?  old  ?=(%1 -.old)
    (load-1-to-2 old)
  ?>  ?=(%2 -.old)
  behn-gate(state old)
  ::
  ++  state
    $^  behn-state-ket
    $%  behn-state-0
        behn-state-1
        behn-state
    ==
  ::
  ++  load-1-to-2
    |=  old=behn-state-1
    ^-  behn-state
    =;  new-timers  old(- %2, timers new-timers)
    =/  timers=(list timer)  ~(tap in ~(key by timers.old))
    %+  roll  timers
    |=  [t=timer acc=(tree [@da (qeu duct)])]
    ^+  acc
    =|  mock=behn-state
    =.  timers.mock  acc
    =/  event-core  (per-event *[@p @da duct] mock)
    (set-timer:event-core t)
  ::
  ++  timer-map-1
    %-  (ordered-map ,timer ,~)
    |=  [a=timer b=timer]
    (lth date.a date.b)
  ::
  +$  behn-state-1
    $:  %1
        timers=(tree [timer ~])
        unix-duct=duct
        next-wake=(unit @da)
        drips=drip-manager
    ==
  ::
  +$  behn-state-0
    $:  ~
        unix-duct=duct
        next-wake=(unit @da)
        drips=drip-manager
    ==
  ::
  +$  behn-state-ket
    $:  timers=(list timer)
        unix-duct=duct
        next-wake=(unit @da)
        drips=drip-manager
    ==
  ::
  ++  ket-to-1
    |=  old=behn-state-ket
    ^-  behn-state-1
    :-  %1
    %=    old
        timers
      %+  gas:timer-map-1  *(tree [timer ~])
      (turn timers.old |=(=timer [timer ~]))
    ==
  ::
  ++  load-0-to-1
    |=  old=behn-state-0
    ^-  behn-state-1
    [%1 old]
  --
::  +scry: view timer state
::
::    TODO: not referentially transparent w.r.t. elapsed timers,
::    which might or might not show up in the product
::
++  scry
  |=  [fur=(unit (set monk)) ren=@tas why=shop syd=desk lot=coin tyl=path]
  ^-  (unit (unit cage))
  ::
  ?.  ?=(%& -.why)
    ~
  ?.  ?=(%timers syd)
    [~ ~]
  =/  tiz=(list [@da duct])
    %-  zing
    %+  turn  (tap:timer-map timers)
    |=  [date=@da q=(qeu duct)]
    %+  turn  ~(tap to q)
    |=(d=duct [date d])
  [~ ~ %noun !>(tiz)]
::
++  stay  state
++  take
  |=  [tea=wire hen=duct dud=(unit goof) hin=(hypo sign)]
  ^-  [(list move) _behn-gate]
  ?^  dud
    ~|(%behn-take-dud (mean tang.u.dud))
  ::
  ?>  ?=([%drip @ ~] tea)
  =/  event-core  (per-event [our now hen] state)
  =^  moves  state
    (take-drip:event-core (slav %ud i.t.tea) error.q.hin)
  [moves behn-gate]
--
